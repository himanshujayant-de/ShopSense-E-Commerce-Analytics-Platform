## ADF Responsibilities

Azure Data Factory is used for:

- Loading initial CSV files from ADLS Gen2 into Azure SQL Database
- Full-load ingestion for static source tables
- CDC-based incremental ingestion for Orders, OrderItems and Returns
- Loading raw data into the Bronze layer
- Scheduling and orchestrating ingestion pipelines


# Azure Data Factory

This folder contains the exported Azure Data Factory ARM template used in the ShopSense data engineering project.

## Files

### `ARMTemplateForFactory.json`

Contains the main Azure Data Factory resource definitions, including pipelines, datasets, linked services, triggers and other factory objects.

### `ARMTemplateParametersForFactory.json`

Contains deployment parameters used by the ARM template.
