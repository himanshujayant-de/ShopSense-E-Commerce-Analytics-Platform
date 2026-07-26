-- WATERMARK CONTROL TABLE
CREATE TABLE dbo.watermark_control (
    source_name           VARCHAR(100)  NOT NULL PRIMARY KEY,
    last_load_timestamp   NVARCHAR(50)  NOT NULL,
    last_load_rows        BIGINT        DEFAULT 0,
    last_run_status       VARCHAR(20)   DEFAULT 'INIT'
);

INSERT INTO dbo.watermark_control VALUES
('orders',     '2020-01-01 00:00:00', 0, 'INIT'),
('orderitems', '2020-01-01 00:00:00', 0, 'INIT'),
('returns',    '2020-01-01 00:00:00', 0, 'INIT');


-- ============================================================
-- FIX WATERMARK TABLE
-- ============================================================


ALTER TABLE dbo.watermark_control
    ALTER COLUMN last_load_timestamp DATETIME2;

-- Update the seeded values to proper DATETIME2
UPDATE dbo.watermark_control
SET last_load_timestamp = CAST('2020-01-01 00:00:00' AS DATETIME2);

SELECT 'All data types fixed' AS status;



-- STORED PROCEDURE: Update watermark after each successful load
CREATE PROCEDURE dbo.usp_UpdateWatermark
    @source_name  VARCHAR(100),
    @rows_loaded  BIGINT
AS
BEGIN
    UPDATE dbo.watermark_control
    SET last_load_timestamp = GETDATE(),   -- now DATETIME2 = GETDATE() works perfectly
        last_load_rows      = @rows_loaded,
        last_run_status     = 'SUCCESS'
    WHERE source_name = @source_name;
END;
