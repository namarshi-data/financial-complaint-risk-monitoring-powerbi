# Data Dictionary

This document describes the source data, processed fields, model-ready tables, and validation tables used in the Financial Complaint Analytics Power BI project.

The report is built around a complaint-level fact table and supporting dimension tables for date, company, category, state, response outcome, and submission channel.

---

## 1. Source Table: `fact_complaints.csv`

`fact_complaints.csv` is the primary complaint-level dataset used to build the Power BI model.

| Field | Recommended Power BI Type | Description |
|---|---|---|
| Complaint ID | Whole number | Unique complaint transaction identifier. Used as the primary complaint-level key. |
| Date received | Date | Date the complaint was received. Used for monthly trends, date filtering, and reporting period analysis. |
| month | Text / Date helper | Complaint month in `YYYY-MM` format. Used as a source helper for monthly reporting. |
| Product | Text | Original product or complaint category description from the source data. |
| label_clean | Text | Cleaned complaint category key used for consistent category grouping. |
| Issue | Text | Detailed complaint issue reported by the consumer. Used for issue-level and root-cause analysis. |
| Company | Text | Company associated with the complaint. Used for benchmarking, drill-through, and concentration analysis. |
| State | Text | State code associated with the complaint. Missing values are handled as `Unknown`. |
| Submitted via | Text | Complaint submission channel. In this dataset, submission channel is 100% Web. |
| Company response to consumer | Text | Company response or resolution outcome. Used to analyze response outcome mix. |
| Timely response? | Text | Source Yes/No field indicating whether the company response was timely. |
| narrative_word_count | Whole number | Word count of the complaint narrative. Used as a proxy for complaint complexity. |

---

## 2. Processed Fields

The following fields are created during data preparation in Power Query or as calculated columns in Power BI.

| Field | Type | Description |
|---|---|---|
| MonthStart | Date | First day of the complaint month. Used for monthly trend analysis and sorting. |
| Year | Whole number | Complaint year extracted from the complaint date. |
| CategoryKeyClean | Text | Standardized category key derived from `label_clean`. |
| Category Standardized | Text | Business-friendly complaint category label used in report visuals. |
| StateClean | Text | Cleaned state value. Blank or missing state values are classified as `Unknown`. |
| IsTimely | Whole number | Numeric timely response flag. `1` = timely response, `0` = not timely. |
| IsLate | Whole number | Numeric late response flag. `1` = late response, `0` = timely response. |
| Narrative Complexity Band | Text | Complaint narrative complexity grouping: `Low`, `Moderate`, `Complex`, or `Very Complex`. |
| IsComplexNarrative | Whole number | Flag for complex narratives. `1` if `narrative_word_count >= 300`, otherwise `0`. |
| HighRiskFlag | Whole number | High-risk complaint flag. `1` if the complaint is late or has a complex narrative. |
| High Risk Status | Text | Business-friendly high-risk label used for Key Influencers: `High Risk` or `Not High Risk`. |

---

## 3. High-Risk Definition

A complaint is classified as high risk if it meets at least one of the following conditions:

```DAX
HighRiskFlag =
VAR LateRisk =
    Fact_Complaints[IsLate] = 1
VAR ComplexNarrativeRisk =
    Fact_Complaints[narrative_word_count] >= 300
RETURN
    IF (
        LateRisk || ComplexNarrativeRisk,
        1,
        0
    )
```

This definition combines two operational risk indicators:

- Late response behavior
- Complaint narrative complexity

The high-risk flag is used for risk monitoring, KPI reporting, and the AI Insights page.

---

## 4. Narrative Complexity Definition

Narrative complexity is based on complaint narrative word count.

```DAX
Narrative Complexity Band =
SWITCH (
    TRUE (),
    Fact_Complaints[narrative_word_count] >= 500, "Very Complex",
    Fact_Complaints[narrative_word_count] >= 300, "Complex",
    Fact_Complaints[narrative_word_count] >= 100, "Moderate",
    "Low"
)
```

| Complexity Band | Rule |
|---|---|
| Low | Less than 100 words |
| Moderate | 100 to 299 words |
| Complex | 300 to 499 words |
| Very Complex | 500 or more words |

---

## 5. Power BI Model Tables

The Power BI model follows a star-schema structure.

---

### `Fact_Complaints`

Primary fact table containing one row per complaint.

| Key Field | Description |
|---|---|
| Complaint ID | Unique complaint transaction key |
| Date received / MonthStart | Connects to `Dim_Date` |
| Company | Connects to `Dim_Company` |
| CategoryKeyClean / Category Standardized | Connects to `Dim_Category` |
| StateClean | Connects to `Dim_State` |
| Company response to consumer | Connects to `Dim_Response` |
| Submitted via | Connects to submission channel reporting |

---

### `Dim_Date`

Date dimension used for time-based filtering and trend analysis.

| Field | Description |
|---|---|
| Date | Calendar date |
| Year | Calendar year |
| Month Number | Month number used for sorting |
| Month Name | Month name |
| Year Month | Month-year display label |
| Month Start | First date of the month |

---

### `Dim_Company`

Company dimension used for benchmarking, slicers, ranking, and drill-through.

| Field | Description |
|---|---|
| Company | Company name |
| Company Sort / Rank fields | Optional fields used for ranking and visual sorting |

---

### `Dim_Category`

Complaint category dimension used for standardized category reporting.

| Field | Description |
|---|---|
| CategoryKeyClean | Standardized category key |
| Complaint Category | Business-friendly complaint category name |

---

### `Dim_State`

State dimension used for geographic filtering and missing state monitoring.

| Field | Description |
|---|---|
| StateClean | Cleaned state value |
| State Display | State label used in visuals, with missing values shown as `Unknown` |

---

### `Dim_Response`

Response outcome dimension used to analyze company response mix.

| Field | Description |
|---|---|
| CompanyResponse | Company response or resolution outcome |

Common response values include:

- Closed with explanation
- Closed with non-monetary relief
- Closed with monetary relief
- Untimely response

---

## 6. QA Validation Tables

QA tables are included to support validation of aggregate outputs against the complaint-level fact table.

These tables are not the primary reporting source. They are used for control checks and reconciliation.

---

### `company_category_summary.csv`

Used to validate complaint counts and timeliness rates by company and category.

| Field | Type | Description |
|---|---|---|
| Company | Text | Company name |
| label_clean | Text | Cleaned category key |
| complaint_count | Whole number | Complaint count by company and category |
| timely_rate | Decimal | Timely response rate by company and category |

Recommended validation use:

- Compare company/category complaint counts against Power BI matrix totals.
- Validate company-level and category-level timeliness calculations.
- Support QA checks for aggregation accuracy.

---

### `monthly_category_kpis.csv`

Used to validate monthly and category-level KPI calculations.

| Field | Type | Description |
|---|---|---|
| month | Text | Complaint month in `YYYY-MM` format |
| label_clean | Text | Cleaned category key |
| complaint_count | Whole number | Complaint count by month and category |
| avg_narrative_word_count | Decimal | Average narrative word count by month and category |
| timely_rate | Decimal | Timely response rate by month and category |

Recommended validation use:

- Compare monthly complaint trends against the fact table.
- Validate monthly/category complaint counts.
- Validate average narrative complexity calculations.
- Validate monthly/category timeliness rates.

---

## 7. Data Quality Notes

Key data quality assumptions used in the project:

- Complaint ID is treated as the unique transaction key.
- Category values are standardized before reporting.
- Missing state values are classified as `Unknown`.
- Submission channel is 100% Web, so it is monitored as a data characteristic rather than used as a major segmentation driver.
- QA summary tables are used for validation, but the complaint-level fact table remains the primary reporting source.
- AI visual outputs are treated as exploratory and directional, not as automated decisioning.

---

## 8. Reporting Grain

The primary reporting grain is:

```text
One row per complaint
```

This means complaint-level analysis, company benchmarking, category analysis, timeliness monitoring, and high-risk complaint identification are all based on distinct complaint records.

---

## 9. Key Business Metrics

| Metric | Definition |
|---|---|
| Complaint Count | Distinct count of Complaint ID |
| Timely Response Rate | Timely response complaints divided by total complaints |
| Late Response Rate | Late response complaints divided by total complaints |
| Complex Narrative Rate | Complex narrative complaints divided by total complaints |
| High-Risk Complaint Rate | High-risk complaints divided by total complaints |
| Top 10 Company Concentration Rate | Complaint share represented by the top 10 companies |
| Operational Risk Score | Composite score based on complaint share, late response rate, and narrative complexity |

---

## 10. Data Refresh Notes

The current project uses CSV files as source data.

For local refresh:

```text
data/raw/
```

For scheduled refresh in Power BI Service, source files should be moved to a supported cloud location such as OneDrive or SharePoint, and the Power Query source paths should be updated.