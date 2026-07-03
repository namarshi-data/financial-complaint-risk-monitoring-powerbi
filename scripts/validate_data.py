"""
Data-quality checks for the Financial Complaint Analytics Power BI project.

Run:
    python scripts/validate_data.py
"""

from pathlib import Path
import sys
import pandas as pd


ROOT = Path(__file__).resolve().parents[1]
RAW = ROOT / "data" / "raw"


def fail(message: str) -> None:
    print(f"[FAIL] {message}")
    sys.exit(1)


def pass_check(message: str) -> None:
    print(f"[PASS] {message}")


def main() -> None:
    fact_path = RAW / "fact_complaints.csv"
    company_summary_path = RAW / "company_category_summary.csv"
    monthly_path = RAW / "monthly_category_kpis.csv"

    for path in [fact_path, company_summary_path, monthly_path]:
        if not path.exists():
            fail(f"Missing required file: {path}")
        pass_check(f"Found {path.name}")

    fact = pd.read_csv(fact_path)
    company_summary = pd.read_csv(company_summary_path)
    monthly = pd.read_csv(monthly_path)

    required_fact_cols = {
        "Complaint ID",
        "Date received",
        "month",
        "Product",
        "label_clean",
        "Issue",
        "Company",
        "State",
        "Submitted via",
        "Company response to consumer",
        "Timely response?",
        "narrative_word_count",
    }

    missing_cols = required_fact_cols.difference(fact.columns)
    if missing_cols:
        fail(f"Fact table missing columns: {sorted(missing_cols)}")
    pass_check("Fact table required columns are present")

    if fact["Complaint ID"].duplicated().any():
        fail("Complaint ID contains duplicates")
    pass_check("Complaint ID uniqueness validated")

    if fact["Complaint ID"].isna().any():
        fail("Complaint ID contains missing values")
    pass_check("Complaint ID has no missing values")

    valid_timely_values = {"Yes", "No"}
    invalid_timely = set(fact["Timely response?"].dropna().unique()).difference(valid_timely_values)
    if invalid_timely:
        fail(f"Invalid Timely response? values: {invalid_timely}")
    pass_check("Timely response values are valid")

    fact["Date received"] = pd.to_datetime(fact["Date received"], errors="coerce")
    if fact["Date received"].isna().any():
        fail("Date received contains invalid dates")
    pass_check("Date received values are valid dates")

    if fact["Submitted via"].nunique(dropna=False) != 1:
        print("[WARN] Submission channel has more than one value; update governance notes if this is expected")
    else:
        pass_check("Submission channel characteristic validated")

    # Reconcile company-category summary
    fact_company_category = (
        fact.groupby(["Company", "label_clean"], dropna=False)
        .agg(complaint_count=("Complaint ID", "nunique"))
        .reset_index()
        .sort_values(["Company", "label_clean"])
        .reset_index(drop=True)
    )

    company_summary_check = (
        company_summary[["Company", "label_clean", "complaint_count"]]
        .sort_values(["Company", "label_clean"])
        .reset_index(drop=True)
    )

    if not fact_company_category.equals(company_summary_check):
        fail("Company/category summary does not reconcile to fact table complaint counts")
    pass_check("Company/category summary reconciles to fact table")

    # Reconcile monthly category summary
    fact["month_check"] = fact["Date received"].dt.to_period("M").astype(str)
    fact_monthly = (
        fact.groupby(["month_check", "label_clean"], dropna=False)
        .agg(complaint_count=("Complaint ID", "nunique"))
        .reset_index()
        .rename(columns={"month_check": "month"})
        .sort_values(["month", "label_clean"])
        .reset_index(drop=True)
    )

    monthly_check = (
        monthly[["month", "label_clean", "complaint_count"]]
        .sort_values(["month", "label_clean"])
        .reset_index(drop=True)
    )

    if not fact_monthly.equals(monthly_check):
        fail("Monthly category KPI table does not reconcile to fact table complaint counts")
    pass_check("Monthly category KPI table reconciles to fact table")

    print("\nAll validation checks completed successfully.")


if __name__ == "__main__":
    main()
