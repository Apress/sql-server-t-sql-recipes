-- recipe 3.1
USE AdventureWorks2014;
GO
SELECT  h.SalesOrderID,
        h.CreditCardApprovalCode,
        CreditApprovalCode_Display = ISNULL(h.CreditCardApprovalCode,
                                            '**NO APPROVAL**')
FROM    Sales.SalesOrderHeader h ;

SELECT  ISNULL(CAST(NULL AS INT), 'String Value') ;

SELECT  ISNULL(CAST(NULL AS CHAR(10)), '20 characters*******') ;

SELECT  ISNULL(1, 'String Value') ;





-- recipe 3.2
SELECT  c.CustomerID,
        SalesPersonPhone = spp.PhoneNumber,
        CustomerPhone = pp.PhoneNumber,
        PhoneNumber = COALESCE(pp.PhoneNumber, spp.PhoneNumber)--, '**NO PHONE**')
FROM    Sales.Customer c
        LEFT OUTER JOIN Sales.Store s
            ON c.StoreID = s.BusinessEntityID
        LEFT OUTER JOIN Person.PersonPhone spp
            ON s.SalesPersonID = spp.BusinessEntityID
        LEFT OUTER JOIN Person.PersonPhone pp
            ON c.CustomerID = pp.BusinessEntityID
ORDER BY CustomerID ;





-- recipe 3.3
DECLARE @sql NVARCHAR(MAX) = '
    SELECT  ISNULL(''5'', 5),
            ISNULL(5, ''5''),
            COALESCE(''5'', 5),
            COALESCE(5, ''5'') ;
    ' ;

EXEC sp_executesql @sql ;

SELECT  column_ordinal,
        is_nullable,
        system_type_name
FROM    master.sys.dm_exec_describe_first_result_set(@sql, NULL, 0) a ;

SELECT  COALESCE('five', 5) ;

DECLARE @i INT = NULL ;
SELECT  ISNULL(@i, 'five') ;

DECLARE @sql NVARCHAR(MAX) = '
SELECT TOP 10
        FirstName,
        LastName,
        MiddleName_ISNULL = ISNULL(MiddleName, ''''),
        MiddleName_COALESCE = COALESCE(MiddleName, '''')
FROM    Person.Person ;
	' ;

EXEC sp_executesql @sql ;

SELECT  column_ordinal,
        name,
        is_nullable
FROM    master.sys.dm_exec_describe_first_result_set(@sql, NULL, 0) a ;




-- recipe 3.4
DECLARE @value INT = NULL;

SELECT  CASE WHEN @value = NULL THEN 1
             WHEN @value <> NULL THEN 2
             WHEN @value IS NULL THEN 3
             ELSE 4
        END ;


SELECT TOP 5
        LastName, FirstName, MiddleName
FROM    Person.Person
WHERE   MiddleName IS NULL ;


SET SHOWPLAN_TEXT ON ;
GO

SELECT  JobCandidateID,
        BusinessEntityID
FROM    HumanResources.JobCandidate
WHERE   ISNULL(BusinessEntityID, 1) <> 1 ;
GO

SET SHOWPLAN_TEXT OFF ;


SET SHOWPLAN_TEXT ON ;
GO

SELECT  JobCandidateID,
        BusinessEntityID
FROM    HumanResources.JobCandidate
WHERE   ISNULL(BusinessEntityID, 1) = BusinessEntityID ;
GO

SET SHOWPLAN_TEXT OFF ;



SET SHOWPLAN_TEXT ON ;
GO

SELECT  JobCandidateID,
        BusinessEntityID
FROM    HumanResources.JobCandidate
WHERE   BusinessEntityID IS NOT NULL ;
GO

SET SHOWPLAN_TEXT OFF ;




-- recipe 3.5
SELECT  r.ProductID,
        r.OperationSequence,
        StartDateVariance = AVG(DATEDIFF(day, ScheduledStartDate,
                                         ActualStartDate)),
        StartDateVariance_Adjusted = AVG(NULLIF(DATEDIFF(day,
                                                         ScheduledStartDate,
                                                         ActualStartDate), 0))
FROM    Production.WorkOrderRouting r
GROUP BY r.ProductID,
        r.OperationSequence
ORDER BY r.ProductID,
        r.OperationSequence ;



-- recipe 3.6
USE tempdb;
GO
IF OBJECT_ID('dbo.Product') IS NOT NULL DROP TABLE dbo.Product;
CREATE TABLE dbo.Product
       (
        ProductId INT NOT NULL
                      CONSTRAINT PK_Product PRIMARY KEY CLUSTERED,
        ProductName NVARCHAR(50) NOT NULL,
        CodeName NVARCHAR(50)
       ) ;
GO
CREATE UNIQUE INDEX UX_Product_CodeName ON dbo.Product (CodeName) ;
GO
INSERT  INTO dbo.Product (ProductId, ProductName, CodeName) VALUES  (1, 'Product 1', 'Shiloh') ;
INSERT  INTO dbo.Product (ProductId, ProductName, CodeName) VALUES  (2, 'Product 2', 'Sphynx');
INSERT  INTO dbo.Product (ProductId, ProductName, CodeName) VALUES  (3, 'Product 3', NULL);
INSERT  INTO dbo.Product (ProductId, ProductName, CodeName) VALUES  (4, 'Product 4', NULL);
GO


DROP INDEX dbo.Product.UX_Product_CodeName;
GO
CREATE UNIQUE INDEX UX_Product_CodeName ON dbo.Product (CodeName) WHERE CodeName IS NOT NULL
GO
INSERT  INTO dbo.Product (ProductId, ProductName, CodeName) VALUES  (4, 'Product 4', NULL);
INSERT  INTO dbo.Product (ProductId, ProductName, CodeName) VALUES  (5, 'Product 5', NULL);
GO


INSERT  INTO dbo.Product (ProductId, ProductName, CodeName) VALUES  (6, 'Product 6', 'Shiloh');

SELECT  *
FROM    dbo.Product;



-- recipe 3.7
USE tempdb;
GO
IF OBJECT_ID('dbo.Item') IS NOT NULL DROP TABLE dbo.Item;
IF OBJECT_ID('dbo.Category') IS NOT NULL DROP TABLE dbo.Category;
CREATE TABLE dbo.Category
       (
        CategoryId INT NOT NULL
                       CONSTRAINT PK_Category PRIMARY KEY CLUSTERED,
        CategoryName NVARCHAR(50) NOT NULL
       ) ;
GO
INSERT INTO dbo.Category (CategoryId, CategoryName) 
VALUES  (1, 'Category 1'),
        (2, 'Category 2'),
        (3, 'Category 3') ;
GO

CREATE TABLE dbo.Item
       (
        ItemId INT NOT NULL
                   CONSTRAINT PK_Item PRIMARY KEY CLUSTERED,
        ItemName NVARCHAR(50) NOT NULL,
        CategoryId INTEGER NULL 
                   CONSTRAINT FK_Item_Category FOREIGN KEY REFERENCES Category(CategoryId)
       ) ;
GO

/*
Attempt to insert three rows into the Item table. 
The first row contains a valid reference to the Category table. 
The second row will fail with a foreign key violation. 
The third row will insert successfully because the CategoryId is NULL. 
*/
INSERT INTO dbo.Item (ItemId, ItemName, CategoryId) VALUES  (1, 'Item 1', 1);
INSERT INTO dbo.Item (ItemId, ItemName, CategoryId) VALUES  (2, 'Item 2', 4);
INSERT INTO dbo.Item (ItemId, ItemName, CategoryId) VALUES  (3, 'Item 3', NULL);

SELECT  * 
FROM    dbo.Item;



-- recipe 3.8
USE tempdb;
GO
IF OBJECT_ID('dbo.Test1') IS NOT NULL DROP TABLE dbo.Test1;
IF OBJECT_ID('dbo.Test2') IS NOT NULL DROP TABLE dbo.Test2;
CREATE TABLE dbo.Test1
       (
        TestValue NVARCHAR(10) NULL
       );
CREATE TABLE dbo.Test2
       (
        TestValue NVARCHAR(10) NULL
       ) ;
GO

INSERT  INTO dbo.Test1
VALUES  ('apples'),
        ('oranges'),
        (NULL),
        (NULL) ; 

INSERT  INTO dbo.Test2
VALUES  (NULL),
        ('oranges'),
        ('grapes'),
        (NULL) ;
GO
SELECT  t1.TestValue,
        t2.TestValue
FROM    dbo.Test1 t1
        INNER JOIN dbo.Test2 t2
            ON t1.TestValue = t2.TestValue ;
