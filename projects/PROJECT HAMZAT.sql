USE ECOMMERCE;
-- 1. TOTAL SALES BY EMPLOYEE
SELECT e.EmployeeID, e.FirstName, e.LastName,
       SUM(od.Quantity * od.UnitPrice) AS Total_Sales
FROM Orders o
INNER JOIN Employees e ON o.EmployeeID = e.EmployeeID
INNER JOIN OrderDetails od ON od.OrderID = o.OrderID
GROUP BY e.EmployeeID, e.FirstName, e.LastName
ORDER BY Total_Sales DESC;

-- 2. TOP 5 CUSTOMERS BY SALES;
 SELECT c.CUSTOMERID, 
SUM(OD.QUANTITY * OD.UNITPRICE) AS TOTAL_SPENT
FROM ORDERS O
 INNER JOIN CUSTOMERS C ON o.CUSTOMERID=C.CUSTOMERID
 INNER JOIN ORDERDETAILS OD ON O.ORDERID = OD.ORDERID
GROUP BY c.CUSTOMERID
ORDER BY TOTAL_SPENT DESC
LIMIT 5;

-- 3. MONTHLY SALES TREND (1997)
SELECT MONTH(O.ORDERDATE) AS MONTH,
SUM(Od.QUANTITY * Od.UNITPRICE) AS MONTHLY_SALES
FROM ORDERS O
INNER JOIN ORDERDETAILS OD ON O.ORDERID= OD.ORDERID
WHERE YEAR(O.ORDERDATE) = 1997
GROUP BY MONTH(O.ORDERDATE)
ORDER BY MONTH;

-- 4. ORDER FULFILMENT TIME:
SELECT E.EMPLOYEEID, E.FIRSTNAME, E.LASTNAME,
    AVG(
      CASE
          WHEN YEAR(O.ORDERDATE) = 1996 THEN 3
          WHEN YEAR(O.ORDERDATE) = 1997 THEN 5
      END
    ) AS AVG_FULFILMENT_DAY
FROM ORDERS O
INNER JOIN EMPLOYEES E ON O.EmployeeID = e.EmployeeID
GROUP BY E.EmployeeID, E.FIRSTNAME, E.LASTNAME;


-- 5. PRODUCTS BY CATEGORY WITH NO SALES:
SELECT C.CustomerID, C.CustomerName,
       SUM(OD.Quantity * OD.UnitPrice) AS Total_Sales
FROM Orders O
INNER JOIN Customers C ON O.CustomerID = C.CustomerID
INNER JOIN OrderDetails OD ON O.OrderID = OD.OrderID
WHERE C.City = 'London'
GROUP BY C.CustomerID, C.CustomerName
ORDER BY Total_Sales DESC;

-- 6. CUSTOMERS WITH MULTIPLE ORDERS ON THE SAME DATE
SELECT C.CustomerID, C.CustomerName, O.OrderDate,
       COUNT(O.OrderID) AS Num_OF_Orders
FROM Orders O
INNER JOIN Customers C ON O.CustomerID = C.CustomerID
GROUP BY C.CustomerID, C.CustomerName, O.OrderDate
HAVING COUNT(O.OrderID) > 1
ORDER BY C.CustomerName, O.OrderDate;

-- 7. AVERAGE DISCOUNT PER PRODUCT
SELECT P.PRODUCTID, P.PRODUCTNAME,
 ROUND(AVG(OD.DISCOUNT), 2) AS AVG_DISCOUNT
FROM ORDERDETAILS OD
LEFT JOIN PRODUCTS P ON OD.PRODUCTID =P.PRODUCTID
GROUP BY P.PRODUCTID, P.PRODUCTNAME;

-- 8. PRODUCTS ORDERED BY EACH CUSTOMER
SELECT C.CUSTOMERID, C.CUSTOMERNAME, 
       P.PRODUCTID, P.PRODUCTNAME,
       SUM(OD.QUANTITY) AS TOTAL_QUANTITY
FROM Customers C
INNER JOIN Orders O ON C.CustomerID = O.CustomerID
INNER JOIN OrderDetails OD ON O.OrderID = OD.OrderID
INNER JOIN Products P ON OD.ProductID = P.ProductID
GROUP BY C.CUSTOMERID, C.CUSTOMERNAME, P.PRODUCTID, P.PRODUCTNAME
ORDER BY C.CUSTOMERNAME, P.PRODUCTNAME;

-- 9. EMPLOYEE SALES RANKING
SELECT E.EMPLOYEEID, 
       CONCAT(E.FirstName, "  ", E.LastName) AS EMPLOYEENAME,
       SUM(OD.Quantity * OD.UnitPrice) AS Total_Sales,
       RANK() OVER (ORDER BY SUM(OD.Quantity * OD.UnitPrice) DESC) AS SALES_RANK
FROM Employees E
INNER JOIN Orders O ON E.EmployeeID = O.EmployeeID
INNER JOIN OrderDetails OD ON O.OrderID = OD.OrderID
GROUP BY E.EMPLOYEEID, E.FIRSTNAME, E.LASTNAME
ORDER BY SALES_RANK;

-- 10.SALES BY COUNTRY AND CATEGORY
SELECT C.COUNTRY,
       CAT.CATEGORYNAME,
       SUM(OD.Quantity * OD.UnitPrice) AS TOTAL_SALES_AMOUNT
FROM Customers C
INNER JOIN Orders O ON C.CustomerID = O.CustomerID
INNER JOIN OrderDetails OD ON O.OrderID = OD.OrderID
INNER JOIN Products P ON OD.ProductID = P.ProductID
INNER JOIN Categories Cat ON P.CategoryID = Cat.CategoryID
GROUP BY C.COUNTRY, CAT.CATEGORYNAME
ORDER BY C.Country, TOTAL_SALES_AMOUNT DESC;

-- 11. YEAR_OVER_YEAR SALES GROWTH:
SELECT P.PRODUCTID,
       P.PRODUCTNAME,
       YEAR(O.OrderDate) AS Sales_Year,
       SUM(OD.Quantity * OD.UnitPrice) AS Total_Sales,
       ROUND(
         (SUM(OD.Quantity * OD.UnitPrice) -
          LAG(SUM(OD.Quantity * OD.UnitPrice))
          OVER (PARTITION BY P.ProductID ORDER BY YEAR(O.OrderDate)))
          /
          LAG(SUM(OD.Quantity * OD.UnitPrice))
          OVER (PARTITION BY P.ProductID ORDER BY YEAR(O.OrderDate))
          * 100, 2
       ) AS YoY_Growth_Percent
FROM Orders O
INNER JOIN OrderDetails OD ON O.OrderID = OD.OrderID
INNER JOIN Products P ON OD.ProductID = P.ProductID
GROUP BY P.ProductID, P.ProductName, YEAR(O.OrderDate)
ORDER BY P.ProductName, Sales_Year;

-- SOLUTION 2
SELECT P.ProductID,
       P.ProductName,
       YEAR(O.OrderDate) AS SalesYear,
       SUM(OD.Quantity * OD.UnitPrice) AS YearlySales
FROM Orders O
INNER JOIN OrderDetails OD ON O.OrderID = OD.OrderID
INNER JOIN Products P ON OD.ProductID = P.ProductID
GROUP BY P.ProductID, P.ProductName, YEAR(O.OrderDate);

SELECT curr.ProductID,
       curr.ProductName,
       curr.SalesYear,
       curr.YearlySales,
       prev.YearlySales AS PrevYearSales,
       ROUND(
         (curr.YearlySales - prev.YearlySales) / prev.YearlySales * 100, 2
       ) AS YoY_Growth_Percent
FROM (
    SELECT P.ProductID,
           P.ProductName,
           YEAR(O.OrderDate) AS SalesYear,
           SUM(OD.Quantity * OD.UnitPrice) AS YearlySales
    FROM Orders O
    INNER JOIN OrderDetails OD ON O.OrderID = OD.OrderID
    INNER JOIN Products P ON OD.ProductID = P.ProductID
    GROUP BY P.ProductID, P.ProductName, YEAR(O.OrderDate)
) curr
LEFT JOIN (
    SELECT P.ProductID,
           P.ProductName,
           YEAR(O.OrderDate) AS SalesYear,
           SUM(OD.Quantity * OD.UnitPrice) AS YearlySales
    FROM Orders O
    INNER JOIN OrderDetails OD ON O.OrderID = OD.OrderID
    INNER JOIN Products P ON OD.ProductID = P.ProductID
    GROUP BY P.ProductID, P.ProductName, YEAR(O.OrderDate)
) prev
ON curr.ProductID = prev.ProductID
AND curr.SalesYear = prev.SalesYear + 1
ORDER BY curr.ProductName, curr.SalesYear;

-- 12. ORDER QUANTITY PERCENTILE
SELECT O.ORDERID,
       SUM(OD.Quantity) AS Total_Quantity,
       PERCENT_RANK() OVER (ORDER BY SUM(OD.Quantity)) AS Quantity_Percentile
FROM Orders O
INNER JOIN OrderDetails OD ON O.OrderID = OD.OrderID
GROUP BY O.ORDERID
ORDER BY Quantity_Percentile;

-- 13. PRODUCTS NEVER REORDERED
SELECT P.PRODUCTID, P.PRODUCTNAME
FROM ORDERDETAILS OD
INNER JOIN PRODUCTS P ON OD.PRODUCTID = P.PRODUCTID
GROUP BY P.PRODUCTID, P.PRODUCTNAME
HAVING COUNT(DISTINCT OD.ORDERID) =1;

-- 14.MOST VALUABLE PROUCT BY REVENUE
SELECT c.categoryid,
       c.categoryname,
       p.productid,
       p.productname,
       SUM(od.quantity * od.unitprice) AS total_revenue
FROM orderdetails od
JOIN products p ON od.productid = p.productid
JOIN categories c ON p.categoryid = c.categoryid
GROUP BY c.categoryid, p.productid, p.productname
HAVING SUM(od.quantity * od.unitprice) = (
    SELECT MAX(category_revenue)
    FROM (
        SELECT p2.categoryid,
               SUM(od2.quantity * od2.unitprice) AS category_revenue
        FROM orderdetails od2
        JOIN products p2 ON od2.productid = p2.productid
        WHERE p2.categoryid = c.categoryid
        GROUP BY p2.productid
    ) AS sub
);

-- 15. COMPLETE ORDER DETAILS
SELECT O.ORDERID,
SUM(OD.QUANTITY * OD.UNITPRICE * (1 - OD.DISCOUNT)) AS TOTAL_ORDER_PRICE
FROM ORDERS o
INNER JOIN ORDERDETAILS OD ON O.ORDERID = OD.ORDERID
GROUP BY O.ORDERID
HAVING SUM(OD.QUANTITY *OD.UNITPRICE * (1 - OD.DISCOUNT)) > 100
AND MAX(OD.DISCOUNT) >=0.05;
