
--first we tried to create a table from jupyter and then use replace option to  bring the data here, however,
--it seems like in this case the datatypes are not memmory efficient . 
--so we decide to create table manualy in sql and append the data from the python to the created table here.

--drop table df_orders

--create table df_orders (
--order_id    int primary key,
--order_date  date,
--ship_mode varchar(20),
--segment        varchar(20),
--country         varchar(20),
--city             varchar(20),
--state            varchar(20),
--postal_code     varchar(20),
--region          varchar(20),
--category       varchar(20),
--sub_category   varchar(20),
--product_id  varchar(50),
--quantity   int,
--discount   decimal(7,2),
--sale_price decimal(7,2),
--profit  decimal(7,2)
--)

--select * from df_orders

--1. find top 10 highest reveue generating products(which products are sold more)
select top 10 product_id, sum(sale_price) as sale
from df_orders
group by product_id
order by sale desc


--2.find top 5 highest selling products in each region. since we want the top 5 sales in each region we generate rank

with cte as (
select  product_id, region, sum(sale_price) as sale
from df_orders
group by region, product_id
 )
select * 
from (
select *
, ROW_NUMBER() over(partition by region order by sale desc) as rn
from cte) A
where rn <=5

--3.find month over month growth comparison for 2022 and 2023 sales eg jan 2022 and jan 2023

with cte as(select month(order_date) as month, year(order_date) as year, sum(sale_price) as sales
from df_orders
group by month(order_date), year(order_date)
)

select month
,sum(case when year = 2022 then sales else 0 end) as sales_2022
, sum(case when year = 2023 then sales else 0 end) as sales_2023

from cte
group by month
order by month

--4.for each category which month has the highest sale?
with cte as (select category, month(order_date) as  order_month, sum(sale_price) as sales
from df_orders
group by category, month(order_date))

select * from(
select *,
ROW_NUMBER() over(partition by category order by sales desc) as rn
from cte) a 
where rn=1

--5.which sub category had highest growth by profit in 2023 compare to 2022?
with cte as (
select sub_category, year(order_date) as order_year, sum(sale_price) as sales
from df_orders
group by sub_category, year(order_date))
,cte2 as (

select sub_category
,sum(case when order_year= 2022 then sales else 0 end) as sales_2022
,sum(case when order_year= 2023 then sales else 0 end) as sales_2023
from cte
group by sub_category)

select top 1 *, (sales_2023 - sales_2022)*100 / sales_2022 as profit_percent
from cte2
order by profit_percent desc


 


 


