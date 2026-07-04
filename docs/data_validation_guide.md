# Data Validation Guide

## Purpose

The project includes Python scripts for repeatable data-quality checks and data profiling.

## Install Requirements

```bash
pip install -r requirements.txt
```

## Run Validation

```bash
python scripts/validate_data.py
```

## Generate Data Profile

```bash
python scripts/generate_data_profile.py
```

## Recommended Checks

| Check | Purpose |
|---|---|
| Row count check | Confirms expected record count |
| Complaint ID uniqueness | Confirms complaint-level grain |
| Missing state check | Measures completeness issue |
| Category standardization check | Confirms reporting categories are consistent |
| Date range check | Confirms reporting period |
| Timely response check | Validates response outcome fields |
| Web submission rate check | Confirms channel limitation |
| High-risk flag check | Confirms business-rule outputs |
| Aggregate KPI tie-out | Confirms totals match Power BI outputs |

## Governance Notes

Validation outputs should be reviewed before dashboard refreshes and after major transformation changes.
