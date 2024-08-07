/******************* 1- write a query to get region wise count of return orders *******************/
SELECT 
	o.region,
	--o.*,
	COUNT(DISTINCT r.order_id) AS count_return_orders
	--r.order_id,
	--r.return_reason
FROM
	orders o
	LEFT JOIN [returns] r ON o.order_id = r.order_id
--WHERE
---	o.region = 'South'
GROUP BY
	o.region

/******************* 2- write a query to get category wise sales of orders that were not returned *******************/
SELECT
	o.category, SUM(o.sales) AS sum_sales
FROM
	orders o
	LEFT JOIN [returns] r ON o.order_id = r.order_id
WHERE
	r.order_id IS NULL
GROUP BY
	o.category

/******************* 3- write a query to print dep name and average salary of employees in that dep *******************/
SELECT
	d.dep_name, AVG(e.salary) AS avg_sal
FROM
	dept d
	LEFT JOIN employee e ON d.dep_id = e.dept_id
GROUP BY 
	d.dep_name

/******************* 4- write a query to print dep names where none of the emplyees have same salary *******************/
SELECT
	d.dep_name, e.salary, COUNT(1)
FROM
	employee e
	INNER JOIN dept d
		ON e.dept_id = d.dep_id
GROUP BY
	d.dep_name, e.salary
HAVING COUNT(1) = 1

/******************* 5- write a query to print sub categories where we have all 3 kinds of returns (others,bad quality,wrong items) *******************/
--descriptive results
SELECT
	o.order_id, o.sub_category, o.*, r.return_reason
	--o.sub_category, r.return_reason, COUNT(1)
FROM
	orders o
	INNER JOIN [returns] r ON o.order_id = r.order_id
WHERE
	r.return_reason in ('Bad Quality','Others','Wrong Items')
	AND o.sub_category = 'Bookcases'
GROUP BY o.sub_category, r.return_reason
ORDER BY o.sub_category, r.return_reason

--quantitative results
SELECT
	a.sub_category, COUNT(1)
FROM(
SELECT
	DISTINCT o.sub_category, r.return_reason
FROM
	orders o
	INNER JOIN [returns] r ON o.order_id = r.order_id
WHERE
	r.return_reason in ('Bad Quality','Others','Wrong Items')
)a
GROUP BY a.sub_category
HAVING COUNT(1) = 3

/******************* 6- write a query to find cities where not even a single order was returned *******************/

SELECT DISTINCT city FROM orders o
WHERE city NOT IN(
SELECT
	DISTINCT o.city
FROM
	orders o
	INNER JOIN [returns] r ON o.order_id = r.order_id
)

/******************* 7- write a query to find top 3 subcategories by sales of returned orders in east region *******************/
SELECT TOP 3
	o.sub_category, SUM(o.sales) AS sum_sales
FROM
	orders o
	INNER JOIN [returns] r ON o.order_id = r.order_id
WHERE
	o.region = 'East'
GROUP BY
	o.sub_category
ORDER BY
	sum_sales DESC

/******************* 8- write a query to print dep name for which there is no employee *******************/
SELECT
	d.dep_name
FROM
	dept d
	LEFT JOIN employee e ON e.dept_id = d.dep_id
WHERE
	e.dept_id IS NULL

/******************* 9- write a query to print employees name for dep id is not avaiable in dept table *******************/
SELECT
	e.emp_name
FROM
	employee e
	LEFT JOIN  dept d ON e.dept_id = d.dep_id
WHERE
	d.dep_id IS NULL
