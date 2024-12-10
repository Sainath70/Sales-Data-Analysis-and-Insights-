drop table df_orders;

create table df_orders
(
	order_id int primary key,
	order_date date,
	ship_mode varchar(20),
	segment varchar(20),
	country varchar(20),
	city varchar(20),
	state varchar(20),
	postal_code varchar(20),
	region varchar(20),
	category varchar(20),
	sub_category varchar(20),
	product_id varchar(20),
	quantity int,
	discount decimal(7,2),
	sale_price decimal(7,2),
	profit decimal(7,2)
	
	
	)

select * from df_orders;


--Q1) find top 10 highest revenue genetrating products

--we have to find which products are sold most based on product_id and sale price
--first get for each product what is total sale

select product_id,sum(sale_price) as sales
from df_orders
group by product_id
order by sales desc
limit 10;

--Q2) find top 5 highest selling product in each region

with cte as(
select region,product_id, sum(sale_price) as sales
from df_orders
group  by region, product_id
order by region, sales desc)

select * from
(select * , row_number()over(partition by region order by sales desc) as rn
from cte) A
where rn <= 5;

--Q3)find month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023
WITH cte AS (
    SELECT 
        EXTRACT(YEAR FROM order_date) AS order_year,
        EXTRACT(MONTH FROM order_date) AS order_month,
        SUM(sale_price) AS sales
    FROM df_orders
    GROUP BY EXTRACT(YEAR FROM order_date), EXTRACT(MONTH FROM order_date)
)
SELECT 
    order_month,
    SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS sales_2022,
    SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS sales_2023
FROM cte
GROUP BY order_month
ORDER BY order_month;


--Q4) for each category which month had highest sales 
WITH cte AS (
    SELECT 
        category,
        TO_CHAR(order_date, 'YYYYMM') AS order_year_month,
        SUM(sale_price) AS sales
    FROM df_orders
    GROUP BY category, TO_CHAR(order_date, 'YYYYMM')
)
SELECT *
FROM (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY category ORDER BY sales DESC) AS rn
    FROM cte
) a
WHERE rn = 1;


	
--Q5) which sub category had highest growth by profit in 2023 compare to 2022
with cte as (
select sub_category,EXTRACT(YEAR FROM order_date) as order_year,
sum(sale_price) as sales
from df_orders
group by sub_category,EXTRACT(YEAR FROM order_date)	
--order by year(order_date),month(order_date)
	) 
	
, cte2 as (
select sub_category
, sum(case when order_year=2022 then sales else 0 end) as sales_2022
, sum(case when order_year=2023 then sales else 0 end) as sales_2023
from cte 
group by sub_category
)
select *
,(sales_2023-sales_2022)
from  cte2
order by (sales_2023-sales_2022) desc
limit 1;




