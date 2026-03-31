SQL Supply Chain Case Study — Richard’s Supply
This project explores a complete SQL case study based on Richard’s Supply, a company dealing with a wide range of food products sourced from multiple suppliers and sold to customers across different countries.
The database captures suppliers, products, customers, orders, and order items, enabling rich analytical queries for supply chain insights.
The company has maintained its database for two years, and this case study focuses on answering real‑world business questions using SQL.
Project Overview
Richard’s Supply works with:
- A pool of suppliers, each providing multiple food products
- A diverse set of customers placing orders
- Orders that may contain multiple products and quantities
- Products sold at varying discount rates, with actual prices stored in the product table and selling prices stored in the order item table
The goal of this project is to design SQL queries that extract meaningful insights from the supply chain database.

SQL Tasks Covered
The following tasks come directly from the case study instructions :
1. Customer & Supplier Insights
- Country‑wise count of customers
- Country with the maximum number of suppliers
- Customers who did not place any orders
- Combined list of customers and suppliers based on:
- Same country
- Customers without suppliers in their country
- Suppliers without customers in their country
2. Product Insights
- Display products that are not discontinued
- List companies (suppliers) along with the products they supply
- Identify the supplier who owns the highest number of products
- Rank products by high demand (based on customer orders)
3. Order Insights
- Month‑wise and year‑wise order counts
- Total number of orders delivered every year
- Customer with the maximum order amount, including past orders
- Customers who ordered more than 10 products in a single order
- Total amount ordered by each customer (high → low)
 Revenue & Savings
- Year‑wise total revenue
- Calculate total amount saved in each order
- Using actual product price vs. selling price
- Display orders from highest → lowest savings
How to Use This Project
- Create the database using 2_Data.sql and 3_constraints.sql (or your own ERD).
  
- Run each query in queries.sql to generate insights. Each query corressponds to a task in supply chain questions.docx
