--create table icc_world_cup
--(
--team_1 Varchar(20),
--team_2 Varchar(20),
--winner Varchar(20)
--);
--INSERT INTO icc_world_cup values('India','SL','India');
--INSERT INTO icc_world_cup values('SL','Aus','Aus');
--INSERT INTO icc_world_cup values('SA','Eng','Eng');
--INSERT INTO icc_world_cup values('Eng','NZ','NZ');
--INSERT INTO icc_world_cup values('Aus','India','India');

/*************** 1- write a query to produce below output from icc_world_cup table.
team_name, no_of_matches_played , no_of_wins , no_of_losses *********************/

SELECT team, SUM(win_flag)
FROM(
SELECT team_1 AS team, CASE WHEN team_1=winner THEN 1 ELSE 0 END AS win_flag
FROM icc_world_cup
union all
SELECT team_2 AS team, CASE WHEN team_2=winner THEN 1 ELSE 0 END AS win_flag
FROM icc_world_cup
)a
GROUP BY team


/*************** 2- write a query to print first name and last name of a customer using orders table
(everything after first space can be considered as last name) *********************/
SELECT 
	customer_name, 
	TRIM(LEFT(customer_name, CHARINDEX(' ', customer_name))) AS first_name, 
	RIGHT(customer_name, LEN(customer_name)-CHARINDEX(' ', customer_name)) AS last_name
FROM	
	orders o

--create table drivers(id varchar(10), start_time time, end_time time, start_loc varchar(10), end_loc varchar(10));
--insert into drivers values('dri_1', '09:00', '09:30', 'a','b'),('dri_1', '09:30', '10:30', 'b','c'),('dri_1','11:00','11:30', 'd','e');
--insert into drivers values('dri_1', '12:00', '12:30', 'f','g'),('dri_1', '13:30', '14:30', 'c','h');
--insert into drivers values('dri_2', '12:15', '12:30', 'f','g'),('dri_2', '13:30', '14:30', 'c','h');

/*************** 3- write a query to print below output using drivers table. 
Profit rides are the no of rides where end location of a ride is same as start location of immediate next ride for a driver *********************/
 
SELECT
	d1.id, COUNT(1) AS count_rides, COUNT(d2.id) AS count_profit_rides
FROM
	drivers d1
	LEFT JOIN drivers d2 ON d1.id = d2.id AND d1.end_loc = d2.start_loc AND d1.end_time = d2.start_time
GROUP BY d1.id

/*************** 4- write a query to print customer name and no of occurence of character 'n' in the customer name.*********************/
--SELECT customer_name,  FROM orders 
select customer_name , len(customer_name)-len(replace(lower(customer_name),'n','')) as count_of_occurence_of_n
from orders

/*************** 5-write a query to print below output from orders data. example output
hierarchy type,hierarchy name ,total_sales_in_west_region,total_sales_in_east_region and so on all the category ,subcategory and ship_mode hierarchies 
*********************/
SELECT
	'category' AS hierarchy_type,
	category AS hierarchy_name,
	SUM(CASE WHEN region = 'WEST' THEN sales END) AS total_sales_in_west_region,
	SUM(CASE WHEN region = 'EAST' THEN sales END) AS total_sales_in_east_region
FROM
	orders
GROUP BY category
UNION ALL
SELECT
	'sub-category' AS hierarchy_type,
	sub_category AS hierarchy_name,
	SUM(CASE WHEN region = 'WEST' THEN sales END) AS total_sales_in_west_region,
	SUM(CASE WHEN region = 'EAST' THEN sales END) AS total_sales_in_east_region
FROM
	orders
GROUP BY sub_category
UNION ALL
SELECT
	'ship_mode' AS hierarchy_type,
	ship_mode AS hierarchy_name,
	SUM(CASE WHEN region = 'WEST' THEN sales END) AS total_sales_in_west_region,
	SUM(CASE WHEN region = 'EAST' THEN sales END) AS total_sales_in_east_region
FROM
	orders
GROUP BY ship_mode


/*************** - the first 2 characters of order_id represents the country of order placed . write a query to print total no of orders placed in each country
(an order can have 2 rows in the data when more than 1 item was purchased in the order but it should be considered as 1 order) *********************/
SELECT
	LEFT(order_id, 2), COUNT(DISTINCT order_id) AS count_orders
FROM
	orders
GROUP BY
	LEFT(order_id, 2)