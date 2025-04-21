# Case Study #2- Pizza Runner 🍕
<img src="https://8weeksqlchallenge.com/images/case-study-designs/2.png" alt="Image Description" width="400">

This is the second case study of **8 Week SQL Challenge**.

- This [Case Study](https://8weeksqlchallenge.com/case-study-2/) is the most challenging I have encountered so far.
- I approached it with all the `SQL` knowledge I have accumulated, and the journey has been incredibly rewarding. 
- The best aspect of this project was the process itself. I gained a deep understanding of new concepts, and by breaking down each problem step by step, I steadily built my confidence.

# Table Of Content
 * [Project Overview](#project-overview-)
 * [Entity Relationship Diagram](#entity-relationship-diagram-)
 * [Note](#note-)
 * [Data Cleaning](#data-cleaning-)
 * [Case Study Questions](#case-study-questions-)
 * [Insights](#insights-)

# Project Overview 📋
- After the successful launch of [Danny's Diner](https://8weeksqlchallenge.com/case-study-1/), Danny has decided to start his new venture called [Pizza Runner](https://8weeksqlchallenge.com/case-study-2/).
- Danny has build a mobile app for receiving all the orders and alos recruited runners which would be assisting in delivering pizzas.
- With the few days of the operations, Danny has collected the data and now wants to apply calculations to his data to optimiste
the Pizza Runner's operations and to guide his runners well.
- There are few tables in this case study which need to be cleaned before using them in the queries.

# Entity Relationship Diagram 📊
![Pizza Runner](https://github.com/YatinShekhar/8-Week-SQL-Challenge/assets/121398971/cc4ffeaf-a7ad-4c8a-8ad3-5c30c3af2c8b)

# Tables 
- **runners:** It contains `runner_id` along with the `registration_date`.
- **customer_orders:** All the information about the customer's orders is recorded in this table along with the `customer_id`.
- **runner_orders:** It contains information about the delivery of the order along with the `runner_id`.
- **pizza_names:** All the `pizza_name` along with `pizza_id`.
- **pizza_toppings:** All the toppings available along with `topping_id`.
- **pizza_recipes:** The specific toppings used in the making of specific pizzas.

# Note: 💡
I have solved each question using a single SQL statement. But there are easier ways by which you can solve the similar problem. 

For eg: You can create `helper tables` which will reduce your code a lot.

# Data Cleaning ⛏
Their are two tables `customer_orders` and `runner_orders` which needs cleaning like handling **null**, cleaning particular columns, assigning proper datatypes, etc., before using them into the queries.
## Customer_Orders

This is the metadata of the `customer_orders` dataset.

```sql
describe customer_orders;
```

| Field        | Type       | Null | Key | Default | Extra |
|--------------|------------|------|-----|---------|-------|
| order_id     | int        | YES  |     |         |       |
| customer_id  | int        | YES  |     |         |       |
| pizza_id     | int        | YES  |     |         |       |
| exclusions   | varchar(4) | YES  |     |         |       |
| extras       | varchar(4) | YES  |     |         |       |
| order_time   | timestamp  | YES  |     |         |       |

By looking at the metadata, it seems pretty fine. Therefore, we do not require `DDL Commands` to change the structure of the data.

This is how the uncleaned table looks like :-

| order_id | customer_id | pizza_id | exclusions | extras | order_time           |
|----------|-------------|----------|------------|--------|----------------------|
| 1        | 101         | 1        |            |        | 2021-01-01 18:05:02  |
| 2        | 101         | 1        |            |        | 2021-01-01 19:00:52  |
| 3        | 102         | 1        |            |        | 2021-01-02 23:51:23  |
| 3        | 102         | 2        |            | NaN    | 2021-01-02 23:51:23  |
| 4        | 103         | 1        | 4          |        | 2021-01-04 13:23:46  |
| 4        | 103         | 1        | 4          |        | 2021-01-04 13:23:46  |
| 4        | 103         | 2        | 4          |        | 2021-01-04 13:23:46  |
| 5        | 104         | 1        | null       | 1      | 2021-01-08 21:00:29  |
| 6        | 101         | 2        | null       | null   | 2021-01-08 21:03:13  |
| 7        | 105         | 2        | null       | 1      | 2021-01-08 21:20:29  |
| 8        | 102         | 1        | null       | null   | 2021-01-09 23:54:33  |
| 9        | 103         | 1        | 4          | 1, 5   | 2021-01-10 11:22:59  |
| 10       | 104         | 1        | null       | null   | 2021-01-11 18:34:49  |
| 10       | 104         | 1        | 2, 6       | 1, 4   | 2021-01-11 18:34:49  |

- The 'null' string in the `exclusions` column needs to be assigned **null**.
- The `extras` contains unknown values as **'NaN'** and **'null'** string which needs to be converted into one particular type that is **null**.
- We will be using `DML Command` like `update` to clean the dataset.

```sql
update customer_orders
set 
  exclusions = case when exclusion in ('', 'null') then null end,
  extras = case when extras in ('', 'null') then null end;
```
And this is how the table looks like after claning the table :-

| order_id | customer_id | pizza_id | exclusions | extras | order_time           |
|----------|-------------|----------|------------|--------|----------------------|
| 1        | 101         | 1        |            |        | 2020-01-01 18:05:02  |
| 2        | 101         | 1        |            |        | 2020-01-01 19:00:52  |
| 3        | 102         | 1        |            |        | 2020-01-02 23:51:23  |
| 3        | 102         | 2        |            |        | 2020-01-02 23:51:23  |
| 4        | 103         | 1        | 4          |        | 2020-01-04 13:23:46  |
| 4        | 103         | 1        | 4          |        | 2020-01-04 13:23:46  |
| 4        | 103         | 2        | 4          |        | 2020-01-04 13:23:46  |
| 5        | 104         | 1        |            | 1      | 2020-01-08 21:00:29  |
| 6        | 101         | 2        |            |        | 2020-01-08 21:03:13  |
| 7        | 105         | 2        |            | 1      | 2020-01-08 21:20:29  |
| 8        | 102         | 1        |            |        | 2020-01-09 23:54:33  |
| 9        | 103         | 1        | 4          | 1, 5   | 2020-01-10 11:22:59  |
| 10       | 104         | 1        |            |        | 2020-01-11 18:34:49  |
| 10       | 104         | 1        | 2, 6       | 1, 4   | 2020-01-11 18:34:49  |

## Runner_Orders

This is the metadata of the raw dataset :-

```sql
describe runner_orders;
```

| Field        | Type        | Null | Key | Default | Extra |
|--------------|-------------|------|-----|---------|-------|
| order_id     | int         | YES  |     |         |       |
| runner_id    | int         | YES  |     |         |       |
| pickup_time  | varchar(19) | YES  |     |         |       |
| distance     | varchar(7)  | YES  |     |         |       |
| duration     | varchar(10) | YES  |     |         |       |
| cancellation | varchar(23) | YES  |     |         |       |

The `pickup_time` needs to be converted into datetime, `distance` and `duration` into numeric datatype.\
We will be using `DDL Command` to change the definition of the table. But we will be doing it after cleaning the table.\
This is how the raw table looks like :-

| order_id | runner_id | pickup_time          | distance | duration     | cancellation             |
|----------|-----------|----------------------|----------|--------------|--------------------------|
| 1        | 1         | 2021-01-01 18:15:34  | 20km     | 32 minutes   |                          |
| 2        | 1         | 2021-01-01 19:10:54  | 20km     | 27 minutes   |                          |
| 3        | 1         | 2021-01-03 00:12:37  | 13.4km   | 20 mins      | NaN                      |
| 4        | 2         | 2021-01-04 13:53:03  | 23.4     | 40           | NaN                      |
| 5        | 3         | 2021-01-08 21:10:57  | 10       | 15           | NaN                      |
| 6        | 3         | null                 | null     | null         | Restaurant Cancellation  |
| 7        | 2         | 2020-01-08 21:30:45  | 25km     | 25mins       | null                     |
| 8        | 2         | 2020-01-10 00:15:02  | 23.4 km  | 15 minute    | null                     |
| 9        | 2         | null                 | null     | null         | Customer Cancellation    |
| 10       | 1         | 2020-01-11 18:50:20  | 10km     | 10minutes    | null                     |

- The `distance` column needs to be cleaned and converted into numeric datatype.
- Same goes with `duration` column.
- And dealing with **'null'** and **'NaN'** values in the `cancellation` column.

```sql
update runner_orders
set
  pickup_time = case when pickup_time in ('', 'null') then null 
                     else pickup_time end,
  distance = case when distance = 'null' then null
		              when distance like '%km' then replace(distance, 'km', '') 
		              else distance end,
  duration = case when duration = 'null' then null
		              when duration like '%m%' then trim(insert(duration, position('m' in duration), length(duration), '')) 
		              else duration end, 
  cancellation = case when cancellation in ('', 'null') then null 
                      else cancellation end;
```

- After cleaning the table, we also need to convert the datatypes of the cleaned column into the required ones.
- We will be changing the datatypes of the columns using `alter` `modify` command.

```sql
alter table runner_orders
modify pickup_time timestamp,
modify distance float,
modify duration int;
```

This is how the cleaned version looks like :-

| order_id | runner_id | pickup_time          | distance | duration | cancellation             |
|----------|-----------|----------------------|----------|----------|--------------------------|
| 1        | 1         | 2020-01-01 18:15:34  | 20       | 32       |                          |
| 2        | 1         | 2020-01-01 19:10:54  | 20       | 27       |                          |
| 3        | 1         | 2020-01-03 00:12:37  | 13.4     | 20       |                          |
| 4        | 2         | 2020-01-04 13:53:03  | 23.4     | 40       |                          |
| 5        | 3         | 2020-01-08 21:10:57  | 10       | 15       |                          |
| 6        | 3         |                      |          |          | Restaurant Cancellation  |
| 7        | 2         | 2020-01-08 21:30:45  | 25       | 25       |                          |
| 8        | 2         | 2020-01-10 00:15:02  | 23.4     | 15       |                          |
| 9        | 2         |                      |          |          | Customer Cancellation    |
| 10       | 1         | 2020-01-11 18:50:20  | 10       | 10       |                          |

Since the tables have been cleaned, therefore let's move to the case studies.

# Case Studies ❓

This case study has been grouped into 5 different parts-
1. [Pizza Metrices](#pizza-metrices-)
2. [Runners and Customer Experiences](#runners-and-customer-experiences-)
3. [Ingredient Optimisation](#ingredient-optimisation-)
4. [Pricing and Ratings](#pricing-and-ratings-)
5. [Bonus Question](#bonus-question-)

# 1. Pizza Metrices

## **1.1 How many pizzas were ordered?**

```sql
select 
    count(*) as pizza_ordered
from customer_orders;
```
| pizzas_ordered |
|----------------|
| 14             |

- There were a total of 14 pizzas ordered from `Pizza Runner`

## **1.2 How many unique customer orders were made?**

```sql
select 
    count(distinct order_id) as unique_customer_orders
from customer_orders;
```
| unique_customer_orders |
|------------------------|
| 10                     |

- Total 10 orders were unique customer orders

## **1.3 How many successful orders were delivered by each runner?**

- Successful orders are the orders which were delivered and not cancelled by the customer or the restaurant.

```sql
select 
    runner_id, 
    count(order_id) as successful_deliveries
from runner_orders
where cancellation is null
group by runner_id;
```

| runner_id | successful_deliveries |
|-----------|------------------------|
| 1         | 4                      |
| 2         | 3                      |
| 3         | 1                      |

- **Runner 1** delivered 4 orders
- **Runner 2** delivered 3 orders
- **Runner 3** delivered 1 successful order

## **1.4 How many each type of pizza was delivered?**

```sql
select 
    pizza_id, 
    pizza_name, 
    count(*) as pizza_delivered
from customer_orders
inner join pizza_names using(pizza_id)
inner join runner_orders using(order_id)
where cancellation is null
group by pizza_id, pizza_name;
```

| pizza_id | pizza_name  | pizzas_delivered |
|----------|-------------|------------------|
| 1        | Meatlovers  | 9               |
| 2        | Vegetarian  | 3               |

- There were total 14 pizzas ordered. Out of them 12 were delivered and 2 were cancelled.
- Out of 12 delivered pizzas, 9 were `Meatlovers` and 3 were `Vegetarian`

## **1.5 How many Vegetarian and Meatlovers were ordered by each customer?**

```sql
select 
    customer_id,
    sum(case when pizza_name = 'Meatlovers' then 1 else 0 end) as Meatlovers , 
    sum(case when pizza_name = 'Vegetarian' then 1 else 0 end) as Vegetarian 
from customer_orders
inner join pizza_names using(pizza_id)
group by customer_id;
```

| customer_id | Meatlovers | Vegetarian |
|-------------|------------|------------|
| 101         | 2          | 1          |
| 102         | 2          | 1          |
| 103         | 3          | 1          |
| 104         | 3          | 0          |
| 105         | 0          | 1          |

- By looking at the result, it seems customers loves `Meatlovers` as compared to `Vegetarian`

## **1.6 What was the maximum number of pizzas delivered in a single order?**

```sql
select 
    co.order_id, 
    co.customer_id, 
    count(*) as no_of_orders_delivered
from customer_orders co 
inner join runner_orders ro using(order_id)
where cancellation is null
group by order_id, customer_id
order by no_of_orders_delivered desc
limit 1;
```

| order_id | customer_id | no_of_orders_delivered |
|----------|-------------|------------------------|
| 4        | 103         | 3                      |

- `Customer 103` ordered maximum number of pizzas in an order

## **1.7 For each customer, how many delivered pizzas had at least 1 change and how many had no changes?**

```sql
select 
    customer_id,
    sum(case when exclusions is null and extras is null then 1 else 0 end) as had_no_change,
    sum(case when exclusions is not null or extras is not null then 1 else 0 end) as had_at_least_one_change
from customer_orders 
inner join runner_orders using(order_id)
where cancellation is null
group by customer_id;
```

| customer_id | had_no_change | had_at_least_one_change |
|-------------|---------------|-------------------------|
| 101         | 2             | 0                       |
| 102         | 3             | 0                       |
| 103         | 0             | 3                       |
| 104         | 1             | 2                       |
| 105         | 0             | 1                       |

- `Customer 103` had done the most changes while `Customer 102` had the minimum changes

## **1.8 How many pizzas were delivered that had both exclusions and extras?**

```sql
select 
    sum(case when exclusions is not null and extras is not null then 1 else 0 end) as no_of_pizzas_with_exclusion_and_extras
from customer_orders 
inner join runner_orders using(order_id)
where cancellation is null;
```

| no_of_pizzas_with_exclusion_and_extras |
|----------------------------------------|
| 1                                      |

- There was just 1 pizza which had both the `excluded` as well as `extra` toppings.

## **1.9 What was the total volume of pizzas ordered for each hour of the day?**

```sql
with recursive cte as 
(
    select 0 as hour
    union all
    select hour + 1 from cte where hour < 23
    )
select 
    hour as hour_of_the_day,
    sum(case when order_time is not null then 1 else 0 end) as total_orders
from cte
left join customer_orders on cte.hour = hour(order_time)
group by hour;
```

| hour_of_the_day | total_orders |
|-----------------|--------------|
| 0               | 0            |
| 1               | 0            |
| 2               | 0            |
| 3               | 0            |
| 4               | 0            |
| 5               | 0            |
| 6               | 0            |
| 7               | 0            |
| 8               | 0            |
| 9               | 0            |
| 10              | 0            |
| 11              | 1            |
| 12              | 0            |
| 13              | 3            |
| 14              | 0            |
| 15              | 0            |
| 16              | 0            |
| 17              | 0            |
| 18              | 3            |
| 19              | 1            |
| 20              | 0            |
| 21              | 3            |
| 22              | 0            |
| 23              | 3            |


- Most of the orders are place at `1:00 PM`, `6:00 PM`, `9:00 PM` and `11:00 PM`
- `12:00 AM` to `10:00 AM`, there are no orders

## **10. What was the volume of orders for each day of the week?**

```sql
with recursive cte as 
(
    select now() as a, now() as b
    union all
    select a, date_add(b, interval 1 day) from cte where 
    datediff(b,a) <6 
    )
select 
    dayname(b) as day, 
    count(order_id) as total_orders from cte 
left join customer_orders co on dayname(b) = dayname(order_time)
group by 1;
```

| day       | total_orders |
|-----------|--------------|
| Tuesday   | 0            |
| Wednesday | 5            |
| Thursday  | 3            |
| Friday    | 1            |
| Saturday  | 5            |
| Sunday    | 0            |
| Monday    | 0            |

- Most of the orders are placed on `Wednesday` and `Saturday` followed by `Thursday`
- No orders are placed on `Sunday`, `Monday` and `Tuesday`


# 2. Runners and Customer Experiences

## **1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)**

```sql
with recursive cte as 
(
    select '2021-01-01' as start_date, date_add('2021-01-01', interval 6 day) as end_date
    union all
    select date_add(end_date, interval 1 day) , date_add(end_date, interval 7 day)
    from cte 
    where end_date < '2021-01-31'
    )
select 
    row_number() over(order by start_date) as week , 
    start_date, 
    end_date , 
    sum(case when registration_date is not null then 1 else 0 end) as total_registration 
from cte 
left join runners r
on registration_date between start_date and end_date
group by start_date, end_date;
```

| Week | Start Date | End Date   | Total Registrations |
|------|------------|------------|----------------------|
| 1    | 2021-01-01 | 2021-01-07 | 2                    |
| 2    | 2021-01-08 | 2021-01-14 | 1                    |
| 3    | 2021-01-15 | 2021-01-21 | 1                    |
| 4    | 2021-01-22 | 2021-01-28 | 0                    |
| 5    | 2021-01-29 | 2021-02-04 | 0                    |

- Most of the runners registered in the `1st week` of the month

## **2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?**

```sql
with cte as 
(
    select c.order_id, runner_id, avg(timestampdiff(minute, order_time, pickup_time)) as diff
    from runner_orders r 
    inner join customer_orders c
    using(order_id)
    where pickup_time is not null
    group by 1, 2
    )
select 
    runner_id, 
    concat(round(avg(diff),0), ' mins') as avg_time_to_arrive 
from cte
group by 1;
```

| runner_id | avg_time_to_arrive |
|-----------|--------------------|
| 1         | 14 mins            |
| 2         | 20 mins            |
| 3         | 10 mins            |


- `Runner 2` takes `maximum` time to reach to the HQ
- `Runner 3` takes the `minimum`

## **3. Is there any relationship between the number of pizzas and how long the order takes to prepare?**

```sql
with cte as
(
    select order_id, runner_id, timestampdiff(minute, order_time, pickup_time) as time_difference, count(*) as no_of_orders
    from customer_orders
    inner join runner_orders
    using(order_id)
    group by 1,2,3
    )
select 
    no_of_orders, 
    concat(round(avg(time_difference), 0), ' min') as avg_time
from cte
group by 1
order by 1 desc;
```

| no_of_orders | avg_time |
|--------------|----------|
| 3            | 29 min |
| 2            | 18 min |
| 1            | 12 min |

- As the number of pizzas in an order increases the average time taken to prepare it also increases.
- Time taken to prepare is `directly proportional` to the pizzas in an order.


## **4. What was the average distance travelled for each customer?**

```sql
with cte as
(
    select order_id, customer_id, distance
    from customer_orders co
    inner join runner_orders ro
    using(order_id)
    group by 1,2,3
    )
select 
    customer_id, 
    concat(round(avg(distance), 1), ' km') as avg_distance_travelled
from cte 
group by 1;
```

| customer_id | avg_distance_travelled |
|-------------|-------------------------|
| 101         | 20 km                   |
| 102         | 18.4 km                 |
| 103         | 23.4 km                 |
| 104         | 10 km                   |
| 105         | 25 km                   |

- Average distance travelled for `Customer 104` is 10 km as he may live/work near to the restaurant.
- While the delivery distance is farthest for `Customer 105`


## **5. What was the difference between the longest and shortest delivery times for all orders?**

```sql
select 
    concat(max(duration) - min(duration), ' min') as delivery_time_difference
from  runner_orders;
```

| delivery_time_distance |
|------------------------|
|        30 min          |

- The difference between the longest delivery time and the shortest delivery time is `30 min`

## **6. What was the average speed for each runner for each delivery and do you notice any trend for these values?**

```sql
with cte as 
(
    select runner_id, order_id, round(distance/ (duration/60), 1) as speed 
    from runner_orders ro inner join customer_orders co
    using(order_id)
    where distance is not null
    )
select 
    runner_id, 
    order_id, 
    avg(speed) as `avg_speed(in kmph)`
from cte
group by 1, 2
order by 1, 2;
```

| runner_id | order_id | avg_speed(in kmph) |
|-----------|----------|----------------------|
| 1         | 1        | 37.5                 |
| 1         | 2        | 44.4                 |
| 1         | 3        | 40.2                 |
| 1         | 10       | 60                   |
| 2         | 4        | 35.1                 |
| 2         | 7        | 60                   |
| 2         | 8        | 93.6                 |
| 3         | 5        | 40                   |

- `Runner 2` had the fastest speed among all but his speed varies a lot for different orders.
- `Runner 1` was the slowest but has a consistent speed.


## **7. What is the successful delivery percentage for each runner?**

```sql
with cte as
(
    select runner_id, count(order_id) - count(cancellation) as delivered_orders, 
    count(order_id) as total_orders
    from runners left join runner_orders
    using(runner_id)
    group by runner_id
    )
select 
    *, 
    concat(round(delivered_orders/total_orders * 100.0, 0), '%')  as successful_deliveries 
from cte;
```

| runner_id | delivered_orders | total_orders | successful_deliveries |
|-----------|------------------|--------------|-----------------------|
| 1         | 4                | 4            | 100%                  |
| 2         | 3                | 4            | 75%                   |
| 3         | 1                | 2            | 50%                   |
| 4         | 0                | 0            | N/A                   |

- `Runner 1` had the successful delivery percentage of 100


# 3. Ingredient Optimisation

## **1. What are the standard ingredients for each pizza?**

```sql
with recursive cte as 
(
    select pizza_id, toppings from pizza_recipes
    union all
    select pizza_id, substr(toppings, position(',' in toppings) + 2 ) from cte
    where length(toppings) > 2
    )
, cte2 as 
(
    select pizza_id, substring_index(toppings, ',', 1) as topping_id from cte
    )
, cte3 as 
(
    select pizza_name, topping_name
    from cte2 inner join pizza_names using(pizza_id)
    inner join pizza_toppings using(topping_id)
    )
select 
    pizza_name, 
    group_concat(topping_name separator ', ' ) as standard_ingredient
from cte3
group by pizza_name;
```

| pizza_name | standard_ingredient                                                    |
|------------|------------------------------------------------------------------------|
| Meatlovers | Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami  |
| Vegetarian | Cheese, Mushrooms, Onions, Peppers, Tomatoes, Tomato Sauce             |


## **2. What was the most commonly added extra?**

```sql
with recursive cte as 
(
    select order_id, extras from customer_orders 
    where extras is not null
    union all
    select order_id, substr(extras, position(',' in extras) + 2 ) from cte
    where length(extras) > 2
    )
, cte2 as 
(
    select order_id, substring_index(extras, ',', 1) as topping_id from cte
    )
select 
    topping_id, 
    topping_name, count(*) as no_of_times_added
from cte2 
inner join pizza_toppings using(topping_id)
group by 1, 2
order by no_of_times_added desc 
limit 1;
```

| topping_id | topping_name | no_of_times_added |
|------------|--------------|-------------------|
| 1          | Bacon        | 4                 |


- `Bacon` was added in 4 of the 14 pizzas.

## **3. What was the most common exclusion?**

```sql
with recursive cte as 
(
    select order_id, exclusions from customer_orders 
    where exclusions is not null
    union all
    select order_id, substr(exclusions, position(',' in exclusions) + 2 ) from cte
    where length(exclusions) > 2
    )
, cte2 as 
(
    select order_id, substring_index(exclusions, ',', 1) as topping_id from cte
    )
select 
    topping_id, 
    topping_name, 
    count(*) as no_of_times_excluded
from cte2 
inner join pizza_toppings using(topping_id)
group by 1, 2
order by no_of_times_excluded desc 
limit 1;
```

| topping_id | topping_name | no_of_times_excluded |
|------------|--------------|----------------------|
| 4          | Cheese       | 4                    |

-- Cheese was excluded in 4 of the 14 pizzas

## **4. Generate an order item for each record in the customers_orders table in the format of one of the following:**
## Meat Lovers
## Meat Lovers - Exclude Beef
## Meat Lovers - Extra Bacon
## Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

```sql
with cte as 
(
    select *, row_number() over(order by order_id) as rn
    from customer_orders inner join pizza_names
    using(pizza_id)
    )
, cte2 as 
(
    with recursive a as (
    select rn, exclusions from cte
    union all
    select rn, substr(exclusions, position(',' in exclusions) + 2 ) from a
    where length(exclusions) > 2 )
    , b as (
    select rn, substring_index(exclusions, ',', 1) as topping_id from a)
    , c as (
    select rn, topping_name 
    from b left join pizza_toppings
    using(topping_id))
    , d as (
    select rn, group_concat(topping_name separator ', ') as excluded_toppings from c
    group by rn)
    select rn, case when excluded_toppings is not null then ' - Exclude ' else '' end as excluded_case,
    excluded_toppings from d
    )
, cte3 as 
(
    with recursive a as (
    select rn, extras from cte
    union all
    select rn, substr(extras, position(',' in extras) + 2 ) from a
    where length(extras) > 2 )
    , b as (
    select rn, substring_index(extras, ',', 1) as topping_id from a)
    , c as (
    select rn, topping_name 
    from b left join pizza_toppings
    using(topping_id))
    , d as (
    select rn, group_concat(topping_name separator ', ') as extra_toppings from c
    group by rn)
    select rn, case when extra_toppings is not null then ' - Extra ' else '' end as extra_case,
    extra_toppings from d
    )
select 
    order_id, 
    customer_id,
    concat(pizza_name, excluded_case, coalesce(excluded_toppings, ''), extra_case, coalesce(extra_toppings, '')) as order_item
from cte 
inner join cte2 using(rn)
inner join cte3 using(rn);
```

| order_id | customer_id | order_item                                                      |
|----------|-------------|-----------------------------------------------------------------|
| 1        | 101         | Meatlovers                                                      |
| 2        | 101         | Meatlovers                                                      |
| 3        | 102         | Meatlovers                                                      |
| 3        | 102         | Vegetarian                                                      |
| 4        | 103         | Meatlovers - Exclude Cheese                                     |
| 4        | 103         | Meatlovers - Exclude Cheese                                     |
| 4        | 103         | Vegetarian - Exclude Cheese                                     |
| 5        | 104         | Meatlovers - Extra Bacon                                        |
| 6        | 101         | Vegetarian                                                      |
| 7        | 105         | Vegetarian - Extra Bacon                                        |
| 8        | 102         | Meatlovers                                                      |
| 9        | 103         | Meatlovers - Exclude Cheese - Extra Bacon, Chicken              |
| 10       | 104         | Meatlovers                                                      |
| 10       | 104         | Meatlovers - Exclude BBQ Sauce, Mushrooms - Extra Bacon, Cheese |


## **5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients 
For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"

```sql
with recursive cte as 
(
	select pizza_id, toppings from pizza_recipes
	union all
	select pizza_id, substr(toppings, position(',' in toppings) + 2 ) from cte
	where length(toppings) > 2
    )
, cte2 as 
(
	select pizza_id, substring_index(toppings, ',', 1) as topping_id from cte
    )
, cte3 as 
(
	select pizza_id, pizza_name, topping_name
	from cte2 inner join pizza_names using(pizza_id)
	inner join pizza_toppings using(topping_id)
    )
, cte4 as (
    select pizza_id, pizza_name, 
    group_concat(topping_name separator ', ' ) as standard_ingredient
    from cte3
    group by pizza_id, pizza_name)
select 
    co.order_id,
    co.customer_id,
    case 
        when co.exclusions = '2, 6' and co.extras = '1, 4' and co.pizza_id = '1' then concat(pn.pizza_name, ': ', '2xBacon,Beef,2xCheese,Chicken,Pepperoni,Salami')
        when co.exclusions = '4' and co.extras = '1, 5' and co.pizza_id = '1' then concat(pn.pizza_name, ': ', '2xBacon,BBQ Sauce,Beef,2xChicken,Mushrooms,Pepperoni,Salami')
        when co.exclusions = '4' and co.pizza_id = 1 then concat(pn.pizza_name, ': ', 'Bacon,BBQ Sauce,Beef,Chicken,Mushrooms,Pepperoni,Salami')
        when co.exclusions = '4' and co.pizza_id = 2 then concat(pn.pizza_name, ': ', 'Mushrooms,Onions,Peppers,Tomato Sauce,Tomatoes')
        when co.extras = '1' and co.pizza_id = 1 then concat(pn.pizza_name, ': ', '2xBacon,BBQ Sauce,Beef,Cheese,Chicken,Mushrooms,Pepperoni,Salami')
        when co.extras = '1' and co.pizza_id = 2 then concat(pn.pizza_name, ': ', 'Bacon,Cheese,Mushrooms,Onions,Peppers,Tomato Sauce,Tomatoes')
        else concat(pn.pizza_name, ': ', cte4.standard_ingredient)
    end as list_of_ingredients
from customer_orders co
inner join pizza_names pn on co.pizza_id = pn.pizza_id
inner join cte4 on cte4.pizza_id = co.pizza_id;
```

| order_id | customer_id | list_of_ingredients                                                                            |
|----------|-------------|-----------------------------------------------------------------------------------------------|
| 1        | 101         | Meatlovers: Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami             |
| 2        | 101         | Meatlovers: Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami             |
| 3        | 102         | Meatlovers: Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami             |
| 3        | 102         | Vegetarian: Cheese, Mushrooms, Onions, Peppers, Tomatoes, Tomato Sauce                        |
| 4        | 103         | Meatlovers: Bacon, BBQ Sauce, Beef, Chicken, Mushrooms, Pepperoni, Salami                     |
| 4        | 103         | Meatlovers: Bacon, BBQ Sauce, Beef, Chicken, Mushrooms, Pepperoni, Salami                     |
| 4        | 103         | Vegetarian: Mushrooms, Onions, Peppers, Tomato Sauce, Tomatoes                                |
| 5        | 104         | Meatlovers: 2xBacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami           |
| 6        | 101         | Vegetarian: Cheese, Mushrooms, Onions, Peppers, Tomatoes, Tomato Sauce                        |
| 7        | 105         | Vegetarian: Bacon, Cheese, Mushrooms, Onions, Peppers, Tomato Sauce, Tomatoes                 |
| 8        | 102         | Meatlovers: Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami             |
| 9        | 103         | Meatlovers: 2xBacon, BBQ Sauce, Beef, 2xChicken, Mushrooms, Pepperoni, Salami                 |
| 10       | 104         | Meatlovers: Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami            |
| 10       | 104         | Meatlovers: 2xBacon, Beef, 2xCheese, Chicken, Pepperoni, Salami                               |


## **6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?**

```sql
with cte as 
(
    with recursive a as (
    select pizza_id, toppings from pizza_recipes
    union all
    select pizza_id, substr(toppings, position(',' in toppings) + 2 ) from a
    where length(toppings) > 2 )
    , b as 
    (select pizza_id, substring_index(toppings, ',', 1) as topping_id from a)
    select topping_name, count(*) as count
    from b 
    inner join pizza_toppings using(topping_id)
    inner join customer_orders using(pizza_id)
    inner join runner_orders using(order_id)
    where cancellation is null
    group by topping_name
    ) 
, cte2 as 
(
    with recursive a as (
    select order_id, extras from customer_orders 
    where extras is not null
    union all
    select order_id, substr(extras, position(',' in extras) + 2 ) from a
    where length(extras) > 2 )
    , b as 
    (select order_id, substring_index(extras, ',', 1) as topping_id from a)
    select  topping_name, count(*) as no_of_times_added
    from b 
    inner join pizza_toppings using(topping_id)
    inner join runner_orders using(order_id)
    where cancellation is null
    group by 1
    )
, cte3 as 
(
    with recursive a as (
    select order_id, exclusions from customer_orders 
    where exclusions is not null
    union all
    select order_id, substr(exclusions, position(',' in exclusions) + 2 ) from a
    where length(exclusions) > 2 )
    , b as 
    (select order_id, substring_index(exclusions, ',', 1) as topping_id from a)
    select  topping_name, count(*) as no_of_times_excluded
    from b 
    inner join pizza_toppings using(topping_id)
    inner join runner_orders using(order_id)
    where cancellation is null
    group by 1
    ) 
select 
    cte.topping_name, 
    count + coalesce(no_of_times_added, 0) - coalesce(no_of_times_excluded, 0) as ingredient_quantity
from cte 
left join cte2 using(topping_name)
left join cte3 using(topping_name)
order by ingredient_quantity desc;
```

| topping_name  | ingredient_quantity |
|---------------|---------------------|
| Bacon         | 12                  |
| Mushrooms     | 11                  |
| Cheese        | 10                  |
| Beef          | 9                   |
| Chicken       | 9                   |
| Pepperoni     | 9                   |
| Salami        | 9                   |
| BBQ Sauce     | 8                   |
| Onions        | 3                   |
| Peppers       | 3                   |
| Tomatoes      | 3                   |
| Tomato Sauce  | 3                   |

- `Bacon` is used the most in all the pizzas followed by `Mushrooms`
- The least used ingredient is `Tomato Sauce`

# 4. Pricing and Ratings

## **1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?**

```sql
with cte as 
(
    select co.*, pn.pizza_name
    from customer_orders co 
    inner join pizza_names pn using(pizza_id)
    inner join runner_orders ro using(order_id)
    where cancellation is null
    )
select 
    concat('$',sum(case when pizza_name = "Meatlovers" then 12 else 10 end)) as total_revenue
from cte;
```

| total_revenue |
|---------------|
| $138          |


## **2. What if there was an additional $1 charge for any pizza extras? Add cheese is $1 extra**

```sql
with cte as 
(
    select co.*, pn.pizza_name
    from customer_orders co 
    inner join pizza_names pn using(pizza_id)
    inner join runner_orders ro using(order_id)
    where cancellation is null
    )
, cte2 as 
(
    select case when pizza_name = "Meatlovers" then 12 else 10 end as pizza_cost
    , 1 * (length(extras) - length(replace(extras, ',', '')) + 1) as extras_cost
    from cte
    )
select 
    concat('$', sum(pizza_cost) + sum(extras_cost)) as total_revenue 
from cte2;
```

| total_revenue |
|---------------|
| $142          |

## **3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.**

```sql
create table ratings as  
select ro.order_id, customer_id, runner_id,
(case when duration <= 10 then 5      
      when duration > 10 and duration <= 20 then 4      
      when duration > 20 and duration <= 30 then 3      
      when duration > 30 and duration <= 40 then 2      
      else 1 end ) as rating 
from customer_orders co 
inner join runner_orders ro using(order_id) 
where cancellation is null 
group by 1,2,3,4;
```
```sql
select * from ratings;
```

| order_id | customer_id | runner_id | rating |
|----------|-------------|-----------|--------|
| 1        | 101         | 1         | 2      |
| 2        | 101         | 1         | 3      |
| 3        | 102         | 1         | 4      |
| 4        | 103         | 2         | 2      |
| 5        | 104         | 3         | 4      |
| 7        | 105         | 2         | 3      |
| 8        | 102         | 2         | 4      |
| 10       | 104         | 1         | 5      |

` When delivery time is less than 10 minutes than rating is 5
` When delivery time is more than 10 and less than 20 mins than 4
` When delivery time is between 20 and 30 then 3
` When deilvery is less tahn 40 minutes than 2
` And in all other cases it's 1

- Runner 1 has the highest and the lowest rating amongst all.


## **4. Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?**
-- customer_id
-- order_id
-- runner_id
-- rating
-- order_time
-- pickup_time
-- Time between order and pickup
-- Delivery duration
-- Average speed
-- Total number of pizzas

```sql
with cte as 
(
    select r.customer_id, r.order_id, r.runner_id, r.rating, 
    co.order_time, 
    ro.pickup_time,
    concat(timestampdiff(minute, order_time, pickup_time), ' min') as time_diff, 
    concat(ro.duration, ' min') as delivery_duration, 
    concat(round(distance/ (duration/60), 1), ' km/h') as avg_speed
    from ratings r 
    inner join customer_orders co using(order_id)
    inner join runner_orders ro using(order_id)
    )
, cte2 as 
(
    select order_id, count(*) as total_pizzas
    from customer_orders co 
    inner join runner_orders ro using(order_id)
    group by 1)
select 
    distinct customer_id, 
    order_id, 
    runner_id, 
    rating, 
    order_time, 
    pickup_time, 
    time_diff, 
    delivery_duration, 
    avg_speed, 
    total_pizzas
from cte inner join cte2 using(order_id);
```

| customer_id | order_id | runner_id | rating | pickup_time          | delivery_time        | time_diff | delivery_duration | avg_speed | total_pizzas |
|-------------|----------|-----------|--------|----------------------|----------------------|-----------|-------------------|-----------|--------------|
| 101         | 1        | 1         | 2      | 2020-01-01 18:05:02  | 2020-01-01 18:15:34  | 10 min   | 32 min            | 37.5 km/h | 1            |
| 101         | 2        | 1         | 3      | 2020-01-01 19:00:52  | 2020-01-01 19:10:54  | 10 min   | 27 min            | 44.4 km/h | 1            |
| 102         | 3        | 1         | 4      | 2020-01-02 23:51:23  | 2020-01-03 00:12:37  | 21 min   | 20 min            | 40.2 km/h | 2            |
| 103         | 4        | 2         | 2      | 2020-01-04 13:23:46  | 2020-01-04 13:53:03  | 29 min   | 40 min            | 35.1 km/h | 3            |
| 104         | 5        | 3         | 4      | 2020-01-08 21:00:29  | 2020-01-08 21:10:57  | 10 min   | 15 min            | 40 km/h   | 1            |
| 105         | 7        | 2         | 3      | 2020-01-08 21:20:29  | 2020-01-08 21:30:45  | 10 min   | 25 min            | 60 km/h   | 1            |
| 102         | 8        | 2         | 4      | 2020-01-09 23:54:33  | 2020-01-10 00:15:02  | 20 min   | 15 min            | 93.6 km/h | 1            |
| 104         | 10       | 1         | 5      | 2020-01-11 18:34:49  | 2020-01-11 18:50:20  | 15 min   | 10 min            | 60 km/h   | 2            |


## **5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?**

```sql
with cte as 
(
    select sum(case when pizza_name = "Meatlovers" then 12 else 10 end )as total_revenue
    from customer_orders co 
    inner join pizza_names pn using(pizza_id)
    inner join runner_orders ro using(order_id)
    where cancellation is null
    )
, cte2 as 
(
    select round(sum(distance) * 0.3, 1) as delivery_charge from runner_orders 
    where cancellation is null
    )
select 
    concat('$', total_revenue - delivery_charge) as leftover_revenue
from cte join cte2;
```

| leftover_revenue |
|------------------|
| $94.4            |


# 5. Bonus Question

## **If Danny wants to expand his range of pizzas - how would this impact the existing data design? Write an INSERT statement to demonstrate what would happen if a new Supreme pizza with all the toppings was added to the Pizza Runner menu?**

```sql
insert into pizza_recipes values (3, '1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12');
```

```sql
insert into pizza_names values (3, 'Supreme');
```

```sql
select 
    pr.pizza_id, 
    pizza_name, 
    toppings
from pizza_recipes pr 
inner join pizza_names pn using(pizza_id);
```

| pizza_id | pizza_name  | toppings            |
|----------|-------------|---------------------|
| 1        | Meatlovers  | 1, 2, 3, 4, 5, 6, 8, 10 |
| 2        | Vegetarian  | 4, 6, 7, 9, 11, 12  |
| 3        | Supreme     | 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12 |

- `Supreme` pizza contains all the toppings