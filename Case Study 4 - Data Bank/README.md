# Case Study #4- Data Bank 💰
<img src="https://8weeksqlchallenge.com/images/case-study-designs/4.png" alt="Image Description" width="400">

This is the fourth case study of **8 Week SQL Challenge**.
The case study is designed to simulate real-world banking analytics while teaching advanced SQL concepts through practical business questions.

# Table Of Content 📋
 * [Project Overview](#project-overview-)
 * [Entity Relationship Diagram](#entity-relationship-diagram-)
 * [Tables](#tables)
 * [Note](#note)
 * [Case Studies](#case-studies-)
 * [Insights](#insights-)

 # Project Overview 📋

 - Data Bank is a `Neo-bank` (new aged digital only bank without physical branches) that runs banking services through a network of nodes. 
 - Customers are allocated to different nodes, and their account balances directly impact the bank's data storage allocation - essentially linking financial data to cloud storage capacity.
 - Data Bank want to increase their total customer base - but also need some help tracking just how much data storage their customers will need.

 # Entity Relationship Diagram 📊

 ![Image](https://github.com/user-attachments/assets/fa2f3a8f-2c89-4037-9640-74dc75a1109a)

 # Tables

- **Regions:** Geographic `region_id` along with `region_name` where nodes operate
- **Customer Nodes:** Mapping of customers to specific nodes with dates which include `customer id`, `region id`, `node id`, `start date` and `end date`
- **Customer Transactions:** All banking transactions (deposits, withdrawals, purchases)

# Note:
- `reallocation days metric` This refers to how long customers stay at each node before being moved (reallocated) to a different node
- There's an `end_date` column in `customer nodes` table. One of the value of end_date is '9999-12-31' which indicates "no end date" or "still active"

# Case Studies ❓

This case study has 3 segments -

1. [Customer Nodes Exploration](#customer-nodes-exploration)
2. [Customer Transactions](#customer-transactions)
3. [Data Allocation Challenge](#data-allocation-challenge)

# Customer Nodes Exploration

## **1. How many unique nodes are there on the Data Bank system?**

```sql
select 
	count(distinct node_id) as unique_nodes 
from customer_nodes;
```

| unique_nodes |
| ------------ |
|      5       |

- There are `5` unique nodes in Data Bank system.

## **2. What is the number of nodes per region?**

```sql
select 
	region_name as region, count(node_id) as no_of_nodes
from customer_nodes 
inner join regions
    using(region_id)
group by region_name;
```

| region   | no_of_nodes |
|----------|-------------|
| Africa   | 714         |
| Europe   | 616         |
| Australia| 770         |
| America  | 735         |
| Asia     | 665         |

- `Australia` has the highest nodes while `Europe` has the least.

## **3. How many customers are allocated to each region?**

```sql
select 
	region_name, count(distinct customer_id) as customer_count
from customer_nodes 
inner join regions 
    using(region_id)
group by region_name;
```

| region_name | customer_count |
|-------------|----------------|
| Africa      | 102            |
| America     | 105            |
| Asia        | 95             |
| Australia   | 110            |
| Europe      | 88             |

- Customers are distributed highest in `Austraila` region while `Europe` has least customers.

## **4. How many days on average are customers reallocated to a different node?**

```sql
select 
	avg(datediff(end_date, start_date)) as avg_days
from customer_nodes
where end_date!= "9999-12-31";
```

| avg_days |
| -------- |
|   14.63  |

- On average, it takes `14.63` days to reallocate customer to a different node

## **5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?**

```sql
with cte as
	(select 
		cn.node_id, cn.start_date, cn.end_date, r.region_name, 
		datediff(cn.end_date, cn.start_date) as reallocation_days
	from customer_nodes cn
	inner join regions r on cn.region_id = r.region_id
	where cn.end_date != '9999-12-31')
, cte2 as
	(select 
		region_name, reallocation_days, 
        row_number() over (partition by region_name order by reallocation_days) as rn,
		count(*) over (partition by region_name) as total_count 
	from cte)
select 
	region_name,  
	max(case when rn = cast(0.50 * total_count as signed) then reallocation_days end) as percentile_50th,
	max(case when rn = cast(0.85 * total_count as signed) then reallocation_days end) as percentile_85th,
	max(case when rn = cast(0.95 * total_count as signed) then reallocation_days end) as percentile_95th
from cte2
group by region_name;
```

| region_name | percentile_50th | percentile_80th | percentile_95th |
|-------------|------------------|------------------|------------------|
| Africa      | 15               | 24               | 28               |
| America     | 15               | 23               | 28               |
| Asia        | 15               | 23               | 28               |
| Australia   | 15               | 23               | 28               |
| Europe      | 15               | 24               | 28               |

- Around `50 percent` of the customers in each region gets reallocated within `15 days`
- `80 percent` of the customers are reallocated till `24 days`
- Till `28 days`, `95 percent` of the customers gets reallocated 

# Customer Transactions

## **1. What is the unique count and total amount for each transaction type?**

```sql
select 
	txn_type, count(*) as count, concat('$ ', format(sum(txn_amount), 0)) as total_amount
from customer_transactions
group by txn_type;
```

| txn_type   | count | total_amount |
|------------|-------|---------------|
| deposit    | 2671  | $ 1,359,168   |
| withdrawal | 1580  | $ 793,003     |
| purchase   | 1617  | $ 806,537     |


- Customers `deposited` `$ 1.35 million` which is highest as compared to `withdrawal` and `purchase`

## **2. What is the average total historical deposit counts and amounts for all customers?**

```sql
with cte as
	(select 
		customer_id, count(txn_type) as deposit_count, sum(txn_amount) as total_amount
	from customer_transactions
	where txn_type = "deposit"
	group by customer_id
	order by customer_id)
select 
	round(avg(deposit_count), 0) as avg_deposit_count, 
	concat('$ ', format(round(avg(total_amount), 0), 0)) as avg_total_amount
from cte;
```

| avg_deposit_count | avg_total_amount |
| ----------------- | ---------------- |
|          5        |      $2,718      |

- The Data Bank customers made an average of `5` deposits, with an average amount of `$ 2,718`.

## **3. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?**

```sql
with cte as 
	(select 
		month(txn_date) as month, monthname(txn_date) as month_name, customer_id,
		sum(case when txn_type = "deposit" then 1 else 0 end) as deposit_count, 
		sum(case when txn_type = "withdrawal" then 1 else 0 end) as withdrawal_count,
		sum(case when txn_type = "purchase" then 1 else 0 end) as purchase_count
	from customer_transactions
	group by month, month_name, customer_id)
select 
	month, month_name, count(customer_id)
from cte
where deposit_count > 1 and (purchase_count >= 1 or withdrawal_count >= 1)
group by month, month_name
order by month;
```

| month | month_name | count(customer_id) |
|-------|------------|---------------------|
| 1     | January    | 168                 |
| 2     | February   | 181                 |
| 3     | March      | 192                 |
| 4     | April      | 70                  |

- `March` saw the highest customers who made more than 1 deposit and at least 1 purchase or withdrawal
- `April` saw the least customers with this trend.

## **4. What is the closing balance for each customer at the end of the month?**

```sql
with cte as 
	(select 
		customer_id, 
        month(txn_date) as txn_month, monthname(txn_date) as month_name, 
        txn_date, txn_type, txn_amount,
		sum(case when txn_type = "deposit" then txn_amount else -1 * txn_amount end)
				over(partition by customer_id order by txn_date) as closing_balance
	from customer_transactions)
, cte2 as (
	select 
		customer_id, txn_month, month_name, closing_balance, 
        row_number() over (partition by customer_id, txn_month order by txn_date desc) as rn
	from cte)
select 
	customer_id, txn_month, month_name, closing_balance 
from cte2
where rn = 1;
```

| customer_id | txn_month | month_name | closing_balance |
|-------------|-----------|------------|------------------|
| 1           | 1         | January    | 312              |
| 1           | 3         | March      | -640             |
| 2           | 1         | January    | 549              |
| 2           | 3         | March      | 610              |
| 3           | 1         | January    | 144              |
| 3           | 2         | February   | -821             |
| 3           | 3         | March      | -1222            |
| 3           | 4         | April      | -729             |
| 4           | 1         | January    | 848              |
| 4           | 3         | March      | 655              |

- The closing balance of `Customer 1` for `January` and `March` is `$ 312` and `-$ 640` respectively

## **5. What is the percentage of customers who increase their closing balance by more than 5%?**

```sql
with cte as 
	(select 
		month(txn_date) as month, monthname(txn_date) as month_name, customer_id, 
		sum(case when txn_type = "deposit" then txn_amount else 0 end) as deposit_amount,
		sum(case when txn_type in ("withdrawal", "purchase") then txn_amount else 0 end) as deducted_amount
	from customer_transactions
	group by month(txn_date), monthname(txn_date), customer_id)
, cte2 as 
	(select 
		customer_id, month, month_name, 
        deposit_amount - deducted_amount as closing_balance
	from cte)
, cte3 as 
	(select 
		customer_id, month, month_name, closing_balance, 
		lag(closing_balance, 1) over (partition by customer_id order by month) as prev_month_closing_balance
	from cte2)
select 
	count(distinct customer_id) as five_percent_increase_customer, 
	(select count(distinct customer_id) from customer_transactions) as total_customers,
	round((count(distinct customer_id)/(select count(distinct customer_id) from customer_transactions))*100, 1) as percent_customers
from cte3
where((closing_balance - prev_month_closing_balance)/prev_month_closing_balance)*100 > 5;
```

| five_percent_increase_customer | total_customers | percent_customers |
| ------------------------------ | --------------- | ----------------- |
|         269                    |      500        |        53.8 %     |

- There are `53.8 %` of the Data Bank customers who increase their closing balance by more than 5%.


# Data Allocation Challenge

## **1. Running customer balance column that includes the impact each transaction**

```sql
select
	customer_id, txn_date, txn_type, txn_amount,
	sum(case when txn_type = "deposit" then txn_amount else -1 * txn_amount end)
	over(partition by customer_id order by txn_date) as running_balance
from customer_transactions;
```

| customer_id | txn_date   | txn_type   | txn_amount | running_balance |
|-------------|------------|------------|------------|------------------|
| 1           | 2020-01-02 | deposit    | 312        | 312              |
| 1           | 2020-03-05 | purchase   | 612        | -300             |
| 1           | 2020-03-17 | deposit    | 324        | 24               |
| 1           | 2020-03-19 | purchase   | 664        | -640             |
| 2           | 2020-01-03 | deposit    | 549        | 549              |
| 2           | 2020-03-24 | deposit    | 61         | 610              |
| 3           | 2020-01-27 | deposit    | 144        | 144              |
| 3           | 2020-02-22 | purchase   | 965        | -821             |
| 3           | 2020-03-05 | withdrawal | 213        | -1034            |
| 3           | 2020-03-19 | withdrawal | 188        | -1222            |
| 3           | 2020-04-12 | deposit    | 493        | -729             |

- This analyzes the customer's each transaction along with their running_balance

## **2. Customer balance at the end of each month**

```sql
with cte as 
	(select 
		customer_id, 
        month(txn_date) as txn_month, monthname(txn_date) as month_name, 
        txn_date, txn_type, txn_amount,
		sum(case when txn_type = "deposit" then txn_amount else -1 * txn_amount end)
				over(partition by customer_id order by txn_date) as closing_balance
	from customer_transactions)
, cte2 as (
	select 
		customer_id, txn_month, month_name, closing_balance, 
        row_number() over (partition by customer_id, txn_month order by txn_date desc) as rn
	from cte)
select 
	customer_id, txn_month, month_name, closing_balance 
from cte2
where rn = 1;
```

| customer_id | txn_month | month_name | closing_balance |
|-------------|-----------|------------|------------------|
| 1           | 1         | January    | 312              |
| 1           | 3         | March      | -640             |
| 2           | 1         | January    | 549              |
| 2           | 3         | March      | 610              |
| 3           | 1         | January    | 144              |
| 3           | 2         | February   | -821             |
| 3           | 3         | March      | -1222            |
| 3           | 4         | April      | -729             |
| 4           | 1         | January    | 848              |
| 4           | 3         | March      | 655              |

- - The closing balance of `Customer 1` for `January` and `March` is `$ 312` and `-$ 640` respectively

## **3. Minimum, average and maximum values of the running balance for each customer**

```sql
with cte as
	(select 
		customer_id, txn_date, txn_type, txn_amount,
		sum(case when txn_type = "deposit" then txn_amount else -1 * txn_amount end)
			over(partition by customer_id order by txn_date) as running_balance
from customer_transactions)
select 
	customer_id, 
    min(running_balance) as min_running_balance, 
    max(running_balance) as max_running_balance,
	round(avg(running_balance), 2) as avg_running_balance
from cte
group by customer_id;
```

| customer_id | min_running_balance | max_running_balance | avg_running_balance |
|-------------|----------------------|----------------------|----------------------|
| 1           | -640                 | 312                  | -151.00              |
| 2           | 549                  | 610                  | 579.50               |
| 3           | -1222                | 144                  | -732.40              |
| 4           | 458                  | 848                  | 653.67               |
| 5           | -2413                | 1780                 | -135.45              |
| 6           | -552                 | 2197                 | 624.00               |
| 7           | 887                  | 3539                 | 2268.69              |
| 8           | -1029                | 1363                 | 173.70               |

- It includes each customer's `minimum`, `maximum` and `average` running balance

# Insights: 🔍

## 1. Australia-Centric Operations 🌏
The bank is clearly strongest in `Australia` with the highest node count and customer concentration, followed by America. `Europe` appears to be an underdeveloped market

## 2. Financial Health 💰
`$1.35M` in deposits vs `$793K` withdrawals indicates growing customer trust, positive cashflow for the bank and healhty liquidity

## 3. Quality Customer Base 💎
Average deposits of `$2,718` across 5 transactions suggests customers are making substantial, regular deposits rather than small, frequent ones

## 4. Montly Business Pattern 📅
`January`, `February` and  `March` showing highest activity indicates strong start-of-year financial planning

## 5. Impressive Growth Rate 📈
`53.8%` of customers increasing their closing balance by >5% indicates strong customer satisfaction and engagement