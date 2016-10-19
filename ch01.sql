1-1. Connecting to a Database

USE AdventureWorks2012;


1-2. Checking the Database Server Version

SELECT @@VERSION;


1-3. Checking the Database Name

select DB_NAME();


1-4. Checking Your Username

SELECT ORIGINAL_LOGIN(), CURRENT_USER, SYSTEM_USER;


1-5. Querying a TABLE

Example #1
SELECT NationalIDNumber,
       LoginID,
       JobTitle 
FROM HumanResources.Employee;

Example #2
SELECT  *
FROM  HumanResources.Employee;


1-6. Returning Specific Rows

SELECT  Title, FirstName, LastName
FROM Person.Person 
WHERE Title = 'Ms.';


1-7. Listing the Available Tables

Example #1
SELECT table_name, table_type
FROM information_schema.tables
WHERE table_schema = 'HumanResources';

Example #2 
SELECT name
FROM sys.tables
WHERE SCHEMA_NAME(schema_id)='HumanResources';

Example #3
SELECT 'DROP ' + table_schema + '.' + table_name + ';'
FROM information_schema.tables
WHERE table_schema = 'HumanResources'
  AND table_type = 'BASE TABLE';

  
1-8. Naming the Output Columns

SELECT BusinessEntityID AS "Employee ID",
   VacationHours AS "Vacation",
   SickLeaveHours AS "Sick Time"
FROM HumanResources.Employee;


1-9. Providing Shorthand Names for Tables

SELECT E.BusinessEntityID AS "Employee ID",
   E.VacationHours AS "Vacation",
   E.SickLeaveHours AS "Sick Time"
FROM HumanResources.Employee AS E
WHERE E.VacationHours > 40;


1-10. Computing New Columns from Existing Data 

SELECT BusinessEntityID AS "EmployeeID",
   VacationHours + SickLeaveHours AS "AvailableTimeOff"
FROM HumanResources.Employee; 


1-11. Negating a Search Condition 

SELECT  Title, FirstName, LastName
FROM  Person.Person 
WHERE NOT Title = 'Ms.';


1-12. Keeping the WHERE Clause Unambiguous

SELECT Title, FirstName, LastName 
FROM   Person.Person 
WHERE  Title = 'Ms.' AND
       (FirstName = 'Catherine' OR
       LastName = 'Adams');

	   
1-13. Testing for Existence

Example #1 
SELECT TOP(1) 1
FROM HumanResources.Employee
WHERE SickLeaveHours > 80;

Example #2 
SELECT 1
WHERE  EXISTS (
   SELECT *
   FROM HumanResources.Employee
   WHERE SickLeaveHours > 40
);


1-14. Specifying a Range of Values 

SELECT SalesOrderID, ShipDate 
FROM Sales.SalesOrderHeader 
WHERE ShipDate BETWEEN '2005-07-23 00:00:00.0' AND '2005-07-24 23:59:59.0';


1-15. Checking for Null Values 

SELECT  ProductID, Name, Weight
FROM    Production.Product
WHERE   Weight IS NULL;


1-16. Writing an IN-LIST 

SELECT  ProductID, Name, Color 
FROM Production.Product 
WHERE Color IN ('Silver', 'Black', 'Red');


1-17. Performing Wildcard Searches 

SELECT ProductID, Name 
FROM Production.Product 
WHERE Name LIKE 'B%';


1-18. Sorting Your Results

SELECT p.Name, h.EndDate, h.ListPrice
FROM   Production.Product p
INNER JOIN Production.ProductListPriceHistory h ON
           p.ProductID = h.ProductID
ORDER BY p.Name, h.EndDate;


1-19. Specifying Case-Sensitivity of a SORT

SELECT p.Name, h.EndDate, h.ListPrice
FROM   Production.Product p
INNER JOIN Production.ProductListPriceHistory h ON
           p.ProductID = h.ProductID
ORDER BY p.Name, h.EndDate;


1-20. Sorting Nulls High or LOW 

SELECT  ProductID, Name, Weight
FROM    Production.Product
ORDER BY ISNULL(Weight, 1) DESC, Weight;


1-21. Forcing Unusual Sort Orders

SELECT p.ProductID, p.Name, p.Color
FROM Production.Product AS p
WHERE p.Color IS NOT NULL
ORDER BY CASE p.Color
WHEN 'Red' THEN NULL ELSE p.COLOR END;


1-22. Paging Through a Result Set 

SELECT ProductID, Name
FROM Production.Product
ORDER BY Name
OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;

SELECT ProductID, Name
FROM Production.Product
ORDER BY Name
OFFSET 8 ROWS FETCH NEXT 10 ROWS ONLY;


1-23. Sampling a Subset of Rows 

Example #1 
SELECT *
FROM Purchasing.PurchaseOrderHeader
TABLESAMPLE (5 PERCENT);

Example #2 
SELECT *
FROM Purchasing.PurchaseOrderHeader
TABLESAMPLE (200 ROWS);





