# Case Study #1- Danny's Diner 🍱
<img src="https://8weeksqlchallenge.com/images/case-study-designs/1.png" alt="Image Description" width="400">

It is the first case study of **8 Week SQL Challenge**.\
I have used `MySql` to get the insights for [Danny Ma's](https://github.com/datawithdanny) restaurant to keep his business afloat.

# Project Overview 📋
- Danny is running a Japanese restaurant called Danny's Diner.
- Danny is in need of someone who can assist him to help his restaurant stay afloat.
- The restaurant has captured some very basic data from their few months of operation.
- Danny wants the answers of a few simple questions about his customers, especially about their visiting patterns,\
how much money they’ve spent and also which menu items are their favourite to deliver a better and more\
personalised experience for his loyal customers.
- I would be assisting Danny and his business by providing insights and recommendations on the basis of the restaurant's data.

# Entity Relationship Diagram 📊
![Danny's Diner](https://github.com/YatinShekhar/8-Week-SQL-Challenge/assets/121398971/9730e9d7-4803-42fc-a903-47e87b9d0339)

# Note 💡

Their are some questions which demands more accurate data, since we lack precise data on the matter,\
I have made some assumptions on my own. 

# Case Study Questions ❓

## **1. What is the total amount each customer spent at the restaurant?**

```sql
select s.customer_id, sum(price) as amount
from sales s 
inner join 
menu m using(product_id)
group by 1;
```
| customer_id | amount |
|-------------|--------|
| A           | 76     |
| B           | 74     |
| C           | 36     |


## **2. How many days has each customer visited the restaurant?**

```sql
select customer_id , count(distinct order_date) as visited_days 
from sales
group by 1;
```

| customer_id | visited_days |
|-------------|--------------|
| A           | 4            |
| B           | 6            |
| C           | 2            |
 
## **3. What was the first item from the menu purchased by each customer?**

### **Assumption**
Since the `exact time` of purchase is not mentioned, therefore a single customer can\
have more than one item as their first purchase.

```sql
with cte as 
	(select *, dense_rank() over(partition by customer_id order by order_date) as rn
	from sales s 
    inner join menu m using(product_id))
select customer_id, product_name 
from cte 
where rn = 1
group by 1,2;
```

| customer_id | product_name |
|-------------|--------------|
| A           | sushi        |
| A           | curry        |
| B           | curry        |
| C           | ramen        |

## **4. What is the most purchased item on the menu and how many times was it purchased by all customers?**

```sql
with cte as 
	(select  m.product_name, count(*) as purchases , dense_rank() over(order by count(*) desc) as rn 
	from sales  s 
    inner join menu m using(product_id)
	group by 1)
select product_name, purchases
from cte 
where rn = 1;
```

| product_name | purchases |
|--------------|-----------|
| ramen        | 8         |

## **5. Which item was the most popular for each customer?**

```sql
with cte as
	(select s.customer_id, m.product_name, count(*) as ordered, 
	dense_rank() over(partition by customer_id order by count(*) desc) as rn
	from sales s
	inner join 
    menu m using(product_id)
	group by 1,2)
select customer_id, product_name 
from cte 
where rn = 1;
```

| customer_id | product_name |
|-------------|--------------|
| A           | ramen        |
| B           | curry        |
| B           | sushi        |
| B           | ramen        |
| C           | ramen        |

## **6. Which item was purchased first by the customer after they became a member?**

### **Assumption**
Since the `exact time` of the order and `exact time` of membership is not mentioned,\
therefore I have considered the membership just before the order made by the customer.

```sql
with cte as 
	(select * , dense_rank() over(partition by customer_id order by order_date) as rn
	from sales s
	inner join 
    members m using(customer_id)
	inner join 
    menu me using(product_id)
	where order_date >= join_date)
select customer_id, product_name 
from cte 
where rn = 1;
```

| customer_id | product_name |
|-------------|--------------|
| A           | curry        |
| B           | sushi        |

## **7. Which item was purchased just before the customer became a member?**

### **Assumption**
Since the `exact time` of the order and `exact time` of membership is not mentioned,\
therefore I have considered the membership just before the order made by the customer.

```sql
with cte as 
	(select * , dense_rank() over(partition by customer_id order by order_date desc) as rn
	from sales s
	inner join 
    members m using(customer_id)
	inner join 
    menu me using(product_id)
	where order_date < join_date)
select customer_id, product_name 
from cte 
where rn = 1;
```

| customer_id | product_name |
|-------------|--------------|
| A           | sushi        |
| A           | curry        |
| B           | sushi        |

## **8. What is the total items and amount spent for each member before they became a member?**

```sql
select s.customer_id, count(*) as products, sum(price) as amount
from sales s
left join 
members m using(customer_id)
inner join 
menu me using(product_id)
where order_date < join_date or join_date is null
group by 1;
```

| customer_id | products | amount |
|-------------|----------|--------|
| A           | 2        | 25     |
| B           | 3        | 40     |
| C           | 3        | 36     |

## **9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?**

```sql
with cte as 
	(select s.customer_id, price , 
	case 
		when product_name = 'Sushi' then price*10*2 
		when product_name = 'Curry' then price*10
		when product_name = 'Ramen' then price* 10 
	end as points
	from sales s 
    inner join 
    menu m using(product_id))
select customer_id, sum(points) as total_points
from cte
group by 1;
```

| customer_id | total_points |
|-------------|--------------|
| A           | 860          |
| B           | 940          |
| C           | 360          |

## **10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi -how many points do customer A and B have at the end of January?**

```sql
with cte as 
	(select s.customer_id, s.order_date, m.join_date, 
    datediff(order_date, join_date) as date_diff , me.product_name, me.price
	from sales s
	inner join 
    members m using(customer_id)
	inner join 
    menu me using(product_id) 
	where order_date >= join_date and order_date <= '2021-01-31')
select customer_id, sum(price)*2*10 as points
from cte
where date_diff < 7
group by 1;
```

| customer_id | points |
|-------------|--------|
| B           | 200    |
| A           | 1020   |

# Bonus Questions

## Join all the things and recreate the following output

| customer_id | order_date | product_name | price | member |
|-------------|------------|--------------|-------|--------|
| A           | 2021-01-01 | sushi        | 10    | N      |
| A           | 2021-01-01 | curry        | 15    | N      |
| A           | 2021-01-07 | curry        | 15    | Y      |
| A           | 2021-01-10 | ramen        | 12    | Y      |
| A           | 2021-01-11 | ramen        | 12    | Y      |
| A           | 2021-01-11 | ramen        | 12    | Y      |
| B           | 2021-01-01 | curry        | 15    | N      |
| B           | 2021-01-02 | curry        | 15    | N      |
| B           | 2021-01-04 | sushi        | 10    | N      |
| B           | 2021-01-11 | sushi        | 10    | Y      |
| B           | 2021-01-16 | ramen        | 12    | Y      |
| B           | 2021-02-01 | ramen        | 12    | Y      |
| C           | 2021-01-01 | ramen        | 12    | N      |
| C           | 2021-01-01 | ramen        | 12    | N      |
| C           | 2021-01-07 | ramen        | 12    | N      |

```sql
select 
	s.customer_id, s.order_date, me.product_name, me.price, 
    case
      when s.order_date < m.join_date or m.join_date is null then 'N' 
      else 'Y'
    end as member
from sales s
left join
menu me using(product_id)
left join
members m using(customer_id);
```

## Rank all the things and recreate the following outupt

| customer_id | order_date | product_name | price | member | ranking |
|-------------|------------|--------------|-------|--------|---------|
| A           | 2021-01-01 | sushi        | 10    | N      |         |
| A           | 2021-01-01 | curry        | 15    | N      |         |
| A           | 2021-01-07 | curry        | 15    | Y      | 1       |
| A           | 2021-01-10 | ramen        | 12    | Y      | 2       |
| A           | 2021-01-11 | ramen        | 12    | Y      | 3       |
| A           | 2021-01-11 | ramen        | 12    | Y      | 3       |
| B           | 2021-01-01 | curry        | 15    | N      |         |
| B           | 2021-01-02 | curry        | 15    | N      |         |
| B           | 2021-01-04 | sushi        | 10    | N      |         |
| B           | 2021-01-11 | sushi        | 10    | Y      | 1       |
| B           | 2021-01-16 | ramen        | 12    | Y      | 2       |
| B           | 2021-02-01 | ramen        | 12    | Y      | 3       |
| C           | 2021-01-01 | ramen        | 12    | N      |         |
| C           | 2021-01-01 | ramen        | 12    | N      |         |
| C           | 2021-01-07 | ramen        | 12    | N      |         |

```sql
with cte as (
select 
	s.customer_id, s.order_date, me.product_name, me.price,
  case
    when s.order_date < m.join_date or m.join_date is null then 'N'
    else 'Y'
  end as member
from sales s
left join menu me using(product_id)
left join members m using(customer_id))
select *,
        case
          when member = 'Y' then dense_rank() over(partition by customer_id, member order by order_date)
          when member = 'N' then null
        end as ranking
from cte;
```











