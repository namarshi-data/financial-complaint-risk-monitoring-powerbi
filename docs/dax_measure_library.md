# DAX Measure Library

Use these measures in a dedicated Power BI measure table named `_Measures`.

> **Important:** Calculated columns should be created inside `Fact_Complaints`, not inside `_Measures`.

---

## 1. Core Volume Measures

### Complaint Count

```DAX
Complaint Count =
COALESCE (
    DISTINCTCOUNT ( Fact_Complaints[Complaint ID] ),
    0
)
```

### Total Complaints

Optional alias if older report visuals still use `[Total Complaints]`.

```DAX
Total Complaints =
[Complaint Count]
```

### Total Records

```DAX
Total Records =
COUNTROWS ( Fact_Complaints )
```

### Timely Response Complaints

```DAX
Timely Response Complaints =
COALESCE (
    CALCULATE (
        [Complaint Count],
        Fact_Complaints[IsTimely] = 1
    ),
    0
)
```

### Late Response Complaints

```DAX
Late Response Complaints =
COALESCE (
    CALCULATE (
        [Complaint Count],
        Fact_Complaints[IsLate] = 1
    ),
    0
)
```

### Company Count

```DAX
Company Count =
DISTINCTCOUNT ( Fact_Complaints[Company] )
```

### Complaint Category Count

```DAX
Complaint Category Count =
DISTINCTCOUNT ( Fact_Complaints[Category Standardized] )
```

---

## 2. Rate Measures

### Timely Response Rate

```DAX
Timely Response Rate =
DIVIDE (
    [Timely Response Complaints],
    [Complaint Count]
)
```

### Late Response Rate

```DAX
Late Response Rate =
DIVIDE (
    [Late Response Complaints],
    [Complaint Count]
)
```

### Complaint Share

```DAX
Complaint Share =
DIVIDE (
    [Complaint Count],
    CALCULATE (
        [Complaint Count],
        ALLSELECTED ( Dim_Company[Company] )
    )
)
```

---

## 3. Narrative Complexity Measures

### Avg Complaint Narrative Length

```DAX
Avg Complaint Narrative Length =
AVERAGE ( Fact_Complaints[narrative_word_count] )
```

### Complex Narrative Complaints

```DAX
Complex Narrative Complaints =
COALESCE (
    CALCULATE (
        [Complaint Count],
        Fact_Complaints[narrative_word_count] >= 300
    ),
    0
)
```

### Complex Narrative Rate

```DAX
Complex Narrative Rate =
DIVIDE (
    [Complex Narrative Complaints],
    [Complaint Count]
)
```

---

## 4. High-Risk Complaint Logic

Create these calculated columns in `Fact_Complaints`.

### HighRiskFlag

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

### High Risk Status

Use this column for the Key Influencers visual.

```DAX
High Risk Status =
IF (
    Fact_Complaints[HighRiskFlag] = 1,
    "High Risk",
    "Not High Risk"
)
```

### Narrative Complexity Band

Use this column to make AI visual interpretation cleaner.

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

Create these measures in `_Measures`.

### High-Risk Complaints

```DAX
High-Risk Complaints =
COALESCE (
    CALCULATE (
        [Complaint Count],
        Fact_Complaints[HighRiskFlag] = 1
    ),
    0
)
```

### High-Risk Complaint Rate

```DAX
High-Risk Complaint Rate =
DIVIDE (
    [High-Risk Complaints],
    [Complaint Count]
)
```

Format as **Percentage, 1 decimal place**.

---

## 5. Company Concentration Measures

### Company Complaint Rank

```DAX
Company Complaint Rank =
RANKX (
    ALLSELECTED ( Dim_Company[Company] ),
    [Complaint Count],
    ,
    DESC,
    DENSE
)
```

### Category Complaint Rank

```DAX
Category Complaint Rank =
RANKX (
    ALLSELECTED ( Dim_Category[Complaint Category] ),
    [Complaint Count],
    ,
    DESC,
    DENSE
)
```

### Top 10 Company Complaints

```DAX
Top 10 Company Complaints =
VAR TopCompanies =
    TOPN (
        10,
        ALLSELECTED ( Dim_Company[Company] ),
        [Complaint Count],
        DESC
    )
RETURN
    CALCULATE (
        [Complaint Count],
        KEEPFILTERS ( TopCompanies )
    )
```

### Top 10 Company Concentration Rate

```DAX
Top 10 Company Concentration Rate =
DIVIDE (
    [Top 10 Company Complaints],
    CALCULATE (
        [Complaint Count],
        ALLSELECTED ( Dim_Company[Company] )
    )
)
```

### Avg Complaints per Company

```DAX
Avg Complaints per Company =
DIVIDE (
    [Complaint Count],
    [Company Count]
)
```

### Highest Complaint Volume

```DAX
Highest Complaint Volume =
MAXX (
    ALLSELECTED ( Dim_Company[Company] ),
    [Complaint Count]
)
```

---

## 6. Trend Measures

### Previous Month Complaints

```DAX
Previous Month Complaints =
CALCULATE (
    [Complaint Count],
    DATEADD ( Dim_Date[Date], -1, MONTH )
)
```

### MoM Complaint Change

```DAX
MoM Complaint Change =
[Complaint Count] - [Previous Month Complaints]
```

### MoM Complaint Change %

```DAX
MoM Complaint Change % =
DIVIDE (
    [MoM Complaint Change],
    [Previous Month Complaints]
)
```

### Rolling 3M Complaints

```DAX
Rolling 3M Complaints =
CALCULATE (
    [Complaint Count],
    DATESINPERIOD (
        Dim_Date[Date],
        MAX ( Dim_Date[Date] ),
        -3,
        MONTH
    )
)
```

---

## 7. Timeliness Target Measures

### Target Timely Rate

```DAX
Target Timely Rate =
0.95
```

### Below Target Timely Rate Marker

Use this measure for red breach markers on the timeliness trend chart.

```DAX
Below Target Timely Rate Marker =
VAR CurrentRate =
    [Timely Response Rate]
VAR TargetRate =
    [Target Timely Rate]
RETURN
    IF (
        NOT ISBLANK ( CurrentRate )
            && CurrentRate < TargetRate,
        CurrentRate,
        BLANK ()
    )
```

---

## 8. Operational Risk Score

### Operational Risk Score

```DAX
Operational Risk Score =
VAR VolumeComponent =
    COALESCE ( [Complaint Share], 0 ) * 100 * 0.35
VAR LateComponent =
    COALESCE ( [Late Response Rate], 0 ) * 100 * 0.35
VAR ComplexityComponent =
    COALESCE ( [Complex Narrative Rate], 0 ) * 100 * 0.30
RETURN
    VolumeComponent + LateComponent + ComplexityComponent
```

### Composite Risk Band

Use **Composite Risk Band** instead of only “Risk Band” because the score combines volume, lateness, and complexity.

```DAX
Composite Risk Band =
SWITCH (
    TRUE (),
    [Late Response Rate] >= 0.10
        || [Operational Risk Score] >= 35, "High",
    [Late Response Rate] >= 0.03
        || [Operational Risk Score] >= 15, "Medium",
    "Low"
)
```

---

## 9. Data Quality & Governance Measures

### Missing State Complaints

```DAX
Missing State Complaints =
COALESCE (
    CALCULATE (
        [Complaint Count],
        FILTER (
            Fact_Complaints,
            ISBLANK ( Fact_Complaints[StateClean] )
                || Fact_Complaints[StateClean] = ""
                || Fact_Complaints[StateClean] = "Unknown"
        )
    ),
    0
)
```

### Missing State Rate

```DAX
Missing State Rate =
DIVIDE (
    [Missing State Complaints],
    [Complaint Count]
)
```

### Min Complaint Date

```DAX
Min Complaint Date =
MIN ( Fact_Complaints[DateReceived] )
```

### Max Complaint Date

```DAX
Max Complaint Date =
MAX ( Fact_Complaints[DateReceived] )
```

### Complaint Date Range

```DAX
Complaint Date Range =
FORMAT ( [Min Complaint Date], "MMM yyyy" )
    & " - "
    & FORMAT ( [Max Complaint Date], "MMM yyyy" )
```

### Web Submission Complaints

```DAX
Web Submission Complaints =
COALESCE (
    CALCULATE (
        [Complaint Count],
        FILTER (
            Fact_Complaints,
            UPPER ( TRIM ( Fact_Complaints[Submitted via] ) ) = "WEB"
        )
    ),
    0
)
```

### Web Submission Rate

```DAX
Web Submission Rate =
DIVIDE (
    [Web Submission Complaints],
    [Complaint Count]
)
```

### Duplicate Complaint Records

```DAX
Duplicate Complaint Records =
[Total Records] - [Complaint Count]
```

### Duplicate Complaint Rate

```DAX
Duplicate Complaint Rate =
DIVIDE (
    [Duplicate Complaint Records],
    [Total Records]
)
```

---

## 10. Conditional Formatting Measures

### Company Risk Bubble Color

```DAX
Company Risk Bubble Color =
IF (
    [Late Response Rate] >= 0.10,
    "#DC2626",
    "#2563EB"
)
```

### Response Outcome Color

```DAX
Response Outcome Color =
VAR Outcome =
    SELECTEDVALUE ( Dim_Response[CompanyResponse] )
RETURN
    SWITCH (
        TRUE (),
        Outcome = "Closed with explanation", "#2563EB",
        Outcome = "Closed with monetary relief", "#15803D",
        Outcome = "Closed with non-monetary relief", "#0F766E",
        Outcome = "Untimely response", "#DC2626",
        "#6B7280"
    )
```

### Heatmap Background Color

```DAX
Heatmap Background Color =
VAR CellValue =
    [Complaint Count]
RETURN
    SWITCH (
        TRUE (),
        ISBLANK ( CellValue ) || CellValue = 0, "#F8FAFC",
        CellValue >= 50, "#1E3A8A",
        CellValue >= 8, "#60A5FA",
        "#DBEAFE"
    )
```

### Heatmap Text Color

```DAX
Heatmap Text Color =
VAR CellValue =
    [Complaint Count]
RETURN
    IF (
        NOT ISBLANK ( CellValue )
            && CellValue >= 50,
        "#FFFFFF",
        "#111827"
    )
```

---

## 11. Final Formatting Recommendations

| Measure | Format |
|---|---|
| Complaint Count | Whole number |
| Company Count | Whole number |
| Timely Response Rate | Percentage, 1 decimal |
| Late Response Rate | Percentage, 1 decimal |
| Top 10 Company Concentration Rate | Percentage, 1 decimal |
| High-Risk Complaint Rate | Percentage, 1 decimal |
| Complex Narrative Rate | Percentage, 1 decimal |
| Missing State Rate | Percentage, 1 decimal |
| Web Submission Rate | Percentage, 1 decimal |
| Operational Risk Score | Decimal, 1 decimal |
| Avg Complaints per Company | Decimal, 1 decimal |
| Avg Complaint Narrative Length | Whole number or 1 decimal |