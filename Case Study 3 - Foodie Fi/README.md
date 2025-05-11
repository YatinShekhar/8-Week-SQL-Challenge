# Case Study #3- Foodie Fi 🍱
<img src="https://8weeksqlchallenge.com/images/case-study-designs/3.png" alt="Image Description" width="400">

This is the third case study of **8 Week SQL Challenge**.

- I enjoyed solving this [Case Study](https://8weeksqlchallenge.com/case-study-3/)
- The project was somewhat easy as compared to previous one but it was tricky at some points.
- SQL concepts like `joins`, `common table expressions`, `windowing functions` were used in the case study.

# Table Of Content 📋
 * [Project Overview](#project-overview-)
 * [Entity Relationship Diagram](#entity-relationship-diagram-)
 * [Tables](#tables-)
 * [Note](#note-)
 * [Case Studies](#case-studies-)
 * [Insights](#insights-)

# Project Overview 📋

- Danny finds a few smart friends to launch his new startup Foodie-Fi in 2020 and started selling monthly and annual subscriptions, giving their customers unlimited on-demand access to exclusive food videos from around the world!
- It's like he wanted to create a new streaming service that only had food related content - something like Netflix but with only cooking shows.
- Danny is a data-driven person therefore he wants to make all his future investments based on insights from the data.

# Entity Relationship Diagram 📊

![Image](https://github.com/user-attachments/assets/bb3f6c90-cf3c-423a-96a1-315e1058be83)

# Tables 

- **plans:** It contains information about each available plan in the Foodie Fi subscription model with information like `plan_id`, `plan_name` and `price` of the plan
- **subscriptions:** Customer subscriptions show the exact date where their specific plan_id starts. It contains information like `customer_id`, `plan_id`, `start_date`.

# Note:
- If a customer downgrades their account, the higher plan will remain in place until the period is over.
- If a customer upgrades, the higher plan will take effect straightaway.
- When customers churn - they will keep their access until the end of their current billing period but the `start_date` will be technically the day they decided to cancel their service.

# Case Studies ❓

1. [Customer Journey](#customer-journey)
2. [Data Analysis Questions](#data-analysis-questions)

# Customer Journey

## **Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each customer’s onboarding journey.** 

```sql
select 
    * 
from subscriptions 
inner join plans using(plan_id)
where customer_id in (1, 2, 11, 13, 15, 16, 18, 19);
```

- `Customer 1` started with a basic plan.
- `Customer 2` chose pro annul subscription. It shows them enjoying the content.
- `Customer 11` did not liked the platform at all therefore they cancelled their subscription after free trial ended.
- `Customer 13` started with basic plan and then moved to pro monthly. I think they gradually started liking the platform.
- I think cooking ain't the hobby of `Customer 15` as they chose to cancel the subscription.
- `Customer 16` started with basic monthly and then moved to pro annually.
- Cooking's passion made `Customer 18` to move with pro monthly.
- `Customer 19` started with pro monthly and then switched to pro annual.


# Data Analysis Questions

## **1. How many customers has Foodie-Fi ever had?**

```sql
select 
    count(distinct customer_id) as unique_customers 
from subscriptions;
```


| unique_customers |
|------------------|
|      1000        |

- There are `1000` unique customers in Foodie-Fi.


## **2. What is the monthly distribution of trial plan start_date values for our dataset use the start of the month as the group by value**

```sql
select 
    monthname(start_date) as month_name , 
    count(*) as trials
from subscriptions 
where plan_id = 0
group by monthname(start_date), month(start_date)
order by month(start_date);
```

| month_name | trials |
|------------|--------|
| January    | 88     |
| February   | 68     |
| March      | 94     |
| April      | 81     |
| May        | 88     |
| June       | 79     |
| July       | 89     |
| August     | 88     |
| September  | 87     |
| October    | 79     |
| November   | 75     |
| December   | 84     |

- `March` had the highest trials followed by  `July` while `February` had the least trials.

## **3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name**

```sql
select 
    plan_name, 
    count(*) as count
from subscriptions s
inner join plans p on s.plan_id = p.plan_id
where year(start_date ) > 2020
group by plan_name;
```

| plan_name       | count |
|------------------|-------|
| Churn            | 71    |
| Pro Monthly      | 60    |
| Pro Annual       | 63    |
| Basic Monthly    | 8     |

- The number of customers `churned` the Foodie-fi service after 2020 is highest which is `71`
- Customers with `Basic Monthly` subscriptions is least i.e., `8`

## **4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?**

```sql
select 
    sum(case when plan_name = 'churn' then 1 else 0 end ) as churned_customers,
    count(distinct customer_id) as total_customers, 
    concat(round(sum(case when plan_name = 'churn' then 1 else 0 end )* 100.0/count(distinct customer_id),1), "%") as percent_total
from subscriptions s 
left join plans p using(plan_id);
```

| churned_customers | total_customers | percent_total |
|-------------------|------------------|---------|
| 307               | 1000             | 30.7%   |

- Of the total customrers Foodie-Fi ever had, `30.7%` customers churned.

## **5. How many customers have churned straight after their initial free trial what percentage is this rounded to the nearest whole number?**

```sql
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
```

| churned_customers | total_customres | percent_total |
|-------------------|------------------|---------|
| 92                | 1000             | 9%       |

- Of the total customers, almost `9%` of the customers churned after their `initial free trial`

## **6. What is the number and percentage of customer plans after their initial free trial?**

```sql
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
```

| plan_name     | customer_count | percent_total |
|---------------|----------------|----------------|
| basic monthly | 546            | 54.60%         |
| pro annual    | 37             | 3.70%          |
| pro monthly   | 325            | 32.50%         |
| churn         | 92             | 9.20%          |

- More than `half` of the customers went with `basic monthly`
- `9.20%` customers `churned` after their inital free trial
- `3.70%` customers chose `pro annual` plan after their trial.

## **7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?**

```sql
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
```

| plan_name     | customer_count | percent_total |
|---------------|-----------|--------------------|
| pro monthly   | 326       | 32.6%              |
| churn         | 236       | 23.6%              |
| basic monthly | 224       | 22.4%              |
| pro annual    | 195       | 19.5%              |
| trial         | 19        | 1.9%               |

As of `2020-12-31`
* `32.6%` people are subscribed with `pro monthly' which is the highest
* `23.6%` customers have churned
* `1.9%` customers are currently on trial period

## **8. How many customers have upgraded to an annual plan in 2020?**

```sql
select 
    count(*) as customers 
from subscriptions s 
inner join plans p using(plan_id) 
where year(start_date) = 2020 and plan_name = 'pro annual';
```

| customers |
| --------- |
|   195     |

- Total of `195` customers have purchased `pro_annual` in 2020.

## **9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?**

```sql
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
```

| avg_days |
| -------- |
|  105     |

- On average, it takes almost `105` days for a customer to purchase `pro annual` from the day of join.

## **10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)**

```sql
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
```

| period   | customers | avg_days |
|----------|-----------|----------|
| 0-30     | 49        | 10       |
| 31-60    | 24        | 42       |
| 61-90    | 34        | 71       |
| 91-120   | 35        | 101      |
| 121-150  | 42        | 133      |
| 151-180  | 36        | 162      |
| 181-210  | 26        | 191      |
| 211-240  | 4         | 224      |
| 241-270  | 5         | 257      |
| 271-300  | 1         | 285      |
| 301-330  | 1         | 327      |
| 331-360  | 1         | 346      |

- Maximum numbers of customers that is `49 customers` gets converted into a `pro annual member` lies in `0-30 days period`. They take an average of `10 days` to convert from the day of start.
- It is followed by `121-150 days` period in which `42 customers` gets converted and they take an average of `133 days` or `4 months 13 days` to convert.


## **11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?**

```sql
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
```

| downgraded_customers |
| -------------------- |
|     0                |

- No customer downgraded from `pro monthly` to `basic monthly` in 2020.

# Insights: 🔍

## 1. Customer Base Overview
Roughly **1 in 3 customers (30.7%)** have churned over time.

## 2. Trial to Plan Conversion
**March** and **July** are peak months for **trial sign-ups**, suggesting seasonality or effective marketing campaigns.
**February** is the weakest month possibly due to fewer days or lower engagement.

## 3. Post Trial Decisions
A **majority 53%** of users move to **Basic Monthly** after trial.
Only **3.7%** choose the higher-tier **Pro Annual** immediately, indicating hesitancy or cost sensitivity.

## 4. Conversion Timing
The **0–30 days window** is crucial — **49 customers** convert early, in just **10 days** on average.
Another major chunk (**42 customers**) convert after **121–150 days**, taking **~4.5 months** to decide.
This suggests two distinct behavior types:
 - Impulsive or highly satisfied users.
 - Long-term evaluators who commit after extended usage.

## 5. Downgrade Insight
**No downgrades** from **Pro Monthly to Basic Monthly** in 2020 a strong sign that once users commit to Pro, they rarely go backward. Suggests satisfaction or perceived value.


# 🧠 Recommendations

- **Retain trial users better** by optimizing onboarding and adding offers during the first 30 days.
- Consider **nudge campaigns** to convert long-term users into Pro Annual subscribers.
- Since **Basic Monthly** is sticky, try **up-sell strategies** to move them toward **Pro Monthly**.
- The **Pro Monthly** plan is a sweet spot, make it even more valuable to reduce churn further.
- Investigate **February’s poor trial performance**, improve marketing in that period.


