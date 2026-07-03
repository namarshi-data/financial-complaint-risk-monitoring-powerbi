# Data Quality & Governance

This document summarizes the data quality checks, reporting assumptions, governance notes, and known limitations for the Financial Complaint Analytics Power BI project.

The purpose of this documentation is to make the report transparent, auditable, and suitable for finance, risk, compliance, and business intelligence review.

---

## 1. Control Summary

| Check Area | Status | Comment |
|---|---|---|
| Complaint ID uniqueness | Passed | 996 unique complaint IDs found across 996 complaint records. |
| Missing state handling | Monitored | 7 records were classified as `Unknown` to preserve completeness while making missing values visible. |
| Date coverage | Passed | Complaint date range is Mar 2015 to Sep 2021. |
| Submission channel variation | Limited | Submission channel is 100% Web, so channel segmentation is not analytically useful. |
| Primary reporting source | Confirmed | `Fact_Complaints` is used as the primary reporting source. |
| QA aggregate validation | Passed | QA summary tables were used to reconcile aggregate complaint counts and KPI outputs. |
| AI output interpretation | Monitored | AI visual outputs are treated as directional insights, not causal proof or automated decisioning. |

---

## 2. Data Governance Notes

`Complaint ID` is used as the unique transaction key for complaint-level reporting. This supports distinct-count KPIs, reconciliation checks, and drill-through analysis.

Complaint category labels were standardized to support consistent reporting and aggregation across executive, company, category, and risk monitoring pages.

Missing state values are classified as `Unknown`. This preserves the full complaint record population while making data gaps visible in governance reporting.

Submission channel is 100% Web. Because there is no channel variation, submission channel is monitored as a dataset characteristic rather than used as a primary segmentation driver.

Complaint volume is concentrated around 2019. This should be considered when interpreting trend patterns because the time series is not evenly distributed across the full reporting period.

QA summary tables were used to validate aggregate complaint counts against the complaint-level fact table. The QA tables support reconciliation, but the fact table remains the primary source for reporting.

---

## 3. Known Limitations

- The dataset should not be described as Canadian customer data because the geographic field uses U.S.-style state codes.
- Submission channel does not provide segmentation value because all complaint records were submitted through Web.
- Complaint dates are not evenly distributed across the full date range, so trend interpretation should consider period concentration.
- Narrative word count is used as a proxy for complaint complexity. It does not measure legal, regulatory, or financial severity directly.
- The high-risk flag is a business-rule indicator based on late response behavior and narrative complexity. It should not be described as a regulatory risk classification.
- AI visual outputs are exploratory and directional. They should be reviewed by analysts before any business action is taken.

---

## 4. Reporting Controls

| Control | Purpose | Implementation |
|---|---|---|
| Unique complaint key | Prevent duplicate complaint counting | `Complaint ID` is used as the distinct transaction key. |
| Missing state classification | Preserve records while surfacing data gaps | Blank state values are classified as `Unknown`. |
| Category standardization | Improve consistency across visuals | Source category labels are standardized before reporting. |
| Timeliness flags | Support response monitoring | Timely and late response fields are converted into numeric flags. |
| High-risk flag | Support risk monitoring | Complaints are flagged high risk if late or complex. |
| QA summary tables | Validate aggregate outputs | Company/category and monthly/category summaries are used for reconciliation. |
| AI disclaimer | Support responsible AI interpretation | Key Influencers output is labeled as directional evidence, not automated decisioning. |

---

## 5. Data Quality Metrics

| Metric | Value |
|---|---:|
| Total Records | 996 |
| Unique Complaints | 996 |
| Duplicate Complaint Records | 0 |
| Missing State Records | 7 |
| Missing State Rate | 0.7% |
| Web Submission Rate | 100.0% |
| Timely Response Rate | 97.9% |
| Late Response Rate | 2.1% |
| Date Range | Mar 2015 to Sep 2021 |

---

## 6. QA Validation Tables

The project includes QA summary tables for reconciliation and validation.

### `company_category_summary.csv`

Used to validate:

- Complaint counts by company and category
- Company/category timeliness rates
- Matrix and heatmap-level totals

### `monthly_category_kpis.csv`

Used to validate:

- Monthly complaint counts
- Monthly/category KPI calculations
- Average narrative word count
- Timeliness rates by reporting period and category

These QA tables are used as validation references only. The Power BI report uses `Fact_Complaints` as the primary reporting source.

---

## 7. Governance Interpretation

This project applies a finance-ready reporting approach by documenting:

- Business definitions
- Data quality checks
- Known limitations
- Reporting grain
- Source assumptions
- QA validation logic
- Responsible use of AI visuals

The goal is to make the dashboard transparent and explainable for executive, operational, risk, and governance stakeholders.

---

## 8. Recommended Dashboard Governance Note

Use the following short note on the Power BI Data Quality & Governance page:

> Complaint ID is used as the unique transaction key. Category labels were standardized for consistent reporting. Missing state values are classified as `Unknown`. Submission channel is 100% Web and monitored as a data characteristic. QA summary tables support validation, while `Fact_Complaints` remains the primary reporting source.