-- Customer Journey

-- Based off the 8 sample customers provided in the sample from the subscriptions table, 
-- write a brief description about each customer’s onboarding journey.
  
select 
    * 
from subscriptions 
inner join plans using(plan_id)
where customer_id in (1, 2, 11, 13, 15, 16, 18, 19);

-- Customer 1 started with a basic plan at first
-- Customer 2 was so fond of cooking that he chose to go with pro annul subscription
-- Customer 11 did not liked the platform at all therefore he cancelled his subscription after his free trial ended
-- Customer 13 started with basic plan and then moved to pro monthly. I think he is liking the platform
-- I think food is not the love of customer id 15 as he chose to cancel the subscription
-- customer 16 started with basic monthly and then moved to pro annually
-- Cooking's passion made Customer 18 to move with pro monthly
-- Customer 19 started with pro monthly and then switched to pro annual


-- Data Analysis

-- 1. How many customers has Foodie-Fi ever had?

select 
    count(distinct customer_id) as unique_customers 
from subscriptions;

-- 2. What is the monthly distribution of trial plan start_date values for our dataset - 
-- use the start of the month as the group by value

select 
    monthname(start_date) as month_name , 
    count(*) as trials
from subscriptions 
where plan_id = 0
group by monthname(start_date), month(start_date)
order by month(start_date);

-- 3. What plan start_date values occur after the year 2020 for our dataset? 
-- Show the breakdown by count of events for each plan_name

select 
    plan_name, 
    count(*) as count
from subscriptions s
inner join plans p on s.plan_id = p.plan_id
where year(start_date ) > 2020
group by plan_name;

-- 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

select 
    sum(case when plan_name = 'churn' then 1 else 0 end ) as churned_customers,
    count(distinct customer_id) as total_customers, 
    concat(round(sum(case when plan_name = 'churn' then 1 else 0 end )* 100.0/count(distinct customer_id),1), "%") as percent_total
from subscriptions s 
left join plans p using(plan_id);

-- 5. How many customers have churned straight after their initial free trial -
-- what percentage is this rounded to the nearest whole number?

with cte as 
(
    select 
        *, 
        row_number() over(partition by customer_id order by start_date) as rn
    from subscriptions 
    inner join plans using(plan_id)
    )
select 
    count(*) as churned_customers,
    (select count(distinct customer_id) from subscriptions) as total_customers ,
    concat(round(count(*) * 100.0/(select count(distinct customer_id) from subscriptions), 0), '%')  as percent_total
from cte 
where plan_name = 'churn' and rn = 2;

-- 6. What is the number and percentage of customer plans after their initial free trial?

with cte as 
(
    select 
        *, 
        row_number() over(partition by customer_id order by start_date) as rn
    from subscriptions 
    inner join plans using(plan_id)
    )
select 
    plan_name, 
    count(*) as customer_count, 
    concat(round(count(*)* 100.0/(select count(distinct customer_id) from subscriptions),2), "%") as percent_total
from cte 
where rn = 2
group by plan_name;

-- 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?

with cte as
(
    select 
        s.customer_id, 
        s.plan_id, 
        p.plan_name, 
        s.start_date, 
        dense_rank() over (partition by s.customer_id order by s.start_date desc) as rk
    from subscriptions s
    join plans p ON s.plan_id = p.plan_id
    where s.start_date <= '2020-12-31'
),
cte2 as
(
    select  
        count(distinct customer_id) as total_customers
    from subscriptions
)
select 
    plan_name, 
    count(plan_name) as customer_count,
    concat(round(count(plan_name) / max(total_customers) * 100, 1), '%') as percent_total
from cte, cte2
where rk = 1
group by plan_name
order by customer_count desc;

-- 8. How many customers have upgraded to an annual plan in 2020?

select 
    count(*) as customers 
from subscriptions s 
inner join plans p using(plan_id) 
where year(start_date) = 2020 and plan_name = 'pro annual';

-- 9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?

with cte as
(
    select 
        * ,
        lag(start_date, 1) over(partition by customer_id order by start_date) as lg 
    from subscriptions s 
    inner join plans p using(plan_id)
    where plan_name in ('trial', 'pro annual')
    )
select 
    round(avg(datediff(start_date, lg)),0) as avg_days
from cte 
where lg is not null;

-- 10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)

with recursive cte as
(
    select 
        0 as a, 
        30 as b
    union all
    select 
        b+1, 
        b+30 
    from cte 
    where b < 346
    )
, cte2 as
(
    select 
        a, 
        b, 
        concat(a, '-', b) as `period`
    from cte
    )
, cte3 as 
(
    select 
        * ,
        lag(start_date, 1) over(partition by customer_id order by start_date) as lg 
    from subscriptions s 
    inner join plans p using(plan_id)
    where plan_name in ('trial', 'pro annual')
    )
, cte4 as 
(
    select 
        datediff(start_date, lg) as date_diff 
    from cte3 
    where lg is not null
    )
select 
`period`, count(date_diff) as customers, avg(date_diff) as avg_days
from cte4 
inner join cte2 on a <= date_diff and b>= date_diff
group by `period`
order by cast(left(`period`, position('-' in period)-1) as unsigned);

-- 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

with cte as 
(
    select 
        *, 
        row_number() over(partition by customer_id order by start_date) as rn 
    from subscriptions 
    inner join plans using(plan_id)
    where plan_name in ('pro monthly', 'basic monthly') and year(start_date) = 2020
    )
select 
    case when count(customer_id) is null 
    then 0 else count(customer_id) end as downgraded_customers
from cte 
where rn = 2 and plan_name = 'basic monthly';



