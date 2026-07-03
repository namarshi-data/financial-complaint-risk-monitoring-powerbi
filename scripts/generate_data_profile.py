"""
Generate a markdown data profile for the Financial Complaint Analytics project.

Run:
    python scripts/generate_data_profile.py
"""

from pathlib import Path
import pandas as pd


ROOT = Path(__file__).resolve().parents[1]
RAW = ROOT / "data" / "raw"
DOCS = ROOT / "docs"


def pct(value: float) -> str:
    return f"{value:.1%}"


def main() -> None:
    fact = pd.read_csv(RAW / "fact_complaints.csv")
    fact["Date received"] = pd.to_datetime(fact["Date received"])
    fact["is_late"] = (fact["Timely response?"] == "No").astype(int)
    fact["is_timely"] = (fact["Timely response?"] == "Yes").astype(int)
    fact["is_complex"] = (fact["narrative_word_count"] >= 300).astype(int)
    fact["is_high_risk"] = ((fact["is_late"] == 1) | (fact["is_complex"] == 1)).astype(int)

    top_categories = fact.groupby("label_clean")["Complaint ID"].nunique().sort_values(ascending=False).head(10)
    top_companies = fact.groupby("Company")["Complaint ID"].nunique().sort_values(ascending=False).head(10)

    lines = [
        "# Data Profile",
        "",
        "## Summary",
        "",
        f"- Records: {len(fact):,}",
        f"- Unique complaints: {fact['Complaint ID'].nunique():,}",
        f"- Companies: {fact['Company'].nunique():,}",
        f"- Categories: {fact['label_clean'].nunique():,}",
        f"- Date range: {fact['Date received'].min().date()} to {fact['Date received'].max().date()}",
        f"- Timely response rate: {pct(fact['is_timely'].mean())}",
        f"- Late response rate: {pct(fact['is_late'].mean())}",
        f"- Complex narrative rate: {pct(fact['is_complex'].mean())}",
        f"- High-risk complaint rate: {pct(fact['is_high_risk'].mean())}",
        f"- Missing state rate: {pct(fact['State'].isna().mean())}",
        f"- Web submission rate: {pct((fact['Submitted via'] == 'Web').mean())}",
        "",
        "## Top Categories",
        "",
        "| Category | Complaints |",
        "|---|---:|",
    ]

    for category, count in top_categories.items():
        lines.append(f"| {category} | {count:,} |")

    lines.extend(["", "## Top Companies", "", "| Company | Complaints |", "|---|---:|"])

    for company, count in top_companies.items():
        lines.append(f"| {company} | {count:,} |")

    (DOCS / "data_profile.md").write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"Wrote {DOCS / 'data_profile.md'}")


if __name__ == "__main__":
    main()
