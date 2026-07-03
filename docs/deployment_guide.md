# Deployment Guide

This guide explains how to open, refresh, publish, and share the Power BI report included in this repository.

## 1. Open the Report Locally

1. Clone or download the repository.
2. Open the Power BI file:

   `powerbi/financial_complaint_analytics.pbix`

3. In Power BI Desktop, go to:

   `Home > Transform Data > Data source settings`

4. Confirm that the CSV file paths point to the local repository folder:

   `data/raw/`

5. Refresh the dataset.
6. Review each report page to confirm visuals, slicers, drill-through navigation, and AI visuals load correctly.
7. Save the updated PBIX file.

## 2. Publish to Power BI Service

1. Sign in to Power BI Service.
2. Create or select a workspace, for example:

   `Portfolio - Finance Analytics`

3. From Power BI Desktop, select:

   `Home > Publish`

4. Publish the report to the selected workspace.
5. Open the report in Power BI Service and confirm that all pages render correctly in Reading View.
6. Export a PDF copy for recruiter-facing review if needed.
7. Save final dashboard screenshots for the GitHub README and portfolio materials.

## 3. Scheduled Refresh

The current report uses local CSV files. For scheduled refresh in Power BI Service, move the source files to a supported cloud location such as OneDrive or SharePoint.

After moving the files:

1. Update the Power Query source paths.
2. Republish the PBIX file.
3. Configure dataset credentials in Power BI Service.
4. Test refresh manually before enabling a schedule.