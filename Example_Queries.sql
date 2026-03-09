-- =============================================
-- Example Usage: Price Change Index Calculation
-- =============================================

-- 1. Execute the stored procedure to calculate indices
-- This will calculate price change indices for months 1 and 2 of 2026 vs 2025
EXEC SP_Calculate_Price_Change_Index;

-- 2. View all calculated indices
SELECT 
    Order_dt_y,
    Order_dt_m,
    cal_level,
    CASE 
        WHEN cal_level = 0 THEN 'Company Total'
        WHEN cal_level = 1 THEN 'Category'
    END AS Level_Description,
    Category,
    channel,
    idx_Laspeyres,
    idx_Paasche,
    idx_Fisher,
    ModDate
FROM [onn].[DB_sales_price_idx_cat_ch]
WHERE Order_dt_y = 2026 AND Order_dt_m IN (1, 2)
ORDER BY Order_dt_m, cal_level DESC, channel, Category;

-- 3. View company total indices (cal_level = 0)
SELECT 
    Order_dt_y,
    Order_dt_m,
    channel,
    idx_Laspeyres,
    idx_Paasche,
    idx_Fisher,
    -- Calculate percentage change from base period (index = 100)
    (idx_Fisher - 1) * 100 AS Fisher_Pct_Change
FROM [onn].[DB_sales_price_idx_cat_ch]
WHERE Order_dt_y = 2026 
    AND Order_dt_m IN (1, 2)
    AND cal_level = 0
ORDER BY Order_dt_m, channel;

-- 4. View category level indices (cal_level = 1) for a specific month and channel
SELECT 
    Category,
    idx_Laspeyres,
    idx_Paasche,
    idx_Fisher,
    (idx_Fisher - 1) * 100 AS Fisher_Pct_Change
FROM [onn].[DB_sales_price_idx_cat_ch]
WHERE Order_dt_y = 2026 
    AND Order_dt_m = 1
    AND cal_level = 1
    AND channel = 'tot'
ORDER BY Category;

-- 5. Compare indices across channels for the same category
SELECT 
    Order_dt_m,
    Category,
    MAX(CASE WHEN channel = 'tot' THEN idx_Fisher END) AS Fisher_Total,
    MAX(CASE WHEN channel = 'onn' THEN idx_Fisher END) AS Fisher_Online,
    MAX(CASE WHEN channel = 'man' THEN idx_Fisher END) AS Fisher_Manual
FROM [onn].[DB_sales_price_idx_cat_ch]
WHERE Order_dt_y = 2026 
    AND Order_dt_m IN (1, 2)
    AND cal_level = 1
GROUP BY Order_dt_m, Category
ORDER BY Order_dt_m, Category;

-- 6. View month-over-month changes at company level
SELECT 
    channel,
    MAX(CASE WHEN Order_dt_m = 1 THEN idx_Fisher END) AS Fisher_Jan_2026,
    MAX(CASE WHEN Order_dt_m = 2 THEN idx_Fisher END) AS Fisher_Feb_2026,
    MAX(CASE WHEN Order_dt_m = 2 THEN idx_Fisher END) - 
    MAX(CASE WHEN Order_dt_m = 1 THEN idx_Fisher END) AS MoM_Change
FROM [onn].[DB_sales_price_idx_cat_ch]
WHERE Order_dt_y = 2026 
    AND Order_dt_m IN (1, 2)
    AND cal_level = 0
GROUP BY channel
ORDER BY channel;
