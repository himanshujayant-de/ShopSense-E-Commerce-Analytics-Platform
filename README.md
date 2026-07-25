# ShopSense-E-Commerce-Analytics-Platform
End-to-end Azure data engineering project for e-commerce analytics using Azure SQL CDC, Azure Data Factory, ADLS Gen2, Azure Databricks, PySpark, Delta Lake and Power BI.



## Project Overview
ShopSense is an end-to-end data engineering project built to process and analyse e-commerce data.
The project captures source data changes, stores raw data in the Bronze layer, cleans and transforms it in the Silver layer, creates business-ready Gold tables and finally presents insights through Power BI dashboards.



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


## Architecture

Azure SQL Database  --> ADLS  --> Azure Data Factory -->  ADLS Gen2 Bronze Layer  --> Azure Databricks Silver Layer  --> Azure Databricks Gold Layer  --> Databricks SQL Warehouse --> Power BI Dashboard


<img width="1055" height="1491" alt="image" src="https://github.com/user-attachments/assets/5a1ac30b-6da3-4864-a965-e45e9be9736f" />















