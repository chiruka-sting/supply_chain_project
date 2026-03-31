# ------- 1. Country-wise count of customers

SELECT count(*) num_customers, country 
FROM customer 
GROUP BY country 
ORDER BY num_customers DESC;

#------------- 2. Display the products that are not discontinued. 

SELECT ProductName 
FROM PRODUCT 
WHERE CAST(IsDiscontinued as unsigned)=0;

# -------------3. Display the list of companies along with the product name that they are supplying. 

SELECT s.Id Company_Id, s.CompanyName Company_Name, p.Product_Name  
FROM SUPPLIER s 
inner join PRODUCT p  
on s.Id=p.Id
ORDER by company_Name;

# modification of query 3 to count how may products from each supplier and a list of products

WITH SupplierProducts AS (
    SELECT 
        s.Id AS SupplierId,
        s.CompanyName,
        GROUP_CONCAT(p.ProductName ORDER BY p.ProductName) AS Products,
        COUNT(*) AS num_products
    FROM Supplier s
    JOIN Product p ON s.Id = p.SupplierId
    GROUP BY s.Id, s.CompanyName
)
SELECT CompanyName, num_products
FROM SupplierProducts
order by num_products
LIMIT 5;


#------------ 4. display supplier ID who owns the highest number of products.

WITH SupplierProducts AS (
    SELECT 
        s.Id AS SupplierId,
        s.CompanyName,
        COUNT(*) AS num_products
    FROM Supplier s
    JOIN Product p ON s.Id = p.SupplierId
    GROUP BY s.Id, s.CompanyName
),
Ranked AS (
    SELECT *,
           DENSE_RANK() OVER (ORDER BY num_products DESC) AS rnk
    FROM SupplierProducts
)
SELECT SupplierId, CompanyName, num_products
FROM Ranked
WHERE rnk = 1;


#----------5. Display month-wise and year-wise counts of the orders placed.

 WITH orders_placed AS(
	SELECT  o_r.Id,
			o_r.Quantity,
			year(o.OrderDate) as Year,
			month(o.OrderDate) as Month,
			count(*) AS num_orders 
			
			From ORDERITEM AS o_r 
			INNER JOIN ORDERs AS o 
			on o_r.OrderId=o.Id 
			Group by o_r.id,
				o_r.Quantity,
				YEAR(orderDate),
				MONTH(o.OrderDate)
				)
			
	select year,
		   month,
		   sum(Quantity) total_quantity,
		   sum(num_orders) as total_orders
		   from orders_placed 
		   group by year, Month 
		   order by year, month;
		   
#------ 5.1 modification to include year totals 

WITH orders_placed AS (
    SELECT 
        YEAR(o.OrderDate) AS Year,
        MONTH(o.OrderDate) AS Month,
        SUM(o_r.Quantity) AS total_quantity,
        COUNT(*) AS total_orders
    FROM ORDERITEM AS o_r
    INNER JOIN Orders AS o
        ON o_r.OrderId = o.Id
    GROUP BY 
        YEAR(o.OrderDate),
        MONTH(o.OrderDate)
)
SELECT 
    Year,
    Month,
    total_quantity,
    total_orders
FROM orders_placed

UNION ALL

SELECT
    Year,
    NULL AS Month,
    SUM(total_quantity),
    SUM(total_orders)
FROM orders_placed
GROUP BY Year

ORDER BY Year, Month;


#---------6 Which country has the maximum number of suppliers?

WITH max_supplies AS (
		select country, count(*) as num_suppliers 
		from SUPPLIER 
		group by country
	
),
Ranked AS (
    SELECT *,
           DENSE_RANK() OVER (ORDER BY num_suppliers DESC) AS rnk
    FROM max_supplies
)
SELECT country, num_suppliers
FROM Ranked
WHERE rnk = 1;


#---------7.	Which customers did not place any orders?

SELECT 
	c.Id Customer_Id,
	CONCAT(c.FirstName," ", c.LastName) AS Full_Name,
	c.country AS country 
FROM customer c
LEFT JOIN orders o
ON c.Id = o.customerid
WHERE o.Id IS NULL;

#-------------8. Arrange the Product ID and Name based on the high demand by the customer.

SELECT 
        p.Id AS Product_Id,
        p.ProductName,
        SUM(o.Quantity) AS Total_Quantity
    FROM Product p
    INNER JOIN OrderItem o
        ON p.Id = o.ProductId
    GROUP BY p.Id, p.ProductName
    ORDER BY Total_Quantity DESC
	limit 5 ;

#------------8.1 top n demanded products and suppliers 

WITH TopProducts AS (
    SELECT 
        p.Id AS Product_Id,
        p.ProductName,
        p.SupplierId,
        SUM(o.Quantity) AS Total_Quantity
    FROM Product p
    INNER JOIN OrderItem o
        ON p.Id = o.ProductId
    GROUP BY p.Id, p.ProductName, p.SupplierId
    ORDER BY Total_Quantity DESC
    LIMIT 5  #------the limit can be changed to a suitable n value
)
SELECT 
    tp.Product_Id,
    tp.ProductName,
    s.CompanyName,
    tp.Total_Quantity
FROM TopProducts tp
JOIN Supplier s
    ON tp.SupplierId = s.Id;
	
#-------------9. Display the total number of orders delivered every year

SELECT YEAR(o.orderdate) Year, 
	   SUM(oi.quantity) Quantity
FROM orderitem oi
INNER JOIN orders o 
	ON oi.orderid= o.id
GROUP BY YEAR(o.orderdate)
ORDER BY YEAR;

#--------------10. Yearwise total revenue.

SELECT 
	YEAR(o.Orderdate) Year,
	SUM(oi.unitprice * oi.quantity) Total_revenue
FROM orders o
INNER JOIN OrderItem oi
	ON oi.orderid= o.id
GROUP BY YEAR(o.orderdate)
ORDER BY YEAR;

#--------------10.1 year wise total revenue per product

 SELECT 
    p.Id AS Product_Id,
    p.ProductName,
    SUM(oi.UnitPrice * oi.Quantity) AS Total_Revenue
FROM Product p
INNER JOIN OrderItem oi
    ON oi.ProductId = p.Id
INNER JOIN Orders o
    ON oi.OrderId = o.Id
GROUP BY 
    p.Id,
    p.ProductName
ORDER BY 
    Total_Revenue DESC;
	
# --------- 11.Display the customer details whose order amount is maximum. 

WITH max_orders AS(
SELECT c.id,concat(c.firstname,' ',c.lastname) name, sum(o.totalamount) total_amount
from customer c
inner join orders o 
on o.customerid = c.id
group by c.id

),

Ranked AS (
    SELECT *,
           DENSE_RANK() OVER (ORDER BY total_amount DESC) AS rnk
    FROM max_orders
)
SELECT *
FROM Ranked
WHERE rnk = 1;

#-------------- 11.1 include the past orders for number 1 ranked 

WITH max_orders AS(
SELECT c.id, CONCAT(c.firstname,' ',c.lastname) name, SUM(o.totalamount) total_amount
FROM customer c
INNER JOIN orders o 
	ON o.customerid = c.id
GROUP BY c.id

),
Ranked AS (
    SELECT *,
           DENSE_RANK() OVER (ORDER BY total_amount DESC) AS rnk
    FROM max_orders
	WHERE TOTAL_AMOUNT IS NOT NULL

)

SELECT 
	c.id id, CONCAT(c.firstname,' ',c.lastname) name, 
	c.city city, c.country country, c.phone phone, 
	o.id order_id , o.totalamount order_amount
FROM customer c 
INNER JOIN orders o 
	ON c.id = o.customerid 
WHERE c.id IN (SELECT id FROM ranked WHERE rnk=1);

#-------------------- 11.2 TOP 5 CUSTOMERS WITH ORDER HISTORY AND TOTAL ORDER AMOUNT

WITH CustomerTotals AS (
    SELECT 
        c.Id AS CustomerId,
        CONCAT(c.FirstName, ' ', c.LastName) AS Name,
        SUM(o.TotalAmount) AS Total_Spent
    FROM Customer c
    INNER JOIN Orders o
        ON o.CustomerId = c.Id
    GROUP BY c.Id, Name
),
Top5 AS (
    SELECT *,
           DENSE_RANK() OVER (ORDER BY Total_Spent DESC) AS rnk
    FROM CustomerTotals
    WHERE Total_Spent IS NOT NULL
)
SELECT 
    c.Id AS Customer_Id,
    CONCAT(c.FirstName, ' ', c.LastName) AS Name,
    c.City,
    c.Country,
    c.Phone,
    o.Id AS Order_Id,
    o.OrderDate,
    o.TotalAmount AS Order_Amount,
    t.Total_Spent AS Customer_Total_Revenue
FROM Top5 t
INNER JOIN Customer c
    ON c.Id = t.CustomerId
INNER JOIN Orders o
    ON o.CustomerId = c.Id
WHERE t.rnk <= 5
ORDER BY 
    t.Total_Spent DESC,
    c.Id,
    o.OrderDate DESC;
	
# ----------alternative using window function
SELECT
    Customer_Id,
    Name,
    City,
    Country,
    Phone,
    Order_Id,
    OrderDate,
    Order_Amount,
    Customer_Total_Revenue
FROM (
    SELECT 
        c.Id AS Customer_Id,
        CONCAT(c.FirstName, ' ', c.LastName) AS Name,
        c.City,
        c.Country,
        c.Phone,
        o.Id AS Order_Id,
        o.OrderDate,
        o.TotalAmount AS Order_Amount,
        SUM(o.TotalAmount) OVER (PARTITION BY c.Id) AS Customer_Total_Revenue,
        DENSE_RANK() OVER (
            ORDER BY SUM(o.TotalAmount) OVER (PARTITION BY c.Id) DESC
        ) AS rnk
    FROM Customer c
    INNER JOIN Orders o
        ON o.CustomerId = c.Id
) t
WHERE rnk <= 5
ORDER BY 
    Customer_Total_Revenue DESC,
    Customer_Id,
    OrderDate DESC;
	
# 12. Display the total amount ordered by each customer from high to low.
 
SELECT C.ID, SUM(O.TOTALAMOUNT) TOTAL_AMT
FROM customer c
INNER JOIN orders o 
	ON c.id = o.CustomerId
GROUP BY c.id
ORDER BY total_amt DESC
limit 5;

#12. Display the total amount ordered by each customer from high to low.

SELECT 
    c.Id Customer_ID,
    CONCAT(c.FirstName, ' ', c.LastName) AS Name,
    COALESCE(SUM(o.TotalAmount), 0) AS Total_Amt
FROM Customer c
LEFT JOIN Orders o 
    ON c.Id = o.CustomerId
GROUP BY c.Id, Name
ORDER BY Total_Amt DESC;


#13 ----Fetch the customer details who ordered more than 10 products in a single order.
#------depending on how one inteprets products.(can be distinct products or quantity)

#13.1. --------- if distinct products 
SELECT 
    c.Id AS CustomerId,
    CONCAT(c.FirstName, ' ', c.LastName) AS Name,
    o.Id AS OrderId,
    o.OrderDate,
    COUNT(DISTINCT oi.ProductId) AS Num_Products
FROM Customer c
JOIN Orders o 
    ON o.CustomerId = c.Id
JOIN OrderItem oi
    ON oi.OrderId = o.Id
GROUP BY 
    c.Id, Name, o.Id, o.OrderDate
HAVING COUNT(DISTINCT oi.ProductId) > 10
ORDER BY Num_Products DESC;

#13.2---- if using quantity > 10 in a single order

SELECT 
    c.Id AS CustomerId,
    CONCAT(c.FirstName, ' ', c.LastName) AS Name,
    o.Id AS OrderId,
    o.OrderDate,
    SUM(oi.Quantity) AS Total_Items
FROM Customer c
JOIN Orders o 
    ON o.CustomerId = c.Id
JOIN OrderItem oi
    ON oi.OrderId = o.Id
GROUP BY 
    c.Id, Name, o.Id, o.OrderDate
HAVING SUM(oi.Quantity) > 10
ORDER BY Total_Items DESC;

#14 ----------14.	The company sells the products at different discount rates. 
#--Refer actual product price in the product table and the selling price in the order item table
#--Write a query to find out the total amount saved in each order then 
#--the orders from highest to lowest amount saved. 

SELECT 
	oi.orderid,
	SUM((p.unitprice-oi.unitprice)*oi.quantity) AS total_amount_saved  
FROM product p 
INNER JOIN orderitem oi 
	ON p.id=oi.productid 
GROUP BY oi.orderid 
ORDER BY total_amount_saved desc;


#----15.	Create a combined list to display customers' and suppliers' details considering the following criteria 
#a. Both customer and supplier belong to the same country 
#b.	Customers who do not have a supplier in their country
#c.	A supplier who does not have customers in their country 

SELECT 
    c.*, 
    s.*
FROM customer c
LEFT JOIN supplier s
    ON c.country = s.country

UNION ALL

SELECT 
    c.*, 
    s.*
FROM supplier s
LEFT JOIN customer c
    ON c.country = s.country
WHERE c.country IS NULL;
