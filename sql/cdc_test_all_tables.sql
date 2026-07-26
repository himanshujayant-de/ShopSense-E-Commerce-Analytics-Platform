
-- ============================================================
-- CDC TEST CHANGES FOR ORDERS, ORDERITEMS, RETURNS
-- Run in Azure SQL Query Editor
-- Generates INSERT/UPDATE/DELETE for all 3 CDC tables
-- ============================================================

-- ============================================================
-- SECTION 1: ORDERS — INSERT 5, UPDATE 10, DELETE 3
-- ============================================================

-- INSERT 5 new orders (simulates new customer purchases)
INSERT INTO dbo.Orders
(OrderID, CustomerID, SellerID, OrderDate, ShippedDate, DeliveredDate,
 OrderStatus, PaymentMethod, ShippingCity, ShippingState, ShippingPinCode,
 TotalAmount, DiscountAmount, ShippingCharges, IsPrimeOrder, LastModifiedDate)
VALUES
('ORD_NEW_001','CUST00010','SELL005',GETDATE(),NULL,NULL,
 'PROCESSING','UPI','Mumbai','Maharashtra','400001',
 2499.00,200.00,0.00,'TRUE',GETDATE()),

 ('ORD_NEW_002','CUST00020','SELL010',GETDATE(),NULL,NULL,
 'PROCESSING','CreditCard','Delhi','Delhi','110001',
 5999.00,500.00,0.00,'TRUE',GETDATE()),

('ORD_NEW_003','CUST00030','SELL015',GETDATE(),NULL,NULL,
 'PROCESSING','COD','Bangalore','Karnataka','560001',
 1299.00,0.00,49.00,'FALSE',GETDATE()),

('ORD_NEW_004','CUST00040','SELL020',GETDATE(),NULL,NULL,
 'PROCESSING','UPI','Chennai','Tamil Nadu','600001',
 3799.00,300.00,0.00,'TRUE',GETDATE()),

('ORD_NEW_005','CUST00050','SELL025',GETDATE(),NULL,NULL,
 'PROCESSING','Wallet','Pune','Maharashtra','411001',
 899.00,0.00,40.00,'FALSE',GETDATE());

select * from dbo.Orders




---Before this ensure ADF CDC must be start

-- UPDATE 10 existing orders with different status changes
-- (simulates real business operations during the day)

-- Mark 3 as SHIPPED (warehouse packed and dispatched)
UPDATE dbo.Orders
SET OrderStatus = 'SHIPPED',
    ShippedDate = GETDATE(),
    LastModifiedDate = GETDATE()
WHERE OrderID IN (
    SELECT TOP 3 OrderID FROM dbo.Orders
    WHERE OrderStatus = 'PROCESSING'
    AND OrderID NOT LIKE 'ORD_NEW_%'
    ORDER BY OrderID ASC
);

-- Mark 3 as DELIVERED (delivery completed)
UPDATE dbo.Orders
SET OrderStatus = 'DELIVERED',
    DeliveredDate = GETDATE(),
    LastModifiedDate = GETDATE()
WHERE OrderID IN (
    SELECT TOP 3 OrderID FROM dbo.Orders
    WHERE OrderStatus = 'SHIPPED'
    AND OrderID NOT LIKE 'ORD_NEW_%'
    ORDER BY OrderID ASC
);

-- Mark 2 as CANCELLED (customer cancelled)
UPDATE dbo.Orders
SET OrderStatus = 'CANCELLED',
    LastModifiedDate = GETDATE()
WHERE OrderID IN (
    SELECT TOP 2 OrderID FROM dbo.Orders
    WHERE OrderStatus = 'PROCESSING'
    AND OrderID NOT LIKE 'ORD_NEW_%'
    ORDER BY OrderID DESC
);

-- Mark 2 as RETURNED (customer returned after delivery)
UPDATE dbo.Orders
SET OrderStatus = 'RETURNED',
    LastModifiedDate = GETDATE()
WHERE OrderID IN (
    SELECT TOP 2 OrderID FROM dbo.Orders
    WHERE OrderStatus = 'DELIVERED'
    AND OrderID NOT LIKE 'ORD_NEW_%'
    ORDER BY OrderID ASC
);

-- DELETE 3 test/duplicate orders (admin cleanup)
DELETE FROM dbo.Orders
WHERE OrderID IN ('ORD_NEW_003','ORD_NEW_004','ORD_NEW_005');

-- Verify CDC captured orders changes
SELECT
    CASE __$operation
        WHEN 1 THEN 'DELETE'
        WHEN 2 THEN 'INSERT'
        WHEN 3 THEN 'BEFORE_UPDATE'
        WHEN 4 THEN 'AFTER_UPDATE'
    END AS operation_type,
    COUNT(*) AS row_count
FROM cdc.dbo_Orders_CT
GROUP BY __$operation
ORDER BY __$operation;





select * from OrderItems

-- ============================================================
-- SECTION 2: ORDERITEMS — UPDATE 8, INSERT 4, DELETE 2
-- ============================================================

-- INSERT 4 new order items (for the new orders we created)
INSERT INTO dbo.OrderItems
(OrderItemID, OrderID, ProductID, SellerID, Quantity,
 UnitPrice, DiscountAmount, TotalPrice, Category, IsGift, LastModifiedDate)
VALUES
('ITEM_NEW_001','ORD_NEW_001','PROD0001','SELL005',
 2,1199.50,200.00,2199.00,'Electronics','FALSE',GETDATE()),

('ITEM_NEW_002','ORD_NEW_001','PROD0050','SELL005',
 1,299.00,0.00,299.00,'Clothing','TRUE',GETDATE()),

('ITEM_NEW_003','ORD_NEW_002','PROD0101','SELL010',
 3,1999.67,500.00,5499.01,'Books','FALSE',GETDATE()),

('ITEM_NEW_004','ORD_NEW_002','PROD0150','SELL010',
 1,499.99,0.00,499.99,'HomeKitchen','FALSE',GETDATE());

-- UPDATE 8 existing order items (quantity changes, price corrections)

-- Increase quantity for 4 items (customer requested more)
UPDATE dbo.OrderItems
SET Quantity = Quantity + 1,
    TotalPrice = UnitPrice * (Quantity + 1) - DiscountAmount,
    LastModifiedDate = GETDATE()
WHERE OrderItemID IN (
    SELECT TOP 4 OrderItemID FROM dbo.OrderItems
    WHERE OrderID NOT LIKE 'ORD_NEW_%'
    AND Quantity < 4
    ORDER BY OrderItemID ASC
);

-- Apply discount correction for 4 items
UPDATE dbo.OrderItems
SET DiscountAmount = ROUND(UnitPrice * 0.10, 2),
    TotalPrice = ROUND(UnitPrice * Quantity * 0.90, 2),
    LastModifiedDate = GETDATE()
WHERE OrderItemID IN (
    SELECT TOP 4 OrderItemID FROM dbo.OrderItems
    WHERE DiscountAmount = 0
    AND UnitPrice > 500
    AND OrderID NOT LIKE 'ORD_NEW_%'
    ORDER BY UnitPrice DESC
);

-- DELETE 2 order items (item removed from cancelled order)
DELETE FROM dbo.OrderItems
WHERE OrderItemID IN ('ITEM_NEW_003','ITEM_NEW_004');

-- Verify CDC captured orderitems changes
SELECT
    CASE __$operation
        WHEN 1 THEN 'DELETE'
        WHEN 2 THEN 'INSERT'
        WHEN 3 THEN 'BEFORE_UPDATE'
        WHEN 4 THEN 'AFTER_UPDATE'
    END AS operation_type,
    COUNT(*) AS row_count
FROM cdc.dbo_OrderItems_CT
GROUP BY __$operation
ORDER BY __$operation;


SELECT * FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_NAME = 'Returns';

















-- ============================================================
-- SECTION 3: RETURNS — INSERT 5, UPDATE 6, DELETE 1
-- ============================================================

-- INSERT 5 new return requests
-- (customers returning recently delivered orders)
INSERT INTO dbo.Returns
(ReturnID, OrderID, CustomerID, ReturnDate, ReturnReason,
 ReturnStatus, RefundAmount, RefundDate, RefundMethod,
 ConditionOnReturn, LastModifiedDate)
VALUES
('RET_NEW_001',
 (SELECT TOP 1 OrderID FROM dbo.Orders WHERE OrderStatus='RETURNED'
  ORDER BY OrderID ASC),
 'CUST00010', GETDATE(), 'DEFECTIVE_PRODUCT',
 'PROCESSING', 2499.00, NULL, 'UPI', 'DAMAGED', GETDATE()),

('RET_NEW_002',
 (SELECT TOP 1 OrderID FROM dbo.Orders WHERE OrderStatus='DELIVERED'
  AND OrderID NOT LIKE 'ORD_NEW_%' ORDER BY OrderID ASC),
 'CUST00020', GETDATE(), 'WRONG_ITEM',
 'PROCESSING', 1500.00, NULL, 'CreditCard', 'GOOD', GETDATE()),

('RET_NEW_003',
 (SELECT TOP 1 OrderID FROM dbo.Orders WHERE OrderStatus='DELIVERED'
  AND OrderID NOT LIKE 'ORD_NEW_%' ORDER BY OrderID DESC),
 'CUST00030', GETDATE(), 'NOT_AS_DESCRIBED',
 'PROCESSING', 800.00, NULL, 'COD', 'OPENED', GETDATE()),

('RET_NEW_004',
 (SELECT TOP 1 OrderID FROM dbo.Orders WHERE OrderStatus='RETURNED'
  AND OrderID NOT LIKE 'ORD_NEW_%' ORDER BY OrderID DESC),
 'CUST00040', GETDATE(), 'CHANGED_MIND',
 'PROCESSING', 3799.00, NULL, 'UPI', 'SEALED', GETDATE()),

('RET_NEW_005',
 (SELECT TOP 1 OrderID FROM dbo.Orders WHERE OrderStatus='DELIVERED'
  AND OrderID NOT LIKE 'ORD_NEW_%' ORDER BY TotalAmount DESC),
 'CUST00050', GETDATE(), 'QUALITY_ISSUE',
 'PROCESSING', 5999.00, NULL, 'CreditCard', 'GOOD', GETDATE());

-- UPDATE 6 existing returns — approve refunds (status changes)

-- Approve 3 returns → REFUNDED
UPDATE dbo.Returns
SET ReturnStatus = 'REFUNDED',
    RefundDate   = GETDATE(),
    LastModifiedDate = GETDATE()
WHERE ReturnID IN (
    SELECT TOP 3 ReturnID FROM dbo.Returns
    WHERE ReturnStatus = 'PROCESSING'
    AND ReturnID NOT LIKE 'RET_NEW_%'
    ORDER BY ReturnDate ASC
);

-- Reject 2 returns (condition damaged, not eligible)
UPDATE dbo.Returns
SET ReturnStatus = 'REJECTED',
    LastModifiedDate = GETDATE()
WHERE ReturnID IN (
    SELECT TOP 2 ReturnID FROM dbo.Returns
    WHERE ReturnStatus = 'PROCESSING'
    AND ConditionOnReturn = 'DAMAGED'
    AND ReturnID NOT LIKE 'RET_NEW_%'
    ORDER BY ReturnDate ASC
);

-- Update refund amount correction for 1 return
UPDATE dbo.Returns
SET RefundAmount = RefundAmount * 0.85,  -- 15% restocking fee applied
    LastModifiedDate = GETDATE()
WHERE ReturnID IN (
    SELECT TOP 1 ReturnID FROM dbo.Returns
    WHERE ReturnStatus = 'PROCESSING'
    AND ConditionOnReturn = 'OPENED'
    AND ReturnID NOT LIKE 'RET_NEW_%'
    ORDER BY RefundAmount DESC
);

-- DELETE 1 fraudulent return request
DELETE FROM dbo.Returns
WHERE ReturnID = 'RET_NEW_005';

-- Verify CDC captured returns changes
SELECT
    CASE __$operation
        WHEN 1 THEN 'DELETE'
        WHEN 2 THEN 'INSERT'
        WHEN 3 THEN 'BEFORE_UPDATE'
        WHEN 4 THEN 'AFTER_UPDATE'
    END AS operation_type,
    COUNT(*) AS row_count
FROM cdc.dbo_Returns_CT
GROUP BY __$operation
ORDER BY __$operation;

-- ============================================================
-- FINAL SUMMARY: Total CDC changes across all 3 tables
-- ============================================================
SELECT 'Orders'     AS table_name,
    SUM(CASE WHEN __$operation=2 THEN 1 ELSE 0 END) AS inserts,
    SUM(CASE WHEN __$operation=4 THEN 1 ELSE 0 END) AS updates,
    SUM(CASE WHEN __$operation=1 THEN 1 ELSE 0 END) AS deletes,
    COUNT(*) AS total_cdc_rows
FROM cdc.dbo_Orders_CT
UNION ALL
SELECT 'OrderItems',
    SUM(CASE WHEN __$operation=2 THEN 1 ELSE 0 END),
    SUM(CASE WHEN __$operation=4 THEN 1 ELSE 0 END),
    SUM(CASE WHEN __$operation=1 THEN 1 ELSE 0 END),
    COUNT(*)
FROM cdc.dbo_OrderItems_CT
UNION ALL
SELECT 'Returns',
    SUM(CASE WHEN __$operation=2 THEN 1 ELSE 0 END),
    SUM(CASE WHEN __$operation=4 THEN 1 ELSE 0 END),
    SUM(CASE WHEN __$operation=1 THEN 1 ELSE 0 END),
    COUNT(*)
FROM cdc.dbo_Returns_CT;





