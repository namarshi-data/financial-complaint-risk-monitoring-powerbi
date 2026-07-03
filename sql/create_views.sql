/*
================================================================================
Financial Complaint Analytics & Risk Monitoring Dashboard
MySQL Workbench Professional View Layer
================================================================================

Dialect:
    MySQL / MySQL Workbench

Purpose:
    1. Clean and standardize complaint-level source data.
    2. Create reusable reporting views for Power BI and QA validation.
    3. Support finance-style KPI reporting, risk monitoring, and governance checks.

Source table:
    fact_complaints

================================================================================
*/


/*==============================================================================
0. Drop Existing Views
Run in reverse dependency order so the script can be rerun safely.
==============================================================================*/

DROP VIEW IF EXISTS vw_missing_state_exceptions;
DROP VIEW IF EXISTS vw_data_quality_summary;
DROP VIEW IF EXISTS vw_portfolio_summary;
DROP VIEW IF EXISTS vw_category_summary;
DROP VIEW IF EXISTS vw_company_risk_summary;
DROP VIEW IF EXISTS vw_company_risk_summary_base;
DROP VIEW IF EXISTS vw_company_category_kpis;
DROP VIEW IF EXISTS vw_monthly_complaint_kpis;
DROP VIEW IF EXISTS vw_dim_channel;
DROP VIEW IF EXISTS vw_dim_response;
DROP VIEW IF EXISTS vw_dim_state;
DROP VIEW IF EXISTS vw_dim_category;
DROP VIEW IF EXISTS vw_dim_company;
DROP VIEW IF EXISTS vw_dim_date;
DROP VIEW IF EXISTS vw_fact_complaints_clean;


/*==============================================================================
1. Clean Complaint-Level Fact View
==============================================================================*/

CREATE VIEW vw_fact_complaints_clean AS
SELECT
    standardized.complaint_id,
    standardized.date_received,
    standardized.month_start,
    standardized.complaint_year,

    standardized.product,
    standardized.issue,
    standardized.company,
    standardized.state_clean,
    standardized.submitted_via,
    standardized.company_response,
    standardized.timely_response,

    standardized.narrative_word_count,
    standardized.category_key,

    CASE
        WHEN standardized.category_key = 'credit_reporting' THEN 'Credit Reporting'
        WHEN standardized.category_key = 'debt_collection' THEN 'Debt Collection'
        WHEN standardized.category_key = 'credit_card_or_prepaid_card' THEN 'Credit Card / Prepaid Card'
        WHEN standardized.category_key = 'mortgage' THEN 'Mortgage'
        WHEN standardized.category_key = 'bank_account' THEN 'Bank Account'
        WHEN standardized.category_key = 'student_loan' THEN 'Student Loan'
        WHEN standardized.category_key = 'money_transfer' THEN 'Money Transfer'
        WHEN standardized.category_key = 'vehicle_loan_or_lease' THEN 'Vehicle Loan / Lease'
        WHEN standardized.category_key = 'payday_loan_title_loan_or_personal_loan' THEN 'Payday / Title / Personal Loan'
        WHEN standardized.category_key = 'consumer_loan' THEN 'Consumer Loan'
        WHEN standardized.category_key = 'unknown' THEN 'Unknown'
        ELSE standardized.category_key
    END AS category_standardized,

    CASE
        WHEN UPPER(standardized.timely_response) = 'YES' THEN 1
        ELSE 0
    END AS is_timely,

    CASE
        WHEN UPPER(standardized.timely_response) = 'NO' THEN 1
        ELSE 0
    END AS is_late,

    CASE
        WHEN COALESCE(standardized.narrative_word_count, 0) >= 500 THEN 'Very Complex'
        WHEN COALESCE(standardized.narrative_word_count, 0) >= 300 THEN 'Complex'
        WHEN COALESCE(standardized.narrative_word_count, 0) >= 100 THEN 'Moderate'
        ELSE 'Low'
    END AS narrative_complexity_band,

    CASE
        WHEN COALESCE(standardized.narrative_word_count, 0) >= 300 THEN 1
        ELSE 0
    END AS is_complex_narrative,

    CASE
        WHEN UPPER(standardized.timely_response) = 'NO'
            OR COALESCE(standardized.narrative_word_count, 0) >= 300
        THEN 1
        ELSE 0
    END AS is_high_risk,

    CASE
        WHEN UPPER(standardized.timely_response) = 'NO'
            OR COALESCE(standardized.narrative_word_count, 0) >= 300
        THEN 'High Risk'
        ELSE 'Not High Risk'
    END AS high_risk_status,

    CASE
        WHEN standardized.complaint_id IS NULL THEN 1
        ELSE 0
    END AS is_missing_complaint_id,

    CASE
        WHEN standardized.date_received IS NULL THEN 1
        ELSE 0
    END AS is_missing_or_invalid_date,

    CASE
        WHEN standardized.state_clean = 'Unknown' THEN 1
        ELSE 0
    END AS is_missing_state

FROM
    (
        SELECT
            source_clean.complaint_id,
            source_clean.date_received,

            CASE
                WHEN source_clean.date_received IS NOT NULL
                    THEN STR_TO_DATE(
                        CONCAT(
                            YEAR(source_clean.date_received),
                            '-',
                            LPAD(MONTH(source_clean.date_received), 2, '0'),
                            '-01'
                        ),
                        '%Y-%m-%d'
                    )
                ELSE NULL
            END AS month_start,

            CASE
                WHEN source_clean.date_received IS NOT NULL
                    THEN YEAR(source_clean.date_received)
                ELSE NULL
            END AS complaint_year,

            source_clean.product,
            source_clean.issue,
            source_clean.company,

            CASE
                WHEN source_clean.state_raw IS NULL THEN 'Unknown'
                ELSE UPPER(source_clean.state_raw)
            END AS state_clean,

            source_clean.submitted_via_raw AS submitted_via,
            source_clean.company_response_raw AS company_response,
            source_clean.timely_response_raw AS timely_response,
            source_clean.narrative_word_count_raw AS narrative_word_count,

            CASE
                WHEN source_clean.label_clean_raw = 'money_transfers' THEN 'money_transfer'
                WHEN source_clean.label_clean_raw IS NULL THEN 'unknown'
                ELSE source_clean.label_clean_raw
            END AS category_key

        FROM
            (
                SELECT
                    CASE
                        WHEN NULLIF(TRIM(CAST(`Complaint ID` AS CHAR)), '') REGEXP '^[0-9]+$'
                            THEN CAST(NULLIF(TRIM(CAST(`Complaint ID` AS CHAR)), '') AS UNSIGNED)
                        ELSE NULL
                    END AS complaint_id,

                    CASE
                        WHEN NULLIF(TRIM(CAST(`Date received` AS CHAR)), '') REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}'
                            THEN STR_TO_DATE(LEFT(TRIM(CAST(`Date received` AS CHAR)), 10), '%Y-%m-%d')
                        WHEN NULLIF(TRIM(CAST(`Date received` AS CHAR)), '') REGEXP '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}$'
                            THEN STR_TO_DATE(TRIM(CAST(`Date received` AS CHAR)), '%c/%e/%Y')
                        ELSE NULL
                    END AS date_received,

                    NULLIF(TRIM(`Product`), '') AS product,
                    NULLIF(TRIM(`Issue`), '') AS issue,
                    NULLIF(TRIM(`Company`), '') AS company,

                    NULLIF(TRIM(`State`), '') AS state_raw,
                    NULLIF(TRIM(`Submitted via`), '') AS submitted_via_raw,
                    NULLIF(TRIM(`Company response to consumer`), '') AS company_response_raw,
                    NULLIF(TRIM(`Timely response?`), '') AS timely_response_raw,

                    CASE
                        WHEN NULLIF(TRIM(CAST(`narrative_word_count` AS CHAR)), '') REGEXP '^[0-9]+$'
                            THEN CAST(NULLIF(TRIM(CAST(`narrative_word_count` AS CHAR)), '') AS UNSIGNED)
                        ELSE NULL
                    END AS narrative_word_count_raw,

                    LOWER(NULLIF(TRIM(`label_clean`), '')) AS label_clean_raw

                FROM fact_complaints
            ) AS source_clean
    ) AS standardized;


/*==============================================================================
2. Dimension Views
==============================================================================*/

CREATE TABLE dim_date AS
SELECT DISTINCT
    date_received,
    month_start,
    complaint_year,
    MONTH(date_received) AS month_number,
    MONTHNAME(date_received) AS month_name,
    CONCAT(
        YEAR(date_received),
        '-',
        LPAD(MONTH(date_received), 2, '0')
    ) AS `year_month`
FROM vw_fact_complaints_clean
WHERE date_received IS NOT NULL;


CREATE VIEW vw_dim_company AS
SELECT DISTINCT
    company
FROM vw_fact_complaints_clean
WHERE company IS NOT NULL;


CREATE VIEW vw_dim_category AS
SELECT DISTINCT
    category_key,
    category_standardized
FROM vw_fact_complaints_clean
WHERE category_key IS NOT NULL;


CREATE VIEW vw_dim_state AS
SELECT DISTINCT
    state_clean,
    CASE
        WHEN state_clean = 'Unknown' THEN 'Missing / Unknown'
        ELSE 'Available'
    END AS state_data_status
FROM vw_fact_complaints_clean;


CREATE VIEW vw_dim_response AS
SELECT DISTINCT
    company_response
FROM vw_fact_complaints_clean
WHERE company_response IS NOT NULL;


CREATE VIEW vw_dim_channel AS
SELECT DISTINCT
    submitted_via
FROM vw_fact_complaints_clean
WHERE submitted_via IS NOT NULL;


/*==============================================================================
3. Monthly Complaint KPI View
==============================================================================*/

CREATE VIEW vw_monthly_complaint_kpis AS
SELECT
    month_start,
    complaint_year,
    category_key,
    category_standardized,

    COUNT(DISTINCT complaint_id) AS complaint_count,
    COUNT(DISTINCT CASE WHEN is_timely = 1 THEN complaint_id END) AS timely_response_count,
    COUNT(DISTINCT CASE WHEN is_late = 1 THEN complaint_id END) AS late_response_count,
    COUNT(DISTINCT CASE WHEN is_complex_narrative = 1 THEN complaint_id END) AS complex_narrative_count,
    COUNT(DISTINCT CASE WHEN is_high_risk = 1 THEN complaint_id END) AS high_risk_count,

    AVG(CAST(narrative_word_count AS DECIMAL(18, 4))) AS avg_narrative_word_count,

    COUNT(DISTINCT CASE WHEN is_timely = 1 THEN complaint_id END) * 1.0
        / NULLIF(COUNT(DISTINCT complaint_id), 0) AS timely_response_rate,

    COUNT(DISTINCT CASE WHEN is_late = 1 THEN complaint_id END) * 1.0
        / NULLIF(COUNT(DISTINCT complaint_id), 0) AS late_response_rate,

    COUNT(DISTINCT CASE WHEN is_complex_narrative = 1 THEN complaint_id END) * 1.0
        / NULLIF(COUNT(DISTINCT complaint_id), 0) AS complex_narrative_rate,

    COUNT(DISTINCT CASE WHEN is_high_risk = 1 THEN complaint_id END) * 1.0
        / NULLIF(COUNT(DISTINCT complaint_id), 0) AS high_risk_rate

FROM vw_fact_complaints_clean
GROUP BY
    month_start,
    complaint_year,
    category_key,
    category_standardized;


/*==============================================================================
4. Company and Category KPI View
==============================================================================*/

CREATE VIEW vw_company_category_kpis AS
SELECT
    company,
    category_key,
    category_standardized,

    COUNT(DISTINCT complaint_id) AS complaint_count,
    COUNT(DISTINCT CASE WHEN is_timely = 1 THEN complaint_id END) AS timely_response_count,
    COUNT(DISTINCT CASE WHEN is_late = 1 THEN complaint_id END) AS late_response_count,
    COUNT(DISTINCT CASE WHEN is_complex_narrative = 1 THEN complaint_id END) AS complex_narrative_count,
    COUNT(DISTINCT CASE WHEN is_high_risk = 1 THEN complaint_id END) AS high_risk_count,

    AVG(CAST(narrative_word_count AS DECIMAL(18, 4))) AS avg_narrative_word_count,

    COUNT(DISTINCT CASE WHEN is_timely = 1 THEN complaint_id END) * 1.0
        / NULLIF(COUNT(DISTINCT complaint_id), 0) AS timely_response_rate,

    COUNT(DISTINCT CASE WHEN is_late = 1 THEN complaint_id END) * 1.0
        / NULLIF(COUNT(DISTINCT complaint_id), 0) AS late_response_rate,

    COUNT(DISTINCT CASE WHEN is_complex_narrative = 1 THEN complaint_id END) * 1.0
        / NULLIF(COUNT(DISTINCT complaint_id), 0) AS complex_narrative_rate,

    COUNT(DISTINCT CASE WHEN is_high_risk = 1 THEN complaint_id END) * 1.0
        / NULLIF(COUNT(DISTINCT complaint_id), 0) AS high_risk_rate

FROM vw_fact_complaints_clean
WHERE company IS NOT NULL
GROUP BY
    company,
    category_key,
    category_standardized;


/*==============================================================================
5. Company Risk Summary Base View
This base view calculates risk metrics without ranking.
==============================================================================*/

CREATE VIEW vw_company_risk_summary_base AS
SELECT
    scored.company,
    scored.complaint_count,
    scored.complaint_share,

    scored.timely_response_count,
    scored.late_response_count,
    scored.complex_narrative_count,
    scored.high_risk_count,

    scored.timely_response_rate,
    scored.late_response_rate,
    scored.complex_narrative_rate,
    scored.high_risk_rate,

    scored.avg_narrative_word_count,
    scored.operational_risk_score,

    CASE
        WHEN scored.late_response_rate >= 0.10
            OR scored.operational_risk_score >= 35
        THEN 'High'
        WHEN scored.late_response_rate >= 0.03
            OR scored.operational_risk_score >= 15
        THEN 'Medium'
        ELSE 'Low'
    END AS composite_risk_band

FROM
    (
        SELECT
            rate_calc.company,
            rate_calc.complaint_count,
            rate_calc.complaint_share,

            rate_calc.timely_response_count,
            rate_calc.late_response_count,
            rate_calc.complex_narrative_count,
            rate_calc.high_risk_count,

            rate_calc.timely_response_rate,
            rate_calc.late_response_rate,
            rate_calc.complex_narrative_rate,
            rate_calc.high_risk_rate,

            rate_calc.avg_narrative_word_count,

            (
                COALESCE(rate_calc.complaint_share, 0) * 100 * 0.35
                + COALESCE(rate_calc.late_response_rate, 0) * 100 * 0.35
                + COALESCE(rate_calc.complex_narrative_rate, 0) * 100 * 0.30
            ) AS operational_risk_score

        FROM
            (
                SELECT
                    company_summary.company,
                    company_summary.complaint_count,
                    company_summary.timely_response_count,
                    company_summary.late_response_count,
                    company_summary.complex_narrative_count,
                    company_summary.high_risk_count,
                    company_summary.avg_narrative_word_count,

                    company_summary.timely_response_count * 1.0
                        / NULLIF(company_summary.complaint_count, 0) AS timely_response_rate,

                    company_summary.late_response_count * 1.0
                        / NULLIF(company_summary.complaint_count, 0) AS late_response_rate,

                    company_summary.complex_narrative_count * 1.0
                        / NULLIF(company_summary.complaint_count, 0) AS complex_narrative_rate,

                    company_summary.high_risk_count * 1.0
                        / NULLIF(company_summary.complaint_count, 0) AS high_risk_rate,

                    company_summary.complaint_count * 1.0
                        / NULLIF(total_summary.total_complaints, 0) AS complaint_share

                FROM
                    (
                        SELECT
                            company,

                            COUNT(DISTINCT complaint_id) AS complaint_count,
                            COUNT(DISTINCT CASE WHEN is_timely = 1 THEN complaint_id END) AS timely_response_count,
                            COUNT(DISTINCT CASE WHEN is_late = 1 THEN complaint_id END) AS late_response_count,
                            COUNT(DISTINCT CASE WHEN is_complex_narrative = 1 THEN complaint_id END) AS complex_narrative_count,
                            COUNT(DISTINCT CASE WHEN is_high_risk = 1 THEN complaint_id END) AS high_risk_count,

                            AVG(CAST(narrative_word_count AS DECIMAL(18, 4))) AS avg_narrative_word_count

                        FROM vw_fact_complaints_clean
                        WHERE company IS NOT NULL
                        GROUP BY company
                    ) AS company_summary

                CROSS JOIN
                    (
                        SELECT
                            COUNT(DISTINCT complaint_id) AS total_complaints
                        FROM vw_fact_complaints_clean
                        WHERE company IS NOT NULL
                    ) AS total_summary
            ) AS rate_calc
    ) AS scored;


/*==============================================================================
6. Company Risk Summary View
This final view adds dense-rank-style rankings without DENSE_RANK().
==============================================================================*/

CREATE VIEW vw_company_risk_summary AS
SELECT
    base.company,
    base.complaint_count,
    base.complaint_share,

    base.timely_response_count,
    base.late_response_count,
    base.complex_narrative_count,
    base.high_risk_count,

    base.timely_response_rate,
    base.late_response_rate,
    base.complex_narrative_rate,
    base.high_risk_rate,

    base.avg_narrative_word_count,
    base.operational_risk_score,
    base.composite_risk_band,

    (
        SELECT
            COUNT(DISTINCT higher.complaint_count) + 1
        FROM vw_company_risk_summary_base AS higher
        WHERE higher.complaint_count > base.complaint_count
    ) AS complaint_volume_rank,

    (
        SELECT
            COUNT(DISTINCT higher.operational_risk_score) + 1
        FROM vw_company_risk_summary_base AS higher
        WHERE higher.operational_risk_score > base.operational_risk_score
    ) AS operational_risk_rank

FROM vw_company_risk_summary_base AS base;


/*==============================================================================
7. Category Summary View
==============================================================================*/

CREATE VIEW vw_category_summary AS
SELECT
    category_key,
    category_standardized,

    COUNT(DISTINCT complaint_id) AS complaint_count,
    COUNT(DISTINCT CASE WHEN is_late = 1 THEN complaint_id END) AS late_response_count,
    COUNT(DISTINCT CASE WHEN is_complex_narrative = 1 THEN complaint_id END) AS complex_narrative_count,
    COUNT(DISTINCT CASE WHEN is_high_risk = 1 THEN complaint_id END) AS high_risk_count,

    AVG(CAST(narrative_word_count AS DECIMAL(18, 4))) AS avg_narrative_word_count,

    COUNT(DISTINCT CASE WHEN is_late = 1 THEN complaint_id END) * 1.0
        / NULLIF(COUNT(DISTINCT complaint_id), 0) AS late_response_rate,

    COUNT(DISTINCT CASE WHEN is_complex_narrative = 1 THEN complaint_id END) * 1.0
        / NULLIF(COUNT(DISTINCT complaint_id), 0) AS complex_narrative_rate,

    COUNT(DISTINCT CASE WHEN is_high_risk = 1 THEN complaint_id END) * 1.0
        / NULLIF(COUNT(DISTINCT complaint_id), 0) AS high_risk_rate

FROM vw_fact_complaints_clean
GROUP BY
    category_key,
    category_standardized;


/*==============================================================================
8. Portfolio Summary View
==============================================================================*/

CREATE VIEW vw_portfolio_summary AS
SELECT
    base.total_records,
    base.unique_complaints,
    base.company_count,
    base.category_count,

    base.timely_response_count,
    base.late_response_count,
    base.complex_narrative_count,
    base.high_risk_count,

    base.min_complaint_date,
    base.max_complaint_date,

    top_10.top_10_company_complaints,

    base.timely_response_count * 1.0
        / NULLIF(base.unique_complaints, 0) AS timely_response_rate,

    base.late_response_count * 1.0
        / NULLIF(base.unique_complaints, 0) AS late_response_rate,

    base.complex_narrative_count * 1.0
        / NULLIF(base.unique_complaints, 0) AS complex_narrative_rate,

    base.high_risk_count * 1.0
        / NULLIF(base.unique_complaints, 0) AS high_risk_rate,

    top_10.top_10_company_complaints * 1.0
        / NULLIF(base.unique_complaints, 0) AS top_10_company_concentration_rate

FROM
    (
        SELECT
            COUNT(*) AS total_records,
            COUNT(DISTINCT complaint_id) AS unique_complaints,

            COUNT(DISTINCT company) AS company_count,
            COUNT(DISTINCT category_key) AS category_count,

            COUNT(DISTINCT CASE WHEN is_timely = 1 THEN complaint_id END) AS timely_response_count,
            COUNT(DISTINCT CASE WHEN is_late = 1 THEN complaint_id END) AS late_response_count,
            COUNT(DISTINCT CASE WHEN is_complex_narrative = 1 THEN complaint_id END) AS complex_narrative_count,
            COUNT(DISTINCT CASE WHEN is_high_risk = 1 THEN complaint_id END) AS high_risk_count,

            MIN(date_received) AS min_complaint_date,
            MAX(date_received) AS max_complaint_date

        FROM vw_fact_complaints_clean
    ) AS base

CROSS JOIN
    (
        SELECT
            SUM(company_top_10.complaint_count) AS top_10_company_complaints
        FROM
            (
                SELECT
                    company,
                    complaint_count
                FROM vw_company_risk_summary_base
                ORDER BY complaint_count DESC, company ASC
                LIMIT 10
            ) AS company_top_10
    ) AS top_10;


/*==============================================================================
9. Data Quality Summary View
==============================================================================*/

CREATE VIEW vw_data_quality_summary AS
SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT complaint_id) AS unique_complaints,
    COUNT(*) - COUNT(DISTINCT complaint_id) AS duplicate_complaint_records,

    SUM(is_missing_complaint_id) AS missing_complaint_id_records,
    SUM(is_missing_or_invalid_date) AS missing_or_invalid_date_records,
    SUM(is_missing_state) AS missing_state_records,

    SUM(CASE WHEN UPPER(submitted_via) = 'WEB' THEN 1 ELSE 0 END) AS web_submission_records,

    COUNT(DISTINCT CASE WHEN is_timely = 1 THEN complaint_id END) AS timely_response_count,
    COUNT(DISTINCT CASE WHEN is_late = 1 THEN complaint_id END) AS late_response_count,
    COUNT(DISTINCT CASE WHEN is_complex_narrative = 1 THEN complaint_id END) AS complex_narrative_count,
    COUNT(DISTINCT CASE WHEN is_high_risk = 1 THEN complaint_id END) AS high_risk_count,

    MIN(date_received) AS min_complaint_date,
    MAX(date_received) AS max_complaint_date,

    SUM(is_missing_state) * 1.0
        / NULLIF(COUNT(*), 0) AS missing_state_rate,

    SUM(CASE WHEN UPPER(submitted_via) = 'WEB' THEN 1 ELSE 0 END) * 1.0
        / NULLIF(COUNT(*), 0) AS web_submission_rate,

    COUNT(DISTINCT CASE WHEN is_timely = 1 THEN complaint_id END) * 1.0
        / NULLIF(COUNT(DISTINCT complaint_id), 0) AS timely_response_rate,

    COUNT(DISTINCT CASE WHEN is_late = 1 THEN complaint_id END) * 1.0
        / NULLIF(COUNT(DISTINCT complaint_id), 0) AS late_response_rate,

    COUNT(DISTINCT CASE WHEN is_high_risk = 1 THEN complaint_id END) * 1.0
        / NULLIF(COUNT(DISTINCT complaint_id), 0) AS high_risk_rate

FROM vw_fact_complaints_clean;


/*==============================================================================
10. Missing State Exceptions View
==============================================================================*/

CREATE VIEW vw_missing_state_exceptions AS
SELECT
    category_key,
    category_standardized,
    COUNT(DISTINCT complaint_id) AS missing_state_complaints
FROM vw_fact_complaints_clean
WHERE state_clean = 'Unknown'
GROUP BY
    category_key,
    category_standardized;


/*==============================================================================
11. Validation Queries
Run these queries after creating the views.
==============================================================================*/

/*
SELECT *
FROM vw_portfolio_summary;

SELECT *
FROM vw_data_quality_summary;

SELECT
    company,
    complaint_count,
    late_response_count,
    high_risk_count,
    ROUND(operational_risk_score, 1) AS operational_risk_score,
    composite_risk_band
FROM vw_company_risk_summary
ORDER BY complaint_count DESC, company ASC
LIMIT 10;

SELECT
    category_standardized,
    complaint_count,
    high_risk_count,
    ROUND(high_risk_rate * 100, 1) AS high_risk_rate_pct
FROM vw_category_summary
ORDER BY complaint_count DESC;

SELECT
    month_start,
    category_standardized,
    complaint_count,
    ROUND(timely_response_rate * 100, 1) AS timely_response_rate_pct,
    ROUND(high_risk_rate * 100, 1) AS high_risk_rate_pct
FROM vw_monthly_complaint_kpis
ORDER BY month_start, category_standardized;
*/


/*==============================================================================
12. Optional Performance Recommendations
Create indexes on the raw table only if this project is moved to a larger database.
Do not create indexes blindly on small portfolio datasets.
==============================================================================*/

/*
CREATE INDEX ix_fact_complaints_complaint_id
ON fact_complaints (`Complaint ID`);

CREATE INDEX ix_fact_complaints_date_received
ON fact_complaints (`Date received`);

CREATE INDEX ix_fact_complaints_company
ON fact_complaints (`Company`);

CREATE INDEX ix_fact_complaints_category
ON fact_complaints (`label_clean`);
*/
