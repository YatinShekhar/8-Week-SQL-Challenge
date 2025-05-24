-- Customer Nodes Exploration
  
-- 1. How many unique nodes are there on the Data Bank system?
  
select 
	count(distinct node_id) as unique_nodes 
from customer_nodes;
  
-- 2. What is the number of nodes per region?
  
select 
	region_name as region, count(node_id) as no_of_nodes
from customer_nodes 
inner join regions
    using(region_id)
group by region_name;

-- 3. How many customers are allocated to each region?

select 
	region_name, count(distinct customer_id) as customer_count
from customer_nodes 
inner join regions 
    using(region_id)
group by region_name;

-- 4. How many days on average are customers reallocated to a different node?

select 
	avg(datediff(end_date, start_date)) as avg_days
from customer_nodes
where end_date!= "9999-12-31";

-- 5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?

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


-- Customer Transactions

-- 1. What is the unique count and total amount for each transaction type?

select 
	txn_type, count(*) as count, concat('$ ', format(sum(txn_amount), 0)) as total_amount
from customer_transactions
group by txn_type;

-- 2. What is the average total historical deposit counts and amounts for all customers?

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

-- 3. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal 
-- in a single month?

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

-- 4. What is the closing balance for each customer at the end of the month?

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

-- 5. What is the percentage of customers who increase their closing balance by more than 5%?

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
where((closing_balance - prev_month_closing_balance)/prev_month_closing_balance)*100 > 5 ;

-- Data Allocation Challenge

-- To test out a few different hypotheses - the Data Bank team wants to run an experiment where 
-- different groups of customers would be allocated data using 3 different options:

-- Option 1: data is allocated based off the amount of money at the end of the previous month
-- Option 2: data is allocated on the average amount of money kept in the account in the previous 30 days
-- Option 3: data is updated real-time
-- For this multi-part challenge question - you have been requested to generate the following data elements to
-- help the Data Bank team estimate how much data will need to be provisioned for each option:

-- 1. running customer balance column that includes the impact each transaction
-- 2. customer balance at the end of each month
-- 3. minimum, average and maximum values of the running balance for each customer
-- 4. Using all of the data available - how much data would have been required for each option on a monthly basis


-- 1. running customer balance column that includes the impact each transaction

select
	customer_id, txn_date, txn_type, txn_amount,
	sum(case when txn_type = "deposit" then txn_amount else -1 * txn_amount end)
	over(partition by customer_id order by txn_date) as running_balance
from customer_transactions;


-- 2. customer balance at the end of each month

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


-- 3. minimum, average and maximum values of the running balance for each customer

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