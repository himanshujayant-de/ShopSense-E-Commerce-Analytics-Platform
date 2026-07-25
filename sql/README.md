# SQL Scripts
This folder contains the SQL scripts used in the ShopSense data engineering project.

## Main SQL Tables

The project uses the following source tables:

- Customers
- Products
- Sellers
- Orders
- OrderItems
- Returns

## CDC-Enabled Tables

CDC is mainly used for:

- Orders
- OrderItems
- Returns

Static or full-referesh processing is used for:

- Customers
- Products
- Sellers

  

1.cdc_test_all_tables.sql

This script generates INSERT, UPDATE and DELETE operations for the Orders, OrderItems and Returns tables.

It is used to simulate real-time business changes and verify that Azure SQL Change Data Capture records the changes correctly.

2. ADF_CDC_Test.sql
This script contains controlled CDC test records used to test the Azure Data Factory CDC pipelines.

It inserts, updates and deletes test records and verifies the captured operations from the SQL CDC change tables.



## Execution Notes

- Run these scripts in Azure SQL Database or SQL Server Management Studio.
- Ensure CDC is enabled before executing the test changes.
- Run the ADF CDC pipeline before generating new source changes.
- Use test IDs only to avoid affecting the original project data.


