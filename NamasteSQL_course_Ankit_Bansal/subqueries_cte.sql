
/********** 1- write a query to find premium customers from orders data. Premium customers are those who have done more orders than average no of orders per customer. ***********/
WITH cnt_ord_per_cust AS(
	SELECT 
		customer_id, COUNT(DISTINCT order_id) AS cnt_orders 
	FROM 
		orders 
	GROUP BY 
		customer_id
)
SELECT * 
FROM
	cnt_ord_per_cust
WHERE
	cnt_orders > (SELECT AVG(cnt_orders) FROM cnt_ord_per_cust)

/**********2- write a query to find employees whose salary is more than average salary of employees in their department***********/

WITH avg_sal_by_dept AS(
SELECT 
	dept_id, AVG(salary) AS avg_sal
FROM 
	employee 
	GROUP BY dept_id
)
SELECT * 
FROM 
	employee e
	INNER JOIN avg_sal_by_dept avsal ON e.dept_id = avsal.dept_id
WHERE e.salary >  avsal.avg_sal

/**********3- write a query to find employees whose age is more than average age of all the employees.***********/
SELECT *
FROM
	employee
WHERE
	emp_age > (SELECT AVG(emp_age) FROM employee)

/**********4- write a query to print emp name, salary and dep id of highest salaried employee in each department ***********/
WITH highest_sal_emp_per_dept AS(
SELECT 
	dept_id, MAX(salary) AS max_sal
FROM
	employee
GROUP BY
	dept_id
)
SELECT
	e.*
FROM
	employee e
	INNER JOIN highest_sal_emp_per_dept hsepd 
		ON hsepd.dept_id = e.dept_id 
		AND hsepd.max_sal = e.salary 

/**********5- write a query to print emp name, salary and dep id of highest salaried overall***********/
SELECT *
FROM employee
WHERE salary = (SELECT MAX(salary) FROM employee)

/**********6- write a query to print product id and total sales of highest selling products (by no of units sold) in each category***********/

with product_quantity as (
select category,product_id,sum(quantity) as total_quantity
from orders 
group by category,product_id)
,cat_max_quantity as (
select category,max(total_quantity) as max_quantity from product_quantity 
group by category
)
select *
from product_quantity pq
inner join cat_max_quantity cmq on pq.category=cmq.category
where pq.total_quantity  = cmq.max_quantity

