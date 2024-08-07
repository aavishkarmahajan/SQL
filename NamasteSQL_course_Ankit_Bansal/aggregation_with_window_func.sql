/*********1- write a sql to find top 3 products in each category by highest rolling 3 months total sales for Jan 2020.***********/

WITH sum_sales AS
(
SELECT category, product_id, DATEPART(YEAR, order_date) AS yr, DATEPART(MONTH, order_date) AS mth, SUM(sales) AS sum_sales
FROM orders
GROUP BY category, product_id, DATEPART(YEAR, order_date), DATEPART(MONTH, order_date)
),
roll_3_mth AS
(
SELECT *, SUM(sum_sales) OVER(PARTITION BY category, product_id ORDER BY yr, mth ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS rolling_sum_3_mth
FROM sum_sales
--WHERE yr = 2020 AND mth = 1
)
SELECT *, RANK() OVER (PARTITION BY category ORDER BY rolling_sum_3_mth DESC) AS rnk_roll_3_mth_tot_sales
FROM roll_3_mth
WHERE yr = 2020 AND mth = 1

/*********2- write a query to find products for which month over month sales has never declined.***********/
WITH monthly_sales AS
(
SELECT product_id, DATEPART(YEAR, order_date) AS yr, DATEPART(MONTH, order_date) AS mth, SUM(sales) AS sum_sales
FROM orders
GROUP BY product_id, DATEPART(YEAR, order_date), DATEPART(MONTH, order_date)
),
prev AS
(	
SELECT *, LAG(sum_sales,1,sum_sales) OVER(PARTITION BY product_id ORDER BY yr, mth) AS prev_mon_sales 
FROM monthly_sales
)
SELECT DISTINCT product_id FROM prev WHERE product_id NOT IN (
SELECT DISTINCT product_id
FROM prev
WHERE sum_sales<prev_mon_sales)

/*********3- write a query to find month wise sales for each category for months where sales is more than the combined sales of previous 2 months for that category.***********/
WITH monthly AS
(
SELECT category, DATEPART(year, order_date) AS yr, DATEPART(month, order_date) AS mth, SUM(SALES) AS monthly_sales
FROM orders
GROUP BY category, DATEPART(year, order_date), DATEPART(month, order_date)
),
prev_sales AS
(
SELECT *, SUM(monthly_sales) OVER (PARTITION BY category ORDER BY yr, mth ROWS BETWEEN 2 PRECEDING AND 1 PRECEDING) AS prev_2_mth_sales
FROM monthly
)
SELECT *
FROM prev_sales
WHERE monthly_sales > prev_2_mth_sales
