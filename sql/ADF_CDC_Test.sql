

-- ============================================================
-- ADF CDC TEST 1: INSERT 5 ORDERS
-- ============================================================

INSERT INTO dbo.Orders
(
    OrderID,
    CustomerID,
    SellerID,
    OrderDate,
    ShippedDate,
    DeliveredDate,
    OrderStatus,
    PaymentMethod,
    ShippingCity,
    ShippingState,
    ShippingPinCode,
    TotalAmount,
    DiscountAmount,
    ShippingCharges,
    IsPrimeOrder,
    LastModifiedDate
)
VALUES
(
    'ORD_CDC_111',
    'CUST00010',
    'SELL005',
    GETDATE(),
    NULL,
    NULL,
    'PROCESSING',
    'UPI',
    'Mumbai',
    'Maharashtra',
    '400001',
    2100.00,
    100.00,
    0.00,
    'TRUE',
    GETDATE()
),
(
    'ORD_CDC_112',
    'CUST00020',
    'SELL010',
    GETDATE(),
    NULL,
    NULL,
    'PROCESSING',
    'CreditCard',
    'Delhi',
    'Delhi',
    '110001',
    4600.00,
    300.00,
    0.00,
    'TRUE',
    GETDATE()
),
(
    'ORD_CDC_113',
    'CUST00030',
    'SELL015',
    GETDATE(),
    NULL,
    NULL,
    'PROCESSING',
    'COD',
    'Bangalore',
    'Karnataka',
    '560001',
    1500.00,
    0.00,
    49.00,
    'FALSE',
    GETDATE()
),
(
    'ORD_CDC_114',
    'CUST00040',
    'SELL020',
    GETDATE(),
    NULL,
    NULL,
    'PROCESSING',
    'UPI',
    'Chennai',
    'Tamil Nadu',
    '600001',
    3300.00,
    200.00,
    0.00,
    'TRUE',
    GETDATE()
),
(
    'ORD_CDC_115',
    'CUST00050',
    'SELL025',
    GETDATE(),
    NULL,
    NULL,
    'PROCESSING',
    'Wallet',
    'Pune',
    'Maharashtra',
    '411001',
    1000.00,
    0.00,
    40.00,
    'FALSE',
    GETDATE()
);

SELECT @@ROWCOUNT AS inserted_rows;



DELETE FROM dbo.Orders
WHERE OrderID IN (
    'ORD_CDC_113',
    'ORD_CDC_114',
    'ORD_CDC_115'
);

SELECT @@ROWCOUNT AS deleted_rows;



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







-------------------------------------


INSERT INTO dbo.OrderItems
(
    OrderItemID,
    OrderID,
    ProductID,
    SellerID,
    Quantity,
    UnitPrice,
    DiscountAmount,
    TotalPrice,
    Category,
    IsGift,
    LastModifiedDate
)
VALUES
(
    'ITEM_CDC_109',
    'ORD_CDC_111',
    'PROD0001',
    'SELL005',
    2,
    1199.50,
    200.00,
    2199.00,
    'Electronics',
    'FALSE',
    GETDATE()
),
(
    'ITEM_CDC_110',
    'ORD_CDC_111',
    'PROD0050',
    'SELL005',
    1,
    299.00,
    0.00,
    299.00,
    'Clothing',
    'TRUE',
    GETDATE()
),
(
    'ITEM_CDC_111',
    'ORD_CDC_112',
    'PROD0101',
    'SELL010',
    3,
    1999.67,
    500.00,
    5499.01,
    'Books',
    'FALSE',
    GETDATE()
),
(
    'ITEM_CDC_112',
    'ORD_CDC_112',
    'PROD0150',
    'SELL010',
    1,
    499.99,
    0.00,
    499.99,
    'HomeKitchen',
    'FALSE',
    GETDATE()
);



SELECT
    OrderItemID,
    OrderID,
    Quantity,
    TotalPrice,
    LastModifiedDate
FROM dbo.OrderItems
WHERE OrderItemID IN (
    'ITEM_CDC_109',
    'ITEM_CDC_110',
    'ITEM_CDC_111',
    'ITEM_CDC_112'
)
ORDER BY OrderItemID;

DELETE FROM dbo.OrderItems
WHERE OrderItemID IN (
    'ITEM_CDC_111',
    'ITEM_CDC_112'
);

SELECT @@ROWCOUNT AS deleted_rows;

SELECT OrderItemID
FROM dbo.OrderItems
WHERE OrderItemID IN (
    'ITEM_CDC_111',
    'ITEM_CDC_112'
);


SELECT
    capture_instance,
    supports_net_changes,
    index_name
FROM cdc.change_tables
WHERE source_object_id = OBJECT_ID('dbo.Returns');

-- ============================================================
-- SECTION 3: RETURNS — INSERT 5, UPDATE 6, DELETE 1
-- ============================================================
SELECT ReturnID
FROM dbo.Returns
WHERE ReturnID IN (
    'RET_CDC_101',
    'RET_CDC_102',
    'RET_CDC_103',
    'RET_CDC_104',
    'RET_CDC_105'
);


SELECT ReturnID
FROM dbo.Returns
WHERE ReturnID = 'RET_CDC_101';



INSERT INTO dbo.Returns
(
    ReturnID,
    OrderID,
    CustomerID,
    ReturnDate,
    ReturnReason,
    ReturnStatus,
    RefundAmount,
    RefundDate,
    RefundMethod,
    ConditionOnReturn,
    LastModifiedDate
)
VALUES
(
    'RET_CDC_101',
    'ORD0000028',
    'CUST00291',
    GETDATE(),
    'DEFECTIVE_PRODUCT',
    'PROCESSING',
    1200.00,
    NULL,
    'UPI',
    'DAMAGED',
    GETDATE()
);


SELECT
    ReturnID,
    OrderID,
    CustomerID,
    ReturnStatus,
    RefundAmount,
    LastModifiedDate
FROM dbo.Returns
WHERE ReturnID = 'RET_CDC_101';


INSERT INTO dbo.Returns
(
    ReturnID,
    OrderID,
    CustomerID,
    ReturnDate,
    ReturnReason,
    ReturnStatus,
    RefundAmount,
    RefundDate,
    RefundMethod,
    ConditionOnReturn,
    LastModifiedDate
)
VALUES
(
    'RET_CDC_102',
    'ORD0000004',
    'CUST00286',
    GETDATE(),
    'WRONG_ITEM',
    'PROCESSING',
    1500.00,
    NULL,
    'CREDITCARD',
    'GOOD',
    GETDATE()
),
(
    'RET_CDC_103',
    'ORD0000006',
    'CUST00088',
    GETDATE(),
    'NOT_AS_DESCRIBED',
    'PROCESSING',
    800.00,
    NULL,
    'COD',
    'OPENED',
    GETDATE()
),
(
    'RET_CDC_104',
    'ORD0000007',
    'CUST00461',
    GETDATE(),
    'CHANGED_MIND',
    'PROCESSING',
    2000.00,
    NULL,
    'UPI',
    'SEALED',
    GETDATE()
),
(
    'RET_CDC_105',
    'ORD0000009',
    'CUST00395',
    GETDATE(),
    'QUALITY_ISSUE',
    'PROCESSING',
    3000.00,
    NULL,
    'CREDITCARD',
    'GOOD',
    GETDATE()
);

SELECT @@ROWCOUNT AS inserted_rows;

SELECT
    ReturnID,
    OrderID,
    CustomerID,
    ReturnStatus,
    RefundAmount,
    LastModifiedDate
FROM dbo.Returns
WHERE ReturnID IN (
    'RET_CDC_101',
    'RET_CDC_102',
    'RET_CDC_103',
    'RET_CDC_104',
    'RET_CDC_105'
)
ORDER BY ReturnID;





-- UPDATE 

-- 101 and 102 → REFUNDED
UPDATE dbo.Returns
SET
    ReturnStatus = 'REFUNDED',
    RefundDate = GETDATE(),
    LastModifiedDate = GETDATE()
WHERE ReturnID IN (
    'RET_CDC_101',
    'RET_CDC_102'
);

SELECT @@ROWCOUNT AS refunded_rows;


-- 103 and 104 → REJECTED
UPDATE dbo.Returns
SET
    ReturnStatus = 'REJECTED',
    LastModifiedDate = GETDATE()
WHERE ReturnID IN (
    'RET_CDC_103',
    'RET_CDC_104'
);

SELECT @@ROWCOUNT AS rejected_rows;


-- 105 → Refund amount correction
UPDATE dbo.Returns
SET
    RefundAmount = ROUND(RefundAmount * 0.85, 2),
    LastModifiedDate = GETDATE()
WHERE ReturnID = 'RET_CDC_105';

SELECT @@ROWCOUNT AS corrected_rows;


DELETE FROM dbo.Returns
WHERE ReturnID = 'RET_CDC_105';

SELECT @@ROWCOUNT AS deleted_rows;


SELECT ReturnID
FROM dbo.Returns
WHERE ReturnID = 'RET_CDC_105';


SELECT COUNT(*) AS remaining_rows
FROM dbo.Returns
WHERE ReturnID = 'RET_CDC_105';


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








