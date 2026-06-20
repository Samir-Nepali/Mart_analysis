--1. Find different payment method and number of transactions, number of qty sold.
select payment_method, count(*) as no_of_payment, sum(quantity) as no_of_quantity_sold from walmart
group by payment_method;

--2. Find the highest_rated category in each branch, displaying the branch, category, avg rating.
 select * from (select branch , category, avg(rating) as avg_rating, rank() over (partition by branch order by avg(rating)desc)
from walmart  group by 1,2) where rank=1;

--3. Find the busiest day for each branch based on the number of transactions.
 select * from(select branch , to_char(to_date(date,'DD/MM/YY'),'Day') as day_name,
count(*) as no_transactions,
rank() over(partition by branch order by count(*)desc)as rank from walmart group by 1,2) where rank=1

--4. Calculate the total quantity of items sold per payment method. List payment_method and total_quantity.
select payment_method, sum(quantity) as total_quantity from walmart group by payment_method;

--5. Determine the average, minimum and maximum rating of category for each city. list the city, average _rating,min_rating and max_rating.
select city, category, min(rating)as min_rating, max(rating) as max_rating, avg(rating) as avg_rating from walmart 
group by city , category;

--6. Calculate the total profit for each category by considering total_profit as (unit_price *quantity * profit_margin).
-- List category and total_profit, ordered from highest to lowest profit.
select category, sum(total) as total_revenue, sum(total+profit_margin)as profit from walmart  group by category;

--7. Determine the most common payment method for each branch. Display Branch and the preferred_payment_method.
with cte as (select branch, payment_method, count(*)as total_trans, rank() over (partition by branch order by count(*)desc) as rank
from walmart group by 1,2) select * from cte where rank=1;

--8. Categorize sales into 3 group Morning, Afternoon, Evening. Find Out each of the shift and number of invoices.
select branch,
case when extract(hour from(time::time))< 12 then 'Morning'
     when extract(hour from(time::time)) between 12 and 17 then 'Afternoon'
     Else 'Evening'
	 end day_time,
	 count(*)
from walmart
group by 1,2 order by 1,3 desc;

--9. Find 5 branch with highest decrease ratio in revenue compare to last year(present 2023 and last 2022)
select *, 
extract(year from to_date(date,'DD/MM/YY'))as day_name
from walmart

with revenue_2022 as
(select branch, sum(total)as revenue from walmart where extract(year from to_date(date,'DD/MM/YY'))=2022
group by 1),
revenue_2023 as
(select branch, sum(total)as revenue from walmart where extract(year from to_date(date,'DD/MM/YY'))=2023
group by 1)
select ls.branch, ls.revenue as last_year_revenue,
cs.revenue as current_year_revenue,
round((ls.revenue-cs.revenue)::numeric/ls.revenue::numeric*100,2) as rev_dec_ratio
from revenue_2022 as ls
join
revenue_2023 as cs 
on ls.branch=cs.branch where ls.revenue> cs.revenue order by 4 desc limit 5