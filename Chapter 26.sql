SET NOCOUNT ON;
EXECUTE sys.xp_create_subdir 'N:\Apress\';
EXECUTE sys.xp_create_subdir 'O:\Apress\';
EXECUTE sys.xp_create_subdir 'P:\Apress\';

USE master;
GO
IF DB_ID('BookStoreArchive') IS NOT NULL DROP DATABASE BookStoreArchive;
GO

CREATE DATABASE BookStoreArchive 
ON PRIMARY
(NAME = 'BookStoreArchive', 
 FILENAME = 'N:\Apress\BookStoreArchive.MDF', 
 SIZE = 4MB, 
 MAXSIZE = UNLIMITED, 
 FILEGROWTH = 10MB)
LOG ON
(NAME = 'BookStoreArchive_log', 
 FILENAME = 'P:\Apress\BookStoreArchive_log.LDF', 
 SIZE = 512KB, 
 MAXSIZE = UNLIMITED, 
 FILEGROWTH = 512KB);



-- recipe 26-1
ALTER DATABASE BookStoreArchive
ADD FILE
(  NAME = 'BookStoreArchive2',
FILENAME = 'O:\Apress\BookStoreArchive2.NDF' ,
SIZE = 1MB ,
MAXSIZE = 10MB,
FILEGROWTH = 1MB ) 
TO FILEGROUP [PRIMARY];

ALTER DATABASE BookStoreArchive
ADD LOG FILE
(  NAME = 'BookStoreArchive2Log',
FILENAME = 'P:\Apress\BookStoreArchive2_log.LDF' ,
SIZE = 1MB ,
MAXSIZE = 5MB,
FILEGROWTH = 1MB );
GO



-- recipe 26-2
ALTER DATABASE BookStoreArchive REMOVE FILE BookStoreArchive2;



-- recipe 26-3
ALTER DATABASE BookStoreArchive
MODIFY FILE
(NAME = 'BookStoreArchive', FILENAME = 'O:\Apress\BookStoreArchive.mdf')
GO


USE master;
GO
ALTER DATABASE BookStoreArchive SET RESTRICTED_USER WITH ROLLBACK IMMEDIATE;
GO
ALTER DATABASE BookStoreArchive SET OFFLINE;
GO
-- Move BookStoreArchive.mdf file from N:\Apress\ to O:\Apress now.
-- On my Windows 7 PC, I had to use Administrator access to move the file.
-- On other operating systems, you may have to modify file/folder permissions
-- to prevent an access denied error.



USE master;
GO
ALTER DATABASE BookStoreArchive SET ONLINE;
GO
ALTER DATABASE BookStoreArchive SET MULTI_USER WITH ROLLBACK IMMEDIATE;
GO



-- recipe 26-4
SELECT  name
FROM    BookStoreArchive.sys.database_files;

ALTER DATABASE BookStoreArchive
MODIFY FILE
(NAME = 'BookStoreArchive',
NEWNAME = 'BookStoreArchive_Data');

SELECT  name
FROM    BookStoreArchive.sys.database_files;



-- recipe 26-5
SELECT name, size FROM BookStoreArchive.sys.database_files;

ALTER DATABASE BookStoreArchive
MODIFY FILE
(NAME = 'BookStoreArchive_Data',
 SIZE = 5MB);

SELECT name, size FROM BookStoreArchive.sys.database_files;



-- recipe 26-6
ALTER DATABASE BookStoreArchive
ADD FILEGROUP FG2;
GO



-- recipe 26-7
ALTER DATABASE BookStoreArchive
ADD FILE
(  NAME = 'BW2',
FILENAME = 'N:\Apress\FG2_BookStoreArchive.NDF' ,
SIZE = 1MB ,
MAXSIZE = 50MB,
FILEGROWTH = 5MB ) 
TO FILEGROUP [FG2];



-- recipe 26-8
ALTER DATABASE BookStoreArchive
MODIFY FILEGROUP FG2 DEFAULT;
GO



-- recipe 26-9
USE BookStoreArchive;
GO
CREATE TABLE dbo.Test
       (
        TestID  INT IDENTITY,
        Column1 INT,
        Column2 INT,
        Column3 INT
       )
ON     [FG2];



-- recipe 26-10
-- solution 1
ALTER TABLE dbo.Test
  ADD CONSTRAINT PK_Test PRIMARY KEY CLUSTERED (TestId)
  ON [PRIMARY];
GO

-- solution 2
CREATE TABLE dbo.Test2
       (
        TestID INT IDENTITY
                   CONSTRAINT PK__Test2 PRIMARY KEY CLUSTERED,
        Column1 INT,
        Column2 INT,
        Column3 INT
       )
ON     [FG2];
GO

ALTER TABLE dbo.Test2
DROP CONSTRAINT PK__Test2;

ALTER TABLE dbo.Test2
ADD CONSTRAINT PK__Test2 PRIMARY KEY CLUSTERED (TestId)
ON [PRIMARY];
GO

-- solution 3
CREATE TABLE dbo.Test3
       (
        TestID INT IDENTITY,
        Column1 INT,
        Column2 INT,
        Column3 INT
       )
ON     [FG2];
GO

CREATE CLUSTERED INDEX IX_Test3 ON dbo.Test3 (TestId) 
ON [FG2];
GO

CREATE CLUSTERED INDEX IX_Test3 ON dbo.Test3 (TestId)
WITH (DROP_EXISTING = ON)
ON [PRIMARY];
GO



-- recipe 26-11
ALTER DATABASE BookStoreArchive
MODIFY FILEGROUP [PRIMARY] DEFAULT;
GO

ALTER DATABASE BookStoreArchive 
REMOVE FILE BW2;
GO

ALTER DATABASE BookStoreArchive
REMOVE FILEGROUP FG2;
GO



-- recipe 26-12
-- solution 1
ALTER DATABASE BookStoreArchive SET RESTRICTED_USER WITH ROLLBACK IMMEDIATE;
GO

ALTER DATABASE BookStoreArchive
ADD FILEGROUP FG3;
GO

ALTER DATABASE BookStoreArchive
ADD FILE
(  NAME = 'ArchiveData',
FILENAME = 'N:\Apress\BookStoreArchiveData.NDF' ,
SIZE = 1MB ,
MAXSIZE = 10MB,
FILEGROWTH = 1MB ) 
TO FILEGROUP [FG3];
GO
-- move historical tables to this filegroup

ALTER DATABASE BookStoreArchive
MODIFY FILEGROUP FG3 READ_ONLY;
GO

ALTER DATABASE BookStoreArchive SET MULTI_USER;
GO



-- solution 2
ALTER DATABASE BookStoreArchive SET READ_ONLY;
GO

ALTER DATABASE BookStoreArchive SET READ_WRITE;
GO



-- recipe 26-13
-- solution 1

EXECUTE sp_spaceused;

-- solution 2
EXECUTE sp_spaceused 'dbo.test';

-- solution 3
DBCC SQLPERF(LOGSPACE);



-- recipe 26-14
-- solution 1
ALTER DATABASE BookStoreArchive
MODIFY FILE (NAME = 'BookStoreArchive_log', SIZE = 100MB);

ALTER DATABASE BookStoreArchive
MODIFY FILE (NAME = 'BookStoreArchive_Data', SIZE = 200MB);
GO

USE BookStoreArchive;
GO

EXECUTE sp_spaceused;
GO

DBCC SHRINKDATABASE ('BookStoreArchive', 10);
GO

EXECUTE sp_spaceused;
GO


-- solution 2
ALTER DATABASE BookStoreArchive
MODIFY FILE (NAME = 'BookStoreArchive_Log', SIZE = 200MB);
GO

USE BookStoreArchive;
GO

EXECUTE sp_spaceused;
GO

DBCC SHRINKFILE ('BookStoreArchive_Log', 2);
GO

EXECUTE sp_spaceused;
GO



-- recipe 26-15
DBCC CHECKALLOC ('BookStoreArchive');



-- recipe 26-16
DBCC CHECKDB('BookStoreArchive');



-- recipe 26-17
USE BookStoreArchive;
GO
DBCC CHECKFILEGROUP ('PRIMARY');
GO


-- recipe 26-18
USE AdventureWorks2014;
GO
DBCC CHECKTABLE ('Production.Product');
GO
DBCC CHECKTABLE ('Sales.SalesOrderDetail') WITH ESTIMATEONLY;
GO

DECLARE @IndexId INTEGER;
SELECT  @IndexId = index_id
FROM    sys.indexes
WHERE   object_id = OBJECT_ID('Sales.SalesOrderDetail')
AND     name = 'IX_SalesOrderDetail_ProductID';

DBCC CHECKTABLE ('Sales.SalesOrderDetail', @IndexId) WITH PHYSICAL_ONLY;
GO


-- recipe 26-19
USE AdventureWorks2014;
GO
SELECT StartDate, EndDate FROM Production.WorkOrder WHERE WorkOrderID = 1;
GO
ALTER TABLE Production.WorkOrder NOCHECK CONSTRAINT CK_WorkOrder_EndDate; 
GO
-- Set an EndDate to earlier than a StartDate
UPDATE Production.WorkOrder
SET EndDate = '2001-01-01T00:00:00'
WHERE WorkOrderID = 1;
GO
ALTER TABLE Production.WorkOrder CHECK CONSTRAINT CK_WorkOrder_EndDate;
GO
DBCC CHECKCONSTRAINTS ('Production.WorkOrder');
GO

UPDATE Production.WorkOrder
SET EndDate = '2011-06-13T00:00:00.000'
WHERE WorkOrderID = 1;
DBCC CHECKCONSTRAINTS ('Production.WorkOrder');
GO



-- recipe 26-20
DBCC CHECKCATALOG ('BookStoreArchive');
