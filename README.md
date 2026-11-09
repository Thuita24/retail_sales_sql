# Duka Smart Electronics – Retail Sales Analysis and Customer Intelligence

## 1. Project Overview

Duka Smart Electronics is a retail sales analysis project developed using PostgreSQL and SQL.
The project analyses customer purchasing behaviour, product performance, category profitability and monthly sales trends.
It covers SQL fundamentals, aggregation, joins, subqueries, CTEs, window functions, views and PL/pgSQL functions.

## 2. Project Objectives

- Analyse customer purchasing behaviour.
- Identify top-performing products.
- Evaluate revenue and profitability across product categories.
- Examine monthly sales trends.
- Identify high-value and inactive customers.
- Apply SQL techniques to solve practical business problems.

## 3. Tools and Technologies
- Dbeaver
- PostgreSQL
- SQL
- SQL joins and aggregate functions
- Subqueries and CTEs
- Window functions
- Views
- PL/pgSQL

## 4. Database Structure

The database contains two related tables:

**Customers**
- customer_id
- customer_name
- gender
- city
- registration_date
- customer_segment

**Orders**
- order_id
- customer_id
- order_date
- product_name
- product_category
- quantity
- unit_price
- cost_price
- discount
- payment_method
- order_status

One customer can have multiple orders. The `customer_id` column connects the two tables.

## 5. Business Calculations

- Revenue = quantity × unit_price × (1 − discount / 100)
- Cost = quantity × cost_price
- Profit = revenue − cost
- Profit Margin = (profit / revenue) × 100

## 6. Repository Contents

| File/Folder | Description |
|---|---|
| `README.md` | Project documentation and execution instructions |
| `schema.sql` | Database table creation statements |
| `queries.sql` | All 46 SQL questions and answers |
| `insights.md` | Business insights and recommendations |
| `screenshots/` | SQL verification and analysis results |

## 7. SQL Analysis

The project contains six sections:

1. SQL Fundamentals (Q1–Q10)
2. Aggregation and Grouping (Q11–Q20)
3. Joins and Customer Analytics (Q21–Q28)
4. Subqueries and CTEs (Q29–Q34)
5. Window Functions (Q35–Q42)
6. Advanced Business Intelligence (Q43–Q46)

## 8. How to Set Up and Run the Project

1. Install or open PostgreSQL and connect to your database.
2. Open `schema.sql` and execute the CREATE TABLE statements.
3. Import or insert the customer and order datasets.
4. Run `05_verify_data.sql` to confirm that the data has loaded correctly.
5. Open `queries.sql` and execute the queries.

## 9. Business Insights

The project investigates five key business areas:

- Customer purchasing behaviour.
- Product performance.
- Category profitability.
- Monthly sales performance.
- Overall business performance.

The detailed findings, their business significance and recommendations are documented in `insights.md`.
