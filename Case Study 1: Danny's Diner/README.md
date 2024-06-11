# Case Study #1- Danny's Diner 🍱
<img src="https://8weeksqlchallenge.com/images/case-study-designs/1.png" alt="Image Description" width="400">

It is the first case study of **8 Week SQL Challenge**.\
I have used `MySql` to get the insights for [Danny Ma's](https://github.com/datawithdanny) restaurant to keep his business afloat.

# Table Of Content
* [Project Overview](#project-overview-📋)
* [Entity Relationship Diagram](#entity-relationship-diagram)
* [Note](#note)
* [Case Study Questions](#case-study-questions)
* [Insights](#insights)

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

# Note: 💡

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

- **Customer A** spends the most in Danny's restaurant i.e., `$76.00`
- Followed by **Customer B** who spend `$74.00`
- **Customer C** spends the least which is `$36.00`

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

- **Customer A** visited `4 days`
- While **Customer B** visited the most i.e., `6 days`
- Whereas **Customer C** visited the least of `2 days`
 
## **3. What was the first item from the menu purchased by each customer?**

### **Assumption**
_Since the `exact time` of purchase is not mentioned, therefore a single customer can\
have more than one item as their first purchase._

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

- **Customer A** ordered `sushi` and `curry` as its first order
- **Customer B** ordered `curry`
- While **Customer C** ordered `ramen`

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

- `Ramen` is the most demanding dish in the Danny's menu. It was ordered `8 times`

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

- **Customer A** and **Customer C** likes `ramen` the most
- **Customer B** likes all 3 dishes: `curry` `sushi` and `ramen`

## **6. Which item was purchased first by the customer after they became a member?**

### **Assumption**
_Since the `exact time` of the order and `exact time` of membership is not mentioned,\
therefore I have considered the membership just before the order made by the customer._

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

- **Customer A** ordered `curry` and **Customer B** ordered `sushi` after they joined the membership

## **7. Which item was purchased just before the customer became a member?**

### **Assumption**
_Since the `exact time` of the order and `exact time` of membership is not mentioned,\
therefore I have considered the membership just before the order made by the customer._

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

- **Customer A** and **Customer B** ordered `sushi` just before they became members
- While **Customer A** also ordered `curry`

## **8. What is the total items and amount spent for each member before they became a member?**

### **Assumption**
_Included only those customers who converted to members_

```sql
select s.customer_id, count(*) as products, sum(price) as amount
from sales s
inner join 
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

- **Customer A** purchased `2 products` and spend `$25.00` just before they become the members
- While **Customer B** spend `$40.00` and purchased a total of `3 products`

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

- **Customer A** has total `860 points`
- **Customer B** has maximum of all that is `940 points`
- **Customer C** has least points that is `360 points`

## **10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi -how many points do customer A and B have at the end of January?**

### **Assumption**
_Since it is not instructed clearly whether to include points before the customer joins the program or not,\
I have considered to include points only after the program is joined_

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
select customer_id,
		sum(case
			when product_name = 'Sushi' then price*2*10
			when date_diff < 7 and order_date <= '2021-01-31' then price*2*10
			else price*10
		end) as points
from cte
group by 1;
```

| customer_id | points |
|-------------|--------|
| A           | 1020   |
| B           | 320    |

- **Customer A** took the most advantage of the offer and earned `1020 points`
- Total points for **Customer B** is `320 points`

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

# Insights: 🔍

## 1. High-Value Customers

`Customer A` and `Customer B` contributes significantly to restaurant's revenue, therefore they could be targeted for loyalty \
programs and exclusive offers.

## 2. Menu Popularity

`Ramen` is the most purchased dish in the menu, indicating its strong appeal to customers. It could be promoted further and new variations\
of Ramen can be introduced which would increase the restaurant's revenue.

## 3. Membership Conversion

`Sushi `appears to be a common choice before membership sign-up, indicating it may play a role in customer satisfaction\
that leads to membership conversion.

## 4. Promotional Effectiveness

The significant points earned during the promotional period `(2x points on each order for one week)` highlight the potential of\
time-limited offers. Therefore, the restaurant should invoke these offers in a timely manner which would increase sales.




















