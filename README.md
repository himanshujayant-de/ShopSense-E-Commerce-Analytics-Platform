# ShopSense-E-Commerce-Analytics-Platform
End-to-end Azure data engineering project for e-commerce analytics using Azure SQL CDC, Azure Data Factory, ADLS Gen2, Azure Databricks, PySpark, Delta Lake and Power BI.



## Project Overview
ShopSense is a fictional Amazon India / Flipkart-style e-commerce platform.This project builds a complete data engineering platform that ingests data from multiple sources, transforms it through a medallion architecture, and delivers
analytical dashboards for business decision-making.



## THe project covers
- CDC-based incremental ingestion
- SCD Type 2 for customer history
- PySpark transformations
- Delta Lake tables
- Sales analysis
- Product performance
- Customer RFM segmentation
- Returns analysis
- Cohort retention analysis
- Power BI dashboards




## Architecture

Azure SQL Database  --> ADLS  --> Azure Data Factory -->  ADLS Gen2 Bronze Layer  --> Azure Databricks Silver Layer  --> Azure Databricks Gold Layer  --> Databricks SQL Warehouse --> Power BI Dashboard




<img width="1055" height="1491" alt="image" src="https://github.com/user-attachments/assets/5a1ac30b-6da3-4864-a965-e45e9be9736f" />


## Medallion Architecture

BRONZE (Raw) Exact copy of source data — never modified Parquet format — partitioned by ingestion date Includes CDC change records with operation type
SILVER (Cleaned) Type casting: strings → DATETIME2, DECIMAL, BOOLEAN Deduplication: window functions on primary key Data quality: quarantine for invalid records Enrichment: derived columns (IsDelivered, NetRevenue, etc.) SCD Type 2 on Customers (version history)
GOLD (Aggregated) daily_sales: Revenue by day × category × seller rfm_segments: 1 row per customer with RFM scores product_performance: Revenue, rating, return rate per product returns_analysis: Enriched returns with margin impact customer_cohorts: Monthly retention rates per cohort.



## Key Engineering Patterns

### 1. Change Data Capture (CDC)
SQL Server CDC captures every INSERT, UPDATE, DELETE on transactional
tables. ADF native CDC connector moves changes to ADLS Bronze.
Databricks Silver applies Delta MERGE with soft-delete support.

### 2. SCD Type 2 — Customer History
Customer segment and location changes create new version rows.
SHA-256 hash comparison detects changes efficiently.
Full audit trail: every customer state preserved with valid_from/valid_to.

### 3. RFM Customer Segmentation
Customers scored 1-5 on Recency, Frequency, Monetary dimensions.
Weighted composite score: R=40%, F=35%, M=25%.
10 segments: Champions, Loyal, At Risk, Lost, New Customers, etc.

### 4. Cohort Retention Analysis
Customers grouped by first-order month.
Retention tracked for 6+ months per cohort.
Visualised as a heatmap in Power BI.

### 5. Watermark Incremental Load
Control table tracks last loaded timestamp per source.
ADF Lookup → Copy (WHERE LastModifiedDate > watermark) → StoredProc update.
Proven end-to-end: insert test rows → pipeline pulls only new












