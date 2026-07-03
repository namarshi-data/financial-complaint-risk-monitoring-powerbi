# Interview Talking Points

## 30-Second Project Summary

I built a Power BI financial complaint analytics dashboard to monitor complaint volume, response timeliness, company concentration, high-risk complaint indicators, category drivers, and data quality controls.

The report uses Power Query for data preparation, a star-schema model, DAX measures, synced slicers, drill-through analysis, decomposition tree root-cause exploration, Key Influencers AI insights, and a dedicated data governance page.

The project is positioned as a finance analytics portfolio project for banking, risk, compliance, operations, and business intelligence analyst roles.

---

## Business Problem

Financial institutions need to monitor customer complaint activity to identify operational risk, response delays, recurring complaint issues, and concentration across companies or product categories.

This dashboard simulates how a finance/risk team could track complaint operations and identify areas requiring management attention.

---

## Business Value

The dashboard helps stakeholders answer key business questions:

- Which complaint categories are driving the highest volume?
- Which companies are most concentrated in the complaint portfolio?
- Are responses being handled within expected timeliness thresholds?
- Which complaints should be treated as higher risk based on lateness or narrative complexity?
- What data quality assumptions or limitations should be considered before reporting?

---

## Technical Approach

The data model is built around a complaint-level fact table connected to dimension tables for date, company, complaint category, state, response outcome, and submission channel.

Power Query was used to clean and standardize the data, including category labels, state values, date fields, and reporting-ready dimensions.

DAX was used to calculate core KPIs such as complaint count, timely response rate, late response complaints, high-risk complaint rate, company concentration, narrative complexity, and operational risk score.

---

## Report Pages

The report includes the following analytical views:

1. **Executive Overview**  
   High-level complaint volume, timeliness, company concentration, response outcomes, and portfolio insight.

2. **Risk & Timeliness Monitoring**  
   Late response tracking, response timeliness versus target, company risk matrix, and company risk ranking.

3. **Company Benchmarking**  
   Company ranking, top company concentration, and complaint concentration heatmap by company and category.

4. **Company Detail**  
   Drill-through page for company-level investigation, including complaint trend, category mix, top issues, and response outcome mix.

5. **Category & Issue Deep Dive**  
   Root-cause analysis using category volume, top complaint issues, narrative complexity, and decomposition tree analysis.

6. **Data Quality & Governance**  
   Data completeness checks, unique complaint validation, missing state monitoring, submission channel limitation, and governance notes.

7. **AI Insights: Risk Drivers**  
   Key Influencers analysis to identify factors associated with high-risk complaints.

---

## Important Numbers to Mention

- **996** complaint records
- **245** companies
- **97.9%** timely response rate
- **21** late response complaints
- **267** high-risk complaints
- **26.8%** high-risk complaint rate
- **55.1%** top 10 company concentration
- Date range: **Mar 2015 – Sep 2021**

---

## How I Defined High Risk

High-risk complaints were defined using two operational indicators:

1. Late response indicator
2. Complaint narrative complexity

A complaint is classified as high risk if it has a late response or a complex complaint narrative.

This creates a practical risk-monitoring flag that combines service timeliness with complaint complexity.

---

## How to Explain the Risk Score

The operational risk score is a composite score based on:

- Complaint volume share
- Late response rate
- Complex narrative rate

The purpose of the score is not to replace business judgment, but to help prioritize companies or segments for review.

---

## How to Explain the AI Insights Page

The Key Influencers visual is used as an exploratory Power BI AI visual to identify factors associated with high-risk complaints.

It is not an automated decisioning tool and does not prove causality. I included an interpretation note because AI outputs in finance reporting should be treated as directional evidence that requires analyst review.

The strongest influencer is narrative complexity, which makes sense because high risk is partly defined using complex complaint narratives.

---

## How to Explain the Decomposition Tree

The decomposition tree allows users to start from total complaint volume and drill into the drivers behind it.

For example, users can move from:

`Complaint Count → Company → Complaint Category → Issue → Response Outcome`

This supports root-cause analysis and helps business users understand where complaint volume is coming from.

---

## How to Explain Data Governance

I included a dedicated governance page because finance reporting requires transparency around data assumptions and controls.

Key governance points include:

- Complaint ID is used as the unique transaction key.
- Category labels were standardized for consistent reporting.
- Missing state values are classified as “Unknown”.
- Submission channel is 100% Web, so it is monitored as a data characteristic rather than used as a major segmentation visual.
- QA summary tables support validation, while the complaint-level fact table remains the primary reporting source.

---

## What This Project Demonstrates

This project demonstrates my ability to:

- Build a Power BI report from cleaned complaint-level data
- Design a star-schema data model
- Write DAX measures for KPIs, rates, rankings, and risk scoring
- Create executive, operational, and governance-focused report pages
- Use drill-through and decomposition tree analysis for investigation
- Apply AI visuals responsibly with interpretation notes
- Communicate business insights clearly for finance and risk stakeholders

---

## Interview Closing Statement

This project was designed to show more than visualization skills. It demonstrates how Power BI can be used for financial complaint monitoring, risk prioritization, operational reporting, root-cause analysis, and data governance.

My goal was to build a portfolio project that reflects the type of reporting and analytical thinking expected in finance, banking, risk, compliance, and BI analyst roles.