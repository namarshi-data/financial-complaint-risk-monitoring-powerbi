# SQL View Layer

## Purpose

The SQL view layer supports cleaned reporting outputs, data validation, and Power BI model preparation.

## Example Views

| View | Purpose |
|---|---|
| `vw_fact_complaints_clean` | Clean complaint-level reporting table |
| `vw_monthly_complaint_kpis` | Monthly complaint volume and KPI trends |
| `vw_company_category_kpis` | Company and category-level complaint analysis |
| `vw_company_risk_summary` | Company-level risk and timeliness summary |
| `vw_portfolio_summary` | Overall portfolio KPI summary |
| `vw_data_quality_summary` | Data-quality control metrics |
| `vw_missing_state_exceptions` | Records with missing or unknown state values |

## Why Include SQL?

Including SQL demonstrates that the dashboard logic can be moved beyond Power BI and prepared for database-backed reporting environments.

This is useful for:

- reporting automation
- repeatable view logic
- Power BI DirectQuery or import preparation
- QA validation
- analyst handoff
- governance documentation

## Portfolio Note

The SQL layer is included to show BI engineering readiness. The Power BI dashboard can still run from CSV or Excel sources, but the SQL layer shows how the same reporting logic could be formalized in a database environment.
