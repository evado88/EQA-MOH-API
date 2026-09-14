"""Turns a round's submitted results into scores, grades and statistics.

This runs once, when a cycle moves to 'Report Available', and writes what it
concludes into the evaluation tables. Nothing here is recomputed at report
time - see models/evaluation_model.py for why.
"""
import statistics
from collections import Counter, defaultdict

from sqlalchemy.future import select

from helpers import assist
from models.evaluation_model import (
    PTEnrollmentPerformanceDB,
    PTResultEvaluationDB,
    PTSampleStatisticsDB,
)
from models.laboratory_model import LaboratoryDB
from models.method_model import (
    RESULT_FORM_HIV_EID,
    RESULT_FORM_HIV_VL,
    RESULT_FORM_TB_XPERT_ULTRA,
    RESULT_FORM_TB_XPERT_XDR,
)
from models.methodsample_model import MethodSampleDB
from models.evaluation_model import MethodSampleExpectedValueDB
from models.tbxpertultraresult_model import TBXpertUltraResultDB
from models.tbxpertxdrresult_model import TBXpertXDRResultDB
from models.hivvlresult_model import HIVVLResultDB
from models.hiveidresult_model import HIVEIDResultDB


# which fields on each form are graded, and how
QUANT = assist.EVALUATION_QUANTITATIVE
QUAL = assist.EVALUATION_QUALITATIVE

FORM_ATTRIBUTES = {
    RESULT_FORM_TB_XPERT_ULTRA: [
        ("tb_detection_result", "TB Detection Result", QUAL),
        ("rif_result", "Rif Result", QUAL),
    ],
    RESULT_FORM_TB_XPERT_XDR: [
        ("tb_detection_result", "TB Detection Result", QUAL),
        ("inh_result", "INH Result", QUAL),
        ("flq_result", "FLQ Result", QUAL),
        ("amk_result", "AMK Result", QUAL),
        ("eth_result", "ETH Result", QUAL),
    ],
    RESULT_FORM_HIV_VL: [
        ("viral_load_log10", "Viral Load (log10 copies/ml)", QUANT),
    ],
    RESULT_FORM_HIV_EID: [
        ("hiv_result", "Your Result", QUAL),
    ],
}

FORM_MODELS = {
    RESULT_FORM_TB_XPERT_ULTRA: TBXpertUltraResultDB,
    RESULT_FORM_TB_XPERT_XDR: TBXpertXDRResultDB,
    RESULT_FORM_HIV_VL: HIVVLResultDB,
    RESULT_FORM_HIV_EID: HIVEIDResultDB,
}

# a result only counts once the lab has formally submitted it. A draft is not
# a submission, and a rejected one has been ruled out by the reviewer.
SUBMITTED_STATUSES = (
    assist.STATUS_SUBMITTED,
    assist.STATUS_UNDER_REVIEW,
    assist.STATUS_APPROVED,
)


def _did_report(form, row):
    """Whether the lab actually produced a result for this sample"""
    if form in (RESULT_FORM_HIV_VL, RESULT_FORM_HIV_EID):
        return row.result_reported == "Yes"
    return row.result_interpretable == "Yes"


def _not_reported_reason(form, row):
    if form in (RESULT_FORM_HIV_VL, RESULT_FORM_HIV_EID):
        return row.not_tested_reason or "No result reported"
    return row.uninterpretable_result or "Result not interpretable"


def _robust_statistics(values):
    """Mean, median and the ISO 13528 robust standard deviation (nIQR)"""
    if not values:
        return None

    mean = statistics.fmean(values)
    median = statistics.median(values)
    standard_sd = statistics.stdev(values) if len(values) > 1 else 0.0

    if len(values) >= 4:
        q1, _, q3 = statistics.quantiles(values, n=4, method="inclusive")
    else:
        # too few points for quartiles; fall back to the spread itself
        q1, q3 = min(values), max(values)

    robust_sd = assist.NIQR_FACTOR * (q3 - q1)

    return dict(
        group_mean=round(mean, 4),
        group_median=round(median, 4),
        robust_sd=round(robust_sd, 4),
        standard_sd=round(standard_sd, 4),
        minimum_value=min(values),
        maximum_value=max(values),
    )


async def _load_results(db, ptcycle):
    """Every submitted result for the cycle, across all three forms"""
    loaded = []

    for form, model in FORM_MODELS.items():
        result = await db.execute(
            select(model).where(
                model.pt_cycle_id == ptcycle.id,
                model.status_id.in_(SUBMITTED_STATUSES),
            )
        )
        for row in result.scalars().all():
            loaded.append((form, row))

    return loaded


async def evaluate_cycle(db, ptcycle, user):
    """Scores a round and writes the result. Returns what it wrote."""
    rows = await _load_results(db, ptcycle)

    if not rows:
        return 0, 0, 0

    frozen_at = assist.get_current_date(False)

    # the samples, so a manufactured panel's stated value can be used
    sample_ids = {row.method_sample_id for _, row in rows}
    result = await db.execute(
        select(MethodSampleDB).where(MethodSampleDB.id.in_(sample_ids))
    )
    samples = {s.id: s for s in result.scalars().all()}

    # the stated correct answer, per sample and per graded field
    result = await db.execute(
        select(MethodSampleExpectedValueDB).where(
            MethodSampleExpectedValueDB.method_sample_id.in_(sample_ids)
        )
    )
    expected = {
        (e.method_sample_id, e.attribute): e for e in result.scalars().all()
    }

    # lab codes, for the report number
    lab_ids = {row.lab_id for _, row in rows}
    result = await db.execute(
        select(LaboratoryDB).where(LaboratoryDB.id.in_(lab_ids))
    )
    labs = {lab.id: lab for lab in result.scalars().all()}

    # ---- group every submission by the sample and field being graded ----
    #
    # The same panel material is shipped to every participant; where a scheme
    # runs several platforms each has its own copy of the sample, so pool them
    # by the sample's name. Otherwise a three-platform scheme would compute
    # three consensus values from a third of the participants each.
    grouped = defaultdict(list)
    for form, row in rows:
        sample = samples.get(row.method_sample_id)

        # a kit control is shipped and recorded on the form, but form TF-006
        # leaves the controls out of the evaluation table
        if sample is not None and sample.is_control:
            continue

        group = (row.scheme_id, sample.name if sample else row.method_sample_id)
        for attribute, label, kind in FORM_ATTRIBUTES[form]:
            grouped[(group, attribute)].append((form, row, label, kind))

    statistics_written = []
    evaluations = []

    for (group, attribute), entries in grouped.items():
        form, first, label, kind = entries[0]
        sample_group = group[1]
        policy = assist.scoring_policy(form)

        # the stated value is a property of the material, so any copy will do
        sample_id = first.method_sample_id

        reported = [
            (f, r) for f, r, _, _ in entries if _did_report(f, r)
        ]

        stat = PTSampleStatisticsDB(
            pt_cycle_id=ptcycle.id,
            method_sample_id=sample_id,
            sample_group=str(sample_group),
            method_id=first.method_id,
            service_id=first.service_id,
            scheme_id=first.scheme_id,
            result_form=form,
            attribute=attribute,
            attribute_label=label,
            evaluation_kind=kind,
            participant_count=len(entries),
            reported_count=len(reported),
            frozen_at=frozen_at,
            frozen_by=user.email,
            created_by=user.email,
        )

        if kind == QUANT:
            values = [
                getattr(r, attribute) for _, r in reported
                if getattr(r, attribute) is not None
            ]
            stats = _robust_statistics(values)

            if stats:
                for key, value in stats.items():
                    setattr(stat, key, value)

            stated = expected.get((sample_id, attribute))
            predefined = stated.expected_value_numeric if stated else None
            if predefined is not None:
                stat.assigned_value_numeric = predefined
                stat.assigned_value_source = assist.ASSIGNED_VALUE_PREDEFINED
            elif stats and len(values) >= assist.MIN_PARTICIPANTS_FOR_CONSENSUS:
                # the robust centre of the participants
                stat.assigned_value_numeric = stats["group_median"]
                stat.assigned_value_source = assist.ASSIGNED_VALUE_CONSENSUS

            if stat.assigned_value_numeric is None:
                stat.evaluated = False
                stat.not_evaluated_reason = (
                    f"Fewer than {assist.MIN_PARTICIPANTS_FOR_CONSENSUS} "
                    "participants reported a result, so no consensus value "
                    "could be assigned"
                )
            elif not stat.robust_sd:
                stat.evaluated = False
                stat.not_evaluated_reason = (
                    "The participants showed no measurable spread, so a "
                    "z-score cannot be calculated"
                )
            else:
                stat.evaluated = True

        else:
            values = [
                getattr(r, attribute) for _, r in reported
                if getattr(r, attribute)
            ]

            stated = expected.get((sample_id, attribute))
            predefined = stated.expected_value_text if stated else None
            if predefined:
                stat.assigned_value_text = predefined
                stat.assigned_value_source = assist.ASSIGNED_VALUE_PREDEFINED
            elif len(values) >= assist.MIN_PARTICIPANTS_FOR_CONSENSUS:
                # the answer the participants agreed on
                most_common, count = Counter(values).most_common(1)[0]
                if count * 2 > len(values):
                    stat.assigned_value_text = most_common
                    stat.assigned_value_source = assist.ASSIGNED_VALUE_CONSENSUS

            if not stat.assigned_value_text:
                stat.evaluated = False
                stat.not_evaluated_reason = (
                    "No stated value for this panel and no majority among the "
                    "participants, so no value could be assigned"
                )
            else:
                stat.evaluated = True
                stat.concordant_count = sum(
                    1 for v in values
                    if v.strip().upper() == stat.assigned_value_text.strip().upper()
                )

        db.add(stat)
        statistics_written.append(stat)

        # ---- grade each participant against it ----
        for f, row, lbl, k in entries:
            ev = PTResultEvaluationDB(
                pt_cycle_id=ptcycle.id,
                lab_id=row.lab_id,
                enrollment_id=row.enrollment_id,
                method_sample_id=row.method_sample_id,
                method_id=row.method_id,
                service_id=row.service_id,
                scheme_id=row.scheme_id,
                result_form=f,
                result_id=row.id,
                attribute=attribute,
                attribute_label=lbl,
                assigned_numeric=stat.assigned_value_numeric,
                assigned_text=stat.assigned_value_text,
                group_mean=stat.group_mean,
                robust_sd=stat.robust_sd,
                # set below: only a gradable sample carries marks
                max_score=0,
                frozen_at=frozen_at,
                frozen_by=user.email,
                created_by=user.email,
            )

            if not _did_report(f, row):
                ev.grade = assist.GRADE_NOT_EVALUATED
                ev.score = policy.unacceptable
                ev.evaluated = False
                ev.not_evaluated_reason = _not_reported_reason(f, row)
                # the sample was gradable, so failing to report it costs marks
                if stat.evaluated:
                    ev.max_score = policy.max_per_attribute

            elif not stat.evaluated:
                ev.grade = assist.GRADE_NOT_EVALUATED
                ev.score = policy.unacceptable
                ev.evaluated = False
                ev.not_evaluated_reason = stat.not_evaluated_reason
                if k == QUANT:
                    ev.reported_numeric = getattr(row, attribute)
                else:
                    ev.reported_text = getattr(row, attribute)

            elif k == QUANT:
                ev.max_score = policy.max_per_attribute
                value = getattr(row, attribute)
                ev.reported_numeric = value
                ev.deviation = round(value - stat.assigned_value_numeric, 4)
                ev.z_score = round(ev.deviation / stat.robust_sd, 4)
                ev.grade, ev.score = assist.grade_for_z_score(
                    ev.z_score, policy
                )
                ev.evaluated = True

            else:
                ev.max_score = policy.max_per_attribute
                value = getattr(row, attribute)
                ev.reported_text = value
                ev.grade, ev.score = assist.grade_for_agreement(
                    value, stat.assigned_value_text, policy
                )
                ev.evaluated = True

            db.add(ev)
            evaluations.append(ev)

    # ---- roll up to one standing per enrolment ----
    by_enrollment = defaultdict(list)
    for ev in evaluations:
        by_enrollment[ev.enrollment_id].append(ev)

    performances = 0
    for enrollment_id, items in by_enrollment.items():
        first = items[0]
        lab = labs.get(first.lab_id)

        policy = assist.scoring_policy(first.result_form)
        evaluated = [e for e in items if e.evaluated]

        # a sample counts towards the total when it was gradable, whether or
        # not this laboratory reported it
        counted = [e for e in items if e.max_score > 0]
        total_score = sum(e.score for e in counted)
        max_score = sum(e.max_score for e in counted)
        percent = round(total_score / max_score, 4) if max_score else None

        if not counted:
            performance = assist.PERFORMANCE_NOT_EVALUATED
            reason = (
                items[0].not_evaluated_reason
                or "No result was submitted for this panel"
            )
        else:
            reason = None
            performance = (
                assist.PERFORMANCE_SATISFACTORY
                if percent is not None and percent >= policy.threshold
                else assist.PERFORMANCE_UNSATISFACTORY
            )

        db.add(
            PTEnrollmentPerformanceDB(
                pt_cycle_id=ptcycle.id,
                lab_id=first.lab_id,
                enrollment_id=enrollment_id,
                method_id=first.method_id,
                service_id=first.service_id,
                scheme_id=first.scheme_id,
                result_form=first.result_form,
                report_number=(
                    f"{ptcycle.code}/{lab.code}" if lab else str(enrollment_id)
                ),
                attributes_total=len(items),
                attributes_evaluated=len(evaluated),
                acceptable_count=sum(
                    1 for e in items if e.grade == assist.GRADE_ACCEPTABLE
                ),
                warning_count=sum(
                    1 for e in items if e.grade == assist.GRADE_WARNING
                ),
                unacceptable_count=sum(
                    1 for e in items if e.grade == assist.GRADE_UNACCEPTABLE
                ),
                not_reported_count=sum(1 for e in items if not e.evaluated),
                total_score=total_score,
                max_score=max_score,
                percent_score=percent,
                overall_performance=performance,
                reason_for_no_evaluation=reason,
                frozen_at=frozen_at,
                frozen_by=user.email,
                created_by=user.email,
            )
        )
        performances += 1

    return len(statistics_written), len(evaluations), performances


async def clear_cycle_evaluation(db, ptcycle):
    """Removes a round's evaluation so it can be recomputed"""
    for model in (PTResultEvaluationDB, PTEnrollmentPerformanceDB,
                  PTSampleStatisticsDB):
        result = await db.execute(
            select(model).where(model.pt_cycle_id == ptcycle.id)
        )
        for row in result.scalars().all():
            await db.delete(row)


async def cycle_is_evaluated(db, ptcycle):
    result = await db.execute(
        select(PTSampleStatisticsDB.id).where(
            PTSampleStatisticsDB.pt_cycle_id == ptcycle.id
        )
    )
    return result.scalars().first() is not None
