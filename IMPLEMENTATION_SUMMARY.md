# Implementation Summary

## What Was Delivered

A complete SQL Server stored procedure solution for calculating price change indices with comprehensive documentation.

## Files Created

### 1. SP_Calculate_Price_Change_Index.sql
The main stored procedure that:
- Calculates **Laspeyres**, **Paasche**, and **Fisher** price indices
- Compares **months 1-2 of 2026** to **months 1-2 of 2025**
- Processes three sales channels: **tot** (total), **onn** (online), **man** (manual)
- Aggregates at two levels:
  - **cal_level = 0**: Company total
  - **cal_level = 1**: Category level
- Saves results to **DB_sales_price_idx_cat_ch** table

### 2. README.md
Complete documentation including:
- Overview of price indices
- Data structure definitions
- Usage instructions
- Mathematical formulas
- Example queries

### 3. Example_Queries.sql
Practical examples showing how to:
- Execute the stored procedure
- Query results at different levels
- Compare indices across channels
- Analyze month-over-month changes

## How to Use

### Step 1: Install the Stored Procedure
```sql
-- Execute the SP_Calculate_Price_Change_Index.sql file in your SQL Server
-- This will create the stored procedure in your database
```

### Step 2: Run the Calculation
```sql
-- Execute the stored procedure
EXEC SP_Calculate_Price_Change_Index;
```

### Step 3: View Results
```sql
-- View all results
SELECT * FROM [onn].[DB_sales_price_idx_cat_ch]
WHERE Order_dt_y = 2026 AND Order_dt_m IN (1, 2)
ORDER BY Order_dt_m, cal_level DESC, channel, Category;
```

## Key Features

1. **Simple Code**: Straightforward SQL with clear logic, easy to understand and maintain
2. **Self-Contained**: Automatically creates the output table if needed
3. **Safe**: Handles NULL values and division by zero
4. **Clean**: Clears previous results before recalculation
5. **Traceable**: Records modification timestamps

## Index Formulas

### Laspeyres (Base Period Weighted)
Uses previous year quantities as weights:
```
L = Σ(P_current × Q_previous) / Σ(P_previous × Q_previous)
```

### Paasche (Current Period Weighted)
Uses current year quantities as weights:
```
P = Σ(P_current × Q_current) / Σ(P_previous × Q_current)
```

### Fisher (Geometric Mean)
Combines both indices:
```
F = √(Laspeyres × Paasche)
```

## Data Requirements

The stored procedure requires:
- Source table: `[OnnShop20REC].[onn].[DB_sales_price_idx_products]`
- Data for both 2025 and 2026 (months 1 and 2)
- Non-null prices and positive quantities
- Matching product records across both years

## Output Structure

Results stored in `[onn].[DB_sales_price_idx_cat_ch]`:
- **Order_dt_y**: Year (2026)
- **Order_dt_m**: Month (1 or 2)
- **cal_level**: 0 = Company Total, 1 = Category
- **Category**: Category name or 'TOTAL'
- **channel**: 'tot', 'onn', or 'man'
- **idx_Laspeyres**: Laspeyres index value
- **idx_Paasche**: Paasche index value
- **idx_Fisher**: Fisher index value
- **ModDate**: Timestamp of calculation
