"""Integrity audit.

Run directly:  venv\\Scripts\\python.exe scripts\\checks\\check_integrity.py
"""
import _bootstrap  # noqa: F401  puts the API on the import path, must be first
from _bootstrap import DEV_DSN

import asyncio
import asyncpg

CHECKS = []

# the same structural checks, applied to each result form
for table, form in (("tb_xpert_ultra_results", "tb_xpert_ultra"),
                    ("tb_xpert_xdr_results", "tb_xpert_xdr"),
                    ("hiv_vl_results", "hiv_vl"),
                    ("hiv_eid_results", "hiv_eid")):
    CHECKS += [
        (f"{table}: opened on the wrong form",
         f"""select t.id from {table} t join methods m on m.id=t.method_id
             where m.result_form is distinct from '{form}'"""),
        (f"{table}: enrolment belongs to a different lab",
         f"""select t.id from {table} t join enrollments e on e.id=t.enrollment_id
             where e.lab_id <> t.lab_id"""),
        (f"{table}: enrolment is in a different cycle",
         f"""select t.id from {table} t join enrollments e on e.id=t.enrollment_id
             where e.pt_cycle_id <> t.pt_cycle_id"""),
        (f"{table}: method differs from its enrolment",
         f"""select t.id from {table} t join enrollments e on e.id=t.enrollment_id
             where e.method_id <> t.method_id"""),
        (f"{table}: sample belongs to another method",
         f"""select t.id from {table} t join method_samples s on s.id=t.method_sample_id
             where s.method_id <> t.method_id"""),
        (f"{table}: enrolment was never accepted",
         f"select t.id from {table} t join enrollments e on e.id=t.enrollment_id "
         f"where e.status_id <> 4"),
    ]
    if table.startswith("tb_xpert"):
        CHECKS.append(
            (f"{table}: error code on a non-ERROR result",
             f"""select id from {table} where error_code is not null
                 and uninterpretable_result is distinct from 'ERROR'"""))

# form specific rules
CHECKS += [
    ("ultra: both interpretable and uninterpretable",
     """select id from tb_xpert_ultra_results
        where result_interpretable='Yes' and uninterpretable_result is not null"""),
    ("ultra: submitted result missing a required field",
     """select id from tb_xpert_ultra_results where status_id in (2,4) and (
          result_interpretable is null or date_tested is null
          or xpert_module_number is null
          or (result_interpretable='Yes' and (tb_detection_result is null
               or rif_result is null or ultra_spc is null or rpob1 is null))
          or (result_interpretable='No' and uninterpretable_result is null)
          or (uninterpretable_result='ERROR' and error_code is null))"""),
    ("ultra: TB detection value not on form CDL-PT-F-008",
     """select id from tb_xpert_ultra_results where tb_detection_result is not null
        and tb_detection_result not in ('NOT DETECTED','TRACE','VERY LOW','LOW',
                                        'MEDIUM','HIGH')"""),

    ("xdr: both interpretable and uninterpretable",
     """select id from tb_xpert_xdr_results
        where result_interpretable='Yes' and uninterpretable_result is not null"""),
    ("xdr: submitted result missing a required field",
     """select id from tb_xpert_xdr_results where status_id in (2,4) and (
          result_interpretable is null or date_tested is null
          or (result_interpretable='Yes' and (tb_detection_result is null
               or inh_result is null or flq_result is null or amk_result is null
               or eth_result is null or spc_ahpc is null or rrs is null
               or gyra1 is null or katg is null))
          or (result_interpretable='No' and uninterpretable_result is null)
          or (uninterpretable_result='ERROR' and error_code is null))"""),
    ("xdr: TB detection value not on form CDL-PT-F-027",
     """select id from tb_xpert_xdr_results where tb_detection_result is not null
        and tb_detection_result not in ('NOT DETECTED','DETECTED')"""),
    ("xdr: drug result not on form",
     """select id from tb_xpert_xdr_results where
          inh_result not in ('N/A','NOT DETECTED','DETECTED')
          or flq_result not in ('N/A','NOT DETECTED','DETECTED')
          or amk_result not in ('N/A','NOT DETECTED','DETECTED')
          or eth_result not in ('N/A','NOT DETECTED','DETECTED')"""),
    ("xdr: resistance reported against an undetected complex",
     """select id from tb_xpert_xdr_results where tb_detection_result='NOT DETECTED'
        and (inh_result <> 'N/A' or flq_result <> 'N/A'
             or amk_result <> 'N/A' or eth_result <> 'N/A')"""),
    ("xdr: Ct value outside 0-100",
     """select id from tb_xpert_xdr_results where
          spc_ahpc < 0 or spc_ahpc > 100 or inha < 0 or inha > 100
          or katg < 0 or katg > 100 or rrs < 0 or rrs > 100"""),

    ("vl: tested but no viral load",
     """select id from hiv_vl_results where status_id in (2,4)
        and result_reported='Yes' and viral_load_log10 is null"""),
    ("vl: not tested but carries a viral load",
     """select id from hiv_vl_results
        where result_reported='No' and viral_load_log10 is not null"""),
    ("vl: not tested without a reason",
     """select id from hiv_vl_results where status_id in (2,4)
        and result_reported='No' and not_tested_reason is null"""),
    ("vl: viral load outside 0-10 log10",
     """select id from hiv_vl_results
        where viral_load_log10 < 0 or viral_load_log10 > 10"""),
    ("vl: submitted without the panel details",
     """select id from hiv_vl_results where status_id in (2,4)
        and result_reported='Yes' and (date_panel_received is null
          or date_tested is null or detection_assay is null
          or extraction_assay is null)"""),
    ("vl: reported value not Yes or No",
     """select id from hiv_vl_results where result_reported is not null
        and result_reported not in ('Yes','No')"""),

    ("eid: result phrase not on form TF-012",
     """select id from hiv_eid_results where hiv_result is not null
        and hiv_result not in ('HIV-1 Detected','HIV-1 Not Detected')"""),
    ("eid: tested but no result",
     """select id from hiv_eid_results where status_id in (2,4)
        and result_reported='Yes' and hiv_result is null"""),
    ("eid: not tested but carries a result",
     """select id from hiv_eid_results
        where result_reported='No' and hiv_result is not null"""),
    ("eid: not tested without a reason",
     """select id from hiv_eid_results where status_id in (2,4)
        and result_reported='No' and not_tested_reason is null"""),
    ("eid: submitted without the panel details",
     """select id from hiv_eid_results where status_id in (2,4)
        and result_reported='Yes' and (date_panel_received is null
          or date_tested is null or detection_assay is null
          or extraction_assay is null)"""),
    ("eid: optional value out of range",
     """select id from hiv_eid_results where
        hiv_ct_od_value < 0 or hiv_ct_od_value > 100
        or ic_qs_value < 0 or ic_qs_value > 100"""),

    ("a sample has sheets on more than one form",
     """select u.id from tb_xpert_ultra_results u
        join tb_xpert_xdr_results x
          on x.pt_cycle_id=u.pt_cycle_id and x.lab_id=u.lab_id
         and x.method_sample_id=u.method_sample_id"""),
    ("an accepted Ultra/XDR enrolment with no sheets at all",
     """select e.id from enrollments e
        join methods m on m.id=e.method_id
        join pt_cycles c on c.id=e.pt_cycle_id
        where e.status_id=4 and c.pt_cyle_status_id >= 3
          and m.result_form is not null
          and not exists (select 1 from tb_xpert_ultra_results t where t.enrollment_id=e.id)
          and not exists (select 1 from tb_xpert_xdr_results t where t.enrollment_id=e.id)
          and not exists (select 1 from hiv_vl_results t where t.enrollment_id=e.id)
          and not exists (select 1 from hiv_eid_results t where t.enrollment_id=e.id)"""),
    ("a cycle whose enrolment belongs to another scheme",
     """select e.id from enrollments e join pt_cycles c on c.id=e.pt_cycle_id
        where e.scheme_id <> c.scheme_id"""),
    ("a method whose scheme differs from its service",
     """select m.id from methods m join services s on s.id=m.service_id
        where m.scheme_id <> s.scheme_id"""),
    ("a scheme with no provider",
     """select s.id from schemes s left join providers p on p.id=s.provider_id
        where p.id is null"""),
]


async def go():
    con = await asyncpg.connect(DEV_DSN)
    bad = 0
    for label, q in CHECKS:
        rows = await con.fetch(q)
        if rows:
            bad += 1
            print(f"  FAIL  {label}: {len(rows)} row(s) {[r[0] for r in rows][:8]}")
        else:
            print(f"  ok    {label}")

    print()
    print("ALL CHECKS PASSED" if bad == 0 else f"{bad} CHECK(S) FAILED")

    print("\nResult sheets by method and form:")
    for r in await con.fetch("""
        select m.name method, m.result_form, count(*) c
        from tb_xpert_ultra_results t join methods m on m.id=t.method_id
        group by 1,2
        union all
        select m.name, m.result_form, count(*)
        from tb_xpert_xdr_results t join methods m on m.id=t.method_id
        group by 1,2
        union all
        select m.name, m.result_form, count(*)
        from hiv_vl_results t join methods m on m.id=t.method_id
        group by 1,2
        union all
        select m.name, m.result_form, count(*)
        from hiv_eid_results t join methods m on m.id=t.method_id
        group by 1,2 order by 1"""):
        print(f"   {r['method']:8} {r['result_form']:16} {r['c']}")

    await con.close()
    return 1 if bad else 0


raise SystemExit(asyncio.run(go()))
