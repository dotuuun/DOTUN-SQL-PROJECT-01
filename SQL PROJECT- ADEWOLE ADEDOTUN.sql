USE AdventureWorks2019;

--JOINS

--1.Retrieving all products and their categories
SELECT* FROM Production.ProductCategory;
SELECT* FROM Production.Product;

SELECT p.ProductID, p.Name AS ProductName, pc.Name AS CategoryName
FROM Production.Product p
INNER JOIN Production.ProductCategory pc ON p.ProductID = pc.ProductCategoryID;

--2.All Orders and their corresponding Customer informations.
SELECT* FROM Sales.SalesOrderHeader;
SELECT* FROM Sales.Customer;

SELECT O.SalesOrderID, O.OrderDate, O.CustomerID, C.TerritoryID
FROM Sales.SalesOrderHeader AS O
JOIN Sales.Customer AS C ON O.CustomerID = C.CustomerID;

--3. Finding products and their suppliers as SUPPLIER_NAME
SELECT* FROM Purchasing.Vendor;
SELECT* FROM Purchasing.ProductVendor;


SELECT P.Name AS ProductName, V.Name AS SUPPLIER_NAME
FROM Production.Product AS P
JOIN Purchasing.ProductVendor AS PV ON P.ProductID = PV.ProductID
JOIN Purchasing.Vendor AS V ON PV.BusinessEntityID = V.BusinessEntityID;

--4.Retrieving and listing each product supplied by each vendor, 
--showing the number of each product.

SELECT* FROM Purchasing.Vendor
SELECT* FROM Purchasing.ProductVendor;
SELECT* FROM Production.Product


SELECT v.Name AS VendorName, p.Name AS ProductName, COUNT(p.ProductID) AS Number_Of_Products
FROM Purchasing.Vendor v
JOIN Purchasing.ProductVendor pv ON V.BUSINESSENTITYID = pv.BUSINESSENTITYID
JOIN Production.Product p ON pv.ProductID = p.ProductID
GROUP BY v.Name, p.Name
ORDER BY v.Name, Number_Of_Products DESC;


--5.List All Customers,Their Orders and the OrderDate 

SELECT* FROM SALES.SALESORDERHEADER;
SELECT* FROM SALES.Customer


SELECT O.CustomerID, O.SalesOrderID, o.OrderDate
FROM Sales.Customer c
LEFT JOIN Sales.SalesOrderHeader o ON c.CustomerID = o.CustomerID;

---SUBQUERIES

--6.Products with Sales Greater Than Average
SELECT* FROM Production.Product;

---inner query
SELECT AVG(ListPrice) as AVERAGE_sales
FROM Production.Product;

--subquery
SELECT Name, ListPrice,ProductNumber
FROM Production.Product
WHERE ListPrice > (SELECT AVG(ListPrice) as AVERAGE_sales
					FROM Production.Product);


--7. Products with a total sales value greater than $1,000,000

SELECT* FROM Sales.SalesOrderDetail
--INNERQUERY
SELECT od.ProductID
FROM SALES.SalesOrderDetail AS od
GROUP BY od.ProductID
HAVING SUM(od.LineTotal) > 1000000;

--SUBQUERY
SELECT p.ProductID, p.Name
FROM PRODUCTION.Product AS p
WHERE p.ProductID IN (SELECT od.ProductID
					FROM SALES.SalesOrderDetail AS od
					GROUP BY od.ProductID
					HAVING SUM(od.LineTotal) > 1000000);




--8.People who have more than one email address.
SELECT* FROM Person.Person;

SELECT BusinessEntityID
FROM Person.EmailAddress
GROUP BY BusinessEntityID
HAVING COUNT(EmailAddress)>1

--SUBQUERY

SELECT p.BusinessEntityID, p.FirstName, p.LastName
FROM Person.Person AS p
WHERE p.BusinessEntityID IN (SELECT BusinessEntityID
								FROM Person.EmailAddress
								GROUP BY BusinessEntityID
								HAVING COUNT(EmailAddress)>1); ---- They all have just 1 email address so the result is empty.

								

--9. List of Employees with their VACATION HOURS in Each Department from the highest hours to the lowest.
SELECT* FROM HumanResources.Employee;


SELECT E.BusinessEntityID, E.JobTitle, E.VacationHours
FROM HumanResources.Employee AS E
WHERE E.VacationHours = (SELECT MAX(E2.VacationHours)
                          FROM HumanResources.Employee AS E2
                         WHERE E.BusinessEntityID = E2.BusinessEntityID)
ORDER BY E.VacationHours DESC;
                          


--10.Products That Have Never Been Ordered
SELECT* FROM PRODUCTION.PRODUCT
---INNER QUERY 
SELECT DISTINCT ProductID
FROM Sales.SalesOrderDetail;

--SUBQUERY
SELECT ProductID, Name
FROM Production.Product
WHERE ProductID NOT IN (SELECT DISTINCT ProductID
                        FROM Sales.SalesOrderDetail);


---CTEs (Common Table Expressions)

--11. Total Sales Per Territory
SELECT* FROM Sales.SalesOrderHeader;

WITH Territory_Sales AS (SELECT TerritoryID, SUM(TotalDue) AS Total_Sales
						FROM Sales.SalesOrderHeader
						GROUP BY TerritoryID)
SELECT TerritoryID, Total_Sales
FROM Territory_Sales
ORDER BY Total_Sales DESC;


--12.Identify the Most Expensive Product in Each Category
SELECT* FROM Production.Product


WITH Max_Price_Per_Category AS (SELECT productsubCategoryID , MAX(ListPrice) AS MaxPrice
								FROM Production.Product
								GROUP BY productsubCategoryID),
ExpensiveProducts AS ( SELECT p.ProductID, p.Name, p.ListPrice, p.productsubCategoryID
					FROM Production.Product AS p
					JOIN Max_Price_Per_Category AS m ON p.productsubCategoryID = m.productsubCategoryID AND p.ListPrice = m.MaxPrice)
SELECT ProductID, Name, ListPrice, productsubCategoryID
FROM ExpensiveProducts
ORDER BY LISTPRICE DESC ;


--13. Orders That Include More Than 50 Different Products
SELECT* FROM Sales.SalesOrderDetail

WITH Product_Counts AS (SELECT SalesOrderID, COUNT(DISTINCT ProductID) AS Product_Count
						FROM Sales.SalesOrderDetail
						GROUP BY SalesOrderID)
SELECT SalesOrderID, Product_Count
FROM Product_Counts
WHERE Product_Count > 50;


--14.Employees with the Longest Tenure
SELECT* FROM HumanResources.Employee;

WITH EmployeeTenure AS (SELECT BusinessEntityID, JobTitle, 
                        DATEDIFF(YEAR, HireDate, GETDATE()) AS Tenure
                        FROM HumanResources.Employee)
SELECT TOP 10 BusinessEntityID, JobTitle, Tenure
FROM EmployeeTenure
ORDER BY Tenure DESC;  


--15.Total Sales by Region
SELECT* FROM Sales.SalesOrderHeader;
SELECT* FROM Sales.SalesTerritory;


WITH RegionalSales AS (SELECT r.CountryRegionCode, r.Name AS RegionName, SUM(soh.TotalDue) AS TotalSales
					FROM Sales.SalesOrderHeader AS soh
					JOIN Sales.SalesTerritory AS r ON soh.TerritoryID = r.TerritoryID
					GROUP BY r.CountryRegionCode, r.Name)
SELECT RegionName, TotalSales
FROM RegionalSales
ORDER BY TotalSales DESC;

















