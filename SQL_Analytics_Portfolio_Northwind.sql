-- ============================================================
-- 📊 SQL ANALYTICS PORTFOLIO — NORTHWIND DATABASE
-- 👤 Author: Geudis Martinez
-- 🛠️  Tool: SQL Server (SSMS)
-- 📅 Year: 2026
-- 🎯 Goal: Real Data Analyst skills — from exploration to advanced
-- ============================================================
-- 
-- STRUCTURE:
-- PHASE 0 — Database Exploration (always do this first)
-- PHASE 1 — Foundations (SELECT, WHERE, GROUP BY, JOINs)
-- PHASE 2 — Intermediate (Subqueries, Derived Tables, CASE)
-- PHASE 3 — Advanced (CTEs, Window Functions, Correlated Subqueries)
-- PHASE 4 — Professional (Error Handling, Transactions, Real Business Cases)
-- ============================================================


-- ============================================================
-- 🔍 PHASE 0 — DATABASE EXPLORATION
-- Always run these first when you connect to a new database.
-- A real analyst never touches data without understanding it first.
-- ============================================================

-- 0.1 What tables exist in this database?
SELECT 
    TABLE_SCHEMA,
    TABLE_NAME,
    TABLE_TYPE
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;

-- 0.2 What columns does each table have?
SELECT 
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME IN (
    'Orders','Order Details','Customers',
    'Products','Employees','Categories','Suppliers'
)
ORDER BY TABLE_NAME, ORDINAL_POSITION;

-- 0.3 How many rows does each table have?
SELECT 'Customers'    AS TableName, COUNT(*) AS TotalRows FROM Customers    UNION ALL
SELECT 'Orders',                    COUNT(*)               FROM Orders       UNION ALL
SELECT 'Order Details',             COUNT(*)               FROM [Order Details] UNION ALL
SELECT 'Products',                  COUNT(*)               FROM Products     UNION ALL
SELECT 'Employees',                 COUNT(*)               FROM Employees    UNION ALL
SELECT 'Categories',                COUNT(*)               FROM Categories   UNION ALL
SELECT 'Suppliers',                 COUNT(*)               FROM Suppliers    UNION ALL
SELECT 'Shippers',                  COUNT(*)               FROM Shippers;

-- 0.4 Quick preview of each main table
SELECT TOP 5 * FROM Customers;
SELECT TOP 5 * FROM Orders;
SELECT TOP 5 * FROM [Order Details];
SELECT TOP 5 * FROM Products;
SELECT TOP 5 * FROM Employees;

-- 0.5 Check for NULL values in key columns
SELECT
    COUNT(*)                          AS TotalOrders,
    SUM(CASE WHEN CustomerID  IS NULL THEN 1 ELSE 0 END) AS NullCustomerID,
    SUM(CASE WHEN EmployeeID  IS NULL THEN 1 ELSE 0 END) AS NullEmployeeID,
    SUM(CASE WHEN OrderDate   IS NULL THEN 1 ELSE 0 END) AS NullOrderDate,
    SUM(CASE WHEN ShippedDate IS NULL THEN 1 ELSE 0 END) AS NullShippedDate
FROM Orders;

-- 0.6 Date range of the data
SELECT
    MIN(OrderDate) AS FirstOrder,
    MAX(OrderDate) AS LastOrder,
    DATEDIFF(DAY, MIN(OrderDate), MAX(OrderDate)) AS DaysOfHistory
FROM Orders;

-- 0.7 Understand the relationships — Orders to Order Details
SELECT TOP 10
    o.OrderID,
    o.CustomerID,
    o.OrderDate,
    od.ProductID,
    od.UnitPrice,
    od.Quantity,
    od.Discount,
    (od.UnitPrice * od.Quantity * (1 - od.Discount)) AS LineTotal
FROM Orders o
INNER JOIN [Order Details] od ON o.OrderID = od.OrderID
ORDER BY o.OrderDate DESC;


-- ============================================================
-- 🟢 PHASE 1 — FOUNDATIONS
-- SELECT, WHERE, GROUP BY, HAVING, ORDER BY, JOINs
-- ============================================================

-- ── BLOCK 1: SELECT and WHERE ──────────────────────────────

-- 1.1 All products with price above $20
SELECT 
    ProductName, 
    UnitPrice, 
    UnitsInStock
FROM Products
WHERE UnitPrice > 20
ORDER BY UnitPrice DESC;

-- 1.2 Products that are discontinued AND have stock
SELECT 
    ProductName, 
    UnitPrice, 
    UnitsInStock,
    Discontinued
FROM Products
WHERE Discontinued = 1 
  AND UnitsInStock > 0;

-- 1.3 Customers from USA or Germany
SELECT 
    CompanyName, 
    Country, 
    City
FROM Customers
WHERE Country IN ('USA', 'Germany')
ORDER BY Country, City;

-- 1.4 Products with price between $10 and $30
SELECT 
    ProductName, 
    UnitPrice
FROM Products
WHERE UnitPrice BETWEEN 10 AND 30
ORDER BY UnitPrice;

-- 1.5 Customers whose company name starts with 'A' or 'B'
SELECT 
    CompanyName, 
    ContactName, 
    Country
FROM Customers
WHERE CompanyName LIKE 'A%' 
   OR CompanyName LIKE 'B%'
ORDER BY CompanyName;

-- 1.6 Orders shipped to France in 1997
SELECT 
    OrderID, 
    CustomerID, 
    OrderDate, 
    ShipCountry
FROM Orders
WHERE ShipCountry = 'France'
  AND YEAR(OrderDate) = 1997
ORDER BY OrderDate;

-- ── BLOCK 2: GROUP BY and HAVING ──────────────────────────

-- 1.7 Total orders per customer
SELECT 
    CustomerID,
    COUNT(OrderID)        AS TotalOrders,
    MIN(OrderDate)        AS FirstOrder,
    MAX(OrderDate)        AS LastOrder
FROM Orders
GROUP BY CustomerID
ORDER BY TotalOrders DESC;

-- 1.8 Total revenue per category
SELECT 
    c.CategoryName,
    COUNT(DISTINCT p.ProductID)                               AS TotalProducts,
    SUM(od.UnitPrice * od.Quantity * (1 - od.Discount))      AS TotalRevenue,
    AVG(od.UnitPrice * od.Quantity * (1 - od.Discount))      AS AvgOrderValue
FROM Categories c
INNER JOIN Products p        ON c.CategoryID  = p.CategoryID
INNER JOIN [Order Details] od ON p.ProductID  = od.ProductID
GROUP BY c.CategoryName
ORDER BY TotalRevenue DESC;

-- 1.9 Customers with more than 10 orders (HAVING)
SELECT 
    CustomerID,
    COUNT(OrderID) AS TotalOrders
FROM Orders
GROUP BY CustomerID
HAVING COUNT(OrderID) > 10
ORDER BY TotalOrders DESC;

-- 1.10 Sales by year and month
SELECT
    YEAR(OrderDate)  AS SalesYear,
    MONTH(OrderDate) AS SalesMonth,
    COUNT(OrderID)   AS TotalOrders,
    SUM(Freight)     AS TotalFreight
FROM Orders
GROUP BY YEAR(OrderDate), MONTH(OrderDate)
ORDER BY SalesYear, SalesMonth;

-- ── BLOCK 3: JOINs ────────────────────────────────────────

-- 1.11 Orders with customer and employee name
SELECT
    o.OrderID,
    o.OrderDate,
    c.CompanyName                            AS Customer,
    e.FirstName + ' ' + e.LastName           AS Employee,
    o.ShipCountry
FROM Orders o
INNER JOIN Customers c ON o.CustomerID = c.CustomerID
INNER JOIN Employees e ON o.EmployeeID = e.EmployeeID
ORDER BY o.OrderDate DESC;

-- 1.12 Products with category and supplier
SELECT
    p.ProductName,
    c.CategoryName,
    s.CompanyName   AS Supplier,
    p.UnitPrice,
    p.UnitsInStock
FROM Products p
INNER JOIN Categories c ON p.CategoryID  = c.CategoryID
INNER JOIN Suppliers  s ON p.SupplierID  = s.SupplierID
ORDER BY c.CategoryName, p.ProductName;

-- 1.13 LEFT JOIN — Customers who have NEVER placed an order
SELECT
    c.CustomerID,
    c.CompanyName,
    c.Country
FROM Customers c
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE o.OrderID IS NULL;

-- 1.14 Full order detail — 4 tables joined
SELECT
    o.OrderID,
    o.OrderDate,
    c.CompanyName                       AS Customer,
    p.ProductName,
    cat.CategoryName,
    od.Quantity,
    od.UnitPrice,
    od.Discount,
    ROUND(od.UnitPrice * od.Quantity * (1 - od.Discount), 2) AS LineTotal
FROM Orders o
INNER JOIN Customers      c   ON o.OrderID   = c.CustomerID
INNER JOIN [Order Details] od  ON o.OrderID   = od.OrderID
INNER JOIN Products        p   ON od.ProductID = p.ProductID
INNER JOIN Categories      cat ON p.CategoryID = cat.CategoryID
ORDER BY o.OrderDate DESC, o.OrderID;


-- ============================================================
-- 🟡 PHASE 2 — INTERMEDIATE
-- Subqueries, Derived Tables, CASE WHEN, Date Functions
-- ============================================================

-- ── BLOCK 4: Subqueries ───────────────────────────────────

-- 2.1 Products with price above the average price (simple subquery)
SELECT
    ProductName,
    UnitPrice,
    (SELECT AVG(UnitPrice) FROM Products) AS AvgPrice,
    UnitPrice - (SELECT AVG(UnitPrice) FROM Products) AS DiffFromAvg
FROM Products
WHERE UnitPrice > (SELECT AVG(UnitPrice) FROM Products)
ORDER BY UnitPrice DESC;

-- 2.2 Customers who placed orders in 1997 (subquery with IN)
SELECT
    CustomerID,
    CompanyName,
    Country
FROM Customers
WHERE CustomerID IN (
    SELECT DISTINCT CustomerID 
    FROM Orders 
    WHERE YEAR(OrderDate) = 1997
)
ORDER BY CompanyName;

-- 2.3 Products that have NEVER been ordered (subquery with NOT IN)
SELECT
    ProductID,
    ProductName,
    UnitPrice
FROM Products
WHERE ProductID NOT IN (
    SELECT DISTINCT ProductID 
    FROM [Order Details]
);

-- 2.4 The most expensive product in each category (subquery in WHERE)
SELECT
    p.ProductName,
    p.UnitPrice,
    c.CategoryName
FROM Products p
INNER JOIN Categories c ON p.CategoryID = c.CategoryID
WHERE p.UnitPrice = (
    SELECT MAX(p2.UnitPrice)
    FROM Products p2
    WHERE p2.CategoryID = p.CategoryID   -- correlated!
)
ORDER BY p.UnitPrice DESC;

-- ── BLOCK 5: Correlated Subqueries ────────────────────────
-- A correlated subquery references the outer query.
-- Runs once per row — powerful but requires understanding.

-- 2.5 Employees whose salary is above the average of their city
-- (Simulated with TitleOfCourtesy as group)
SELECT
    e.FirstName + ' ' + e.LastName  AS Employee,
    e.Title,
    e.City,
    (
        SELECT AVG(e2.EmployeeID)   -- using EmployeeID as proxy for "level"
        FROM Employees e2
        WHERE e2.City = e.City
    ) AS AvgLevelInCity
FROM Employees e
ORDER BY e.City;

-- 2.6 For each customer, show their most recent order date
SELECT
    c.CompanyName,
    c.Country,
    (
        SELECT MAX(o.OrderDate)
        FROM Orders o
        WHERE o.CustomerID = c.CustomerID
    ) AS LastOrderDate
FROM Customers c
ORDER BY LastOrderDate DESC;

-- 2.7 Products where stock is below the average stock of their category
SELECT
    p.ProductName,
    p.UnitsInStock,
    p.CategoryID
FROM Products p
WHERE p.UnitsInStock < (
    SELECT AVG(p2.UnitsInStock)
    FROM Products p2
    WHERE p2.CategoryID = p.CategoryID
)
ORDER BY p.CategoryID, p.UnitsInStock;

-- ── BLOCK 6: Derived Tables ───────────────────────────────
-- A derived table is a subquery used in the FROM clause.
-- Treated like a temporary table — very common in real work.

-- 2.8 Top 5 customers by total revenue (derived table)
SELECT TOP 5
    dt.CustomerID,
    c.CompanyName,
    dt.TotalRevenue
FROM (
    SELECT
        o.CustomerID,
        SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS TotalRevenue
    FROM Orders o
    INNER JOIN [Order Details] od ON o.OrderID = od.OrderID
    GROUP BY o.CustomerID
) AS dt
INNER JOIN Customers c ON dt.CustomerID = c.CustomerID
ORDER BY dt.TotalRevenue DESC;

-- 2.9 Average order value per employee using derived table
SELECT
    e.FirstName + ' ' + e.LastName AS Employee,
    emp_stats.TotalOrders,
    emp_stats.TotalRevenue,
    emp_stats.AvgOrderValue
FROM (
    SELECT
        o.EmployeeID,
        COUNT(DISTINCT o.OrderID)                                  AS TotalOrders,
        SUM(od.UnitPrice * od.Quantity * (1 - od.Discount))        AS TotalRevenue,
        AVG(od.UnitPrice * od.Quantity * (1 - od.Discount))        AS AvgOrderValue
    FROM Orders o
    INNER JOIN [Order Details] od ON o.OrderID = od.OrderID
    GROUP BY o.EmployeeID
) AS emp_stats
INNER JOIN Employees e ON emp_stats.EmployeeID = e.EmployeeID
ORDER BY emp_stats.TotalRevenue DESC;

-- ── BLOCK 7: CASE WHEN ────────────────────────────────────

-- 2.10 Product price classification
SELECT
    ProductName,
    UnitPrice,
    CASE
        WHEN UnitPrice < 10  THEN 'Budget'
        WHEN UnitPrice < 30  THEN 'Standard'
        WHEN UnitPrice < 100 THEN 'Premium'
        ELSE                      'Luxury'
    END AS PriceSegment
FROM Products
ORDER BY UnitPrice;

-- 2.11 Order performance by freight cost
SELECT
    OrderID,
    OrderDate,
    ShipCountry,
    Freight,
    CASE
        WHEN Freight < 20  THEN 'Low'
        WHEN Freight < 100 THEN 'Medium'
        ELSE                    'High'
    END AS FreightCategory
FROM Orders
ORDER BY Freight DESC;

-- 2.12 Customer activity flag
SELECT
    c.CompanyName,
    c.Country,
    CASE 
        WHEN MAX(o.OrderDate) >= '1998-01-01' THEN 'Active'
        WHEN MAX(o.OrderDate) >= '1997-01-01' THEN 'Dormant'
        ELSE                                       'Inactive'
    END AS CustomerStatus
FROM Customers c
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CompanyName, c.Country
ORDER BY CustomerStatus, c.CompanyName;

-- 2.13 CASE inside aggregate — pivot-style
SELECT
    YEAR(o.OrderDate) AS SalesYear,
    SUM(CASE WHEN MONTH(o.OrderDate) = 1  THEN od.UnitPrice * od.Quantity ELSE 0 END) AS Jan,
    SUM(CASE WHEN MONTH(o.OrderDate) = 2  THEN od.UnitPrice * od.Quantity ELSE 0 END) AS Feb,
    SUM(CASE WHEN MONTH(o.OrderDate) = 3  THEN od.UnitPrice * od.Quantity ELSE 0 END) AS Mar,
    SUM(CASE WHEN MONTH(o.OrderDate) = 4  THEN od.UnitPrice * od.Quantity ELSE 0 END) AS Apr,
    SUM(CASE WHEN MONTH(o.OrderDate) = 5  THEN od.UnitPrice * od.Quantity ELSE 0 END) AS May,
    SUM(CASE WHEN MONTH(o.OrderDate) = 6  THEN od.UnitPrice * od.Quantity ELSE 0 END) AS Jun,
    SUM(CASE WHEN MONTH(o.OrderDate) = 7  THEN od.UnitPrice * od.Quantity ELSE 0 END) AS Jul,
    SUM(CASE WHEN MONTH(o.OrderDate) = 8  THEN od.UnitPrice * od.Quantity ELSE 0 END) AS Aug,
    SUM(CASE WHEN MONTH(o.OrderDate) = 9  THEN od.UnitPrice * od.Quantity ELSE 0 END) AS Sep,
    SUM(CASE WHEN MONTH(o.OrderDate) = 10 THEN od.UnitPrice * od.Quantity ELSE 0 END) AS Oct,
    SUM(CASE WHEN MONTH(o.OrderDate) = 11 THEN od.UnitPrice * od.Quantity ELSE 0 END) AS Nov,
    SUM(CASE WHEN MONTH(o.OrderDate) = 12 THEN od.UnitPrice * od.Quantity ELSE 0 END) AS Dec
FROM Orders o
INNER JOIN [Order Details] od ON o.OrderID = od.OrderID
GROUP BY YEAR(o.OrderDate)
ORDER BY SalesYear;


-- ============================================================
-- 🔵 PHASE 3 — ADVANCED
-- CTEs, Window Functions, Advanced Analysis
-- ============================================================

-- ── BLOCK 8: CTEs — Simple ────────────────────────────────

-- 3.1 CTE for total revenue per customer, then filter top customers
WITH CustomerRevenue AS (
    SELECT
        o.CustomerID,
        SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS TotalRevenue,
        COUNT(DISTINCT o.OrderID)                            AS TotalOrders
    FROM Orders o
    INNER JOIN [Order Details] od ON o.OrderID = od.OrderID
    GROUP BY o.CustomerID
)
SELECT
    c.CompanyName,
    c.Country,
    cr.TotalRevenue,
    cr.TotalOrders,
    cr.TotalRevenue / cr.TotalOrders AS AvgOrderValue
FROM CustomerRevenue cr
INNER JOIN Customers c ON cr.CustomerID = c.CustomerID
WHERE cr.TotalRevenue > 5000
ORDER BY cr.TotalRevenue DESC;

-- 3.2 CTE for monthly sales, then calculate growth
WITH MonthlySales AS (
    SELECT
        YEAR(OrderDate)  AS SalesYear,
        MONTH(OrderDate) AS SalesMonth,
        SUM(Freight)     AS TotalFreight,
        COUNT(OrderID)   AS TotalOrders
    FROM Orders
    GROUP BY YEAR(OrderDate), MONTH(OrderDate)
)
SELECT
    SalesYear,
    SalesMonth,
    TotalOrders,
    TotalFreight,
    LAG(TotalOrders) OVER (ORDER BY SalesYear, SalesMonth) AS PrevMonthOrders,
    TotalOrders - LAG(TotalOrders) OVER (ORDER BY SalesYear, SalesMonth) AS OrderGrowth
FROM MonthlySales
ORDER BY SalesYear, SalesMonth;

-- ── BLOCK 9: CTEs — Multiple ──────────────────────────────

-- 3.3 Two CTEs: revenue + order count, joined for full customer profile
WITH Revenue AS (
    SELECT
        o.CustomerID,
        SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS TotalRevenue
    FROM Orders o
    INNER JOIN [Order Details] od ON o.OrderID = od.OrderID
    GROUP BY o.CustomerID
),
OrderCount AS (
    SELECT
        CustomerID,
        COUNT(OrderID)   AS TotalOrders,
        MIN(OrderDate)   AS FirstOrder,
        MAX(OrderDate)   AS LastOrder
    FROM Orders
    GROUP BY CustomerID
)
SELECT
    c.CompanyName,
    c.Country,
    r.TotalRevenue,
    oc.TotalOrders,
    oc.FirstOrder,
    oc.LastOrder,
    DATEDIFF(DAY, oc.FirstOrder, oc.LastOrder) AS DaysAsCustomer
FROM Customers c
INNER JOIN Revenue     r  ON c.CustomerID = r.CustomerID
INNER JOIN OrderCount  oc ON c.CustomerID = oc.CustomerID
ORDER BY r.TotalRevenue DESC;

-- 3.4 Three CTEs: products, category stats, supplier info — full product analysis
WITH ProductSales AS (
    SELECT
        od.ProductID,
        SUM(od.Quantity)                                          AS TotalQtySold,
        SUM(od.UnitPrice * od.Quantity * (1 - od.Discount))      AS TotalRevenue
    FROM [Order Details] od
    GROUP BY od.ProductID
),
CategoryAvg AS (
    SELECT
        p.CategoryID,
        AVG(p.UnitPrice) AS AvgCategoryPrice
    FROM Products p
    GROUP BY p.CategoryID
),
ProductDetail AS (
    SELECT
        p.ProductID,
        p.ProductName,
        p.UnitPrice,
        p.UnitsInStock,
        p.CategoryID,
        p.SupplierID
    FROM Products p
    WHERE p.Discontinued = 0
)
SELECT
    pd.ProductName,
    cat.CategoryName,
    s.CompanyName     AS Supplier,
    pd.UnitPrice,
    ca.AvgCategoryPrice,
    pd.UnitPrice - ca.AvgCategoryPrice  AS DiffFromCategoryAvg,
    ps.TotalQtySold,
    ps.TotalRevenue
FROM ProductDetail pd
INNER JOIN CategoryAvg    ca  ON pd.CategoryID  = ca.CategoryID
INNER JOIN ProductSales   ps  ON pd.ProductID   = ps.ProductID
INNER JOIN Categories     cat ON pd.CategoryID  = cat.CategoryID
INNER JOIN Suppliers      s   ON pd.SupplierID  = s.SupplierID
ORDER BY ps.TotalRevenue DESC;

-- ── BLOCK 10: CTE Recursive ───────────────────────────────

-- 3.5 Employee hierarchy — who reports to whom
WITH EmployeeHierarchy AS (
    -- Anchor: top-level employees (no manager)
    SELECT
        EmployeeID,
        FirstName + ' ' + LastName  AS EmployeeName,
        ReportsTo,
        0                           AS HierarchyLevel,
        CAST(FirstName + ' ' + LastName AS VARCHAR(500)) AS HierarchyPath
    FROM Employees
    WHERE ReportsTo IS NULL

    UNION ALL

    -- Recursive: employees who report to someone
    SELECT
        e.EmployeeID,
        e.FirstName + ' ' + e.LastName,
        e.ReportsTo,
        eh.HierarchyLevel + 1,
        CAST(eh.HierarchyPath + ' > ' + e.FirstName + ' ' + e.LastName AS VARCHAR(500))
    FROM Employees e
    INNER JOIN EmployeeHierarchy eh ON e.ReportsTo = eh.EmployeeID
)
SELECT
    EmployeeName,
    HierarchyLevel,
    HierarchyPath
FROM EmployeeHierarchy
ORDER BY HierarchyLevel, EmployeeName;

-- ── BLOCK 11: Window Functions ────────────────────────────

-- 3.6 ROW_NUMBER — top 3 products per category by revenue
WITH ProductRevenue AS (
    SELECT
        p.ProductID,
        p.ProductName,
        c.CategoryName,
        SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS TotalRevenue
    FROM Products p
    INNER JOIN Categories      c  ON p.CategoryID  = c.CategoryID
    INNER JOIN [Order Details] od ON p.ProductID   = od.ProductID
    GROUP BY p.ProductID, p.ProductName, c.CategoryName
)
SELECT *
FROM (
    SELECT
        CategoryName,
        ProductName,
        TotalRevenue,
        ROW_NUMBER() OVER (
            PARTITION BY CategoryName 
            ORDER BY TotalRevenue DESC
        ) AS RankInCategory
    FROM ProductRevenue
) ranked
WHERE RankInCategory <= 3
ORDER BY CategoryName, RankInCategory;

-- 3.7 RANK vs DENSE_RANK vs ROW_NUMBER — understand the difference
SELECT
    ProductName,
    UnitPrice,
    ROW_NUMBER() OVER (ORDER BY UnitPrice DESC) AS RowNum,
    RANK()       OVER (ORDER BY UnitPrice DESC) AS RankNum,
    DENSE_RANK() OVER (ORDER BY UnitPrice DESC) AS DenseRankNum
FROM Products
ORDER BY UnitPrice DESC;

-- 3.8 LAG and LEAD — month over month order comparison
WITH MonthlySales AS (
    SELECT
        YEAR(OrderDate)  AS SalesYear,
        MONTH(OrderDate) AS SalesMonth,
        COUNT(OrderID)   AS TotalOrders
    FROM Orders
    GROUP BY YEAR(OrderDate), MONTH(OrderDate)
)
SELECT
    SalesYear,
    SalesMonth,
    TotalOrders,
    LAG(TotalOrders)  OVER (ORDER BY SalesYear, SalesMonth) AS PrevMonth,
    LEAD(TotalOrders) OVER (ORDER BY SalesYear, SalesMonth) AS NextMonth,
    TotalOrders - LAG(TotalOrders) OVER (ORDER BY SalesYear, SalesMonth) AS MoMChange,
    ROUND(
        100.0 * (TotalOrders - LAG(TotalOrders) OVER (ORDER BY SalesYear, SalesMonth))
        / NULLIF(LAG(TotalOrders) OVER (ORDER BY SalesYear, SalesMonth), 0),
    1) AS MoMGrowthPct
FROM MonthlySales
ORDER BY SalesYear, SalesMonth;

-- 3.9 Running total and moving average
SELECT
    o.OrderID,
    o.OrderDate,
    o.Freight,
    SUM(o.Freight)   OVER (ORDER BY o.OrderDate 
                           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
                          )                                        AS RunningTotal,
    AVG(o.Freight)   OVER (ORDER BY o.OrderDate 
                           ROWS BETWEEN 4 PRECEDING AND CURRENT ROW
                          )                                        AS MovingAvg5
FROM Orders o
ORDER BY o.OrderDate;

-- 3.10 NTILE — segment customers into 4 groups by revenue
WITH CustomerRevenue AS (
    SELECT
        o.CustomerID,
        SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS TotalRevenue
    FROM Orders o
    INNER JOIN [Order Details] od ON o.OrderID = od.OrderID
    GROUP BY o.CustomerID
)
SELECT
    c.CompanyName,
    cr.TotalRevenue,
    NTILE(4) OVER (ORDER BY cr.TotalRevenue DESC) AS CustomerQuartile,
    CASE NTILE(4) OVER (ORDER BY cr.TotalRevenue DESC)
        WHEN 1 THEN 'VIP'
        WHEN 2 THEN 'High Value'
        WHEN 3 THEN 'Medium Value'
        WHEN 4 THEN 'Low Value'
    END AS CustomerSegment
FROM CustomerRevenue cr
INNER JOIN Customers c ON cr.CustomerID = c.CustomerID
ORDER BY cr.TotalRevenue DESC;

-- 3.11 PERCENT_RANK and CUME_DIST — where does each product stand?
SELECT
    ProductName,
    UnitPrice,
    ROUND(PERCENT_RANK() OVER (ORDER BY UnitPrice), 3) AS PercentRank,
    ROUND(CUME_DIST()    OVER (ORDER BY UnitPrice), 3) AS CumulativeDist
FROM Products
ORDER BY UnitPrice DESC;

-- 3.12 FIRST_VALUE / LAST_VALUE — compare each product to category extremes
SELECT
    p.ProductName,
    c.CategoryName,
    p.UnitPrice,
    FIRST_VALUE(p.ProductName) OVER (
        PARTITION BY p.CategoryID 
        ORDER BY p.UnitPrice DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS MostExpensiveInCategory,
    FIRST_VALUE(p.UnitPrice) OVER (
        PARTITION BY p.CategoryID 
        ORDER BY p.UnitPrice DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS MaxPrice,
    FIRST_VALUE(p.UnitPrice) OVER (
        PARTITION BY p.CategoryID 
        ORDER BY p.UnitPrice ASC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS MinPrice
FROM Products p
INNER JOIN Categories c ON p.CategoryID = c.CategoryID
ORDER BY c.CategoryName, p.UnitPrice DESC;


-- ============================================================
-- 🔴 PHASE 4 — PROFESSIONAL
-- Real business cases + Error Handling + Transactions
-- ============================================================

-- ── BLOCK 12: Real Business Analysis ─────────────────────

-- 4.1 RFM Analysis — Recency, Frequency, Monetary
-- This is a real marketing analysis used in every company
WITH RFM_Base AS (
    SELECT
        o.CustomerID,
        DATEDIFF(DAY, MAX(o.OrderDate), '1998-05-06')             AS Recency,
        COUNT(DISTINCT o.OrderID)                                  AS Frequency,
        SUM(od.UnitPrice * od.Quantity * (1 - od.Discount))       AS Monetary
    FROM Orders o
    INNER JOIN [Order Details] od ON o.OrderID = od.OrderID
    GROUP BY o.CustomerID
),
RFM_Scored AS (
    SELECT
        CustomerID,
        Recency,
        Frequency,
        Monetary,
        NTILE(5) OVER (ORDER BY Recency ASC)   AS R_Score,  -- lower recency = better
        NTILE(5) OVER (ORDER BY Frequency)     AS F_Score,
        NTILE(5) OVER (ORDER BY Monetary)      AS M_Score
    FROM RFM_Base
)
SELECT
    c.CompanyName,
    rs.Recency,
    rs.Frequency,
    ROUND(rs.Monetary, 2)     AS Monetary,
    rs.R_Score,
    rs.F_Score,
    rs.M_Score,
    rs.R_Score + rs.F_Score + rs.M_Score AS RFM_Total,
    CASE
        WHEN rs.R_Score + rs.F_Score + rs.M_Score >= 13 THEN 'Champion'
        WHEN rs.R_Score + rs.F_Score + rs.M_Score >= 10 THEN 'Loyal'
        WHEN rs.R_Score + rs.F_Score + rs.M_Score >= 7  THEN 'Potential'
        ELSE                                                  'At Risk'
    END AS CustomerSegment
FROM RFM_Scored rs
INNER JOIN Customers c ON rs.CustomerID = c.CustomerID
ORDER BY RFM_Total DESC;

-- 4.2 Year-over-Year growth analysis
WITH YearlySales AS (
    SELECT
        YEAR(o.OrderDate)                                         AS SalesYear,
        SUM(od.UnitPrice * od.Quantity * (1 - od.Discount))      AS TotalRevenue,
        COUNT(DISTINCT o.OrderID)                                 AS TotalOrders,
        COUNT(DISTINCT o.CustomerID)                              AS UniqueCustomers
    FROM Orders o
    INNER JOIN [Order Details] od ON o.OrderID = od.OrderID
    GROUP BY YEAR(o.OrderDate)
)
SELECT
    SalesYear,
    TotalRevenue,
    TotalOrders,
    UniqueCustomers,
    LAG(TotalRevenue) OVER (ORDER BY SalesYear)  AS PrevYearRevenue,
    ROUND(
        100.0 * (TotalRevenue - LAG(TotalRevenue) OVER (ORDER BY SalesYear))
        / NULLIF(LAG(TotalRevenue) OVER (ORDER BY SalesYear), 0),
    1) AS YoYGrowthPct
FROM YearlySales
ORDER BY SalesYear;

-- 4.3 ABC Product Classification (Pareto Analysis)
-- A = top 80% of revenue, B = next 15%, C = bottom 5%
WITH ProductRevenue AS (
    SELECT
        p.ProductID,
        p.ProductName,
        c.CategoryName,
        SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS TotalRevenue
    FROM Products p
    INNER JOIN [Order Details] od ON p.ProductID   = od.ProductID
    INNER JOIN Categories      c  ON p.CategoryID  = c.CategoryID
    GROUP BY p.ProductID, p.ProductName, c.CategoryName
),
RunningTotal AS (
    SELECT
        ProductID,
        ProductName,
        CategoryName,
        TotalRevenue,
        SUM(TotalRevenue) OVER (ORDER BY TotalRevenue DESC
                                ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS CumulativeRevenue,
        SUM(TotalRevenue) OVER ()                                                  AS GrandTotal
    FROM ProductRevenue
)
SELECT
    ProductName,
    CategoryName,
    ROUND(TotalRevenue, 2)                               AS Revenue,
    ROUND(100.0 * TotalRevenue / GrandTotal, 2)          AS PctOfTotal,
    ROUND(100.0 * CumulativeRevenue / GrandTotal, 2)     AS CumulativePct,
    CASE
        WHEN CumulativeRevenue / GrandTotal <= 0.80 THEN 'A — Top Products'
        WHEN CumulativeRevenue / GrandTotal <= 0.95 THEN 'B — Mid Products'
        ELSE                                             'C — Low Products'
    END AS ABCClass
FROM RunningTotal
ORDER BY TotalRevenue DESC;

-- ── BLOCK 13: TRY CATCH and Transactions ─────────────────

-- 4.4 TRY...CATCH — safe way to run queries that might fail
BEGIN TRY
    SELECT
        OrderID,
        CustomerID,
        CAST(OrderDate AS DATE) AS OrderDate
    FROM Orders
    WHERE OrderID IS NOT NULL;

    PRINT 'Query executed successfully.';
END TRY
BEGIN CATCH
    PRINT 'Error occurred: ' + ERROR_MESSAGE();
    PRINT 'Error number: '   + CAST(ERROR_NUMBER() AS VARCHAR);
    PRINT 'Line: '           + CAST(ERROR_LINE()   AS VARCHAR);
END CATCH;

-- 4.5 Transaction — update with rollback protection
-- Example: increase price of all Beverages by 5%
BEGIN TRANSACTION;

BEGIN TRY
    UPDATE p
    SET p.UnitPrice = p.UnitPrice * 1.05
    FROM Products p
    INNER JOIN Categories c ON p.CategoryID = c.CategoryID
    WHERE c.CategoryName = 'Beverages';

    -- Check how many rows were affected
    PRINT 'Rows updated: ' + CAST(@@ROWCOUNT AS VARCHAR);

    -- If everything looks good, commit
    -- COMMIT TRANSACTION;

    -- For now, let's roll back to keep data clean
    ROLLBACK TRANSACTION;
    PRINT 'Transaction rolled back — data unchanged.';

END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error: ' + ERROR_MESSAGE();
END CATCH;

-- 4.6 Validate data before any operation
BEGIN TRY
    DECLARE @ProductCount INT;
    DECLARE @NullPrices   INT;

    SELECT @ProductCount = COUNT(*)           FROM Products;
    SELECT @NullPrices   = COUNT(*)           FROM Products WHERE UnitPrice IS NULL;

    PRINT 'Total products: '      + CAST(@ProductCount AS VARCHAR);
    PRINT 'Products with NULL price: ' + CAST(@NullPrices AS VARCHAR);

    IF @NullPrices > 0
        PRINT 'WARNING: There are products without a price. Review before proceeding.';
    ELSE
        PRINT 'All products have a valid price. Safe to proceed.';

END TRY
BEGIN CATCH
    PRINT 'Validation error: ' + ERROR_MESSAGE();
END CATCH;


-- ── BLOCK 14: Final Project — Executive Dashboard Query ───

-- 4.7 Complete business summary — one query, everything a manager needs
WITH 
SalesData AS (
    SELECT
        o.OrderID,
        o.CustomerID,
        o.EmployeeID,
        o.OrderDate,
        o.ShipCountry,
        SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS OrderRevenue
    FROM Orders o
    INNER JOIN [Order Details] od ON o.OrderID = od.OrderID
    GROUP BY o.OrderID, o.CustomerID, o.EmployeeID, o.OrderDate, o.ShipCountry
),
CustomerStats AS (
    SELECT
        CustomerID,
        COUNT(OrderID)         AS TotalOrders,
        SUM(OrderRevenue)      AS TotalRevenue,
        AVG(OrderRevenue)      AS AvgOrderValue,
        MIN(OrderDate)         AS FirstOrder,
        MAX(OrderDate)         AS LastOrder
    FROM SalesData
    GROUP BY CustomerID
)
SELECT
    c.CompanyName,
    c.Country,
    cs.TotalOrders,
    ROUND(cs.TotalRevenue,   2) AS TotalRevenue,
    ROUND(cs.AvgOrderValue,  2) AS AvgOrderValue,
    cs.FirstOrder,
    cs.LastOrder,
    DATEDIFF(DAY, cs.FirstOrder, cs.LastOrder)  AS CustomerLifespanDays,
    RANK()       OVER (ORDER BY cs.TotalRevenue DESC)  AS RevenueRank,
    NTILE(4)     OVER (ORDER BY cs.TotalRevenue DESC)  AS RevenueQuartile,
    ROUND(
        100.0 * cs.TotalRevenue / SUM(cs.TotalRevenue) OVER (),
    2) AS PctOfTotalRevenue
FROM CustomerStats cs
INNER JOIN Customers c ON cs.CustomerID = c.CustomerID
ORDER BY cs.TotalRevenue DESC;


-- ============================================================
-- ✅ END OF PORTFOLIO
-- ============================================================
-- 
-- SUMMARY OF SKILLS DEMONSTRATED:
-- ✅ Database exploration (INFORMATION_SCHEMA)
-- ✅ SELECT, WHERE, GROUP BY, HAVING, ORDER BY
-- ✅ INNER JOIN, LEFT JOIN — multiple tables
-- ✅ Simple subqueries (IN, NOT IN, scalar)
-- ✅ Correlated subqueries
-- ✅ Derived tables (subquery in FROM)
-- ✅ CASE WHEN (simple, nested, inside aggregate)
-- ✅ CTEs — simple, multiple, chained
-- ✅ Recursive CTE (employee hierarchy)
-- ✅ Window Functions: ROW_NUMBER, RANK, DENSE_RANK
-- ✅ Window Functions: LAG, LEAD, NTILE
-- ✅ Window Functions: FIRST_VALUE, LAST_VALUE
-- ✅ Window Functions: PERCENT_RANK, CUME_DIST
-- ✅ Running totals and moving averages (ROWS BETWEEN)
-- ✅ Date functions: YEAR, MONTH, DATEDIFF, DATEADD
-- ✅ RFM Analysis (real marketing technique)
-- ✅ Year-over-Year growth analysis
-- ✅ ABC / Pareto product classification
-- ✅ TRY...CATCH error handling
-- ✅ Transactions with ROLLBACK protection
-- ✅ Data validation patterns
-- ============================================================
