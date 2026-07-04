# Risk Scoring Logic

## High-Risk Complaint Definition

A complaint is classified as high risk if it meets at least one of the following conditions:

- The company response was late
- The complaint narrative contains at least 300 words

This definition is used for KPI reporting, company prioritization, risk monitoring, and the AI Insights page.

## Business Rationale

| Risk Driver | Rationale |
|---|---|
| Late response | Indicates potential service, operational, or process failure |
| Complex narrative | Longer narratives may require more analyst time and may contain more detailed complaint issues |

## Important Interpretation Note

The high-risk flag is an analytical indicator. It is not a regulatory risk classification, legal severity rating, or automated decisioning label.

## Operational Risk Score

The company-level operational risk score combines:

- complaint volume or complaint share
- late response rate
- complex narrative rate

Suggested weighting:

| Component | Weight |
|---|---:|
| Complaint share | 40% |
| Late response rate | 35% |
| Complex narrative rate | 25% |

## Recommended Use

The high-risk flag and operational risk score should be used to:

- prioritize companies for operational review
- identify categories requiring deeper analysis
- monitor late response trends
- support drill-through investigation
- guide management discussion

They should not be used to:

- make automated regulatory conclusions
- classify legal severity
- make customer-level decisions
- replace analyst judgment
