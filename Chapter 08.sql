USE AdventureWorks2014;
GO

-- recipe 8-1
BEGIN TRANSACTION;

INSERT  INTO Production.Location
        (Name, CostRate, Availability)
VALUES  ('Wheel Storage', 11.25, 80.00) ;

SELECT  Name,
        CostRate,
        Availability
FROM    Production.Location
WHERE   Name = 'Wheel Storage' ;

ROLLBACK TRANSACTION;




-- recipe 8-2
BEGIN TRANSACTION;
INSERT  Production.Location
        (Name,
         CostRate,
         Availability,
         ModifiedDate)
VALUES  ('Wheel Storage 2',
         11.25,
         80.00,
         '4/1/2012') ;

INSERT  Production.Location
        (Name,
         CostRate,
         Availability,
         ModifiedDate)
VALUES  ('Wheel Storage 3',
         11.25,
         80.00,
         DEFAULT) ;

INSERT  INTO Person.Address
        (AddressLine1,
         AddressLine2,
         City,
         StateProvinceID,
         PostalCode)
VALUES  ('15 Wake Robin Rd',
         DEFAULT,
         'Sudbury',
         30,
         '01776') ;

SELECT * FROM Production.Location WHERE Name LIKE 'Wheel Storage%';
SELECT * FROM Person.Address WHERE AddressLine1 = '15 Wake Robin Rd';
ROLLBACK TRANSACTION;


IF OBJECT_ID('tempdb.dbo.#ExampleTable') IS NOT NULL DROP TABLE #ExampleTable;
CREATE TABLE #ExampleTable 
(
    RowID       INTEGER IDENTITY,
    RowColID    UNIQUEIDENTIFIER DEFAULT NEWID(),
    RowDate     DATETIME DEFAULT GETDATE()
);
INSERT INTO #ExampleTable DEFAULT VALUES;
SELECT * FROM #ExampleTable;




-- recipe 8-3
-- generates an error
INSERT INTO HumanResources.Department (DepartmentID, Name, GroupName)
VALUES (17, 'Database Services', 'Information Technology');

-- works when using SET IDENTITY_INSERT ON.
SET IDENTITY_INSERT HumanResources.Department ON;
INSERT HumanResources.Department (DepartmentID, Name, GroupName)
VALUES (17, 'Database Services', 'Information Technology');
SET IDENTITY_INSERT HumanResources.Department OFF;



-- recipe 8-4
INSERT  Purchasing.ShipMethod
        (Name,
         ShipBase,
         ShipRate,
         rowguid)
VALUES  ('MIDDLETON CARGO TS1',
         8.99,
         1.22,
         NEWID()) ;

SELECT  rowguid,
        Name
FROM    Purchasing.ShipMethod
WHERE   Name = 'MIDDLETON CARGO TS1';



-- recipe 8-5
CREATE TABLE [dbo].[Shift_Archive]
       (
        [ShiftID] [tinyint] NOT NULL,
        [Name] [dbo].[Name] NOT NULL,
        [StartTime] [datetime] NOT NULL,
        [EndTime] [datetime] NOT NULL,
        [ModifiedDate] [datetime] NOT NULL
                                  DEFAULT (GETDATE()),
        CONSTRAINT [PK_Shift_ShiftID] PRIMARY KEY CLUSTERED ([ShiftID] ASC)
       ) ;
GO
INSERT  INTO dbo.Shift_Archive
        (ShiftID,
         Name,
         StartTime,
         EndTime,
         ModifiedDate)
        SELECT  ShiftID,
                Name,
                StartTime,
                EndTime,
                ModifiedDate
        FROM    HumanResources.Shift
        ORDER BY ShiftID ;
SELECT  ShiftID,
        Name
FROM    Shift_Archive ;
DROP TABLE dbo.Shift_Archive;



-- recipe 8-6
IF OBJECT_ID('dbo.usp_SEL_Production_TransactionHistory') IS NOT NULL 
    DROP PROCEDURE dbo.usp_SEL_Production_TransactionHistory;
GO
CREATE PROCEDURE dbo.usp_SEL_Production_TransactionHistory
       @ModifiedStartDT DATETIME,
       @ModifiedEndDT DATETIME
AS 
       SELECT   TransactionID,
                ProductID,
                ReferenceOrderID,
                ReferenceOrderLineID,
                TransactionDate,
                TransactionType,
                Quantity,
                ActualCost,
                ModifiedDate
       FROM     Production.TransactionHistory
       WHERE    ModifiedDate BETWEEN @ModifiedStartDT
                             AND     @ModifiedEndDT
                AND TransactionID NOT IN (
                SELECT  TransactionID
                FROM    Production.TransactionHistoryArchive) ;
GO
EXEC dbo.usp_SEL_Production_TransactionHistory '2013-09-01', '2013-09-02';


BEGIN TRANSACTION;
INSERT  Production.TransactionHistoryArchive
        (TransactionID,
         ProductID,
         ReferenceOrderID,
         ReferenceOrderLineID,
         TransactionDate,
         TransactionType,
         Quantity,
         ActualCost,
         ModifiedDate)
        EXEC dbo.usp_SEL_Production_TransactionHistory '2013-09-01',
            '2013-09-02' ;
ROLLBACK TRANSACTION;



-- recipe 8-7
IF OBJECT_ID('HumanResources.Degree') IS NOT NULL DROP TABLE HumanResources.Degree;
CREATE TABLE HumanResources.Degree
       (
        DegreeID INT NOT NULL
                     IDENTITY(1, 1)
                     PRIMARY KEY,
        DegreeName VARCHAR(30) NOT NULL,
        DegreeCode VARCHAR(5) NOT NULL,
        ModifiedDate DATETIME NOT NULL
       ) ;
GO
INSERT  INTO HumanResources.Degree
        (DegreeName, DegreeCode, ModifiedDate)
VALUES  ('Bachelor of Arts', 'B.A.', GETDATE()),
        ('Bachelor of Science', 'B.S.', GETDATE()),
        ('Master of Arts', 'M.A.', GETDATE()),
        ('Master of Science', 'M.S.', GETDATE()),
        ('Associate" s Degree', 'A.A.', GETDATE()) ;
GO
IF OBJECT_ID('HumanResources.Degree') IS NOT NULL DROP TABLE HumanResources.Degree;




-- recipe 8-8
BEGIN TRANSACTION;
INSERT  Purchasing.ShipMethod
        (Name, ShipBase, ShipRate)
OUTPUT  INSERTED.ShipMethodID, INSERTED.Name,
        INSERTED.rowguid, INSERTED.ModifiedDate
VALUES  ('MIDDLETON CARGO TS11', 10, 10),
        ('MIDDLETON CARGO TS12', 10, 10),
        ('MIDDLETON CARGO TS13', 10, 10);
ROLLBACK TRANSACTION;


BEGIN TRANSACTION
DECLARE @insertedShipMethodIDs TABLE 
(
    ShipMethodID INTEGER
);
INSERT Purchasing.ShipMethod (Name, ShipBase, ShipRate)
OUTPUT inserted.ShipMethodID INTO @insertedShipMethodIDs
VALUES  ('MIDDLETON CARGO TS11', 10, 10),
        ('MIDDLETON CARGO TS12', 10, 10),
        ('MIDDLETON CARGO TS13', 10, 10);
SELECT * FROM @insertedShipMethodIDs;
ROLLBACK TRANSACTION;



-- recipe 8-9
SELECT  DiscountPct
FROM    Sales.SpecialOffer
WHERE   SpecialOfferID = 10 ;

BEGIN TRANSACTION;
UPDATE  Sales.SpecialOffer
SET     DiscountPct = 0.15
WHERE   SpecialOfferID = 10 ;

SELECT  DiscountPct
FROM    Sales.SpecialOffer
WHERE   SpecialOfferID = 10 ;
ROLLBACK TRANSACTION;

BEGIN TRANSACTION;
UPDATE  Sales.SpecialOffer
SET     DiscountPct = 0.15
WHERE   SpecialOfferID IN (10, 11, 12) ;

SELECT  DiscountPct
FROM    Sales.SpecialOffer
WHERE   SpecialOfferID IN (10, 11, 12) ;
ROLLBACK TRANSACTION;



-- recipe 8-10
BEGIN TRANSACTION;
UPDATE  Sales.ShoppingCartItem
SET     Quantity = 2,
        ModifiedDate = GETDATE()
FROM    Sales.ShoppingCartItem c
        INNER JOIN Production.Product p
            ON c.ProductID = p.ProductID
WHERE   p.Name = 'Full-Finger Gloves, M '
AND     c.Quantity > 2 ;
ROLLBACK TRANSACTION;



-- recipe 8-11
BEGIN TRANSACTION;
UPDATE  Sales.SpecialOffer
SET     DiscountPct *= 1.05
OUTPUT  inserted.SpecialOfferID,
        deleted.DiscountPct AS old_DiscountPct,
        inserted.DiscountPct AS new_DiscountPct
WHERE   Category = 'Customer' ;
ROLLBACK TRANSACTION;



-- recipe 8-12
IF OBJECT_ID('dbo.RecipeChapter') IS NOT NULL DROP TABLE dbo.RecipeChapter;
CREATE TABLE dbo.RecipeChapter
       (
        ChapterID INT NOT NULL,
        Chapter VARCHAR(MAX) NOT NULL
       ) ;
GO
INSERT  INTO dbo.RecipeChapter
        (ChapterID,
         Chapter)
VALUES  (1,
         'At the beginning of each chapter you will notice
that basic concepts are covered first.') ;
SELECT  Chapter
FROM    RecipeChapter
WHERE   ChapterID = 1;

--Next, update the inserted row by adding a sentence to the end of the column value:
UPDATE  RecipeChapter
SET     Chapter.WRITE(' In addition to the basics, this chapter will also provide
recipes that can be used in your day to day development and administration.',
                      NULL, NULL)
WHERE   ChapterID = 1 ;
SELECT  Chapter
FROM    RecipeChapter
WHERE   ChapterID = 1;

--Replace the phrase “day to day” with the single word “daily”:
UPDATE  RecipeChapter
SET     Chapter.WRITE('daily', CHARINDEX('day to day', Chapter) - 1,
                      LEN('day to day'))
WHERE   ChapterID = 1 ;
SELECT  Chapter
FROM    RecipeChapter
WHERE   ChapterID = 1;

UPDATE dbo.RecipeChapter
SET    Chapter.WRITE('*test value* ', 7, 0)
WHERE  ChapterID = 1 ;
SELECT  Chapter
FROM    RecipeChapter
WHERE   ChapterID = 1;

UPDATE dbo.RecipeChapter
SET    Chapter.WRITE('', 7, 13)
WHERE  ChapterID = 1 ;
SELECT  Chapter
FROM    RecipeChapter
WHERE   ChapterID = 1;

IF OBJECT_ID('dbo.RecipeChapter') IS NOT NULL DROP TABLE dbo.RecipeChapter;



-- recipe 8-13
IF OBJECT_ID('Production.Example_ProductProductPhoto') IS NOT NULL 
    DROP TABLE Production.Example_ProductProductPhoto;
SELECT *
INTO   Production.Example_ProductProductPhoto
FROM   Production.ProductProductPhoto;

DELETE Production.Example_ProductProductPhoto;


INSERT  Production.Example_ProductProductPhoto
SELECT  *
FROM    Production.ProductProductPhoto;

DELETE  Production.Example_ProductProductPhoto
WHERE   ProductID NOT IN (SELECT    ProductID
                          FROM      Production.Product);

DELETE  
FROM    ppp
FROM    Production.Example_ProductProductPhoto ppp
        LEFT OUTER JOIN Production.Product p
            ON ppp.ProductID = p.ProductID
WHERE   p.ProductID IS NULL;
IF OBJECT_ID('Production.Example_ProductProductPhoto') IS NOT NULL 
    DROP TABLE Production.Example_ProductProductPhoto;



-- recipe 8-14
IF OBJECT_ID('HumanResources.Example_JobCandidate') IS NOT NULL 
    DROP TABLE HumanResources.Example_JobCandidate;
SELECT *
INTO   HumanResources.Example_JobCandidate 
FROM   HumanResources.JobCandidate;

DELETE 
FROM   HumanResources.Example_JobCandidate 
OUTPUT deleted.JobCandidateID
WHERE  JobCandidateID < 5;

IF OBJECT_ID('HumanResources.Example_JobCandidate') IS NOT NULL 
    DROP TABLE HumanResources.Example_JobCandidate;



-- recipe 8-15
IF OBJECT_ID('Production.Example_TransactionHistory') IS NOT NULL 
    DROP TABLE Production.Example_TransactionHistory;
SELECT *
INTO   Production.Example_TransactionHistory
FROM   Production.TransactionHistory ;

TRUNCATE TABLE Production.Example_TransactionHistory ;

SELECT COUNT(*)
FROM   Production.Example_TransactionHistory ;

IF OBJECT_ID('Production.Example_TransactionHistory') IS NOT NULL 
    DROP TABLE Production.Example_TransactionHistory;



-- recipe 8-16
IF OBJECT_ID('Sales.LastCustomerOrder') IS NOT NULL 
    DROP TABLE Sales.LastCustomerOrder;
CREATE TABLE Sales.LastCustomerOrder
       (
        CustomerID      INTEGER,
        SalesorderID    INTEGER,
        CONSTRAINT pk_LastCustomerOrder PRIMARY KEY CLUSTERED (CustomerId)
       ) ;

DECLARE @CustomerID     INTEGER = 100,
        @SalesOrderID   INTEGER = 101;

MERGE INTO Sales.LastCustomerOrder AS tgt
    USING 
        (SELECT @CustomerID AS CustomerID,
                @SalesOrderID AS SalesOrderID
        ) AS src
    ON tgt.CustomerID = src.CustomerID
    WHEN MATCHED 
        THEN UPDATE
          SET       SalesOrderID = src.SalesOrderID
    WHEN NOT MATCHED 
        THEN INSERT (
                     CustomerID,
                     SalesOrderID
                    )
          VALUES    (src.CustomerID,
                     src.SalesOrderID);

SELECT  *
FROM    Sales.LastCustomerOrder;

-- can't update the same row twice, so break this down into two parts
MERGE INTO Sales.LastCustomerOrder AS tgt
    USING 
        (SELECT *
         FROM   (VALUES (101,101),
                        (100,102)
                ) dt(CustomerID, SalesOrderID)
        ) AS src
    ON tgt.CustomerID = src.CustomerID
    WHEN MATCHED 
        THEN UPDATE
          SET       SalesOrderID = src.SalesOrderID
    WHEN NOT MATCHED 
        THEN INSERT (
                     CustomerID,
                     SalesOrderID
                    )
          VALUES    (src.CustomerID,
                     src.SalesOrderID);
SELECT  *
FROM    Sales.LastCustomerOrder;

MERGE INTO Sales.LastCustomerOrder AS tgt
    USING 
        (SELECT *
         FROM   (VALUES (102,103),
                        (100,104),
                        (101,105)
                ) dt(CustomerID, SalesOrderID)
        ) AS src
    ON tgt.CustomerID = src.CustomerID
    WHEN MATCHED 
        THEN UPDATE
          SET       SalesOrderID = src.SalesOrderID
    WHEN NOT MATCHED 
        THEN INSERT (
                     CustomerID,
                     SalesOrderID
                    )
          VALUES    (src.CustomerID,
                     src.SalesOrderID);
SELECT  *
FROM    Sales.LastCustomerOrder;

IF OBJECT_ID('Sales.LastCustomerOrder') IS NOT NULL 
    DROP TABLE Sales.LastCustomerOrder;


IF OBJECT_ID('Sales.LargestCustomerOrder') IS NOT NULL
    DROP TABLE Sales.LargestCustomerOrder;
CREATE TABLE Sales.LargestCustomerOrder
       (
        CustomerID      INTEGER,
        SalesorderID    INTEGER,
		TotalDue        MONEY, 
        CONSTRAINT pk_LargestCustomerOrder PRIMARY KEY CLUSTERED (CustomerId)
       ) ;

DECLARE @CustomerID INT = 100,
        @SalesOrderID INT = 101 ,
        @TotalDue MONEY = 1000.00;

MERGE INTO Sales.LargestCustomerOrder AS tgt
    USING 
        (SELECT @CustomerID AS CustomerID,
                @SalesOrderID AS SalesOrderID,
                @TotalDue AS TotalDue
        ) AS src
    ON tgt.CustomerID = src.CustomerID
    WHEN MATCHED AND tgt.TotalDue < src.TotalDue 
        THEN UPDATE
          SET       SalesOrderID = src.SalesOrderID
		  , TotalDue = src.TotalDue
    WHEN NOT MATCHED 
        THEN INSERT (
                     CustomerID,
                     SalesOrderID,
                     TotalDue
                    )
          VALUES    (src.CustomerID,
                     src.SalesOrderID,
                     src.TotalDue) ;

SELECT  *
FROM    Sales.LargestCustomerOrder;


MERGE INTO Sales.LargestCustomerOrder AS tgt
    USING 
        (SELECT *
         FROM   (VALUES (101, 101, 1000.00),
                        (100, 102, 1100.00)
                ) dt(CustomerID, SalesOrderID, TotalDue)
        ) AS src
    ON tgt.CustomerID = src.CustomerID
    WHEN MATCHED AND tgt.TotalDue < src.TotalDue 
        THEN UPDATE
          SET       SalesOrderID = src.SalesOrderID
		  , TotalDue = src.TotalDue
    WHEN NOT MATCHED 
        THEN INSERT (
                     CustomerID,
                     SalesOrderID,
                     TotalDue
                    )
          VALUES    (src.CustomerID,
                     src.SalesOrderID,
                     src.TotalDue) ;

SELECT  *
FROM    Sales.LargestCustomerOrder;

MERGE INTO Sales.LargestCustomerOrder AS tgt
    USING 
        (SELECT *
         FROM   (VALUES (100, 104, 999.00),
                        (101, 105, 999.00)
                ) dt(CustomerID, SalesOrderID, TotalDue)
        ) AS src
    ON tgt.CustomerID = src.CustomerID
    WHEN MATCHED AND tgt.TotalDue < src.TotalDue 
        THEN UPDATE
          SET       SalesOrderID = src.SalesOrderID
		  , TotalDue = src.TotalDue
    WHEN NOT MATCHED 
        THEN INSERT (
                     CustomerID,
                     SalesOrderID,
                     TotalDue
                    )
          VALUES    (src.CustomerID,
                     src.SalesOrderID,
                     src.TotalDue) ;

SELECT  *
FROM    Sales.LargestCustomerOrder;


DECLARE @CustomerID INT = 100,
        @SalesOrderID INT = 201 ,
        @TotalDue MONEY = 1200.00;

MERGE INTO Sales.LargestCustomerOrder AS tgt
    USING 
        (SELECT @CustomerID AS CustomerID,
                @SalesOrderID AS SalesOrderID,
                @TotalDue AS TotalDue
        ) AS src
    ON tgt.CustomerID = src.CustomerID
    WHEN MATCHED AND tgt.TotalDue < src.TotalDue 
        THEN UPDATE
          SET       SalesOrderID = src.SalesOrderID
		  , TotalDue = src.TotalDue
    WHEN NOT MATCHED 
        THEN INSERT (
                     CustomerID,
                     SalesOrderID,
                     TotalDue
                    )
          VALUES    (src.CustomerID,
                     src.SalesOrderID,
                     src.TotalDue) 
    OUTPUT
        $ACTION,
        DELETED.*,
        INSERTED.*;

SELECT  *
FROM    Sales.LargestCustomerOrder;


-- recipe 8-17
DECLARE @dml_output TABLE (
    MergeAction             VARCHAR(6),
    DeletedCustomerID       INTEGER,
    DeletedSalesOrderID     INTEGER,
    DeletedTotalDue         MONEY,
    InsertedCustomerID      INTEGER,
    InsertedSalesOrderID    INTEGER,
    InsertedTotalDue        MONEY
    );
INSERT INTO @dml_output
        (MergeAction,
         DeletedCustomerID,
         DeletedSalesOrderID,
         DeletedTotalDue,
         InsertedCustomerID,
         InsertedSalesOrderID,
         InsertedTotalDue
        )
SELECT  *
FROM    (
        MERGE INTO Sales.LargestCustomerOrder AS tgt
            USING 
                (SELECT 100 AS CustomerID,
                        205 AS SalesOrderID,
                        2500.00 AS TotalDue
                ) AS src
            ON tgt.CustomerID = src.CustomerID
            WHEN MATCHED AND tgt.TotalDue < src.TotalDue 
                THEN UPDATE
                  SET       SalesOrderID = src.SalesOrderID
		          , TotalDue = src.TotalDue
            WHEN NOT MATCHED 
                THEN INSERT (
                             CustomerID,
                             SalesOrderID,
                             TotalDue
                            )
                  VALUES    (src.CustomerID,
                             src.SalesOrderID,
                             src.TotalDue) 
            OUTPUT
                $ACTION,
                DELETED.*,
                INSERTED.*
        ) dt(MergeAction,
             DeletedCustomerID,
             DeletedSalesOrderID,
             DeletedTotalDue,
             InsertedCustomerID,
             InsertedSalesOrderID,
             InsertedTotalDue);

SELECT  * 
FROM    @dml_output;


IF OBJECT_ID('Sales.LargestCustomerOrder') IS NOT NULL 
    DROP TABLE Sales.LargestCustomerOrder;
