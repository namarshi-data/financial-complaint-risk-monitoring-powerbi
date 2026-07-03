# Dashboard Design Specification

## Design Principles

- **Executive first:** communicate the key business message within the first 10 seconds.
- **Finance-ready:** emphasize risk monitoring, controls, governance, and auditability.
- **Clean layout:** avoid unnecessary visuals, excessive colors, crowded labels, and decorative design.
- **Consistent theme:** use navy, blue, teal, slate, gray, amber, and red with clear business meaning.
- **Recruiter-friendly:** make Power BI skills visible through star-schema modeling, DAX, drill-through, decomposition analysis, AI visuals, and governance documentation.
- **Accessible design:** use readable fonts, strong contrast, consistent labels, and avoid relying on color alone.

---

## Page 1: Executive Overview

**Purpose:**  
Provide a high-level management view of complaint volume, response timeliness, company concentration, response outcomes, and operational risk.

**Recommended visuals:**

- KPI cards:
  - Complaint Count
  - Timely Response Rate
  - Late Response Complaints
  - Top 10 Company Concentration Rate
  - High-Risk Complaints
- Monthly Complaint Volume Trend
- Top Complaint Categories
- Top Companies by Complaint Volume
- Major Company Response Outcomes
- Portfolio Insight card

**Business message:**  
This page should allow an executive user to quickly understand overall complaint health, response performance, concentration risk, and key areas requiring monitoring.

---

## Page 2: Risk & Timeliness Monitoring

**Purpose:**  
Monitor late responses, complex complaints, and company-level operational risk.

**Recommended visuals:**

- KPI cards:
  - Late Response Complaints
  - Late Response Rate
  - Complex Narrative Complaints
  - Complex Narrative Rate
  - Operational Risk Score
- Response Timeliness vs 95% Target
- Company Risk Matrix: Volume vs Late Response Rate
- Late Responses by Complaint Category
- Company Risk Ranking matrix

**Business message:**  
This page helps risk and operations teams identify companies or categories with elevated late-response exposure, complaint complexity, or composite operational risk.

---

## Page 3: Company Benchmarking

**Purpose:**  
Compare companies and identify complaint concentration patterns.

**Recommended visuals:**

- KPI cards:
  - Companies
  - Complaints
  - Top 10 Share
  - Avg / Company
  - Highest Volume
- Top 15 Companies by Complaint Volume
- Complaint Concentration Heatmap by Company and Category

**Business message:**  
This page supports benchmarking by showing which companies drive the highest complaint volume and where category concentration is strongest.

---

## Page 4: Company Detail

**Purpose:**  
Provide a drill-through company profile for investigation and business review.

**Recommended visuals:**

- Selected Company card
- KPI cards:
  - Complaint Count
  - Timely Response Rate
  - Late Response Complaints
  - Operational Risk Score
  - Composite Risk Band
- Monthly Complaint Trend
- Complaint Category Mix
- Top Complaint Issues
- Company Response Outcome Mix

**Business message:**  
This page allows users to investigate a specific company and understand its complaint trend, issue mix, response outcomes, and risk profile.

---

## Page 5: Category & Issue Deep Dive

**Purpose:**  
Analyze root causes, complaint drivers, issue concentration, and narrative complexity.

**Recommended visuals:**

- Complaint Volume by Category
- Average Narrative Complexity by Category
- Top Complaint Issues
- Complaint Driver Decomposition Tree

**Recommended decomposition path:**

`Complaint Count → Company → Complaint Category → Issue → Response Outcome`

**Business message:**  
This page helps users move from “what happened” to “why it happened” by drilling into the major complaint drivers.

---

## Page 6: Data Quality & Governance

**Purpose:**  
Document data assumptions, validation checks, completeness issues, and reporting controls.

**Recommended visuals:**

- KPI cards:
  - Total Records
  - Unique Complaints
  - Missing State
  - Missing State %
  - Web Submission %
  - Date Range
- Data Governance Notes
- Data Quality Control Summary
- Missing State Exceptions by Category
- Complaint Records by Month

**Business message:**  
This page demonstrates finance-ready reporting discipline by documenting assumptions, data limitations, validation checks, and control logic.

---

## Page 7: AI Insights: Risk Drivers

**Purpose:**  
Use Power BI Key Influencers to explore factors associated with high-risk complaints.

**Recommended visuals:**

- Key Influencers of High-Risk Complaints
- KPI cards:
  - High-Risk Complaints
  - High-Risk Rate
  - Late Response Rate
  - Complex Narrative Rate
- Interpretation Note
- High-Risk Complaints by Category
- Directional AI disclaimer

**Business message:**  
This page adds AI-assisted exploratory analysis while clearly stating that Key Influencers results are directional business signals, not causal proof or automated decisioning.

---

# Theme Colors

| Purpose | Hex |
|---|---|
| Header Navy | `#0B1F3A` |
| Primary Blue | `#2563EB` |
| Teal | `#0F766E` |
| Risk Red | `#DC2626` |
| Risk Amber | `#D97706` |
| Page Background | `#F7F9FC` |
| Card Background | `#FFFFFF` |
| Primary Text | `#111827` |
| Secondary Text | `#374151` |
| Muted Text | `#6B7280` |
| Border | `#E5E7EB` |
| Heatmap Low | `#DBEAFE` |
| Heatmap Medium | `#60A5FA` |
| Heatmap High | `#1E3A8A` |

---

# Typography

| Element | Font | Size | Color |
|---|---|---:|---|
| Page title | Segoe UI Semibold | 22–24 px | `#FFFFFF` |
| Page subtitle | Segoe UI | 10.5–11 px | `#D6E4F0` |
| Visual title | Segoe UI Semibold | 11–12 px | `#111827` |
| KPI value | Segoe UI Semibold | 26–32 px | `#0B1F3A` |
| KPI label | Segoe UI | 9.5–10.5 px | `#6B7280` |
| Axis labels | Segoe UI | 8–9 px | `#6B7280` |
| Notes / body text | Segoe UI | 9.5–10.5 px | `#374151` |

---

# Layout Standards

- Canvas size: **16:9**
- Recommended canvas: **1280 × 720**
- Header height: **76 px**
- Page background: `#F7F9FC`
- Visual/card background: `#FFFFFF`
- Visual borders: `#E5E7EB`
- Standard left/right page margin: **24 px**
- Standard spacing between visuals: **16–20 px**
- Slicers should be synced across main report pages where appropriate.
- Page-specific slicers should not be synced unless they support cross-page analysis.

---

# Interaction Standards

- Use synced slicers for:
  - Year
  - Company
  - Complaint Category
  - Response Outcome
  - State
- Use drill-through from company-level visuals to the Company Detail page.
- Use decomposition tree for root-cause exploration.
- Use Key Influencers only as exploratory AI analysis, with an interpretation note.
- Use tooltips to show supporting metrics such as complaint count, late response rate, complex narrative rate, and operational risk score.

---

# Accessibility Notes

- Avoid relying on red/green alone to communicate meaning.
- Use actual values and labels alongside colors.
- Use blue-scale heatmaps for better readability.
- Keep text contrast high.
- Avoid overcrowded legends and unnecessary visual effects.
- Use meaningful page titles, visual titles, and slicer names.