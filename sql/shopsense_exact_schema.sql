-- ============================================================
-- ShopSense: Complete Schema - Generated from actual CSV files
-- Run in Azure SQL Query Editor BEFORE loading any data
-- ============================================================

-- Drop existing tables (safe re-run)
DROP TABLE IF EXISTS dbo.ProductReviews;
DROP TABLE IF EXISTS dbo.Returns;
DROP TABLE IF EXISTS dbo.OrderItems;
DROP TABLE IF EXISTS dbo.Orders;
DROP TABLE IF EXISTS dbo.Products;
DROP TABLE IF EXISTS dbo.Customers;
DROP TABLE IF EXISTS dbo.Sellers;
DROP TABLE IF EXISTS dbo.watermark_control;

-- SELLERS
CREATE TABLE dbo.Sellers (
    SellerID                  VARCHAR(10)    NOT NULL,
    SellerName                NVARCHAR(100),
    SellerEmail               NVARCHAR(100),
    City                      NVARCHAR(100),
    State                     NVARCHAR(100),
    Rating                    DECIMAL(3,1),
    TotalProducts             INT,
    IsActive                  NVARCHAR(100),
    JoinDate                  NVARCHAR(50),
    LastModifiedDate          NVARCHAR(50),
    CONSTRAINT PK_Sellers PRIMARY KEY (SellerID)
);

ALTER TABLE dbo.Sellers ALTER COLUMN JoinDate          DATE;
ALTER TABLE dbo.Sellers ALTER COLUMN LastModifiedDate  DATETIME2;


-- CUSTOMERS
CREATE TABLE dbo.Customers (
    CustomerID                VARCHAR(10)    NOT NULL,
    FirstName                 NVARCHAR(100),
    LastName                  NVARCHAR(100),
    Email                     NVARCHAR(100),
    Phone                     NVARCHAR(100),
    City                      NVARCHAR(100),
    State                     NVARCHAR(100),
    PinCode                   NVARCHAR(100),
    Segment                   NVARCHAR(100),
    IsPrime                   NVARCHAR(100),
    RegistrationDate          NVARCHAR(50),
    LastModifiedDate          NVARCHAR(50),
    CONSTRAINT PK_Customers PRIMARY KEY (CustomerID)
);

ALTER TABLE dbo.Customers ALTER COLUMN RegistrationDate DATE;
ALTER TABLE dbo.Customers ALTER COLUMN LastModifiedDate DATETIME2;

-- PRODUCTS
CREATE TABLE dbo.Products (
    ProductID                 VARCHAR(10)    NOT NULL,
    ProductName               NVARCHAR(200),
    Category                  NVARCHAR(200),
    SubCategory               NVARCHAR(200),
    Brand                     NVARCHAR(200),
    SellerID                  NVARCHAR(200),
    ListPrice                 DECIMAL(10,2),
    CostPrice                 DECIMAL(10,2),
    StockQuantity             INT,
    Rating                    DECIMAL(3,1),
    IsActive                  NVARCHAR(200),
    LaunchDate                NVARCHAR(50),
    LastModifiedDate          NVARCHAR(50),
    CONSTRAINT PK_Products PRIMARY KEY (ProductID)
);

ALTER TABLE dbo.Products ALTER COLUMN LaunchDate       DATE;
ALTER TABLE dbo.Products ALTER COLUMN LastModifiedDate DATETIME2;


-- ORDERS
CREATE TABLE dbo.Orders (
    OrderID                   VARCHAR(20)    NOT NULL,
    CustomerID                NVARCHAR(100),
    SellerID                  NVARCHAR(100),
    OrderDate                 NVARCHAR(50),
    ShippedDate               NVARCHAR(50),
    DeliveredDate             NVARCHAR(50),
    OrderStatus               NVARCHAR(100),
    PaymentMethod             NVARCHAR(100),
    ShippingCity              NVARCHAR(100),
    ShippingState             NVARCHAR(100),
    ShippingPinCode           NVARCHAR(100),
    TotalAmount               DECIMAL(10,2),
    DiscountAmount            DECIMAL(10,2),
    ShippingCharges           DECIMAL(10,2),
    IsPrimeOrder              NVARCHAR(100),
    LastModifiedDate          NVARCHAR(50),
    CONSTRAINT PK_Orders PRIMARY KEY (OrderID)
);

ALTER TABLE dbo.Orders ALTER COLUMN OrderDate        DATETIME2;
ALTER TABLE dbo.Orders ALTER COLUMN ShippedDate      DATETIME2;
ALTER TABLE dbo.Orders ALTER COLUMN DeliveredDate    DATETIME2;
ALTER TABLE dbo.Orders ALTER COLUMN LastModifiedDate DATETIME2;



SELECT
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'ProductReviews'

select * from orders


-- ORDER ITEMS
CREATE TABLE dbo.OrderItems (
    OrderItemID               VARCHAR(25)    NOT NULL,
    OrderID                   NVARCHAR(100),
    ProductID                 NVARCHAR(100),
    SellerID                  NVARCHAR(100),
    Quantity                  INT,
    UnitPrice                 DECIMAL(10,2),
    DiscountAmount            DECIMAL(10,2),
    TotalPrice                DECIMAL(10,2),
    Category                  NVARCHAR(100),
    IsGift                    NVARCHAR(100),
    LastModifiedDate          NVARCHAR(50),
    CONSTRAINT PK_OrderItems PRIMARY KEY (OrderItemID)
);

ALTER TABLE dbo.OrderItems ALTER COLUMN LastModifiedDate DATETIME2;

-- Fix empty strings to NULL in OrderItems
UPDATE dbo.OrderItems SET LastModifiedDate = NULL WHERE LastModifiedDate = '';



select * from dbo.Returns



-- RETURNS
CREATE TABLE dbo.Returns (
    ReturnID                  VARCHAR(15)    NOT NULL,
    OrderID                   NVARCHAR(100),
    CustomerID                NVARCHAR(100),
    ReturnDate                NVARCHAR(50),
    ReturnReason              NVARCHAR(100),
    ReturnStatus              NVARCHAR(100),
    RefundAmount              DECIMAL(10,2),
    RefundDate                NVARCHAR(50),
    RefundMethod              NVARCHAR(100),
    ConditionOnReturn         NVARCHAR(100),
    LastModifiedDate          NVARCHAR(50),
    CONSTRAINT PK_Returns PRIMARY KEY (ReturnID)
);

-- ============================================================
-- FIX RETURNS TABLE
-- ============================================================

ALTER TABLE dbo.Returns ALTER COLUMN ReturnDate        DATETIME2;
ALTER TABLE dbo.Returns ALTER COLUMN RefundDate        DATETIME2;
ALTER TABLE dbo.Returns ALTER COLUMN LastModifiedDate  DATETIME2;

select * from returns 

-- PRODUCT REVIEWS (API source simulation)
CREATE TABLE dbo.ProductReviews (
    ReviewID                  VARCHAR(15)    NOT NULL,
    ProductID                 NVARCHAR(200),
    CustomerID                NVARCHAR(200),
    Rating                    INT,
    ReviewTitle               NVARCHAR(200),
    ReviewText                NVARCHAR(500),
    ReviewDate                NVARCHAR(50),
    IsVerifiedPurchase        NVARCHAR(200),
    HelpfulVotes              INT,
    Source                    NVARCHAR(200),
    LastModifiedDate          NVARCHAR(50),
    CONSTRAINT PK_ProductReviews PRIMARY KEY (ReviewID)
);
ALTER TABLE dbo.ProductReviews ALTER COLUMN ReviewDate  DATE;
ALTER TABLE dbo.ProductReviews ALTER COLUMN LastModifiedDate DATETIME2;


