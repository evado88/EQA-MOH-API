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
                    ("hiv_eid_results", "hiv_eid"),
                    ("bacteriology_results", "bacteriology")):
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
    ("an accepted enrolment on a built form with no sheets at all",
     """select e.id from enrollments e
        join methods m on m.id=e.method_id
        join pt_cycles c on c.id=e.pt_cycle_id
        where e.status_id=4 and c.pt_cyle_status_id >= 3
          and m.result_form is not null
          and not exists (select 1 from tb_xpert_ultra_results t where t.enrollment_id=e.id)
          and not exists (select 1 from tb_xpert_xdr_results t where t.enrollment_id=e.id)
          and not exists (select 1 from hiv_vl_results t where t.enrollment_id=e.id)
          and not exists (select 1 from hiv_eid_results t where t.enrollment_id=e.id)
          and not exists (select 1 from bacteriology_results t where t.enrollment_id=e.id)"""),
    # the bacteriology worksheet, TF-NHRTI-BACT-001
    ("bacteriology: a worked specimen with no stain reaction once submitted",
     """select id from bacteriology_results where status_id in (2,4)
        and not testing_not_done and gram_stain_reaction is null"""),
    ("bacteriology: a worked specimen with no organism once submitted",
     """select id from bacteriology_results where status_id in (2,4)
        and not testing_not_done and organism_identified is null"""),
    ("bacteriology: a result recorded although testing was not done",
     """select id from bacteriology_results where testing_not_done
        and (gram_stain_reaction is not null or organism_identified is not null)"""),
    ("bacteriology: testing not done without a reason once submitted",
     """select id from bacteriology_results where status_id in (2,4)
        and testing_not_done and testing_not_done_reason is null"""),
    ("bacteriology: an AST row on a worksheet that reports no AST",
     """select r.id from bacteriology_results r
        where not r.ast_performed
          and exists (select 1 from bacteriology_ast_results a
                      where a.bacteriology_result_id = r.id)"""),
    ("bacteriology: an AST row with no interpretation once submitted",
     """select a.id from bacteriology_ast_results a
        join bacteriology_results r on r.id = a.bacteriology_result_id
        where r.status_id in (2,4) and a.interpretation is null"""),
    ("bacteriology: an AST row whose reading does not match its method",
     """select id from bacteriology_ast_results
        where (ast_method = 'disk_diffusion' and mic_reading is not null)
           or (ast_method = 'mic' and zone_diameter is not null)"""),
    ("bacteriology: an AST row on neither of the worksheet's tables",
     """select id from bacteriology_ast_results
        where ast_method not in ('disk_diffusion', 'mic')
           or row_no < 1 or row_no > 15"""),
    ("bacteriology: an orphaned AST row",
     """select a.id from bacteriology_ast_results a
        left join bacteriology_results r on r.id = a.bacteriology_result_id
        where r.id is null"""),
    # the noticeboard
    ("announcements: published without a record of who published it",
     """select id from announcements where status_id = 4
        and (published_at is null or published_by is null)"""),
    ("announcements: published with nothing written in it",
     """select id from announcements where status_id = 4
        and (body is null or length(btrim(body)) < 10)"""),
    ("announcements: an occasion published with no date",
     """select id from announcements where status_id = 4
        and category in ('Event', 'Meeting') and event_at is null"""),
    ("announcements: a date on something that is not an occasion",
     """select id from announcements
        where category not in ('Event', 'Meeting') and event_at is not null"""),
    ("announcements: a category the board does not offer",
     """select id from announcements
        where category not in ('Event', 'Meeting', 'Resource', 'General')"""),
    ("announcements: an audience the board does not offer",
     """select id from announcements
        where audience not in ('All Participants', 'Scheme')"""),
    ("announcements: a published Resource pointing nowhere",
     """select a.id from announcements a
        where a.status_id = 4 and a.category = 'Resource'
          and a.link_url is null
          and not exists (select 1 from attachments t
                          where t.type = 'Announcement' and t.parent = a.id)"""),
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
        group by 1,2
        union all
        select m.name, m.result_form, count(*)
        from bacteriology_results t join methods m on m.id=t.method_id
        group by 1,2 order by 1"""):
        print(f"   {r['method']:22} {r['result_form']:16} {r['c']}")

    await con.close()
    return 1 if bad else 0


raise SystemExit(asyncio.run(go()))
