-- case study questions


-- A. Pizza Metrices

-- 1. How many pizzas were ordered?

select 
    count(*) as pizza_ordered
from customer_orders;

-- 2. How many unique customer orders were made?

select 
    count(distinct order_id) as unique_customer_orders 
from customer_orders;

-- 3. How many successful orders were delivered by each runner?

select 
    runner_id, 
    count(order_id) as successful_deliveries 
from runner_orders 
where cancellation is null
group by runner_id;

-- 4. How many of each type of pizza was delivered?

select 
    pizza_id, 
    pizza_name, 
    count(*) as pizza_delivered
from customer_orders 
inner join pizza_names using(pizza_id)
inner join runner_orders using(order_id)
where cancellation is null
group by pizza_id, pizza_name;

-- 5. How many Vegetarian and Meatlovers were ordered by each customer?

select 
    customer_id, 
    sum(case when pizza_name = 'Meatlovers' then 1 else 0 end) as Meatlovers, 
    sum(case when pizza_name = 'Vegetarian' then 1 else 0 end) as Vegetarian 
from customer_orders 
inner join pizza_names using(pizza_id)
group by 1;

-- 6. What was the maximum number of pizzas delivered in a single order?

select 
    co.order_id, 
    count(*) as no_of_orders_delivered
from customer_orders co 
inner join runner_orders ro using(order_id)
where cancellation is null
group by 1
order by 2 desc
limit 1;

-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

select 
    customer_id, 
    sum(case when exclusions is null and extras is null then 1 else 0 end) as had_no_change,
    sum(case when exclusions is not null or extras is not null then 1 else 0 end) as had_at_least_one_change
from customer_orders 
inner join runner_orders using(order_id)
where cancellation is null
group by customer_id;

-- 8. How many pizzas were delivered that had both exclusions and extras?

select 
    sum(case when exclusions is not null and extras is not null then 1 else 0 end) as no_of_pizzas_with_exclusion_and_extras
from customer_orders 
inner join runner_orders using(order_id)
where cancellation is null;

-- 9. What was the total volume of pizzas ordered for each hour of the day?

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
left join customer_orders
on cte.hour = hour(order_time)
group by hour;

-- 10. What was the volume of orders for each day of the week?

with recursive cte as 
(
    select now() as a, now() as b
    union all
    select a, date_add(b, interval 1 day) 
    from cte 
    where datediff(b,a) <6 
    )
select 
    dayname(b) as day, 
    count(order_id) as total_orders 
from cte 
left join customer_orders co
on dayname(b) = dayname(order_time)
group by 1;


-- B. Runners and Customer Experiences

-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

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

-- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ 
-- to pickup the order?

with cte as 
(
    select c.order_id, runner_id, avg(timestampdiff(minute, order_time, pickup_time)) as diff
    from runner_orders r 
    inner join customer_orders c
    using(order_id)
    where pickup_time is not null
    group by 1, 2
    )
select runner_id, concat(round(avg(diff),0), ' mins') as avg_time_to_arrive 
from cte
group by 1;

-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?

with cte as
(
    select order_id, runner_id, 
    timestampdiff(minute, order_time, pickup_time) as time_difference, count(*) as no_of_orders
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

-- 4. What was the average distance travelled for each customer?

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

-- 5. What was the difference between the longest and shortest delivery times for all orders?

-- I have considered delivery time to be the time taken to deliver the order from the time of 
-- order pickup

select 
    concat(max(duration) - min(duration), ' min') as delivery_time_difference
from  runner_orders;

-- 6. What was the average speed for each runner for each delivery and do you notice any trend for
-- these values?

with cte as 
(
    select runner_id, order_id, round(distance/ (duration/60), 1) as speed 
    from runner_orders ro 
    inner join customer_orders co
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

-- 7. What is the successful delivery percentage for each runner?

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


-- C. Ingredient Optimisation

-- 1. What are the standard ingredients for each pizza?

with recursive cte as 
(
    select pizza_id, toppings 
    from pizza_recipes
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

-- 2. What was the most commonly added extra?

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
    topping_name, 
    count(*) as no_of_times_added
from cte2 inner join pizza_toppings using(topping_id)
group by 1, 2
order by no_of_times_added desc limit 1;

-- 3. What was the most common exclusion?

with recursive cte as 
(
    select order_id, exclusions 
    from customer_orders 
    where exclusions is not null
    union all
    select order_id, substr(exclusions, position(',' in exclusions) + 2 ) 
    from cte
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
order by no_of_times_excluded desc limit 1;

-- 4. Generate an order item for each record in the customers_orders table in the format of one 
-- of the following:
-- Meat Lovers
-- Meat Lovers - Exclude Beef
-- Meat Lovers - Extra Bacon
-- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

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
from cte inner join cte2 using(rn)
inner join cte3 using(rn);

-- 5. What is the total quantity of each ingredient used in all delivered pizzas sorted by most 
-- frequent first?

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



-- C. Pricing and Ratings

-- 1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - 
-- how much money has Pizza Runner made so far if there are no delivery fees?

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

-- 2. What if there was an additional $1 charge for any pizza extras? Add cheese is $1 extra

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
select concat('$', sum(pizza_cost) + sum(extras_cost)) as total_revenue 
from cte2;

-- 3. The Pizza Runner team now wants to add an additional ratings system that allows customers 
-- to rate their runner, how would you design an additional table for this new dataset - 
-- generate a schema for this new table and insert your own data for ratings for each 
-- successful customer order between 1 to 5.

create table ratings as  
select ro.order_id, customer_id, runner_id,
(
    case when duration <= 10 then 5      
        when duration > 10 and duration <= 20 then 4      
        when duration > 20 and duration <= 30 then 3      
        when duration > 30 and duration <= 40 then 2      
        else 1 end 
    ) as rating 
from customer_orders co 
inner join runner_orders ro using(order_id) 
where cancellation is null 
group by 1, 2, 3, 4;

select * from ratings;

-- 4. Using your newly generated table - can you join all of the information together to 
-- form a table which has the following information for successful deliveries?
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
    group by 1
    )
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
from cte 
inner join cte2 using(order_id);

-- 5. Generate an alphabetically ordered comma separated ingredient list for each pizza order 
-- from the customer_orders table and add a 2x in front of any relevant ingredients
-- For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"

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
, cte4 as 
(
    select pizza_id, pizza_name, group_concat(topping_name separator ', ' ) as standard_ingredient
    from cte3
    group by pizza_id, pizza_name
    )
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

-- 5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner 
-- is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over 
-- after these deliveries?

with cte as 
(
    select sum(case when pizza_name = "Meatlovers" then 12 else 10 end )as total_revenue
    from customer_orders co 
    inner join pizza_names pn using(pizza_id)
    inner join runner_orders ro using(order_id)
where cancellation is null)
, cte2 as 
(
    select round(sum(distance) * 0.3, 1) as delivery_charge from runner_orders 
    where cancellation is null
    )
select 
    concat('$', total_revenue - delivery_charge) as leftover_revenue
from cte join cte2;


-- D. Bonus Question

-- 1. If Danny wants to expand his range of pizzas - how would this impact the existing data design? 
-- Write an INSERT statement to demonstrate what would happen if a new Supreme pizza with all the 
-- toppings was added to the Pizza Runner menu?

insert into pizza_recipes values (3, '1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12');

insert into pizza_names values (3, 'Supreme');

select 
    pr.pizza_id,
    pizza_name, 
    toppings
from pizza_recipes pr 
inner join pizza_names pn 
using(pizza_id);
