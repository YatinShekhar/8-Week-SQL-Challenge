-- case study questions

-- 1. What is the total amount each customer spent at the restaurant?

select s.customer_id, sum(price) as amount
from sales s 
inner join 
menu m using(product_id)
group by 1;

-- 2. How many days has each customer visited the restaurant?

select customer_id , count(distinct order_date) as visited_days 
from sales
group by 1;

-- 3. What was the first item from the menu purchased by each customer?

with cte as 
	(select *, dense_rank() over(partition by customer_id order by order_date) as rn
	from sales s 
    inner join menu m using(product_id))
select customer_id, product_name 
from cte 
where rn = 1
group by 1, 2;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

with cte as 
	(select  m.product_name, count(*) as purchases , dense_rank() over(order by count(*) desc) as rn 
	from sales  s 
    inner join menu m using(product_id)
	group by 1)
select product_name, purchases
from cte 
where rn = 1;

-- 5. Which item was the most popular for each customer?

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

-- 6. Which item was purchased first by the customer after they became a member?

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

-- 7. Which item was purchased just before the customer became a member?

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

-- 8. What is the total items and amount spent for each member before they became a member?

select s.customer_id, count(*) as products, sum(price) as amount
from sales s
inner join 
members m using(customer_id)
inner join 
menu me using(product_id)
where order_date < join_date or join_date is null
group by 1;

-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - 
-- how many points would each customer have?

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

-- 10. In the first week after a customer joins the program (including their join date) 
-- they earn 2x points on all items, not just sushi - 
-- how many points do customer A and B have at the end of January?

with cte as 
	(select s.customer_id, s.order_date, m.join_date, 
    datediff(order_date, join_date) as date_diff , me.product_name, me.price
	from sales s
	inner join 
    members m using(customer_id)
	inner join 
    menu me using(product_id) 
	where order_date >= join_date and order_date <= '2021-01-31')
select customer_id, sum(case when product_name = 'Sushi' then price*2*10
                         when date_diff < 7 and order_date <= '2021-01-31' then price*2*10
                         else price*10
					end) as points
                    from cte
group by 1
order by 2 desc;


-- bonus questions

-- 11. Join all the tables

select 
	s.customer_id, s.order_date, me.product_name, me.price, 
    case 
		when s.order_date < m.join_date or m.join_date is null then 'N' 
        else 'Y' 
	end as member
from sales s
left join menu me using(product_id)
left join members m using(customer_id);

-- 12. Ranking of the table

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
select *, case  
			when member = 'Y' then dense_rank() over(partition by customer_id, member order by order_date)
			when member = 'N' then null
          end as ranking
from cte;



