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
There are few questions in this case study which are quite complex, therefore I would be breaking queries into different parts for better understanding.

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

By looking at the metadata, it seems preety fine. Therefore, we do not require `DDL Commands` to change the structure of the data.

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
  extras = case when extras in ('', 'null') then null end
  where exclusions in ('', 'null') or extras in ('', 'null');
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
                      else cancellation end
  where 
  pickup_time in ('', 'null') or
  distance = 'null' or 
  distance like '%km%' or
  duration = 'null' or
  duration like '%m%' or
  cancellation in ('null', '');
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

