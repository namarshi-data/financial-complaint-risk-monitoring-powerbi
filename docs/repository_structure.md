# Repository Structure

```text
financial-complaint-risk-monitoring-powerbi/
│
├── powerbi/
│   └── financial_complaint_analytics.pbix
│
├── reports/
│   └── financial_complaint_analytics_dashboard.pdf
│
├── screenshots/
│   ├── page_01_executive_overview.png
│   ├── page_02_risk_timeliness_monitoring.png
│   ├── page_03_company_benchmarking.png
│   ├── page_04_company_detail_drillthrough.png
│   ├── page_05_category_issue_deep_dive.png
│   ├── page_06_data_quality_governance.png
│   └── page_07_ai_insights_high_risk_drivers.png
│
├── data/
│   ├── raw/
│   └── processed/
│
├── docs/
│   ├── project_overview.md
│   ├── dashboard_design_spec.md
│   ├── data_dictionary.md
│   ├── data_profile.md
│   ├── data_quality_governance.md
│   ├── dax_measure_library.md
│   ├── deployment_guide.md
│   ├── interview_talking_points.md
│   ├── power_query_transformation_guide.md
│   ├── resume_bullets.md
│   ├── risk_scoring_logic.md
│   ├── sql_view_layer.md
│   └── data_validation_guide.md
│
├── sql/
│   └── financial_complaint_mysql_workbench_view_layer.sql
│
├── scripts/
│   ├── validate_data.py
│   └── generate_data_profile.py
│
├── assets/
│   └── themes/
│       └── financial_services_theme.json
│
├── .github/
│   └── workflows/
│       └── data-quality.yml
│
├── .gitignore
├── LICENSE
├── requirements.txt
└── README.md
```

## Repository Notes

- Keep the Power BI file in `powerbi/`.
- Keep exported dashboard PDF files in `reports/`.
- Keep screenshot files in `screenshots/`.
- Keep technical documentation in `docs/`.
- Keep raw data out of GitHub if it is large, private, or restricted.
- Keep processed demo outputs only if they are small and safe to share.
