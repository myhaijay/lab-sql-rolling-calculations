-- 1. Get number of monthly active customers.
select * from sakila.payment;
create or replace view sakila.monthly_customers as
with cte_view as (
select customer_id, date_format(convert(payment_date,date), '%m') as Activity_month,
date_format(convert(payment_date,date), '%Y') as Activity_year
from sakila.payment)
select Activity_year, Activity_month, count(distinct customer_id) as Active_Customers
from cte_view
group by Activity_year , Activity_month
order by Activity_year asc, Activity_month asc;

select * from sakila.monthly_customers;

-- 2. Active users in the previous month.
select 
   Activity_year, 
   Activity_month,
   Active_customers, 
   lag(Active_customers) over (partition by Activity_year order by Activity_Month) as Active_Last_month -- order by Activity_year, Activity_Month -- lag(Active_users, 2) -- partition by Activity_year
from sakila.monthly_customers;


-- 3. Percentage change in the number of active customers.
with cte as (
	select 
   Activity_year, 
   Activity_month,
   Active_customers, 
   lag(Active_customers) over (partition by Activity_year order by Activity_Month) as Active_Last_month 
from sakila.monthly_customers)
select Activity_year, Activity_month, Active_customers, Active_Last_month, 
round(((Active_customers - Active_Last_month)/Active_customers) * 100,2) as Percentage_Change
from cte;


-- 4. Retained customers every month.

select Activity_year, Activity_month,count(*) as Retained_Customers from (
	select active_users1.customer_id, active_users1.Activity_month, active_users1.Activity_year from (
		select customer_id, convert(payment_date, date) as Activity_date,
		date_format(convert(payment_date,date), '%m') as Activity_month,
		date_format(convert(payment_date,date), '%Y') as Activity_year
		from sakila.payment 
		order by Activity_year, Activity_month, customer_id) as active_users1 
	join (select customer_id, convert(payment_date, date) as Activity_date,
		date_format(convert(payment_date,date), '%m') as Activity_month,
		date_format(convert(payment_date,date), '%Y') as Activity_year
		from sakila.payment 
		order by Activity_year, Activity_month, customer_id) as  active_users2 
        on active_users1.customer_id = active_users2.customer_id
		and active_users1.Activity_year = active_users2.Activity_year
		and active_users1.Activity_month = active_users2.Activity_month + 1
		group by active_users1.customer_id, active_users1.Activity_month, active_users1.Activity_year) sub
    group by Activity_month, Activity_year;



