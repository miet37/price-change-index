-- =============================================
-- Stored Procedure: SP_Calculate_Price_Change_Index
-- Description: Calculate Laspeyres, Paasche, and Fisher price change indices
--              for months 1 and 2 of 2026 vs 2025
-- =============================================

CREATE PROCEDURE SP_Calculate_Price_Change_Index
AS
BEGIN
    SET NOCOUNT ON;

    -- Create output table if it doesn't exist
    IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[onn].[DB_sales_price_idx_cat_ch]') AND type in (N'U'))
    BEGIN
        CREATE TABLE [onn].[DB_sales_price_idx_cat_ch] (
            [Order_dt_y] INT,
            [Order_dt_m] INT,
            [cal_level] INT,
            [Category] NVARCHAR(255),
            [channel] NVARCHAR(10),
            [idx_Laspeyres] DECIMAL(18, 6),
            [idx_Paasche] DECIMAL(18, 6),
            [idx_Fisher] DECIMAL(18, 6),
            [ModDate] DATETIME DEFAULT GETDATE()
        );
    END

    -- Clear previous results for 2026 months 1 and 2
    DELETE FROM [onn].[DB_sales_price_idx_cat_ch]
    WHERE Order_dt_y = 2026 AND Order_dt_m IN (1, 2);

    -- Calculate indices for TOT channel
    -- Category level (cal_level = 1)
    INSERT INTO [onn].[DB_sales_price_idx_cat_ch] 
        ([Order_dt_y], [Order_dt_m], [cal_level], [Category], [channel], 
         [idx_Laspeyres], [idx_Paasche], [idx_Fisher], [ModDate])
    SELECT 
        t.Order_dt_y,
        t.Order_dt_m,
        1 AS cal_level,
        t.Category,
        'tot' AS channel,
        -- Laspeyres Index: Sum(P1*Q0) / Sum(P0*Q0)
        SUM(t.price_tot * s.Quantity) / NULLIF(SUM(s.price_tot * s.Quantity), 0) AS idx_Laspeyres,
        -- Paasche Index: Sum(P1*Q1) / Sum(P0*Q1)
        SUM(t.price_tot * t.Quantity) / NULLIF(SUM(s.price_tot * t.Quantity), 0) AS idx_Paasche,
        -- Fisher Index: sqrt(Laspeyres * Paasche)
        SQRT(
            (SUM(t.price_tot * s.Quantity) / NULLIF(SUM(s.price_tot * s.Quantity), 0)) *
            (SUM(t.price_tot * t.Quantity) / NULLIF(SUM(s.price_tot * t.Quantity), 0))
        ) AS idx_Fisher,
        GETDATE() AS ModDate
    FROM [OnnShop20REC].[onn].[DB_sales_price_idx_products] t
    INNER JOIN [OnnShop20REC].[onn].[DB_sales_price_idx_products] s 
        ON s.Order_dt = DATEADD(YEAR, -1, t.Order_dt) 
        AND t.PRODIDX = s.PRODIDX
    WHERE t.Order_dt_y = 2026 
        AND t.Order_dt_m IN (1, 2)
        AND t.price_tot IS NOT NULL 
        AND s.price_tot IS NOT NULL
        AND t.Quantity > 0 
        AND s.Quantity > 0
    GROUP BY t.Order_dt_y, t.Order_dt_m, t.Category;

    -- Company total level (cal_level = 0) for TOT channel
    INSERT INTO [onn].[DB_sales_price_idx_cat_ch] 
        ([Order_dt_y], [Order_dt_m], [cal_level], [Category], [channel], 
         [idx_Laspeyres], [idx_Paasche], [idx_Fisher], [ModDate])
    SELECT 
        t.Order_dt_y,
        t.Order_dt_m,
        0 AS cal_level,
        'TOTAL' AS Category,
        'tot' AS channel,
        SUM(t.price_tot * s.Quantity) / NULLIF(SUM(s.price_tot * s.Quantity), 0) AS idx_Laspeyres,
        SUM(t.price_tot * t.Quantity) / NULLIF(SUM(s.price_tot * t.Quantity), 0) AS idx_Paasche,
        SQRT(
            (SUM(t.price_tot * s.Quantity) / NULLIF(SUM(s.price_tot * s.Quantity), 0)) *
            (SUM(t.price_tot * t.Quantity) / NULLIF(SUM(s.price_tot * t.Quantity), 0))
        ) AS idx_Fisher,
        GETDATE() AS ModDate
    FROM [OnnShop20REC].[onn].[DB_sales_price_idx_products] t
    INNER JOIN [OnnShop20REC].[onn].[DB_sales_price_idx_products] s 
        ON s.Order_dt = DATEADD(YEAR, -1, t.Order_dt) 
        AND t.PRODIDX = s.PRODIDX
    WHERE t.Order_dt_y = 2026 
        AND t.Order_dt_m IN (1, 2)
        AND t.price_tot IS NOT NULL 
        AND s.price_tot IS NOT NULL
        AND t.Quantity > 0 
        AND s.Quantity > 0
    GROUP BY t.Order_dt_y, t.Order_dt_m;

    -- Calculate indices for ONN channel (online)
    -- Category level (cal_level = 1)
    INSERT INTO [onn].[DB_sales_price_idx_cat_ch] 
        ([Order_dt_y], [Order_dt_m], [cal_level], [Category], [channel], 
         [idx_Laspeyres], [idx_Paasche], [idx_Fisher], [ModDate])
    SELECT 
        t.Order_dt_y,
        t.Order_dt_m,
        1 AS cal_level,
        t.Category,
        'onn' AS channel,
        SUM(t.price_onn * s.Qty_onn) / NULLIF(SUM(s.price_onn * s.Qty_onn), 0) AS idx_Laspeyres,
        SUM(t.price_onn * t.Qty_onn) / NULLIF(SUM(s.price_onn * t.Qty_onn), 0) AS idx_Paasche,
        SQRT(
            (SUM(t.price_onn * s.Qty_onn) / NULLIF(SUM(s.price_onn * s.Qty_onn), 0)) *
            (SUM(t.price_onn * t.Qty_onn) / NULLIF(SUM(s.price_onn * t.Qty_onn), 0))
        ) AS idx_Fisher,
        GETDATE() AS ModDate
    FROM [OnnShop20REC].[onn].[DB_sales_price_idx_products] t
    INNER JOIN [OnnShop20REC].[onn].[DB_sales_price_idx_products] s 
        ON s.Order_dt = DATEADD(YEAR, -1, t.Order_dt) 
        AND t.PRODIDX = s.PRODIDX
    WHERE t.Order_dt_y = 2026 
        AND t.Order_dt_m IN (1, 2)
        AND t.price_onn IS NOT NULL 
        AND s.price_onn IS NOT NULL
        AND t.Qty_onn > 0 
        AND s.Qty_onn > 0
    GROUP BY t.Order_dt_y, t.Order_dt_m, t.Category;

    -- Company total level (cal_level = 0) for ONN channel
    INSERT INTO [onn].[DB_sales_price_idx_cat_ch] 
        ([Order_dt_y], [Order_dt_m], [cal_level], [Category], [channel], 
         [idx_Laspeyres], [idx_Paasche], [idx_Fisher], [ModDate])
    SELECT 
        t.Order_dt_y,
        t.Order_dt_m,
        0 AS cal_level,
        'TOTAL' AS Category,
        'onn' AS channel,
        SUM(t.price_onn * s.Qty_onn) / NULLIF(SUM(s.price_onn * s.Qty_onn), 0) AS idx_Laspeyres,
        SUM(t.price_onn * t.Qty_onn) / NULLIF(SUM(s.price_onn * t.Qty_onn), 0) AS idx_Paasche,
        SQRT(
            (SUM(t.price_onn * s.Qty_onn) / NULLIF(SUM(s.price_onn * s.Qty_onn), 0)) *
            (SUM(t.price_onn * t.Qty_onn) / NULLIF(SUM(s.price_onn * t.Qty_onn), 0))
        ) AS idx_Fisher,
        GETDATE() AS ModDate
    FROM [OnnShop20REC].[onn].[DB_sales_price_idx_products] t
    INNER JOIN [OnnShop20REC].[onn].[DB_sales_price_idx_products] s 
        ON s.Order_dt = DATEADD(YEAR, -1, t.Order_dt) 
        AND t.PRODIDX = s.PRODIDX
    WHERE t.Order_dt_y = 2026 
        AND t.Order_dt_m IN (1, 2)
        AND t.price_onn IS NOT NULL 
        AND s.price_onn IS NOT NULL
        AND t.Qty_onn > 0 
        AND s.Qty_onn > 0
    GROUP BY t.Order_dt_y, t.Order_dt_m;

    -- Calculate indices for MAN channel (manual/retail)
    -- Category level (cal_level = 1)
    INSERT INTO [onn].[DB_sales_price_idx_cat_ch] 
        ([Order_dt_y], [Order_dt_m], [cal_level], [Category], [channel], 
         [idx_Laspeyres], [idx_Paasche], [idx_Fisher], [ModDate])
    SELECT 
        t.Order_dt_y,
        t.Order_dt_m,
        1 AS cal_level,
        t.Category,
        'man' AS channel,
        SUM(t.price_man * s.Qty_man) / NULLIF(SUM(s.price_man * s.Qty_man), 0) AS idx_Laspeyres,
        SUM(t.price_man * t.Qty_man) / NULLIF(SUM(s.price_man * t.Qty_man), 0) AS idx_Paasche,
        SQRT(
            (SUM(t.price_man * s.Qty_man) / NULLIF(SUM(s.price_man * s.Qty_man), 0)) *
            (SUM(t.price_man * t.Qty_man) / NULLIF(SUM(s.price_man * t.Qty_man), 0))
        ) AS idx_Fisher,
        GETDATE() AS ModDate
    FROM [OnnShop20REC].[onn].[DB_sales_price_idx_products] t
    INNER JOIN [OnnShop20REC].[onn].[DB_sales_price_idx_products] s 
        ON s.Order_dt = DATEADD(YEAR, -1, t.Order_dt) 
        AND t.PRODIDX = s.PRODIDX
    WHERE t.Order_dt_y = 2026 
        AND t.Order_dt_m IN (1, 2)
        AND t.price_man IS NOT NULL 
        AND s.price_man IS NOT NULL
        AND t.Qty_man > 0 
        AND s.Qty_man > 0
    GROUP BY t.Order_dt_y, t.Order_dt_m, t.Category;

    -- Company total level (cal_level = 0) for MAN channel
    INSERT INTO [onn].[DB_sales_price_idx_cat_ch] 
        ([Order_dt_y], [Order_dt_m], [cal_level], [Category], [channel], 
         [idx_Laspeyres], [idx_Paasche], [idx_Fisher], [ModDate])
    SELECT 
        t.Order_dt_y,
        t.Order_dt_m,
        0 AS cal_level,
        'TOTAL' AS Category,
        'man' AS channel,
        SUM(t.price_man * s.Qty_man) / NULLIF(SUM(s.price_man * s.Qty_man), 0) AS idx_Laspeyres,
        SUM(t.price_man * t.Qty_man) / NULLIF(SUM(s.price_man * t.Qty_man), 0) AS idx_Paasche,
        SQRT(
            (SUM(t.price_man * s.Qty_man) / NULLIF(SUM(s.price_man * s.Qty_man), 0)) *
            (SUM(t.price_man * t.Qty_man) / NULLIF(SUM(s.price_man * t.Qty_man), 0))
        ) AS idx_Fisher,
        GETDATE() AS ModDate
    FROM [OnnShop20REC].[onn].[DB_sales_price_idx_products] t
    INNER JOIN [OnnShop20REC].[onn].[DB_sales_price_idx_products] s 
        ON s.Order_dt = DATEADD(YEAR, -1, t.Order_dt) 
        AND t.PRODIDX = s.PRODIDX
    WHERE t.Order_dt_y = 2026 
        AND t.Order_dt_m IN (1, 2)
        AND t.price_man IS NOT NULL 
        AND s.price_man IS NOT NULL
        AND t.Qty_man > 0 
        AND s.Qty_man > 0
    GROUP BY t.Order_dt_y, t.Order_dt_m;

    -- Return result count
    SELECT 
        COUNT(*) AS RecordsInserted,
        'Price change indices calculated successfully' AS Status
    FROM [onn].[DB_sales_price_idx_cat_ch]
    WHERE Order_dt_y = 2026 AND Order_dt_m IN (1, 2);

END;
GO
