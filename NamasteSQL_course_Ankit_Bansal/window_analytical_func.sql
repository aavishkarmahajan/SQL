/*****************1- write a query to print 3rd highest salaried employee details for each department (give preferece to younger employee in case of a tie). 
--In case a department has less than 3 employees then print the details of highest salaried employee in that department. ****************/

WITH base AS(
SELECT 
	*, DENSE_RANK() OVER(partition by dept_id ORDER BY salary DESC) AS row_num
FROM 
	employee
),
third_highest_sal AS(
SELECT *
FROM 
	base
WHERE
	row_num = 3
),
highest_sal AS(
SELECT *
FROM 
	base
WHERE
	row_num = 1
)
SELECT * FROM third_highest_sal
UNION
SELECT * FROM highest_sal WHERE dept_id NOT IN (SELECT dept_id FROM third_highest_sal)

--sol2
with rnk as (
select *, dense_rank() over(partition by dept_id order by salary desc) as rn
,count(1) over(partition by dept_id ) as no_of_emp
from employee)
select
*
from 
rnk 
where rn=3 or  (no_of_emp<3 and rn=1) 

/*****************2- write a query to find top 3 and bottom 3 products by sales in each region.****************/

--my way 1
SELECT TOP 3 * FROM(
SELECT *, RANK() OVER(PARTITION BY region ORDER BY sum_sales DESC) AS rnk
FROM(
SELECT product_id, region, SUM(sales) AS sum_sales
FROM orders
GROUP BY product_id, region
)ss
)top3
UNION
SELECT TOP 3 * FROM(
SELECT *, RANK() OVER(PARTITION BY region ORDER BY sum_sales ASC) AS rnk
FROM(
SELECT product_id, region, SUM(sales) AS sum_sales
FROM orders
GROUP BY product_id, region
)ss
)bot3
ORDER BY sum_sales DESC

--my way 2
SELECT * FROM(
	SELECT *, 
		RANK() OVER(PARTITION BY region ORDER BY sum_sales DESC) AS toprnk,
		RANK() OVER(PARTITION BY region ORDER BY sum_sales) AS botrnk
	FROM(
	SELECT product_id, region, SUM(sales) AS sum_sales
	FROM orders
	GROUP BY product_id, region
	)ss
)ss2
WHERE ss2.toprnk <=3 OR ss2.botrnk <=3

/*****************3- Among all the sub categories..which sub category had highest month over month growth by sales in Jan 2020.****************/

WITH month_wise_catg_sales AS(
SELECT FORMAT(order_date, 'yyyy-MM') AS sale_year_month, sub_category, SUM(sales) AS sum_sales FROM orders
GROUP BY FORMAT(order_date, 'yyyy-MM'), sub_category
),
previous_month_sales AS(
SELECT *, LAG(sum_sales,1, sum_sales) OVER(PARTITION BY sub_category ORDER BY sale_year_month) AS sales_prev_month
FROM month_wise_catg_sales
)
SELECT TOP 1 *, (sum_sales-sales_prev_month)/sales_prev_month AS mom_gr
FROM previous_month_sales
WHERE sale_year_month = '2020-01'
ORDER BY mom_gr DESC

/*****************4- write a query to print top 3 products in each category by year over year sales growth in year 2020.****************/
WITH sales AS(
SELECT
	product_id, category, DATEPART(YEAR, order_date) AS year_order_date, SUM(sales) AS sum_sales
FROM
	orders
GROUP BY 
	product_id, category, DATEPART(YEAR, order_date)
)--,
--prev_sales AS(
SELECT 
	*, LAG(sum_sales, 1, sum_sales) OVER(PARTITION BY category,product_id ORDER BY year_order_date) AS prev_year_sales
FROM 
	sales
),
yoy AS(
SELECT
	*, (sum_sales-prev_year_sales)/prev_year_sales AS yoy_sales
FROM
	prev_sales
WHERE
	year_order_date = 2020
),
ranking AS(
SELECT
	*, RANK() OVER(PARTITION BY category ORDER BY yoy_sales DESC) AS rnk
FROM
	yoy
)
SELECT * FROM ranking WHERE rnk <=3

with cat_sales as (
select category,product_id,datepart(year,order_date) as order_year, sum(sales) as sales
from orders
group by category,product_id,datepart(year,order_date)
)
, prev_year_sales as (select *,lag(sales) over(partition by category,product_id order by order_year) as prev_year_sales
from cat_sales)
,rnk as (
select   * ,rank() over(partition by category order by (sales-prev_year_sales)/prev_year_sales desc) as rn
from prev_year_sales
where order_year='2020'
)
select * from rnk where rn<=3
------------------------------------------------------------------------------

create table call_start_logs
(
phone_number varchar(10),
start_time datetime
);
insert into call_start_logs values
('PN1','2022-01-01 10:20:00'),('PN1','2022-01-01 16:25:00'),('PN2','2022-01-01 12:30:00')
,('PN3','2022-01-02 10:00:00'),('PN3','2022-01-02 12:30:00'),('PN3','2022-01-03 09:20:00')
create table call_end_logs
(
phone_number varchar(10),
end_time datetime
);
insert into call_end_logs values
('PN1','2022-01-01 10:45:00'),('PN1','2022-01-01 17:05:00'),('PN2','2022-01-01 12:55:00')
,('PN3','2022-01-02 10:20:00'),('PN3','2022-01-02 12:50:00'),('PN3','2022-01-03 09:40:00')
;
--select * from call_start_logs
--select * from call_end_logs

/*****************5 write a query to get start time and end time of each call from above 2 tables.Also create a column of call duration in minutes.  Please do take into account that
there will be multiple calls from one phone number and each entry in start table has a corresponding entry in end table.****************/



WITH start_log AS(
SELECT *, ROW_NUMBER() OVER(PARTITION BY phone_number ORDER BY start_time) AS row_num 
FROM call_start_logs
),
end_log AS(
SELECT *, ROW_NUMBER() OVER(PARTITION BY phone_number ORDER BY end_time) AS row_num 
FROM call_end_logs
)
SELECT s.phone_number, s.start_time, e.end_time, DATEDIFF(mi, s.start_time, e.end_time) AS call_duration_mins
FROM start_log s
	INNER JOIN end_log e 
	ON s.phone_number = e.phone_number AND s.row_num = e.row_num