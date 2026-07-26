--Step1  Enable CDC on database
EXEC sys.sp_cdc_enable_db;

--verify it worked 
SELECT name, is_cdc_enabled
FROM sys.databases
WHERE name = 'ss-sql-database';

--Enable CDC on Orders
EXEC sys.sp_cdc_enable_table
    @source_schema = N'dbo',
    @source_name = N'Orders',
    @role_name = NULL,
    @supports_net_changes =1;

EXEC sys.sp_cdc_enable_table
    @source_schema = N'dbo',
    @source_name = N'Orderitems',
    @role_name = NULL,
    @supports_net_changes =1;


EXEC sys.sp_cdc_enable_table
    @source_schema = N'dbo',
    @source_name = N'Returns',
    @role_name = NULL,
    @supports_net_changes = 1;


-- verify CDC is enabled 
SELECT name, is_tracked_by_cdc 
FROM sys.tables
WHERE is_tracked_by_cdc = 1




-- VERIFY: Run after creating all tables
SELECT TABLE_NAME, 
       (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS c 
        WHERE c.TABLE_NAME = t.TABLE_NAME) AS column_count
FROM INFORMATION_SCHEMA.TABLES t
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;


select * from dbo.watermark_control

-- TEST CHANGES TO VERIFY CDC IS WORKING
--INSERT a new order (simulates customer placing order)




INSERT INTO dbo.Orders
(OrderID, CustomerID, SellerID, OrderDate, ShippedDate, DeliveredDate,
 OrderStatus, PaymentMethod, ShippingCity, ShippingState, ShippingPinCode,
 TotalAmount, DiscountAmount, ShippingCharges, IsPrimeOrder, LastModifiedDate)
VALUES
('ORD_TEST_001', 'CUST00001', 'SELL001',
 GETDATE(), NULL, NULL,
 'PROCESSING', 'UPI', 'Mumbai', 'Maharashtra', '400001',
 1299.00, 0.00, 0.00, 'TRUE', GETDATE());

-- TEST 2: UPDATE an existing order (simulates customer cancelling)
UPDATE dbo.Orders
SET    OrderStatus       = 'CANCELLED',
       LastModifiedDate  = GETDATE()
WHERE  OrderID = 'ORD0000001';

-- TEST 3: DELETE the test order we just inserted
DELETE FROM dbo.Orders
WHERE  OrderID = 'ORD_TEST_001';



-- Check CDC change table for Orders


SELECT
    CASE __$operation
        WHEN 1 THEN 'DELETE'
        WHEN 2 THEN 'INSERT'
        WHEN 3 THEN 'BEFORE UPDATE'
        WHEN 4 THEN 'AFTER UPDATE'
    END                  AS operation_type,
    OrderID,
    OrderStatus,
    TotalAmount,
    LastModifiedDate
FROM cdc.dbo_Orders_CT
ORDER BY __$start_lsn DESC;

-- Expected output —  should come exactly 4 rows:


--Step 3 — Also Test OrderItems and Returns CDC
-- Test change on OrderItems

UPDATE dbo.OrderItems
SET    Quantity          = 3,
       LastModifiedDate  = GETDATE()
WHERE  OrderItemID = (SELECT TOP 1 OrderItemID FROM dbo.OrderItems);

-- Verify OrderItems CDC captured it
SELECT
    CASE __$operation
        WHEN 1 THEN 'DELETE'
        WHEN 2 THEN 'INSERT'
        WHEN 3 THEN 'BEFORE UPDATE'
        WHEN 4 THEN 'AFTER UPDATE'
    END         AS operation_type,
    OrderItemID,
    Quantity
FROM cdc.dbo_OrderItems_CT
ORDER BY __$start_lsn DESC;










-- Test change on Returns
UPDATE dbo.Returns
SET    ReturnStatus      = 'REFUNDED',
       LastModifiedDate  = GETDATE()
WHERE  ReturnID = (SELECT TOP 1 ReturnID FROM dbo.Returns);

-- Verify Returns CDC captured it
SELECT
    CASE __$operation
        WHEN 1 THEN 'DELETE'
        WHEN 2 THEN 'INSERT'
        WHEN 3 THEN 'BEFORE UPDATE'
        WHEN 4 THEN 'AFTER UPDATE'
    END         AS operation_type,
    ReturnID,
    ReturnStatus
FROM cdc.dbo_Returns_CT
ORDER BY __$start_lsn DESC;



select * from dbo.watermark_control

-- Add all missing source names to watermark_control
INSERT INTO dbo.watermark_control (source_name, last_load_timestamp, last_load_rows, last_run_status)
VALUES
('customers',      '2020-01-01 00:00:00', 0, 'INIT')
-- Verify all entries exist
SELECT * FROM dbo.watermark_control ORDER BY source_name;

select * from watermark_control




UPDATE dbo.watermark_control
SET last_load_timestamp = '2020-01-01 00:00:00.0000000',
    last_load_rows = 0,
    last_run_status = 'INIT'
WHERE source_name = 'customers';
