# Price Change Index Calculation

This repository contains a SQL Server stored procedure for calculating price change indices at category and company total levels.

## Overview

The stored procedure `SP_Calculate_Price_Change_Index` calculates three types of price indices:
- **Laspeyres Index**: Uses base period quantities as weights
- **Paasche Index**: Uses current period quantities as weights  
- **Fisher Index**: Geometric mean of Laspeyres and Paasche indices

## Data Structure

### Input Table: DB_sales_price_idx_products
Contains product-level sales data with the following key columns:
- `Order_dt_y`: Order year
- `Order_dt_m`: Order month
- `Order_dt`: Order date
- `PRODIDX`: Product index/ID
- `Category`: Product category
- `Quantity`: Total quantity
- `price_tot`: Total channel price
- `Qty_onn`: Online quantity
- `price_onn`: Online channel price
- `Qty_man`: Manual/retail quantity
- `price_man`: Manual/retail channel price

### Output Table: DB_sales_price_idx_cat_ch
Stores calculated indices with the following structure:
- `Order_dt_y`: Order year (2026)
- `Order_dt_m`: Order month (1 or 2)
- `cal_level`: Calculation level (0 = company total, 1 = category)
- `Category`: Category name or 'TOTAL' for company level
- `channel`: Sales channel ('tot', 'onn', 'man')
- `idx_Laspeyres`: Laspeyres price index
- `idx_Paasche`: Paasche price index
- `idx_Fisher`: Fisher price index
- `ModDate`: Modification date

## Usage

### Installing the Stored Procedure
```sql
-- Run the stored procedure creation script
-- Execute SP_Calculate_Price_Change_Index.sql
```

### Executing the Stored Procedure
```sql
-- Calculate price indices for 2026 months 1 and 2 vs 2025
EXEC SP_Calculate_Price_Change_Index;
```

### Viewing Results
```sql
-- View all results
SELECT * FROM [onn].[DB_sales_price_idx_cat_ch]
WHERE Order_dt_y = 2026 AND Order_dt_m IN (1, 2)
ORDER BY Order_dt_m, cal_level DESC, channel, Category;

-- View category level indices only
SELECT * FROM [onn].[DB_sales_price_idx_cat_ch]
WHERE Order_dt_y = 2026 AND Order_dt_m IN (1, 2) AND cal_level = 1
ORDER BY Order_dt_m, channel, Category;

-- View company total indices only
SELECT * FROM [onn].[DB_sales_price_idx_cat_ch]
WHERE Order_dt_y = 2026 AND Order_dt_m IN (1, 2) AND cal_level = 0
ORDER BY Order_dt_m, channel;
```

## Index Formulas

### Laspeyres Index (Base Period Weighted)
```
L = Σ(P1 × Q0) / Σ(P0 × Q0)
```
Where:
- P1 = Current period price
- P0 = Base period price
- Q0 = Base period quantity

### Paasche Index (Current Period Weighted)
```
P = Σ(P1 × Q1) / Σ(P0 × Q1)
```
Where:
- P1 = Current period price
- P0 = Base period price
- Q1 = Current period quantity

### Fisher Index (Geometric Mean)
```
F = √(L × P)
```
Where:
- L = Laspeyres Index
- P = Paasche Index

## Calculation Details

- **Comparison Period**: Month 1 and 2 of 2026 vs Month 1 and 2 of 2025
- **Sales Channels**: 
  - `tot`: Total sales
  - `onn`: Online sales
  - `man`: Manual/retail sales
- **Aggregation Levels**:
  - Category level (cal_level = 1): Indices calculated per product category
  - Company total (cal_level = 0): Indices calculated across all categories

## Features

- Automatic table creation if `DB_sales_price_idx_cat_ch` doesn't exist
- Clears previous results for the specified period before recalculation
- Handles NULL values and division by zero
- Filters out records with zero or negative quantities
- Records modification timestamp for tracking
- Returns count of inserted records upon completion

## Notes

- The stored procedure requires data for both the current period (2026) and base period (2025) to exist in the source table
- Products must be present in both periods to be included in the calculation
- Price and quantity values must be non-null and positive for inclusion in calculations
