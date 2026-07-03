# Power Query Transformation Guide

This guide documents the Power Query preparation steps used in the Financial Complaint Analytics Power BI project.

The goal of the transformation layer is to create a clean, model-ready dataset for reporting, risk monitoring, data governance, and validation.

---

## 1. Query Naming Standards

Use clear, professional query names in Power BI.

| Query Name | Purpose |
|---|---|
| `Fact_Complaints` | Primary complaint-level fact table |
| `QA_CompanyCategorySummary` | QA table for company/category reconciliation |
| `QA_MonthlyCategoryKPIs` | QA table for monthly/category reconciliation |
| `Dim_Date` | Date dimension for time intelligence and trend analysis |
| `Dim_Company` | Company dimension for benchmarking, slicers, and drill-through |
| `Dim_Category` | Standardized complaint category dimension |
| `Dim_State` | Cleaned state dimension |
| `Dim_Response` | Company response outcome dimension |
| `Dim_Channel` | Submission channel dimension |

---

## 2. Recommended Transformation Flow

Recommended Power Query workflow:

1. Import raw CSV files.
2. Promote headers.
3. Set data types.
4. Standardize category keys.
5. Create business-friendly category labels.
6. Clean state values.
7. Create timeliness flags.
8. Create narrative complexity fields.
9. Create high-risk flag.
10. Build dimension tables.
11. Disable load for staging queries if used.
12. Validate record counts against QA summary tables.

---

## 3. Core Data Type Settings

Apply the following data types in `Fact_Complaints`.

| Field | Recommended Type |
|---|---|
| `Complaint ID` | Whole Number |
| `Date received` | Date |
| `month` | Text |
| `Product` | Text |
| `label_clean` | Text |
| `Issue` | Text |
| `Company` | Text |
| `State` | Text |
| `Submitted via` | Text |
| `Company response to consumer` | Text |
| `Timely response?` | Text |
| `narrative_word_count` | Whole Number |

---

## 4. Standardize Category Keys

Create a clean category key to support consistent category reporting.

Recommended new column name:

```text
CategoryKeyClean
```

Power Query formula:

```powerquery
if Text.Lower(Text.Trim([label_clean])) = "money_transfers"
then "money_transfer"
else Text.Lower(Text.Trim([label_clean]))
```

Purpose:

- Standardizes category keys.
- Removes spacing and casing inconsistencies.
- Combines `money_transfers` into `money_transfer` if both represent the same business category.

---

## 5. Create Business-Friendly Category Labels

Create a display label for visuals.

Recommended new column name:

```text
Category Standardized
```

Base formula:

```powerquery
Text.Proper(Text.Replace([CategoryKeyClean], "_", " "))
```

Recommended manual refinements:

| Category Key | Recommended Display Label |
|---|---|
| `credit_reporting` | Credit Reporting |
| `debt_collection` | Debt Collection |
| `credit_card_or_prepaid_card` | Credit Card / Prepaid Card |
| `mortgage` | Mortgage |
| `bank_account` | Bank Account |
| `student_loan` | Student Loan |
| `money_transfer` | Money Transfer |
| `vehicle_loan_or_lease` | Vehicle Loan / Lease |
| `payday_loan_title_loan_or_personal_loan` | Payday / Title / Personal Loan |
| `consumer_loan` | Consumer Loan |

Optional Power Query formula using conditional logic:

```powerquery
if [CategoryKeyClean] = "credit_card_or_prepaid_card" then "Credit Card / Prepaid Card"
else if [CategoryKeyClean] = "vehicle_loan_or_lease" then "Vehicle Loan / Lease"
else if [CategoryKeyClean] = "payday_loan_title_loan_or_personal_loan" then "Payday / Title / Personal Loan"
else Text.Proper(Text.Replace([CategoryKeyClean], "_", " "))
```

---

## 6. Create Clean State Field

Create a cleaned state field for reporting and governance monitoring.

Recommended new column name:

```text
StateClean
```

Power Query formula:

```powerquery
if [State] = null or Text.Trim([State]) = ""
then "Unknown"
else Text.Upper(Text.Trim([State]))
```

Purpose:

- Preserves all complaint records.
- Makes missing geographic values visible.
- Supports the Data Quality & Governance page.

---

## 7. Create Timeliness Flags

Create numeric flags for response timeliness calculations.

### `IsTimely`

```powerquery
if Text.Upper(Text.Trim([Timely response?])) = "YES"
then 1
else 0
```

### `IsLate`

```powerquery
if Text.Upper(Text.Trim([Timely response?])) = "NO"
then 1
else 0
```

Purpose:

- Supports DAX measures for timely and late response counts.
- Improves KPI calculation consistency.
- Avoids repeated text filtering in measures.

---

## 8. Create Month Start Date

Create a proper monthly date field for time-series visuals.

Recommended new column name:

```text
MonthStart
```

Power Query formula:

```powerquery
Date.StartOfMonth([Date received])
```

Purpose:

- Supports monthly trend visuals.
- Allows correct chronological sorting.
- Connects cleanly to `Dim_Date`.

---

## 9. Create Year Field

Recommended new column name:

```text
Year
```

Power Query formula:

```powerquery
Date.Year([Date received])
```

Purpose:

- Supports year slicers.
- Improves filtering and summary reporting.

---

## 10. Create Narrative Complexity Band

Narrative complexity is based on complaint narrative word count.

Recommended new column name:

```text
Narrative Complexity Band
```

Use the same thresholds in Power Query and DAX to keep documentation, AI visuals, and measures consistent.

```powerquery
if [narrative_word_count] >= 500 then "Very Complex"
else if [narrative_word_count] >= 300 then "Complex"
else if [narrative_word_count] >= 100 then "Moderate"
else "Low"
```

| Complexity Band | Rule |
|---|---|
| Low | Less than 100 words |
| Moderate | 100 to 299 words |
| Complex | 300 to 499 words |
| Very Complex | 500 or more words |

---

## 11. Create Complex Narrative Flag

Recommended new column name:

```text
IsComplexNarrative
```

Power Query formula:

```powerquery
if [narrative_word_count] >= 300
then 1
else 0
```

Purpose:

- Supports complex narrative KPIs.
- Supports operational risk scoring.
- Supports high-risk complaint classification.

---

## 12. Create High-Risk Flag

Recommended new column name:

```text
HighRiskFlag
```

Power Query formula:

```powerquery
if [IsLate] = 1 or [narrative_word_count] >= 300
then 1
else 0
```

Purpose:

- Flags complaints requiring higher review priority.
- Supports high-risk complaint KPIs.
- Supports the AI Insights page.

---

## 13. Create High-Risk Status Label

Recommended new column name:

```text
High Risk Status
```

Power Query formula:

```powerquery
if [HighRiskFlag] = 1
then "High Risk"
else "Not High Risk"
```

Purpose:

- Provides a readable target field for Power BI Key Influencers.
- Makes the AI Insights page easier to explain to business users.

---

## 14. Recommended Dimension Table Logic

Create dimension tables from the cleaned fact table.

### `Dim_Company`

Reference `Fact_Complaints`, keep only `Company`, remove duplicates, remove blanks if necessary, and sort ascending.

Recommended fields:

| Field | Description |
|---|---|
| `Company` | Company name used for slicers, rankings, and drill-through |

---

### `Dim_Category`

Reference `Fact_Complaints`, keep category fields, and remove duplicates.

Recommended fields:

| Field | Description |
|---|---|
| `CategoryKeyClean` | Standardized category key |
| `Category Standardized` | Business-friendly category label |

---

### `Dim_State`

Reference `Fact_Complaints`, keep `StateClean`, remove duplicates, and sort ascending.

Recommended fields:

| Field | Description |
|---|---|
| `StateClean` | Cleaned state value, with missing values shown as `Unknown` |

---

### `Dim_Response`

Reference `Fact_Complaints`, keep `Company response to consumer`, remove duplicates, and rename for readability.

Recommended field:

| Field | Description |
|---|---|
| `CompanyResponse` | Company response or outcome category |

---

### `Dim_Channel`

Reference `Fact_Complaints`, keep `Submitted via`, remove duplicates, and rename if needed.

Recommended field:

| Field | Description |
|---|---|
| `SubmittedVia` | Complaint submission channel |

Because submission channel is 100% Web, use this dimension mainly for governance documentation rather than primary segmentation.

---

## 15. Date Dimension

Create `Dim_Date` using a calendar table in Power BI or Power Query.

Recommended fields:

| Field | Description |
|---|---|
| `Date` | Calendar date |
| `Year` | Calendar year |
| `Month Number` | Numeric month |
| `Month Name` | Month name |
| `Year Month` | Month-year display label |
| `Month Start` | First day of the month |

Recommended relationship:

```text
Dim_Date[Date] 1:* Fact_Complaints[Date received]
```

or, if using monthly reporting grain:

```text
Dim_Date[Month Start] 1:* Fact_Complaints[MonthStart]
```

Use one active date relationship for reporting consistency.

---

## 16. Data Model Notes

Use a star-schema structure with single-direction relationships from dimensions to the fact table.

Recommended relationship pattern:

| Dimension | Fact Table Relationship |
|---|---|
| `Dim_Date` | `Dim_Date[Date]` → `Fact_Complaints[Date received]` |
| `Dim_Company` | `Dim_Company[Company]` → `Fact_Complaints[Company]` |
| `Dim_Category` | `Dim_Category[CategoryKeyClean]` → `Fact_Complaints[CategoryKeyClean]` |
| `Dim_State` | `Dim_State[StateClean]` → `Fact_Complaints[StateClean]` |
| `Dim_Response` | `Dim_Response[CompanyResponse]` → `Fact_Complaints[Company response to consumer]` |
| `Dim_Channel` | `Dim_Channel[SubmittedVia]` → `Fact_Complaints[Submitted via]` |

Recommended relationship settings:

- Cardinality: One-to-many
- Cross-filter direction: Single
- Active relationships: Yes
- Use dimension fields in slicers and visuals where possible

---

## 17. Load Settings

Recommended load configuration:

| Query | Load Enabled? | Reason |
|---|---|---|
| `Fact_Complaints` | Yes | Primary reporting table |
| `Dim_Date` | Yes | Date filtering and trend analysis |
| `Dim_Company` | Yes | Company slicers, ranking, drill-through |
| `Dim_Category` | Yes | Category slicers and standardized reporting |
| `Dim_State` | Yes | State filtering and missing state monitoring |
| `Dim_Response` | Yes | Response outcome analysis |
| `Dim_Channel` | Yes | Submission channel documentation |
| `QA_CompanyCategorySummary` | Yes or No | Keep loaded only if used for validation visuals |
| `QA_MonthlyCategoryKPIs` | Yes or No | Keep loaded only if used for validation visuals |
| Staging queries | No | Disable load to keep model clean |

---

## 18. Fields to Hide from Report View

Hide technical fields that are not needed by report users.

Recommended fields to hide:

- Raw category helper fields if replaced by standardized fields
- Technical keys not used directly in visuals
- QA-only fields not required by report users
- Duplicate helper columns
- Sort-only columns after applying sort-by-column settings

Keep visible:

- Business-friendly dimensions
- KPI-relevant columns
- Drill-through fields
- Fields used in slicers
- Fields needed for AI visuals

---

## 19. QA Validation Checks

Before finalizing the report, validate the following:

| Check | Expected Result |
|---|---|
| Total records | 996 |
| Unique complaint IDs | 996 |
| Duplicate complaint records | 0 |
| Timely response rate | 97.9% |
| Late response complaints | 21 |
| Missing state records | 7 |
| Missing state rate | 0.7% |
| Web submission rate | 100.0% |

Recommended validation approach:

- Compare Power BI complaint counts against `company_category_summary.csv`.
- Compare monthly/category totals against `monthly_category_kpis.csv`.
- Confirm that category standardization does not change the total complaint count.
- Confirm that missing states are classified as `Unknown`, not removed.

---

## 20. Governance Notes

- `Complaint ID` is used as the unique transaction key.
- QA tables are validation references, not the main reporting source.
- `Fact_Complaints` remains the primary reporting source.
- Missing state values are preserved as `Unknown`.
- Submission channel is monitored as a data characteristic because all records are Web.
- High-risk logic is a business-rule indicator, not a regulatory risk classification.
- AI outputs are directional and require analyst review before business action.