USE AdventureWorks2014;
GO

-- recipe 13.1
CREATE TABLE dbo.Person (
  PersonID INT IDENTITY CONSTRAINT PK_Person PRIMARY KEY CLUSTERED,
  BusinessEntityId INT NOT NULL 
      CONSTRAINT FK_Person REFERENCES Person.BusinessEntity (BusinessEntityID),
  First_Name VARCHAR(50) NOT NULL);

CREATE TABLE dbo.Test (
  Column1 INT NOT NULL,
  Column2 INT NOT NULL,
  CONSTRAINT PK_Test PRIMARY KEY CLUSTERED (Column1, Column2));


-- recipe 13.2
ALTER TABLE dbo.Person 
ADD Last_Name VARCHAR(50) NULL;


-- recipe 13.3
ALTER TABLE dbo.Person 
ADD IsActive BIT NOT NULL
CONSTRAINT DF__Person__IsActive DEFAULT (0);


--recipe 13.4
ALTER TABLE dbo.Person 
ALTER COLUMN Last_Name VARCHAR(75) NULL;

-- recipe 13.5
ALTER TABLE Production.TransactionHistory 
ADD CostPerUnit AS (ActualCost/Quantity);

CREATE TABLE HumanResources.CompanyStatistic (
  CompanylD int NOT NULL,
  StockTicker char(4) NOT NULL,
  SharesOutstanding int NOT NULL,
  Shareholders int NOT NULL,
  AvgSharesPerShareholder AS (SharesOutstanding/Shareholders) PERSISTED);

SELECT  TOP (1) CostPerUnit, Quantity, ActualCost 
FROM    Production.TransactionHistory 
WHERE   Quantity > 10 
ORDER BY ActualCost DESC;


-- recipe 13.6
ALTER TABLE dbo.Person 
DROP COLUMN Last_Name;


-- recipe 13.7
DROP TABLE dbo.Person;


-- recipe 13.8
EXECUTE sp_help 'Person.Person';


-- recipe 13.9
CREATE TABLE dbo.WebsiteProduct (
    WebsiteProductID int NOT NULL PRIMARY KEY IDENTITY(1,1),
    ProductNM varchar(255) NOT NULL,
    PublisherNM varchar(255) SPARSE NULL,
    ArtistNM varchar(150) SPARSE NULL,
    ISBNNBR varchar(30) SPARSE NULL,
    DiscsNBR int SPARSE NULL,
    MusicLabelNM varchar(255) SPARSE NULL);

INSERT dbo.WebsiteProduct (ProductNM, PublisherNM, ISBNNBR)
  VALUES ('SQL Server Transact-SQL Recipes', 'Apress', '9781484200629');
INSERT dbo.WebsiteProduct (ProductNM, ArtistNM, DiscsNBR, MusicLabelNM)
  VALUES ('Etiquette', 'Casiotone for the Painfully Alone', 1, 'Tomlab');

SELECT ProductNM, PublisherNM,ISBNNBR FROM dbo.WebsiteProduct WHERE ISBNNBR IS NOT NULL;

ALTER TABLE dbo.WebsiteProduct
ADD ProductAttributeCS XML COLUMN_SET FOR ALL_SPARSE_COLUMNS;

IF OBJECT_ID('dbo.WebsiteProduct', 'U') IS NOT NULL 
   DROP TABLE dbo.WebsiteProduct;
CREATE TABLE dbo.WebsiteProduct (
    WebsiteProductID int NOT NULL PRIMARY KEY IDENTITY(1,1),
    ProductNM varchar(255) NOT NULL,
    PublisherNM varchar(255) SPARSE NULL,
    ArtistNM varchar(150) SPARSE NULL,
    ISBNNBR varchar(30) SPARSE NULL,
    DiscsNBR int SPARSE NULL,
    MusicLabelNM varchar(255) SPARSE NULL,
    ProductAttributeCS xml COLUMN_SET FOR ALL_SPARSE_COLUMNS);

SELECT  ProductNM, ProductAttributeCS 
FROM    dbo.WebsiteProduct 
WHERE   ISBNNBR IS NOT NULL;

INSERT dbo.WebsiteProduct (ProductNM, ProductAttributeCS) 
VALUES ('Roots & Echoes', 
        '<ArtistNM>The Coral</ArtistNM> 
         <DiscsNBR>1</DiscsNBR> 
         <MusicLabelNM>Deltasonic</MusicLabelNM>');

SELECT * FROM dbo.WebsiteProduct;


IF OBJECT_ID('dbo.WebsiteProduct') IS NOT NULL DROP TABLE dbo.WebsiteProduct;
IF OBJECT_ID('dbo.WebsiteProduct_sparse') IS NOT NULL DROP TABLE dbo.WebsiteProduct_sparse;
CREATE TABLE dbo.WebsiteProduct (
    WebsiteProductID int NOT NULL PRIMARY KEY ,
    ProductNM varchar(255) NOT NULL,
    PublisherNM varchar(255) NULL,
    ArtistNM varchar(150) NULL,
    ISBNNBR varchar(30) NULL,
    DiscsNBR int NULL,
    MusicLabelNM varchar(255) NULL);
CREATE TABLE dbo.WebsiteProduct_sparse (
    WebsiteProductID int NOT NULL PRIMARY KEY ,
    ProductNM varchar(255) NOT NULL,
    PublisherNM varchar(255) SPARSE NULL,
    ArtistNM varchar(150) SPARSE NULL,
    ISBNNBR varchar(30) SPARSE NULL,
    DiscsNBR int SPARSE NULL,
    MusicLabelNM varchar(255) SPARSE NULL);
GO
WITH Tens    (N) AS (SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL 
                     SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL
                     SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1),
     Hundreds(N) AS (SELECT 1 FROM Tens t1, Tens t2),
     Millions(N) AS (SELECT 1 FROM Hundreds t1, Hundreds t2, Hundreds t3),
     Tally   (N) AS (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) FROM Millions)
INSERT INTO dbo.WebsiteProduct (WebsiteProductID, ProductNM)
SELECT  TOP (500000) N, 'Product#' + CONVERT(VARCHAR(15), N)
FROM    Tally;

INSERT INTO dbo.WebsiteProduct_sparse (WebsiteProductID, ProductNM)
SELECT  WebsiteProductID, ProductNM
FROM    dbo.WebsiteProduct;

EXECUTE sp_spaceused 'dbo.WebsiteProduct';
EXECUTE sp_spaceused 'dbo.WebsiteProduct_sparse';

-- recipe 13.10
CREATE TABLE dbo.Person (
  PersonID INT IDENTITY NOT NULL,
  BusinessEntityId INT NOT NULL,
  First_Name VARCHAR(50) NULL,
  Last_Name VARCHAR(50) NULL);

ALTER TABLE dbo.Person
  ADD CONSTRAINT PK_Person PRIMARY KEY CLUSTERED (PersonID),
      CONSTRAINT FK_Person FOREIGN KEY (BusinessEntityId) 
          REFERENCES Person.BusinessEntity (BusinessEntityID),
      CONSTRAINT UK_Person_Name UNIQUE (First_Name, Last_Name);

IF OBJECT_ID('dbo.Person','U') IS NOT NULL 
   DROP TABLE dbo.Person;
CREATE TABLE dbo.Person (
  PersonID INT IDENTITY NOT NULL,
  BusinessEntityId INT NOT NULL,
  First_Name VARCHAR(50) NULL,
  Last_Name VARCHAR(50) NULL,
  CONSTRAINT PK_Person PRIMARY KEY CLUSTERED (PersonID),
  CONSTRAINT FK_Person FOREIGN KEY (BusinessEntityId) 
      REFERENCES Person.BusinessEntity (BusinessEntityID),
  CONSTRAINT UK_Person_Name UNIQUE (First_Name, Last_Name) );

IF OBJECT_ID('dbo.Person','U') IS NOT NULL 
   DROP TABLE dbo.Person;
CREATE TABLE dbo.Person (
  PersonID INT IDENTITY NOT NULL
      CONSTRAINT PK_Person PRIMARY KEY CLUSTERED (PersonID),
  BusinessEntityId INT NOT NULL
      CONSTRAINT FK_Person FOREIGN KEY (BusinessEntityId) 
          REFERENCES Person.BusinessEntity (BusinessEntityID),
  First_Name VARCHAR(50) NULL,
  Last_Name VARCHAR(50) NULL,
  CONSTRAINT UK_Person_Name UNIQUE (First_Name, Last_Name) );

INSERT INTO dbo.Person (BusinessEntityId, First_Name) VALUES (1, 'MyName');
INSERT INTO dbo.Person (BusinessEntityId, First_Name) VALUES (1, 'MyName2');
INSERT INTO dbo.Person (BusinessEntityId) VALUES (1);


-- recipe 13.11
CREATE TABLE dbo.Employees (
    employee_id INT IDENTITY PRIMARY KEY CLUSTERED,
    manager_id INT NULL REFERENCES dbo.Employees (employee_id));

INSERT INTO dbo.Employees DEFAULT VALUES;
INSERT INTO dbo.Employees (manager_id) VALUES (1);
SELECT * FROM dbo.Employees;

INSERT INTO dbo.Employees (manager_id) VALUES (10);


-- recipe 13.12
IF OBJECT_ID('dbo.PersonPhone','U') IS NOT NULL DROP TABLE dbo.PersonPhone;
IF OBJECT_ID('dbo.PhoneNumberType','U') IS NOT NULL DROP TABLE dbo.PhoneNumberType;
IF OBJECT_ID('dbo.Person','U') IS NOT NULL DROP TABLE dbo.Person;

CREATE TABLE dbo.Person (
  BusinessEntityId INT PRIMARY KEY,
  FirstName VARCHAR(25),
  LastName  VARCHAR(25));

CREATE TABLE dbo.PhoneNumberType (
  PhoneNumberTypeId INT PRIMARY KEY,
  Name VARCHAR(25));

INSERT INTO dbo.PhoneNumberType
SELECT  PhoneNumberTypeId, Name
FROM    Person.PhoneNumberType;

INSERT INTO dbo.Person
SELECT BusinessEntityId, FirstName, LastName
FROM Person.Person
WHERE BusinessEntityID IN (1,2);

CREATE TABLE dbo.PersonPhone (
        [BusinessEntityID] [int] NOT NULL,
        [PhoneNumber] [dbo].[Phone] NOT NULL,
        [PhoneNumberTypeID] [int] NULL,
        [ModifiedDate] [datetime] NOT NULL,
    CONSTRAINT [UQ_PersonPhone_BusinessEntityID_PhoneNumber_PhoneNumberTypeID] 
        UNIQUE CLUSTERED
            ([BusinessEntityID], [PhoneNumber], [PhoneNumberTypeID]),
    CONSTRAINT [FK_PersonPhone_Person_BusinessEntityID] 
        FOREIGN KEY ([BusinessEntityID]) 
        REFERENCES [dbo].[Person] ([BusinessEntityID]) 
        ON DELETE CASCADE,
    CONSTRAINT [FK_PersonPhone_PhoneNumberType_PhoneNumberTypeID] 
        FOREIGN KEY ([PhoneNumberTypeID]) 
        REFERENCES [dbo].[PhoneNumberType] ([PhoneNumberTypeID]) 
        ON UPDATE SET NULL
);


INSERT INTO dbo.PersonPhone (BusinessEntityId, PhoneNumber, PhoneNumberTypeId, ModifiedDate)
VALUES (1, '757-867-5309', 1, '2012-03-22T00:00:00'),
       (2, '804-867-5309', 2, '2012-03-22T00:00:00');

SELECT 'Initial Data', * FROM dbo.PersonPhone;

DELETE FROM dbo.Person
WHERE BusinessEntityID = 1;

UPDATE dbo.PhoneNumberType
   SET PhoneNumberTypeID = 4
 WHERE PhoneNumberTypeID = 2;

SELECT 'Final Data', * FROM dbo.PersonPhone;


-- recipe 13.13
IF OBJECT_ID('dbo.Employees', 'U') IS NOT NULL 
   DROP TABLE dbo.Employees;
CREATE TABLE dbo.Employees (
    EmployeeId INT PRIMARY KEY CLUSTERED,
    First_Name VARCHAR(50) NOT NULL,
    Last_Name  VARCHAR(50) NOT NULL,
    InsertedDate DATETIME DEFAULT GETDATE());

INSERT INTO dbo.Employees (EmployeeId, First_Name, Last_Name) 
VALUES (1, 'Wayne', 'Sheffield');
INSERT INTO dbo.Employees (EmployeeId, First_Name, Last_Name, InsertedDate) 
VALUES (2, 'Jim', 'Smith', NULL);
SELECT * FROM dbo.Employees;


-- recipe 13.14
CREATE TABLE dbo.BooksRead (
  ISBN      VARCHAR(20),
  StartDate DATETIME NOT NULL,
  EndDate   DATETIME NULL,
  CONSTRAINT CK_BooksRead_EndDate CHECK (EndDate > StartDate));

INSERT INTO BooksRead (ISBN, StartDate, EndDate) 
VALUES ('9781430242000', '2012-08-01T16:25:00', '2011-08-15T12:35:00 ');

IF OBJECT_ID('dbo.Employees','U') IS NOT NULL
   DROP TABLE dbo.Employees;
CREATE TABLE dbo.Employees (
  EmployeeId INT IDENTITY,
  FirstName  VARCHAR(50),
  LastName   VARCHAR(50),
  PhoneNumber VARCHAR(12) CONSTRAINT CK_Employees_PhoneNumber 
    CHECK (PhoneNumber LIKE '[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]'));

INSERT INTO dbo.Employees (FirstName, LastName, PhoneNumber)
VALUES ('Wayne', 'Sheffield', '800-555-1212');

INSERT INTO dbo.Employees (FirstName, LastName, PhoneNumber)
VALUES ('Wayne', 'Sheffield', '555-1212');


-- recipe 13.15
ALTER TABLE dbo.Employees
NOCHECK CONSTRAINT CK_Employees_PhoneNumber;

ALTER TABLE dbo.Employees
NOCHECK CONSTRAINT ALL;

ALTER TABLE dbo.Employees
CHECK CONSTRAINT CK_Employees_PhoneNumber;

ALTER TABLE dbo.Employees
WITH CHECK CHECK CONSTRAINT ALL;


-- recipe 13.16
ALTER TABLE dbo.BooksRead
DROP CONSTRAINT CK_BooksRead_EndDate;


-- recipe 13.17
IF OBJECT_ID('dbo.Employees','U') IS NOT NULL
   DROP TABLE dbo.Employees;
CREATE TABLE dbo.Employees (
    employee_id INT IDENTITY PRIMARY KEY CLUSTERED,
    manager_id INT NULL REFERENCES dbo.Employees (employee_id),
    First_Name VARCHAR(50) NULL,
    Last_Name  VARCHAR(50) NULL,
    CONSTRAINT UQ_Employees_Name UNIQUE (First_Name, Last_Name));

INSERT INTO dbo.Employees (manager_id, First_Name, Last_Name)
       VALUES (NULL, 'Wayne', 'Sheffield')

BEGIN TRANSACTION
INSERT INTO dbo.Employees (manager_id, First_Name, Last_Name)
       VALUES (1, 'Jim', 'Smith');
ROLLBACK TRANSACTION;

INSERT INTO dbo.Employees (manager_id, First_Name, Last_Name)
       VALUES (1, 'Jane', 'Smith');

SELECT * FROM dbo.Employees;

SELECT  IDENTITYCOL, employee_id, Last_Name
FROM    dbo.Employees
ORDER BY IDENTITYCOL;


-- recipe 13.18
SELECT @@IDENTITY, SCOPE_IDENTITY(), IDENT_CURRENT('dbo.Employees');


-- recipe 13.19
DBCC CHECKIDENT ('dbo.Employees');

TRUNCATE TABLE dbo.Employees;
INSERT INTO dbo.Employees (manager_id, First_Name, Last_Name)
       VALUES (NULL, 'Wayne', 'Sheffield');

BEGIN TRANSACTION;
INSERT INTO dbo.Employees (manager_id, First_Name, Last_Name)
       VALUES (1, 'Jim', 'Smith');
ROLLBACK TRANSACTION;

DBCC CHECKIDENT ('dbo.Employees', RESEED, 1); 
INSERT INTO dbo.Employees (manager_id, First_Name, Last_Name)
       VALUES (1, 'Jane', 'Smith');

SELECT * FROM dbo.Employees;

DBCC CHECKIDENT ('dbo.Employees');


-- recipe 13.20
SET IDENTITY_INSERT dbo.Employees ON;
INSERT INTO dbo.Employees (employee_id, manager_id, First_Name, Last_Name)
VALUES (5, 1, 'Joe', 'Smith');
SET IDENTITY_INSERT dbo.Employees OFF;


-- recipe 13.21
CREATE TABLE HumanResources.BuildingAccess(
  BuildingEntryExitID uniqueidentifier ROWGUIDCOL 
    CONSTRAINT DF_BuildingAccess_BuildingEntryExitID DEFAULT NEWID() 
    CONSTRAINT UK_BuildingAccess_BuildingEntryExitID UNIQUE, 
  EmployeeID int NOT NULL, 
  AccessTime datetime NOT NULL, 
  DoorID int NOT NULL);
INSERT HumanResources.BuildingAccess (EmployeeID, AccessTime, DoorID) 
VALUES (32, GETDATE(), 2);

SELECT *
  FROM HumanResources.BuildingAccess;
SELECT $ROWGUID
  FROM HumanResources.BuildingAccess;


-- recipe 13.22
CREATE SEQUENCE dbo.MySequence
    AS INTEGER
       START WITH 1
       INCREMENT BY 1;
GO

CREATE TABLE dbo.Table1 (
  Table1ID INTEGER NOT NULL,
  Table1Data VARCHAR(50));
CREATE TABLE dbo.Table2 (
  Table2ID INTEGER NOT NULL,
  Table2Data VARCHAR(50));

INSERT INTO dbo.Table1 (Table1ID, Table1Data)
VALUES (NEXT VALUE FOR dbo.MySequence, 'Ferrari'),
       (NEXT VALUE FOR dbo.MySequence, 'Lamborghini');

INSERT INTO dbo.Table2 (Table2ID, Table2Data)
VALUES (NEXT VALUE FOR dbo.MySequence, 'Apple'),
       (NEXT VALUE FOR dbo.MySequence, 'Orange');    

SELECT * FROM dbo.Table1;
SELECT * FROM dbo.Table2;


-- recipe 13.23
CREATE TABLE #temp (
  Column1 INT,
  Column2 INT);

DECLARE @temp TABLE (
  Column1 INT,
  Column2 INT);

-- cleanup
IF OBJECT_ID('dbo.Person') IS NOT NULL DROP TABLE dbo.Person;
IF OBJECT_ID('dbo.Test') IS NOT NULL DROP TABLE dbo.Test;
IF OBJECT_ID('HumanResources.CompanyStatistic') IS NOT NULL DROP TABLE HumanResources.CompanyStatistic;
IF EXISTS (SELECT 1 FROM sys.columns WHERE name = 'CostPerUnit' AND object_id = OBJECT_ID('Production.TransactionHistory'))
    ALTER TABLE Production.TransactionHistory DROP COLUMN CostPerUnit;
IF OBJECT_ID('dbo.WebsiteProduct') IS NOT NULL DROP TABLE dbo.WebsiteProduct;
IF OBJECT_ID('dbo.Employees') IS NOT NULL DROP TABLE dbo.Employees;
IF OBJECT_ID('dbo.PersonPhone') IS NOT NULL DROP TABLE dbo.PersonPhone;
IF OBJECT_ID('dbo.BooksRead') IS NOT NULL DROP TABLE dbo.BooksRead;
IF OBJECT_ID('HumanResources.BuildingAccess') IS NOT NULL DROP TABLE HumanResources.BuildingAccess;
IF EXISTS (SELECT 1 FROM sys.sequences WHERE name = 'MySequence')
    DROP SEQUENCE dbo.MySequence;
IF OBJECT_ID('dbo.Table1') IS NOT NULL DROP TABLE dbo.Table1;
IF OBJECT_ID('dbo.Table2') IS NOT NULL DROP TABLE dbo.Table2;
