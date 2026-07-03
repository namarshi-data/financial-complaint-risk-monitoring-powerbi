# Data Profile

This document summarizes the complaint-level dataset used in the Financial Complaint Analytics Power BI project.

The purpose of this profile is to document dataset size, coverage, key distributions, concentration patterns, and data quality characteristics before reporting.

---

## 1. Dataset Summary

| Metric | Value |
|---|---:|
| Records | 996 |
| Unique Complaints | 996 |
| Companies | 245 |
| Source Category Keys | 11 |
| Date Range | 2015-03-26 to 2021-09-26 |
| Timely Response Rate | 97.9% |
| Late Response Rate | 2.1% |
| Complex Narrative Rate | 25.5% |
| High-Risk Complaint Rate | 26.8% |
| Missing State Rate | 0.7% |
| Web Submission Rate | 100.0% |

---

## 2. Key Data Observations

- The dataset contains **996 complaint records** and **996 unique complaint IDs**, indicating no duplicate complaint IDs in the reporting table.
- Complaint activity covers the period from **March 2015 to September 2021**.
- The response process appears strong overall, with a **97.9% timely response rate** and a **2.1% late response rate**.
- **26.8% of complaints** are classified as high risk based on late response behavior or narrative complexity.
- **25.5% of complaints** have complex narratives, using a threshold of at least 300 words.
- State coverage is strong, with only **0.7% missing state values**.
- Submission channel is **100.0% Web**, so it is monitored as a data characteristic rather than used as a major segmentation driver.

---

## 3. Top Complaint Categories

The table below shows the complaint distribution by source category key.

| Rank | Category Key | Complaints | Share of Total |
|---:|---|---:|---:|
| 1 | credit_reporting | 424 | 42.6% |
| 2 | debt_collection | 168 | 16.9% |
| 3 | credit_card_or_prepaid_card | 112 | 11.2% |
| 4 | mortgage | 91 | 9.1% |
| 5 | bank_account | 72 | 7.2% |
| 6 | student_loan | 53 | 5.3% |
| 7 | money_transfer | 27 | 2.7% |
| 8 | vehicle_loan_or_lease | 26 | 2.6% |
| 9 | payday_loan_title_loan_or_personal_loan | 21 | 2.1% |
| 10 | consumer_loan | 1 | 0.1% |
| 11 | money_transfers | 1 | 0.1% |

### Category Observations

- `credit_reporting` is the largest complaint category, representing **42.6%** of total complaints.
- The top five categories represent **87.0%** of total complaint volume.
- The dataset includes two similar transfer-related category keys: `money_transfer` and `money_transfers`. These should be reviewed during standardization and combined if they represent the same business category.

---

## 4. Top Companies by Complaint Volume

| Rank | Company | Complaints | Share of Total |
|---:|---|---:|---:|
| 1 | EQUIFAX, INC. | 118 | 11.8% |
| 2 | Experian Information Solutions Inc. | 116 | 11.6% |
| 3 | TRANSUNION INTERMEDIATE HOLDINGS, INC. | 113 | 11.3% |
| 4 | JPMORGAN CHASE & CO. | 44 | 4.4% |
| 5 | WELLS FARGO & COMPANY | 32 | 3.2% |
| 6 | CITIBANK, N.A. | 30 | 3.0% |
| 7 | Navient Solutions, LLC. | 27 | 2.7% |
| 8 | BANK OF AMERICA, NATIONAL ASSOCIATION | 25 | 2.5% |
| 9 | CAPITAL ONE FINANCIAL CORPORATION | 25 | 2.5% |
| 10 | SYNCHRONY FINANCIAL | 19 | 1.9% |

### Company Observations

- The top 10 companies account for **55.1%** of total complaint volume.
- The top three companies account for **34.8%** of total complaint volume.
- The highest-volume companies are concentrated among credit reporting agencies and major financial institutions.
- Company concentration is important for risk monitoring because a small number of companies drive a large share of total complaint activity.

---

## 5. Risk and Timeliness Profile

| Metric | Value |
|---|---:|
| Timely Response Complaints | 975 |
| Late Response Complaints | 21 |
| Timely Response Rate | 97.9% |
| Late Response Rate | 2.1% |
| Complex Narrative Complaints | 254 |
| Complex Narrative Rate | 25.5% |
| High-Risk Complaints | 267 |
| High-Risk Complaint Rate | 26.8% |

### Risk Definition

A complaint is classified as high risk if it meets at least one of the following conditions:

- The complaint response was late.
- The complaint narrative contains at least 300 words.

This definition is used for risk monitoring, KPI reporting, and the Power BI Key Influencers analysis.

---

## 6. Data Quality Profile

| Data Quality Check | Result | Interpretation |
|---|---:|---|
| Complaint ID uniqueness | 996 unique IDs out of 996 records | Passed |
| Missing state rate | 0.7% | Low issue volume; classify as `Unknown` |
| Submission channel coverage | 100.0% Web | Limited channel variation |
| Date coverage | 2015-03-26 to 2021-09-26 | Suitable for trend analysis |
| Category standardization | Required | Similar category keys should be reviewed |

---

## 7. Reporting Considerations

- The dataset is appropriate for complaint monitoring, company benchmarking, timeliness analysis, category analysis, and governance reporting.
- Because submission channel is entirely Web, it should not be used as a major segmentation visual.
- Category labels should be standardized before final reporting to avoid duplicate business concepts.
- High-risk complaint analysis is directional and based on defined business rules, not regulatory classification.
- AI visual outputs should be interpreted as exploratory business signals, not causal proof or automated decisioning.

---

## 8. Recommended Use in Power BI

This data profile supports the following report pages:

| Report Page | Data Profile Relevance |
|---|---|
| Executive Overview | Summary KPIs, top categories, top companies, concentration |
| Risk & Timeliness Monitoring | Late response rate, high-risk complaints, complexity profile |
| Company Benchmarking | Company count, top companies, concentration share |
| Company Detail | Company-level complaint volume and response behavior |
| Category & Issue Deep Dive | Category distribution and issue concentration |
| Data Quality & Governance | Missing state, uniqueness, source limitations |
| AI Insights: Risk Drivers | High-risk flag, complexity bands, Key Influencers analysis |

---

## 9. Portfolio Summary

The dataset is compact but strong enough to demonstrate a professional Power BI workflow, including:

- Data profiling
- Data cleaning and standardization
- Star-schema modeling
- DAX KPI development
- Executive reporting
- Risk monitoring
- Company benchmarking
- Drill-through investigation
- Data governance documentation
- AI-assisted exploratory analysis