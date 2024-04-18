use kaggle;
select * from orders
limit 10;
select * from product
limit 10;
select distinct product_category from product;
select distinct product_line from product;
select distinct product_group from product;
-- Adding a delivery_days column in orders table:
alter table orders
add column delivery_days int;
update orders
set delivery_days = timestampdiff(day,order_date, delivery_date);



-- Analysis of Customers with membership badge.
-- 1. Membership status and do it affects the delivery time for the orders that takes more than a week to deliver.
SELECT p.country, o.customer_status, ROUND(AVG(o.delivery_days),2) AS avg_delivery_days
FROM orders o
JOIN product AS p ON p.product_id = o.product_id
WHERE o.delivery_days > 7  
GROUP BY p.country, o.customer_status  
ORDER BY p.country, o.customer_status; 


-- 2. Countrywise membership status
with customer_count as(
SELECT p.country, o.customer_status, count(o.customer_id) as customers,
sum(count(o.customer_id)) over(partition by country) as total_customers
FROM orders o
JOIN product AS p 
ON p.product_id = o.product_id
GROUP BY p.country, o.customer_status  
ORDER BY p.country, o.customer_status
)
select country, customer_status, concat(round((customers/total_customers*100),1),"%") as percentage_customers
from customer_count; 




-- 3. profit made from each group of members.
select country,customer_status, sum(profit) as Profit, 
count(order_id) as `Order Count`, 
sum(profit)/count(order_id) as `Profit per Order`
from orders o
join product p
on p.product_id = o.product_id
group by 1,2;

-- 4. Top 3 product each group of members has purchased. 
with top_3 as (
select o.customer_status as `Membership Type`, p.country as `Country`, count(o.product_id) as `Total Orders`,
row_number() over(partition by o.customer_status order by count(o.product_id) desc) as rnk
from orders o
join product p
on p.product_id = o.product_id
group by 1,2
)
select `Membership Type`,`Country`,`Total Orders`
from top_3
where rnk <= 3;

-- Year on Year sales and profit 
with Revenue_cte as (
select distinct year(order_date) as year, month(order_date) as month, concat(round(sum(retail_price)/1000,2),'K') as Revenue 
from orders
group by 1,2
)
select month, 
sum(case when year = 2017 then Revenue else 0 end) as `2017`,
sum(case when year = 2018 then Revenue else 0 end) as `2018`,
sum(case when year = 2019 then Revenue else 0 end) as `2019`,
sum(case when year = 2020 then Revenue else 0 end) as `2020`,
sum(case when year = 2021 then Revenue else 0 end) as `2021`
from Revenue_cte
group by 1;