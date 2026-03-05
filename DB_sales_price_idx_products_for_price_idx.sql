SELECT TOP (1000) [Order_dt_y]
      ,[Order_dt_m]
      ,[Order_dt]
      ,[PRODIDX]
      ,[Category]
      ,[Quantity]
      ,[Vnet]
      ,[price_tot]
      ,[Vonn]
      ,[Qty_onn]
      ,[price_onn]
      ,[Qty_man]
      ,[Vman]
      ,[price_man]
      ,[Sold_to_count]
      ,[Sold_to_onn]
      ,[Sold_to_man]
      ,[ModDate]
  FROM [OnnShop20REC].[onn].[DB_sales_price_idx_products]





SELECT t.[Order_dt_y]
      ,t.[Order_dt_m]
      ,t.[Order_dt] Date_dt
      ,format(datefromparts(t.[Order_dt_y],t.[Order_dt_m],1),'yyyyMMdd')+trim(t.Category) dt_cat
      ,t.[PRODIDX]
      ,t.[Category]
      ,t.[Quantity], s.[Quantity] Qty_py
      ,t.[Vnet], s.[Vnet] Vnet_py
      ,t.[price_tot] price_tot_akt, s.[price_tot] price_tot_py, (t.[price_tot]/nullif(s.[price_tot],0)) diff_price_tot 
      ,t.[price_onn] price_onn_akt, s.[price_onn] price_onn_py, (t.[price_onn]/nullif(s.[price_onn],0)) diff_price_onn
      ,t.[price_man] price_man_akt, s.[price_man] price_man_py, (t.[price_man]/nullif(s.[price_man],0)) diff_price_man 
      ,t.[Vonn], s.Vonn Vonn_py
      ,t.[Qty_onn], s.[Qty_onn] Qty_onn_py
      ,t.[price_onn]
      ,t.[Qty_man], s.[Qty_man] Qty_man_py
      ,t.[Vman], s.[Vman] Vman_py
      ,t.[price_man] 
      ,t.[Sold_to_count] Sold_to_count_akt, s.[Sold_to_count] Sold_to_count_py
      ,t.[Sold_to_onn] Sold_to_onn_akt, s.[Sold_to_onn] Sold_to_onn_py
      ,t.[Sold_to_man] Sold_to_man_akt, s.[Sold_to_man] Sold_to_man_py
      --,[ModDate]
  FROM [OnnShop20REC].[onn].[DB_sales_price_idx_products] t
    inner join [OnnShop20REC].[onn].[DB_sales_price_idx_products] s on  
       s.Order_dt=dateadd(year,-1,t.Order_dt) AND t.[ProdIdx]=s.[ProdIdx]

--  where t.[Order_dt] = DATEFROMPARTS(2026,2,1)




