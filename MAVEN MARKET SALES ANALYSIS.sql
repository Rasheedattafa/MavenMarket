--JOINING TRANSACTION TABLES
SELECT * FROM  DBO.MavenMarket_Transactions_1998 
UNION ALL 
SELECT  * FROM   MavenMarket_Transactions_1997 
 
 CREATE VIEW TRANSACTIONS AS
 (
    SELECT      *  FROM  DBO.MavenMarket_Transactions_1998 
    UNION ALL 
    SELECT   *  FROM    MavenMarket_Transactions_1997 
    ) 
SELECT  * FROM TRANSACTIONS


---REVENUE,COST AND PROFIT
WITH SALES(
transaction_date, product_id, customer_id, 
  store_id, quantity, product_cost, product_retail_price, cost_price, 
  Revenue
) AS 
(
  SELECT transaction_date, TRANSACTIONS.product_id, customer_id, 
    store_id,  quantity,  product_cost, product_retail_price, 
    ROUND(quantity * product_cost, 0) AS Cost_price, 
    ROUND(quantity * product_retail_price, 0) AS Revenue 
  FROM TRANSACTIONS 
    JOIN MavenMarket_Products ON TRANSACTIONS.product_id = MavenMarket_Products.product_id
) 
SELECT 
SUM(quantity) AS Total_orders,ROUND(SUM(cost_price),0) AS Cost, 
ROUND(SUM(Revenue), 0) AS Revenue, ROUND( SUM(Revenue - cost_price),  0) AS profit 
FROM SALES


---QUANTITIES SOLD
SELECT
  transaction_date,  YEAR(transaction_date) AS Year, 
  MONTH(transaction_date) AS Month,  Quantity, 
  SUM(Quantity) OVER (ORDER BY transaction_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RunningQuantity, 
  SUM(Quantity) OVER (PARTITION BY transaction_date) AS total_daily_qnty, 
  SUM(Quantity) OVER( PARTITION BY YEAR(transaction_date), MONTH(transaction_date)) AS MTD_quantity, 
  SUM(Quantity) OVER(PARTITION BY YEAR(transaction_date)) AS YTD_quantity 
FROM TRANSACTIONS


 --TOP 30 PRODUCTS
SELECT 
  DISTINCT TOP 30 TRANSACTIONS.product_id, product_name, 
  SUM(TRANSACTIONS.quantity) OVER(PARTITION BY TRANSACTIONS.product_id ) AS ORDERS, 
  sum(quantity * product_retail_price) OVER(PARTITION BY TRANSACTIONS.product_id) AS REVENUE 
FROM 
  TRANSACTIONS 
  JOIN MavenMarket_Products ON TRANSACTIONS.product_id = MavenMarket_Products.product_id 
ORDER BY 
  ORDERS DESC


   ---TOP 10 CUSTOMERS
  SELECT 
  DISTINCT TOP 10 TRANSACTIONS.customer_id, first_name, last_name, 
  SUM(TRANSACTIONS.quantity) OVER( PARTITION BY TRANSACTIONS.customer_id
  ) AS ORDERS, 
  sum(quantity * product_retail_price) OVER(PARTITION BY TRANSACTIONS.customer_id
  ) AS REVENUE 
FROM 
  TRANSACTIONS 
  JOIN MavenMarket_Customers ON TRANSACTIONS.customer_id = MavenMarket_Customers.customer_id 
  JOIN MavenMarket_Products ON TRANSACTIONS.product_id = MavenMarket_Products.product_id 
ORDER BY 
  ORDERS DESC


  -- ---TOTAL REGONAL SALES
SELECT 
  DISTINCT MavenMarket_Stores.store_country, 
  SUM(TRANSACTIONS.quantity) OVER( PARTITION BY MavenMarket_Stores.store_country) AS ORDERS 
FROM 
  TRANSACTIONS 
  JOIN MavenMarket_Stores ON TRANSACTIONS.store_id = MavenMarket_Stores.store_id 
ORDER BY 
  ORDERS DESC


----TOTAL RETURNS
SELECT 
  product_id, SUM(quantity) AS RETURNED 
FROM 
  [MavenMarket_Returns_1997-1998]
GROUP BY 
  product_id 
ORDER BY 
  RETURNED DESC