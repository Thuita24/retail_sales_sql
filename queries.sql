--Section A-SQL Fundamentals
--Q1.Retrieve all customer records.
select * from customers;

--Q2.Display customer names, cities, and segments.
select customer_name,city,customer_segment
from customers;

--Q3.Find customers living in Nairobi.
select * from customers
where city='Nairobi';

--Q4.Find customers registered after January 1, 2025.
select * from customers
where registration_date>'2025-01-01';

--Q5.Display all unique customer cities.
SELECT DISTINCT city
FROM customers;

--Q6Retrieve the 10 most recent orders.
select * from orders
order by order_date desc,order_id desc
limit 10;

--Q7Find orders with unit prices above KSh 10,000.
select*from orders
where unit_price>10000;

--Q8Find customers whose names start with A.
SELECT *
FROM customers
WHERE customer_name LIKE 'A%';

--Q9Retrieve orders with quantities between 2 and 5.
SELECT *
FROM orders
WHERE quantity BETWEEN 2 AND 5;

--Q10Find orders paid through M-Pesa.
select* from orders
where payment_method='M-Pesa';

--Section B — Aggregation and grouping —
--Q11Count all customers.
select count(*) from customers;

--Q12Count all orders.
select count(*) from orders;

--Q13: Calculate completed-order revenue
SELECT ROUND(
    SUM(quantity * unit_price * (1 - discount / 100.0)),
    2
) AS total_revenue
FROM orders
WHERE order_status = 'Completed';

--Q14Calculate the average completed-order value.
SELECT ROUND(
    AVG(quantity * unit_price * (1 - discount / 100.0)),
    2
) AS avg_revenue
FROM orders
WHERE order_status = 'Completed';

-- Q15: Find the highest and lowest product prices
SELECT MAX(unit_price) AS highest_price,
       MIN(unit_price) AS lowest_price
FROM orders;

-- Q16: Calculate revenue by product category
SELECT product_category,
       ROUND(
           SUM(quantity * unit_price * (1 - discount / 100.0)),
           2
       ) AS rev_prod_category
FROM orders
WHERE order_status = 'Completed'
GROUP BY product_category
ORDER BY rev_prod_category DESC;

--Q17 Count customers by city.
Select city, count(customer_id) as total_customers
from customers
group by city;

-- Q18: Calculate quantity sold by product
SELECT product_name,
       SUM(quantity) AS total_quantity_sold
FROM orders
WHERE order_status = 'Completed'
GROUP BY product_name;

-- Q19: Find categories generating more than KSh 100,000 in revenue
SELECT product_category,
       ROUND(
           SUM(quantity * unit_price * (1 - discount / 100.0)),
           2
       ) AS total_revenue
FROM orders
WHERE order_status = 'Completed'
GROUP BY product_category
HAVING SUM(quantity * unit_price * (1 - discount / 100.0)) > 100000
ORDER BY total_revenue DESC;

-- Q20: Calculate the percentage of cancelled orders
SELECT ROUND(
    100.0 * COUNT(*) FILTER (WHERE order_status = 'Cancelled')
    / COUNT(*),
    2
) AS cancelled_orders_pct
FROM orders;

--SECTION C Joins and customer analytics
--Q21 Display orders with customer names and cities.
select c.customer_name,c.customer_id,c.city
from customers c 
inner join orders o on c.customer_id = o.customer_id;


-- Q22: Calculate total spending by customer
SELECT c.customer_id,
       c.customer_name,
           SUM(o.quantity * o.unit_price * (1 - o.discount / 100.0) ) as total_spending
FROM customers c

INNER JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'Completed'
GROUP BY c.customer_id, c.customer_name
ORDER BY total_spending DESC;

--Q23 Identify customers who have never ordered.
select* from customers c 
left join orders o on c.customer_id = o.customer_id 
where order_id is null;

-- Q24 Find the 10 highest-spending customers.
SELECT c.customer_id,
       c.customer_name,
           SUM(o.quantity * o.unit_price * (1 - o.discount / 100.0) ) as total_spending
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'Completed'
GROUP BY c.customer_id, c.customer_name
ORDER BY total_spending DESC
limit 10;


-- Q25 Calculate revenue by customer city
SELECT c.city,
         SUM(o.quantity * o.unit_price * (1 - o.discount / 100.0)) AS total_revenue
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'Completed'
GROUP BY c.city;

--Q26 Identify customers with more than five orders.
select count(order_id) as count_orders ,c.customer_name,c.customer_id 
from customers c 
inner join orders o on c.customer_id = o.customer_id
group by c.customer_id,c.customer_name
having count(o.order_id) > 5;

--Q27 Calculate average customer spending by segment.
SELECT c.customer_segment ,
         ROUND(AVG(o.quantity * o.unit_price * (1 - o.discount / 100.0)),2) AS avg_revenue
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'Completed'
GROUP BY c.customer_segment ;

--Q28 Identify the most popular category among VIP customers.
select o.product_category, count(o.order_id) as total_orders
from orders o 
inner join customers c on o.customer_id = c.customer_id
where c.customer_segment = 'VIP'
group by o.product_category 
order by count(o.order_id ) desc
limit 1;

--Subqueries and CTEs

--Q29 Find customers spending above the average total spending per purchasing customer.
-- Purchasing customer = customer with at least one completed order.
WITH customer_spending AS (
    SELECT c.customer_id,
           c.customer_name,
           SUM(
               o.quantity * o.unit_price * (1 - o.discount / 100.0)
           ) AS total_spending
    FROM customers c
    INNER JOIN orders o
        ON c.customer_id = o.customer_id
    WHERE o.order_status = 'Completed'
    GROUP BY c.customer_id, c.customer_name
)
SELECT customer_id,
       customer_name,
       ROUND(total_spending, 2) AS total_spending
FROM customer_spending
WHERE total_spending > (
    SELECT AVG(total_spending)
    FROM customer_spending
)
ORDER BY total_spending DESC;

-- Q30 Find products priced above the overall average unit price
SELECT  distinct product_name,
                unit_price
FROM orders
WHERE unit_price > (
    SELECT AVG(unit_price)
    FROM orders
)
ORDER BY unit_price DESC, product_name;


WITH AveragePrice AS (
    SELECT
        AVG(unit_price) AS avg_unit_price
    FROM orders p 
)
select distinct
    p.product_name,
    p.unit_price
FROM orders p
CROSS JOIN AveragePrice ap
WHERE p.unit_price > ap.avg_unit_price;

-- Q31: Identify the three highest-revenue months
WITH monthly_revenue AS (
    SELECT DATE_TRUNC('month', order_date)::date AS month,
           SUM(
               quantity * unit_price * (1 - discount / 100.0)
           ) AS revenue
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY DATE_TRUNC('month', order_date)::date
)
SELECT month,
       ROUND(revenue, 2) AS total_revenue
FROM monthly_revenue
ORDER BY revenue DESC, month
LIMIT 3;

-- Q32: Find customers purchasing from at least three categories
SELECT c.customer_id,
       c.customer_name,
       COUNT(DISTINCT o.product_category) AS categories_purchased
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'Completed'
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(DISTINCT o.product_category) >= 3
ORDER BY categories_purchased DESC, c.customer_id;

-- Q33: Calculate category revenue, cost, profit and profit margin
WITH category_totals AS (
    SELECT product_category,
           SUM(
               quantity * unit_price * (1 - discount / 100.0)
           ) AS revenue,
           SUM(quantity * cost_price) AS total_cost
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY product_category
)
SELECT product_category,
       ROUND(revenue, 2) AS revenue,
       ROUND(total_cost, 2) AS total_cost,
       ROUND(revenue - total_cost, 2) AS profit,
       ROUND(
           (revenue - total_cost) / NULLIF(revenue, 0) * 100,
           2
       ) AS profit_margin_pct
FROM category_totals
ORDER BY profit DESC, product_category;

-- Q34: Find customers inactive for more than 90 days
-- Includes only customers with at least one completed order.
WITH customer_last_order AS (
    SELECT c.customer_id,
           c.customer_name,
           MAX(o.order_date) AS last_completed_order
    FROM customers c
    INNER JOIN orders o
        ON c.customer_id = o.customer_id
    WHERE o.order_status = 'Completed'
    GROUP BY c.customer_id, c.customer_name
)
SELECT customer_id,
       customer_name,
       last_completed_order,
       (SELECT MAX(order_date) FROM orders)
           - last_completed_order AS days_since_last_purchase
FROM customer_last_order
WHERE (SELECT MAX(order_date) FROM orders)
          - last_completed_order > 90
ORDER BY days_since_last_purchase DESC, customer_id;

--Window functions
--Q35 Rank customers by spending using RANK()
WITH customer_spending AS (
    SELECT 
        customer_id,
        SUM(quantity * unit_price * (1 - discount / 100)) AS total_spent
    FROM orders
    GROUP BY customer_id
)
SELECT 
    customer_id,
    total_spent,
    RANK() OVER (ORDER BY total_spent DESC) AS spending_rank
FROM customer_spending;

--Q36 Number each customer's orders by recency using ROW_NUMBER()
select order_id,customer_id,order_date,
 ROW_NUMBER() OVER (
        PARTITION BY customer_id
        ORDER BY order_date DESC
    ) AS order_number
FROM orders;

--Q37 Rank products within categories using DENSE_RANK().
select distinct product_name,product_category, unit_price,
       DENSE_RANK() OVER (
        PARTITION BY product_category
        ORDER BY unit_price DESC
    ) AS product_rank
FROM orders o;

--Q38 Calculate cumulative monthly revenue.
WITH monthly_revenue AS (select DATE_TRUNC('month', order_date) AS month,
SUM(quantity * unit_price *
            (1 - discount / 100.0)) AS revenue
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY DATE_TRUNC('month', order_date)
)
select month,revenue,
 SUM(revenue) OVER (
        ORDER BY month
        ROWS BETWEEN UNBOUNDED PRECEDING
        AND CURRENT ROW
    ) AS cumulative_revenue
FROM monthly_revenue
ORDER BY month;

--Q39 Compare monthly revenue using LAG().
WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', order_date) AS month,
        SUM(quantity * unit_price *
            (1 - discount / 100.0)) AS revenue
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY DATE_TRUNC('month', order_date)
)
select month,revenue,
    LAG(revenue) OVER (
        ORDER BY month
    ) AS previous_month_revenue
FROM monthly_revenue
ORDER BY month;

--Q40 Calculate month-over-month revenue growth (%).
WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', order_date) AS month,
        SUM(quantity * unit_price *
            (1 - discount / 100.0)) AS revenue
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY DATE_TRUNC('month', order_date)
),
revenue_comparison AS (
    SELECT
        month,
        revenue,
        LAG(revenue) OVER (
            ORDER BY month
        ) AS previous_month_revenue
    FROM monthly_revenue
)
select month,revenue,previous_month_revenue,
    ROUND(
        ((revenue - previous_month_revenue)
        / NULLIF(previous_month_revenue, 0)) * 100,
        2
    ) AS growth_percentage
FROM revenue_comparison
ORDER BY month;

--Q41 Divide customers into four spending groups using NTILE(4).
WITH customer_spending AS (
    SELECT
        c.customer_id,
        c.customer_name,
        SUM(o.quantity * o.unit_price *
            (1 - o.discount / 100.0)) AS total_spending
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    WHERE o.order_status = 'Completed'
    GROUP BY c.customer_id, c.customer_name
)
SELECT
    customer_id,
    customer_name,
    total_spending,
    NTILE(4) OVER (
        ORDER BY total_spending DESC
    ) AS spending_group
FROM customer_spending;

--Q42Calculate each category's share of total revenue using window functions.
WITH category_revenue AS (
    SELECT
        o.product_category,
        SUM(o.quantity * o.unit_price *
            (1 - o.discount / 100.0)) AS revenue
    FROM orders o
    join customers c 
        ON o.customer_id= c.customer_id 
    WHERE o.order_status = 'Completed'
    GROUP BY o.product_category
)
select product_category,revenue,
    SUM(revenue) OVER () AS total_revenue,
    ROUND(
        (revenue / SUM(revenue) OVER ()) * 100,
        2
    ) AS revenue_percentage
FROM category_revenue
ORDER BY revenue DESC;

--Advanced business intelligence
--Q43 Create a monthly_sales_summary view (month, orders, revenue, cost, profit), then select from it.
CREATE OR REPLACE VIEW monthly_sales_summary AS
SELECT
    DATE_TRUNC('month', order_date)::DATE AS month,
    COUNT(DISTINCT order_id) AS orders,
    SUM(
        CASE
            WHEN order_status = 'Completed'
            THEN quantity * unit_price *
                 (1 - discount / 100.0)
            ELSE 0
        END
    ) AS revenue,
    SUM(
        CASE
            WHEN order_status = 'Completed'
            THEN quantity * cost_price
            ELSE 0
        END
    ) AS cost,
    SUM(
        CASE
            WHEN order_status = 'Completed'
            THEN (quantity * unit_price *
                  (1 - discount / 100.0))
                 - (quantity * cost_price)
            ELSE 0
        END
    ) AS profit
FROM orders
GROUP BY DATE_TRUNC('month', order_date);

SELECT *
FROM monthly_sales_summary
ORDER BY month;

SELECT * FROM monthly_sales_summary;

--Q44Create a PL/pgSQL function that returns completed-order revenue for a supplied customer ID — show it for one customer and for an ID that does not exist (it must return 0).
CREATE OR REPLACE FUNCTION get_customer_revenue(
    p_customer_id INTEGER
)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
    customer_revenue NUMERIC;
BEGIN
    SELECT
        COALESCE(
            SUM(
                quantity * unit_price *
                (1 - discount / 100.0)
            ), 0
        )
    INTO customer_revenue
    FROM orders
    WHERE customer_id = p_customer_id
      AND order_status = 'Completed';
    RETURN customer_revenue;
END;
$$;

--test
SELECT customer_id, customer_name
FROM customers
LIMIT 5;

SELECT get_customer_revenue(1);
--Q45 Segment customers into High, Medium and Low Value, and explain why you chose your thresholds.
WITH customer_spending AS (
    SELECT
        c.customer_id,
        c.customer_name,
        COALESCE(
            SUM(
                o.quantity * o.unit_price *
                (1 - o.discount / 100.0)
            ), 0
        ) AS total_spending
    FROM customers c
    LEFT JOIN orders o
        ON c.customer_id = o.customer_id
       AND o.order_status = 'Completed'
    GROUP BY
        c.customer_id,
        c.customer_name
),
spending_thresholds AS (
    SELECT
        PERCENTILE_CONT(0.25)
            WITHIN GROUP (ORDER BY total_spending) AS low_threshold,
        PERCENTILE_CONT(0.75)
            WITHIN GROUP (ORDER BY total_spending) AS high_threshold
    FROM customer_spending
)
SELECT
    cs.customer_id,
    cs.customer_name,
    cs.total_spending,
    CASE
        WHEN cs.total_spending >= st.high_threshold
            THEN 'High Value'
        WHEN cs.total_spending >= st.low_threshold
            THEN 'Medium Value'
        ELSE 'Low Value'
    END AS customer_segment
FROM customer_spending cs
CROSS JOIN spending_thresholds st
ORDER BY cs.total_spending DESC;

--Q46Produce a management report: top five customers, top five products, the most profitable category, and the lowest-revenue month.
--Top 5 customers
SELECT
    c.customer_id,
    c.customer_name,
    SUM(
        o.quantity * o.unit_price *
        (1 - o.discount / 100.0)
    ) AS total_revenue
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'Completed'
GROUP BY
    c.customer_id,
    c.customer_name
ORDER BY total_revenue DESC
LIMIT 5;

--Top 5 products
SELECT
    o.product_name,
    o.product_category,
    SUM(
        o.quantity * o.unit_price *
        (1 - o.discount / 100.0)
    ) AS total_revenue
FROM orders o 
join customers c 
    on c.customer_id = o.customer_id 
WHERE o.order_status = 'Completed'
GROUP BY
    o.product_name,
    o.product_category
ORDER BY total_revenue DESC
LIMIT 5;

--Most profitable category
SELECT
    o.product_category,
    SUM(
        o.quantity * o.unit_price *
        (1 - o.discount / 100.0)
    ) AS revenue,
    SUM(o.quantity * o.cost_price) AS cost,
    SUM(
        (o.quantity * o.unit_price *
         (1 - o.discount / 100.0))
        -
        (o.quantity * o.cost_price)
    ) AS profit
FROM orders o 
JOIN customers c 
    on c.customer_id = o.customer_id 
WHERE o.order_status = 'Completed'
GROUP BY o.product_category 
ORDER BY profit DESC
LIMIT 1;

--Lowest revenue month
SELECT
    DATE_TRUNC('month', order_date)::DATE AS month,
    SUM(
        quantity * unit_price *
        (1 - discount / 100.0)
    ) AS monthly_revenue
FROM orders
WHERE order_status = 'Completed'
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY monthly_revenue ASC
LIMIT 1;










