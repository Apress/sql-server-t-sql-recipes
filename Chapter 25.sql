USE tempdb;
GO


-- recipe 25-1
IF OBJECT_ID('dbo.Book') IS NOT NULL DROP TABLE dbo.Book;
IF OBJECT_ID('dbo.INS_Book','P') IS NOT NULL DROP PROCEDURE dbo.INS_Book;
CREATE TABLE dbo.Book
        (
         BookID INT IDENTITY PRIMARY KEY,
         ISBNNBR CHAR(13) NOT NULL,
         BookNM VARCHAR(250) NOT NULL,
         AuthorID INT NOT NULL,
         ChapterDesc XML NULL
        );
GO
CREATE PROCEDURE dbo.INS_Book
       @ISBNNBR CHAR(13),
       @BookNM VARCHAR(250),
       @AuthorID INT,
       @ChapterDesc XML
AS 
INSERT  dbo.Book
        (ISBNNBR,
         BookNM,
         AuthorID,
         ChapterDesc)
VALUES  (@ISBNNBR,
         @BookNM,
         @AuthorID,
         @ChapterDesc);
GO
DECLARE @Book XML;
SET @Book =
'
<Book name="SQL Server 2014 T-SQL Recipes">
<Chapters>
<Chapter id="1">Getting Started with SELECT</Chapter>
<Chapter id="2">Elementary Programming</Chapter>
<Chapter id="3">Working with NULLs</Chapter>
<Chapter id="4">Combining Data from Multiple Tables</Chapter>
</Chapters>
</Book>
';
GO


-- recipe 25-2
INSERT  dbo.Book
        (ISBNNBR,
         BookNM,
         AuthorID,
         ChapterDesc)
VALUES  ('9781484200629',
         'SOL Server 2014 T-S0L Recipes',
         55,
'<Book name="SQL Server 2014 T-SQL Recipes">
<Chapters>
<Chapter id="1">Getting Started with SELECT</Chapter>
<Chapter id="2">Elementary Programming</Chapter>
<Chapter id="3">Working with NULLs</Chapter>
<Chapter id="4">Combining Data from Multiple Tables</Chapter>
</Chapters>
</Book>');

DECLARE @Book XML;
SET @Book =
CAST('<Book name="S0L Server 2014 Fast Answers">
<Chapters>
<Chapter id="1"> Installation, Upgrades... </Chapter>
<Chapter id="2"> Configuring SQL Server </Chapter>
<Chapter id="3"> Creating and Configuring Databases </Chapter>
<Chapter id="4"> SQL Server Agent and SQL Logs </Chapter>
</Chapters>
</Book>' as XML);

INSERT  dbo.Book
        (ISBNNBR,
         BookNM,
         AuthorID,
         ChapterDesc)
VALUES  ('1590591615',
         'SOL Server 2014 Fast Answers',
         55,
         @Book);
GO

DECLARE @Book XML;
SET @Book =
CAST('<Book name="S0L Server 2000 Fast Answers">
<Chapters>
<Chapter id="l"> Installation, Upgrades... </Chapter>
<Chapter id="2"> Configuring SQL Server </Chapter>
<Chapter id="3"> Creating and Configuring Databases </Chapter>
<Chapter id="4"> SQL Server Agent and SQL Logs </Chapter>
</Chapters>
' as XML);
GO



-- recipe 25-3
IF EXISTS (SELECT * FROM sys.xml_schema_collections WHERE name = 'BookStoreCollection')
DROP XML SCHEMA COLLECTION BookStoreCollection;
GO
CREATE XML SCHEMA COLLECTION BookStoreCollection
AS
N'<xsd:schema  targetNamespace="http://PROD/BookStore"
               xmlns:xsd="http://www.w3.org/2001/XMLSchema"
               xmlns:sqltypes="http://schemas.microsoft.com/sqlserver/2004/sqltypes"
               elementFormDefault="qualified">
    <xsd:import  namespace="http://schemas.microsoft.com/sqlserver/2004/sqltypes"/>
    <xsd:element  name="Book">
        <xsd:complexType>
            <xsd:sequence>
                <xsd:element  name="BookName"  minOccurs="0">
                    <xsd:simpleType>
                        <xsd:restriction        base="sqltypes:varchar">
                            <xsd:maxLength  value="50"    />
                        </xsd:restriction>
                    </xsd:simpleType>
                </xsd:element>
                <xsd:element  name="ChapterID"  type="sqltypes:int" minOccurs="0"    />
                <xsd:element  name="ChapterNM"  minOccurs="0">
                    <xsd:simpleType>
                        <xsd:restriction        base="sqltypes:varchar">
                            <xsd:maxLength  value="50"    />
                        </xsd:restriction>
                    </xsd:simpleType>
                </xsd:element>
            </xsd:sequence>
        </xsd:complexType>
    </xsd:element>
</xsd:schema>';
GO
DECLARE @Book XML (DOCUMENT BookStoreCollection);
SET @Book =
CAST('
<Book xmlns="http://PROD/BookStore">
    <BookName>"SQL Server 2014 Fast Answers"</BookName>
    <ChapterID>1</ChapterID>
    <ChapterNM>Installation, Upgrades...</ChapterNM>
</Book>' as XML);
GO

DECLARE @Book XML (DOCUMENT BookStoreCollection);
SET @Book =
CAST('
<Book xmlns="http://PROD/BookStore">
    <BookName>"S0L Server 2014 Fast Answers"</BookName>
    <ChapterID>1</ChapterID>
    <ChapterNM>Installation, Upgrades...</ChapterNM>
    <ChapterID>2</ChapterID>
    <ChapterNM>Configuring SQL Server</ChapterNM>
</Book>' as XML);
GO

IF OBJECT_ID('dbo.BookInfoExport') IS NOT NULL DROP TABLE dbo.BookInfoExport;
CREATE TABLE dbo.BookInfoExport
       (
        BookID INT IDENTITY PRIMARY KEY,
        ISBNNBR CHAR(10) NOT NULL,
        BookNM VARCHAR(250) NOT NULL,
        AuthorID INT NOT NULL,
        ChapterDesc XML(BookStoreCollection) NULL
       );
GO


-- recipe 25-4
SELECT  name
FROM    sys.XML_schema_collections
ORDER BY create_date;

SELECT  n.name
FROM    sys.XML_schema_namespaces n
        INNER JOIN sys.XML_schema_collections c
            ON c.XML_collection_id = n.XML_collection_id
WHERE   c.name = 'BookStoreCollection';
GO


-- recipe 25-5
IF OBJECT_ID('dbo.BookInvoice') IS NOT NULL DROP TABLE dbo.BookInvoice;
CREATE  TABLE dbo.BookInvoice
       (
        BookInvoiceID INT IDENTITY PRIMARY  KEY,
        BookInvoiceXML XML NOT  NULL
       )
GO

INSERT  dbo.BookInvoice (BookInvoiceXML)
VALUES  
('<BookInvoice  invoicenumber="1"  customerid="22"     orderdate="2008-07-01Z">
<OrderItems>
<Item  id="22"  qty="1"  name="SQL Fun in the Sun"/>
<Item  id="24"  qty="1"  name="T-SQL Crossword Puzzles"/>
</OrderItems>
</BookInvoice>'),

('<BookInvoice  invoicenumber="1"  customerid="40"  orderdate="2008-07-11Z">
<OrderItems>
<Item  id="11"  qty="1"  name="MCITP Cliff Notes"/>
</OrderItems>
</BookInvoice>'),

('<BookInvoice  invoicenumber="1"  customerid="9"  orderdate="2008-07-22Z">
<OrderItems>
<Item  id="11"  qty="1"  name="MCITP Cliff Notes"/>
<Item  id="24"  qty="1"  name="T-SQL Crossword Puzzles"/>
</OrderItems>
</BookInvoice>');


SELECT  BookInvoiceID
FROM    dbo.BookInvoice
WHERE   BookInvoiceXML.exist('/BookInvoice/OrderItems/Item[@id=11]') = 1;

DECLARE @BookInvoiceXML XML;
SELECT  @BookInvoiceXML = BookInvoiceXML
FROM    dbo.BookInvoice
WHERE   BookInvoiceID = 2;

SELECT  BookID.value('@id', 'integer') BookID
FROM    @BookInvoiceXML.nodes('/BookInvoice/OrderItems/Item') AS BookTable (BookID);
GO

DECLARE @BookInvoiceXML XML;
SELECT  @BookInvoiceXML = BookInvoiceXML
FROM    dbo.BookInvoice
WHERE   BookInvoiceID = 3;
SELECT  @BookInvoiceXML.query('/BookInvoice/OrderItems'); 

SELECT DISTINCT
        BookInvoiceXML.value('(/BookInvoice/OrderItems/Item/@name)[1]',
                             'varchar(30)') AS BookTitles
FROM    dbo.BookInvoice
UNION
SELECT DISTINCT
        BookInvoiceXML.value('(/BookInvoice/OrderItems/Item/@name)[2]',
                             'varchar(30)')
FROM    dbo.BookInvoice;

SELECT DISTINCT
        BookInvoiceXML.value('(/BookInvoice/OrderItems/Item/@name)',
                             'varchar(30)')
FROM    dbo.BookInvoice;


-- recipe 25-6
SELECT BookInvoiceXML 
FROM dbo.BookInvoice 
WHERE BookInvoiceID = 2;

UPDATE dbo.BookInvoice
SET BookInvoiceXML.modify
('insert <Item id="920" qty="l" name="SQL Server 2014 Transact-SOL Recipes"/>
into (/BookInvoice/OrderItems)[1]')
WHERE BookInvoiceID = 2;

SELECT BookInvoiceXML 
FROM dbo.BookInvoice 
WHERE BookInvoiceID = 2;



-- recipe 25-7
CREATE PRIMARY XML INDEX idx_XML_Primary_Book_ChapterDESC
ON dbo.Book(ChapterDesc); 

CREATE XML INDEX idx_XML_Value_Book_ChapterDESC ON dbo.Book(ChapterDESC)
USING XML INDEX idx_XML_Primary_Book_ChapterDESC FOR VALUE;


-- recipe 25-8
SELECT  ShiftID,
        Name
FROM    AdventureWorks2014.HumanResources.[Shift]
FOR     XML RAW('Shift'),
            ROOT('Shifts'),
            TYPE;

SELECT TOP 3
        BusinessEntityID,
        Shift.Name,
        Department.Name
FROM    AdventureWorks2014.HumanResources.EmployeeDepartmentHistory Employee
        INNER JOIN AdventureWorks2014.HumanResources.Shift Shift
            ON Employee.ShiftID = Shift.ShiftID
        INNER JOIN AdventureWorks2014.HumanResources.Department Department
            ON Employee.DepartmentID = Department.DepartmentID
ORDER BY BusinessEntityID
FOR     XML AUTO,
            TYPE;

SELECT TOP 3
        Shift.Name,
        Department.Name,
        BusinessEntityID
FROM    AdventureWorks2014.HumanResources.EmployeeDepartmentHistory Employee
        INNER JOIN AdventureWorks2014.HumanResources.Shift Shift
            ON Employee.ShiftID = Shift.ShiftID
        INNER JOIN AdventureWorks2014.HumanResources.Department Department
            ON Employee.DepartmentID = Department.DepartmentID
ORDER BY Shift.Name,
        Department.Name,
        BusinessEntityID
FOR     XML AUTO,
            TYPE;

SELECT TOP 3
        1 AS Tag,
        NULL AS Parent,
        BusinessEntityID AS [Vendor!1!VendorID],
        Name AS [Vendor!1!VendorName!ELEMENT],
        CreditRating AS [Vendor!1!CreditRating]
FROM    AdventureWorks2014.Purchasing.Vendor
ORDER BY CreditRating
FOR     XML EXPLICIT,
            TYPE;

SELECT  Name AS "@Territory",
        CountryRegionCode AS "@Region",
        SalesYTD
FROM    AdventureWorks2014.Sales.SalesTerritory
WHERE   SalesYTD > 6000000
ORDER BY SalesYTD DESC
FOR     XML PATH('TerritorySales'),
            ROOT('CompanySales'),
            TYPE;

SELECT  Name AS "Territory",
        CountryRegionCode AS "Territory/Region",
        SalesYTD AS "Territory/Region/YTDSales"
FROM    AdventureWorks2014.Sales.SalesTerritory
WHERE   SalesYTD > 6000000
ORDER BY SalesYTD DESC
FOR     XML PATH('TerritorySales'),
            ROOT('CompanySales'),
            TYPE;


-- recipe 25-9
DECLARE @XMLdoc XML,
        @iDoc   INTEGER;
SET  @XMLdoc  =
'<Book  name="SQL Server 2000 Fast Answers">
    <Chapters>
        <Chapter  id="1"  name="Installation, Upgrades"/>
        <Chapter  id="2"  name="Configuring SQL Server"/>
        <Chapter  id="3"  name="Creating and Configuring Databases"/>
        <Chapter  id="4"  name="SQL Server Agent and SQL Logs"/>
    </Chapters>
</Book>';

EXECUTE sp_XML_preparedocument @iDoc OUTPUT, @XMLdoc;

SELECT Chapter, ChapterNm
FROM OPENXML(@iDoc, '/Book/Chapters/Chapter', 0)
WITH (Chapter INT '@id', ChapterNm VARCHAR(50) '@name');

EXECUTE sp_xml_removedocument @idoc;



-- recipe 25-10
SELECT STUFF((SELECT TOP (25) ',' + CONVERT(VARCHAR(15), BusinessEntityID)
              FROM AdventureWorks2014.HumanResources.Employee
              ORDER BY BusinessEntityID
              FOR XML PATH(''), TYPE).value('.','varchar(max)'),1,1,'');

-- cleanup
IF OBJECT_ID('dbo.Book') IS NOT NULL DROP TABLE dbo.Book;
IF OBJECT_ID('dbo.INS_Book','P') IS NOT NULL DROP PROCEDURE dbo.INS_Book;
IF OBJECT_ID('dbo.BookInfoExport') IS NOT NULL DROP TABLE dbo.BookInfoExport;
IF OBJECT_ID('dbo.BookInvoice') IS NOT NULL DROP TABLE dbo.BookInvoice;

IF EXISTS (SELECT * FROM sys.xml_schema_collections WHERE name = 'BookStoreCollection')
DROP XML SCHEMA COLLECTION BookStoreCollection;
-- 