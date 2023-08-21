use supply_db ;


/* Question : Golf related products

List all products in categories related to golf. Display the Product_Id, Product_Name in the output. Sort the output in the order of product id.
Hint: You can identify a Golf category by the name of the category that contains golf. */

/* Answer I */

SELECT
Product_Name, Product_Id
FROM
(
SELECT p.Product_Name , p.Product_Id
FROM product_info AS p
LEFT JOIN category AS c
ON p.Category_Id =c.Id
WHERE LOWER(c.Name) LIKE '%golf%'
ORDER BY Product_id 
)
as summary;

/* Answer II */

select Product_Name, Product_Id
from product_info
where Category_Id IN
    (select Id
    from category
    where Name LIKE '%golf%'
    )
order by Product_Id;
-- **********************************************************************************************************************************

/*
Question : Most sold golf products

Find the top 10 most sold products (based on sales) in categories related to golf. Display the Product_Name and Sales column in the output. Sort the output in the descending order of sales.
Hint: You can identify a Golf category by the name of the category that contains golf.

HINT:
Use orders, ordered_items, product_info, and category tables from the Supply chain dataset.

*/

SELECT
Product_Name, Sales
FROM
(
SELECT p.Product_Name, SUM(Sales) AS Sales,
RANK() OVER(ORDER BY SUM(Sales) DESC) AS Sales_Rank
FROM orders AS o
LEFT JOIN ordered_items AS oi
ON o.Order_Id = oi.Order_Id
LEFT JOIN product_info AS p
ON oi.Item_Id=p.Product_Id
LEFT JOIN category AS c
ON p.Category_Id =c.Id
WHERE LOWER(c.Name) LIKE '%golf%'
GROUP BY p.Product_Name
ORDER BY Sales DESC
)
AS summary
WHERE Sales_Rank<=10;

-- **********************************************************************************************************************************

/*
Question: Segment wise orders

Find the number of orders by each customer segment for orders. Sort the result from the highest to the lowest 
number of orders.The output table should have the following information:
-Customer_segment
-Orders

*/

select c.Segment as Customer_Segment ,count(Order_Id) as Orders
from customer_info c
JOIN orders o ON c.Id = o.Customer_Id
GROUP BY c.Segment
ORDER BY Orders DESC;

-- **********************************************************************************************************************************
/*
Question : Percentage of order split

Description: Find the percentage of split of orders by each customer segment for orders that took six days 
to ship (based on Real_Shipping_Days). Sort the result from the highest to the lowest percentage of split orders,
rounding off to one decimal place. The output table should have the following information:
-Customer_segment
-Percentage_order_split

HINT:
Use the orders and customer_info tables from the Supply chain dataset.

*/

/* Answer I */

SELECT c.Segment as Customer_Segment, round((count(o.Order_Id)/(select count(*) from orders where Real_Shipping_Days=6)) * 100, 1) AS Percentage_order_split
FROM customer_info c
JOIN orders o ON c.Id = o.Customer_Id
WHERE o.Real_Shipping_Days=6
GROUP BY c.Segment
ORDER BY Percentage_order_split DESC;

/* Answer II */

WITH Seg_Orders AS
(
SELECT c.Segment AS customer_segment, COUNT(o.Order_Id) AS Orders
FROM
orders AS o LEFT JOIN customer_info AS c
ON o.Customer_Id = c.Id
WHERE Real_Shipping_Days=6
GROUP BY c.Segment
)
SELECT
a.customer_segment, ROUND(a.Orders/SUM(b.Orders)*100,1) AS percentage_order_split
FROM Seg_Orders AS a
JOIN Seg_Orders AS b
GROUP BY customer_segment
ORDER BY percentage_order_split DESC;

-- **********************************************************************************************************************************
