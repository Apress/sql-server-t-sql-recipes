USE AdventureWorks2014;
GO

-- recipe 9.1
SELECT  TOP (5)
        FullName = CONCAT(LastName, ', ', FirstName, ' ', MiddleName)
FROM    Person.Person p; 

SELECT  TOP (5)
        FullName = CONCAT(LastName, ', ', FirstName, ' ', MiddleName),
        FullName2 = LastName + ', ' + FirstName + ' ' + MiddleName,
        FullName3 = LastName + ', ' + FirstName + 
            IIF(MiddleName IS NULL, '', ' ' + MiddleName)
FROM    Person.Person p
WHERE   MiddleName IS NULL;


-- recipe 9.2
SELECT  ASCII('H'),
        ASCII('e'),
        ASCII('l'),
        ASCII('l'),
        ASCII('o');
SELECT  CHAR(72),
        CHAR(101),
        CHAR(108),
        CHAR(108),
        CHAR(111) ;


-- recipe 9.3
SELECT  UNICODE('G'),
        UNICODE('o'),
        UNICODE('o'),
        UNICODE('d'),
        UNICODE('!');
SELECT  NCHAR(71),
        NCHAR(111),
        NCHAR(111),
        NCHAR(100),
        NCHAR(33) ;


-- recipe 9.4
SELECT CHARINDEX('string to find','This is the bigger string to find something in.');

SELECT TOP 10
        AddressID,
        AddressLine1,
        PATINDEX('%[0]%Olive%', AddressLine1)
FROM    Person.Address
WHERE   PATINDEX('%[0]%Olive%', AddressLine1) > 0;


-- recipe 9.5
SELECT  DISTINCT 
        SOUNDEX(LastName),
        SOUNDEX('Smith'),
        LastName
FROM    Person.Person
WHERE   SOUNDEX(LastName) = SOUNDEX('Smith');

SELECT  DISTINCT
        SOUNDEX(LastName),
        SOUNDEX('smith'),
        DIFFERENCE(LastName, 'Smith'),
        LastName
FROM    Person.Person
WHERE   DIFFERENCE(LastName, 'Smith') = 4;


-- recipe 9.6
SELECT LEFT('I only want the leftmost 10 characters.', 10);
SELECT RIGHT('I only want the rightmost 10 characters.', 10);

SELECT  TOP (5)
        ProductNumber,
        ProductName = LEFT(Name, 10)
FROM    Production.Product;

SELECT  TOP (5)
        CustomerID,
        AccountNumber = CONCAT('AW', RIGHT(REPLICATE('0', 8)
                                     + CAST(CustomerID AS VARCHAR(10)), 8))
FROM    Sales.Customer;


-- recipe 9.7
SELECT  TOP (3)
        PhoneNumber,
        AreaCode = LEFT(PhoneNumber, 3),
        Exchange = SUBSTRING(PhoneNumber, 5, 3)
FROM    Person.PersonPhone
WHERE   PhoneNumber LIKE '[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]';


-- recipe 9.8
SELECT LEN(N'She sells sea shells by the sea shore.  ');

SELECT DATALENGTH(N'She sells sea shells by the sea shore.  '); 
SELECT  DATALENGTH(123),
        DATALENGTH(123.0),
        DATALENGTH(GETDATE());

-- recipe 9.9
SELECT REPLACE('The Classic Roadie is a stunning example of the bikes that AdventureWorks have been producing for years – Order your classic Roadie today and experience AdventureWorks history.', 'Classic', 'Vintage');


-- recipe 9.10
SELECT STUFF ( 'My cat''s name is X. Have you met him?', 18, 1, 'Edgar' );

SELECT STUFF ( 'My cat''s name is X. Have you met him?', 18, 0, 'Edgar' );

SELECT STUFF ( 'My cat''s name is X. Have you met him?', 18, 8, '' );


-- recipe 9.11
SELECT  DocumentSummary
FROM    Production.Document
WHERE   FileName = 'Installing Replacement Pedals.doc';

SELECT  LOWER(DocumentSummary)
FROM    Production.Document
WHERE   FileName = 'Installing Replacement Pedals.doc';

SELECT  UPPER(DocumentSummary)
FROM    Production.Document
WHERE   FileName = 'Installing Replacement Pedals.doc';

SELECT UPPER (N'????????????? unicode');


-- recipe 9.12
SELECT CONCAT('''', LTRIM('     String with leading and trailing blanks.     '), '''' ); 

SELECT CONCAT('''', RTRIM('     String with leading and trailing blanks.     '), '''' ); 

SELECT CONCAT('''', LTRIM(RTRIM('   String with leading and trailing blanks    ')), '''' );


-- recipe 9.13
SELECT REPLICATE ('W', 30);
SELECT REPLICATE ('W_', 30);

-- recipe 9.14
DECLARE @string1 NVARCHAR(20) = 'elephant',
        @string2 NVARCHAR(20) = 'dog',
        @string3 NVARCHAR(20) = 'giraffe' ;

SELECT  *
FROM    ( VALUES
        ( CONCAT(@string1, SPACE(20 - LEN(@string1)), @string2,
                 SPACE(20 - LEN(@string2)), @string3,
                 SPACE(20 - LEN(@string3))))
	,
        ( CONCAT(@string2, SPACE(20 - LEN(@string2)), @string3,
                 SPACE(20 - LEN(@string3)), @string1,
                 SPACE(20 - LEN(@string1)))) ) AS a (formatted_string);


-- recipe 9.15
SELECT REVERSE('Hello World');

SELECT  Path = LEFT(physical_name, LEN(physical_name) - CHARINDEX('\', REVERSE(physical_name)) + 1),
        FileName = RIGHT(physical_name, CHARINDEX('\', REVERSE(physical_name)) - 1)
FROM    sys.database_files;

