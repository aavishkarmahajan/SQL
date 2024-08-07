--alter table  employee add dob date;
--update employee set dob = dateadd(year,-1*emp_age,getdate())

/********* 1- write a query to print emp name , their manager name and diffrence in their age (in days) 
for employees whose year of birth is before their managers year of birth ***********/
SELECT
	e.emp_name AS emp_name,
	m.emp_name AS mgr_name,
	DATEDIFF(day, e.dob, m.dob) AS age_diff_days,
	DATEDIFF(year, e.dob, m.dob) AS age_diff_years_using_dob,
	e.emp_age-m.emp_age AS age_diff_years_using_age
FROM
	employee e
	LEFT JOIN employee m ON e.emp_id = m.manager_id
WHERE
	DATEPART(year, e.dob) < DATEPART(year, m.dob)

/********* 2- write a query to find subcategories who never had any return orders in the month of november (irrespective of years)***********/
SELECT 
	DISTINCT o.sub_category, COUNT(r.order_id)
FROM
	orders o
	LEFT JOIN [returns] r ON o.order_id = r.order_id
WHERE
	DATEPART(MONTH,o.order_date) = 11
GROUP BY
	o.sub_category
HAVING COUNT(r.order_id) = 0

/********* 3- orders table can have multiple rows for a particular order_id when customers buys more than 1 product in an order.
write a query to find order ids where there is only 1 product bought by the customer.***********/

SELECT
	o.order_id, COUNT(o.order_id) AS cnt_products
FROM	
	orders o
GROUP BY
	o.order_id
HAVING 
	COUNT(o.order_id) = 1

/********* 4- write a query to print manager names along with the comma separated list(order by emp salary) of all employees directly reporting to him.***********/

SELECT
	m.emp_name AS manager, STRING_AGG(e.emp_name, ';') WITHIN GROUP (ORDER BY e.salary) AS reportees
FROM
	employee m
	INNER JOIN employee e ON m.emp_id = e.manager_id
GROUP BY
	m.emp_name

/********* 5- write a query to get number of business days between order_date and ship_date (exclude weekends). 
Assume that all order date and ship date are on weekdays only***********/
SELECT
	o.order_id, 
	o.order_date, 
	o.ship_date, 
	DATEDIFF(day, o.order_date, o.ship_date) AS diff_days,
	DATEDIFF(week, o.order_date, o.ship_date) AS diff_weeks,
	--take diff in days minus diff in weeks * 2(for weekends)
	--ex if diff in weeks is 1 then 1*2=2 i.e. 2 days will be subtracted from the diff in days. 
	--This is since diff in weeks = 1 means there was week between order dats and ship date
	DATEDIFF(day, o.order_date, o.ship_date)-2*DATEDIFF(week, o.order_date, o.ship_date) AS diff_bus_days
FROM
	orders o

/********* 6- write a query to print 3 columns : category, total_sales and (total sales of returned orders)***********/
SELECT
	o.category, SUM(o.sales) AS total_sales, SUM(CASE WHEN r.order_id IS NOT NULL THEN o.sales END) AS sales_ret_orders
FROM
	orders o
	LEFT JOIN [returns] r ON o.order_id = r.order_id
GROUP BY
	o.category

/********* 7- write a query to print below 3 columns
category, total_sales_2019(sales in year 2019), total_sales_2020(sales in year 2020)***********/
SELECT
	o.category, 
	SUM(CASE WHEN DATEPART(year, o.order_date) = 2019 THEN o.sales END) AS total_sales_2019,
	SUM(CASE WHEN DATEPART(year, o.order_date) = 2020 THEN o.sales END) AS total_sales_2020
FROM
	orders o
GROUP BY
	o.category

/********* 8- write a query print top 5 cities in west region by average no of days between order date and ship date.***********/
SELECT TOP 5
	o.city, AVG(DATEDIFF(day, o.order_date, o.ship_date)) AS avg_days
FROM
	orders o
WHERE
	o.region = 'West'
GROUP BY
	o.city
ORDER BY
	avg_days DESC

/********* 9- write a query to print emp name, manager name and senior manager name (senior manager is manager's manager)***********/

SELECT
	e.emp_name AS emp_name,
	m.emp_name AS mgr_name,
	sm.emp_name AS sm_name
FROM
	employee e
	LEFT JOIN employee m ON e.manager_id = m.emp_id
	LEFT JOIN employee sm ON m.manager_id = sm.emp_id