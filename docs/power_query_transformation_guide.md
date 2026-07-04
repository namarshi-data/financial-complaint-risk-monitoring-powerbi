# Power Query Transformation Guide

## Transformation Objective

Power Query is used to clean, standardize, and prepare complaint data for Power BI reporting.

## Recommended Transformation Steps

| Step | Purpose |
|---|---|
| Load raw complaint table | Import source complaint data |
| Set data types | Ensure dates, text fields, and numeric fields are typed correctly |
| Trim and clean text | Remove unnecessary whitespace and inconsistent formatting |
| Standardize categories | Consolidate raw category values into consistent reporting groups |
| Clean state values | Replace missing state values with `Unknown` |
| Create date fields | Extract year, month, month-year, and date hierarchy fields |
| Calculate narrative word count | Support complexity analysis |
| Create complex narrative flag | Identify narratives with at least 300 words |
| Create late response flag | Support timeliness KPI reporting |
| Create high-risk flag | Support risk monitoring and AI insight visuals |
| Validate row counts | Confirm transformation does not unintentionally drop records |

## Data Type Guidance

| Field Type | Recommended Type |
|---|---|
| Complaint ID | Text |
| Date Received | Date |
| Product / Category | Text |
| Issue | Text |
| Company | Text |
| State | Text |
| Submitted Via | Text |
| Timely Response | Text or Boolean mapping |
| Narrative Word Count | Whole Number |
| Flags | Whole Number or Boolean |

## Governance Notes

- Do not drop missing state records; classify them as `Unknown`.
- Keep original category values available where useful for auditability.
- Document all business-rule transformations.
- Validate aggregate complaint counts after transformation.
- Avoid using outcome fields as predictors in modelling contexts unless clearly documented.
