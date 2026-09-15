"""Evaluation layer.

Run directly:  venv\\Scripts\\python.exe scripts\\checks\\check_evaluation.py
"""
import _bootstrap  # noqa: F401  puts the API on the import path, must be first
from _bootstrap import DEV_DSN

import asyncio
import sys

import asyncpg
from httpx import ASGITransport, AsyncClient

import main
from helpers import assist

OK, FAIL = [], []


def check(label, cond, detail=""):
    (OK if cond else FAIL).append(label)
    print(("  PASS  " if cond else "  FAIL  ") + label
          + (f"   <- {detail}" if detail and not cond else ""))


async def go():
    con = await asyncpg.connect(DEV_DSN)

    print("Arithmetic")
    # every z-score must equal (reported - assigned) / robust_sd
    bad = await con.fetch("""
        select id, z_score, reported_numeric, assigned_numeric, robust_sd
        from pt_result_evaluations
        where evaluated and z_score is not null and robust_sd > 0
          and abs(z_score - ((reported_numeric - assigned_numeric) / robust_sd)) > 0.001""")
    check("z-scores match their inputs", not bad, [dict(r) for r in bad[:3]])

    # the grade must follow the band the form specifies
    bad = await con.fetch("""
        select id, z_score, grade from pt_result_evaluations
        where evaluated and z_score is not null and (
            (abs(z_score) <= 2.0 and grade <> 'Acceptable') or
            (abs(z_score) > 2.0 and abs(z_score) < 3.0 and grade <> 'Warning') or
            (abs(z_score) >= 3.0 and grade <> 'Unacceptable'))""")
    check("grades follow the TF-007 z-score bands", not bad, [dict(r) for r in bad[:3]])

    # a categorical grade must follow concordance
    bad = await con.fetch("""
        select id from pt_result_evaluations
        where evaluated and assigned_text is not null and (
            (upper(reported_text) = upper(assigned_text) and grade <> 'Acceptable') or
            (upper(reported_text) <> upper(assigned_text) and grade <> 'Unacceptable'))""")
    check("categorical grades follow concordance", not bad, [r["id"] for r in bad[:5]])

    # each scheme has its own marks, so check against the form's own policy
    bad = await con.fetch("""
        select id, score, grade, result_form, max_score
        from pt_result_evaluations
        where (result_form = 'hiv_eid' and (
                 (grade = 'Acceptable' and score <> 20) or
                 (grade <> 'Acceptable' and score <> 0)))
           or (result_form <> 'hiv_eid' and (
                 (grade = 'Acceptable'   and score <> 2) or
                 (grade = 'Warning'      and score <> 1) or
                 (grade = 'Unacceptable' and score <> 0)))""")
    check("score matches grade under each scheme's policy", not bad,
          [dict(r) for r in bad[:3]])

    check("EID scores 20 marks a sample",
          (await con.fetchval("""select count(*) from pt_result_evaluations
                                 where result_form='hiv_eid' and max_score=20""")) > 0)

    print("\nFailure to participate")
    # TF-006: a sample the lab did not report still counts against it
    bad = await con.fetch("""
        select e.id from pt_result_evaluations e
        join pt_sample_statistics st
          on st.pt_cycle_id = e.pt_cycle_id and st.attribute = e.attribute
        join method_samples ms on ms.id = e.method_sample_id
        where st.sample_group = ms.name
          and st.evaluated and not e.evaluated and e.max_score = 0""")
    check("an unreported gradable sample still carries marks", not bad,
          [r["id"] for r in bad[:5]])

    bad = await con.fetch("""
        select id from pt_result_evaluations
        where not evaluated and score <> 0""")
    check("an unreported sample scores zero", not bad, [r["id"] for r in bad[:5]])

    # a sample the provider could not grade must not count against anyone
    bad = await con.fetch("""
        select e.id from pt_result_evaluations e
        join pt_sample_statistics st
          on st.pt_cycle_id = e.pt_cycle_id and st.attribute = e.attribute
        join method_samples ms on ms.id = e.method_sample_id
        where st.sample_group = ms.name
          and not st.evaluated and e.max_score > 0""")
    check("an ungradable sample counts against nobody", not bad,
          [r["id"] for r in bad[:5]])

    print("\nControls")
    bad = await con.fetch("""
        select e.id from pt_result_evaluations e
        join method_samples ms on ms.id = e.method_sample_id
        where ms.is_control""")
    check("kit controls are recorded but never scored", not bad,
          [r["id"] for r in bad[:5]])

    n = await con.fetchval("""select count(*) from hiv_eid_results r
                              join method_samples ms on ms.id = r.method_sample_id
                              where ms.is_control""")
    check("kit controls still get a result sheet", n > 0, n)

    print("\nRoll-up")
    bad = await con.fetch("""
        select pf.id, pf.total_score, sum(e.score) actual
        from pt_enrollment_performance pf
        join pt_result_evaluations e on e.enrollment_id = pf.enrollment_id
        where e.evaluated
        group by pf.id, pf.total_score
        having pf.total_score <> sum(e.score)""")
    check("enrolment totals match their results", not bad, [dict(r) for r in bad[:3]])

    bad = await con.fetch("""
        select id, percent_score, overall_performance, result_form
        from pt_enrollment_performance
        where max_score > 0 and (
            (result_form = 'hiv_eid' and (
                (percent_score >= 1.0 and overall_performance <> 'Satisfactory') or
                (percent_score <  1.0 and overall_performance <> 'Unsatisfactory')))
         or (result_form <> 'hiv_eid' and (
                (percent_score >= 0.80 and overall_performance <> 'Satisfactory') or
                (percent_score <  0.80 and overall_performance <> 'Unsatisfactory'))))""")
    check("performance follows each scheme's own threshold", not bad,
          [dict(r) for r in bad[:3]])

    # TF-006 worked example: only a full 100 is satisfactory
    bad = await con.fetch("""
        select id, total_score, max_score from pt_enrollment_performance
        where result_form = 'hiv_eid' and overall_performance = 'Satisfactory'
          and total_score <> max_score""")
    check("an EID participant is satisfactory only at full marks", not bad,
          [dict(r) for r in bad[:3]])

    bad = await con.fetch("""
        select id from pt_enrollment_performance
        where max_score = 0 and overall_performance <> 'Not Evaluated'""")
    check("an ungradable enrolment is Not Evaluated", not bad, [r["id"] for r in bad[:3]])

    print("\nConsensus pooling")
    rows = await con.fetch("""
        select sample_group, max(participant_count) n
        from pt_sample_statistics
        where evaluation_kind = 'quantitative' and sample_group like 'VL%'
        group by 1 order by 1""")
    check("viral load pools across platforms",
          bool(rows) and all(r["n"] >= 3 for r in rows if r["n"] > 0),
          [dict(r) for r in rows])

    bad = await con.fetch("""
        select id from pt_sample_statistics
        where evaluated and assigned_value_source is null""")
    check("every graded sample says where its value came from", not bad,
          [r["id"] for r in bad[:3]])

    print("\nFreeze")
    bad = await con.fetch("""
        select id from pt_result_evaluations where frozen_at is null""")
    check("every evaluation is stamped frozen", not bad, [r["id"] for r in bad[:3]])

    # only a closed or reporting round should carry an evaluation
    bad = await con.fetch("""
        select distinct c.code from pt_result_evaluations e
        join pt_cycles c on c.id = e.pt_cycle_id
        where c.pt_cyle_status_id < 4""")
    check("only rounds at Report Available or later are scored", not bad,
          [r["code"] for r in bad])

    print("\nReporting views")
    for view in ("vw_pt_result_evaluation", "vw_pt_enrollment_performance",
                 "vw_pt_sample_summary"):
        n = await con.fetchval(f"select count(*) from {view}")
        check(f"{view} returns rows", n > 0, n)

    # the types XtraReports will bind to
    rows = await con.fetch("""
        select column_name, data_type from information_schema.columns
        where table_name = 'vw_pt_result_evaluation'
          and column_name in ('z_score','group_mean','score','participant_count',
                              'shipment_date','grade')""")
    types = {r["column_name"]: r["data_type"] for r in rows}
    check("numeric columns are numeric, not text",
          types.get("z_score") == "double precision"
          and types.get("score") == "integer"
          and types.get("participant_count") == "integer",
          types)
    check("date columns are dates", types.get("shipment_date") == "date", types)

    # an aggregate over the view must work without casting - the thing JSONB
    # would have broken
    avg = await con.fetchval("""
        select avg(z_score) from vw_pt_result_evaluation where evaluated""")
    check("aggregates run natively over the view", avg is not None, avg)

    await con.close()

    print("\nReproducibility")
    async with AsyncClient(transport=ASGITransport(app=main.app),
                           base_url="http://t", timeout=60) as c:
        cycle = 1
        r = await c.put(f"/pt-cycles/evaluate/{cycle}",
                        json={"user_id": 1, "recompute": False})
        check("re-scoring a frozen round is refused without recompute",
              r.status_code == 400 and "already been scored" in r.text,
              f"{r.status_code} {r.text[:160]}")

        r = await c.put("/pt-cycles/evaluate/3", json={"user_id": 1})
        check("a round that has not shipped cannot be scored",
              r.status_code == 400, f"{r.status_code} {r.text[:120]}")

        r = await c.get("/evaluations/report/result-evaluation",
                        params={"pt_cycle_id": 5, "limit": 5})
        check("the report view is readable over the API",
              r.status_code == 200 and len(r.json()) > 0,
              f"{r.status_code} {r.text[:120]}")

        r = await c.get("/evaluations/report/nonsense")
        check("an unknown view name is rejected", r.status_code == 404,
              r.status_code)

    print("\n" + "=" * 62)
    print(f"{len(OK)} passed, {len(FAIL)} failed")
    for f in FAIL:
        print("  -", f)
    return 1 if FAIL else 0


sys.exit(asyncio.run(go()))
