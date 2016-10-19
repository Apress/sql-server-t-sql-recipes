USE master;
GO
IF DB_ID('InMemory') IS NOT NULL 
    DROP DATABASE InMemory;
GO
-- 20-1; Solution 1
/*
Create a database, and modify it to have a memory-optimized filegroup.
*/
CREATE DATABASE InMemory;
ALTER DATABASE InMemory ADD FILEGROUP InMemory_mod CONTAINS MEMORY_OPTIMIZED_DATA;
ALTER DATABASE InMemory
ADD FILE (
	NAME = [InMemory_dir],
	FILENAME = 'C:\MSSQL\MSSQL12.MSSQLSERVER\MSSQL\DATA\InMemory_dir')
TO FILEGROUP [InMemory_mod];
GO

-- 20-1; Solution 2
/*
Create a database with a memory-optimized filegroup.
*/
IF DB_ID('InMemory') IS NULL
CREATE DATABASE In-Memory
ON
PRIMARY (NAME=[InMemory_data],
	FILENAME = 'C:\MSSQL\MSSQL12.MSSQLSERVER\MSSQL\DATA\InMemory_data.mdf',
	SIZE = 50MB),
FILEGROUP InMemory_mod CONTAINS MEMORY_OPTIMIZED_DATA (
	NAME = [InMemory_dir],
	FILENAME = 'C:\MSSQL\MSSQL12.MSSQLSERVER\MSSQL\DATA\InMemory_dir')
LOG ON (NAME = [InMemory_log]
	FILENAME = 'C:\MSSQL\MSSQL12.MSSQLSERVER\MSSQL\DATA\InMemory_log.ldf',
	SIZE=5MB);
GO


USE InMemory;
GO

-- 20-2
/*
Creaate a memory-optimized table.
*/
CREATE TABLE dbo.T1 (
	c1 INTEGER NOT NULL PRIMARY KEY NONCLUSTERED,
	c2 INTEGER NOT NULL,
	INDEX ix_T1 HASH(c2) WITH (BUCKET_COUNT=8)
) WITH (MEMORY_OPTIMIZED=ON, DURABILITY=SCHEMA_AND_DATA);
GO
UPDATE STATISTICS dbo.T1 WITH FULLSCAN, NORECOMPUTE;
GO

-- 20-3
/*
Create a memory-optimized table variable.
*/
CREATE TYPE dbo.imTV AS TABLE (
	Col1 INTEGER NOT NULL,
	INDEX ix_imTV1 HASH(Col1) WITH (BUCKET_COUNT=8)
) WITH (MEMORY_OPTIMIZED=ON);
GO
DECLARE @imTV dbo.imTV;


-- 20-4
/*
Create a natively compiled stored procedure.
*/
CREATE PROCEDURE dbo.imProc
WITH NATIVE_COMPILATION, SCHEMABINDING, EXECUTE AS OWNER
AS
BEGIN ATOMIC WITH (TRANSACTION ISOLATION LEVEL = SNAPSHOT, LANGUAGE = N'us_english')
    DECLARE @TV dbo.imTV;
    INSERT INTO @TV VALUES (4);
    INSERT INTO @TV VALUES (5);
    INSERT INTO @TV VALUES (6);
    SELECT Col1 FROM @TV;
END;
GO

-- 20-5
/*
Get the objects in this database that are configured
to use In-Memory OLTP.
*/
SELECT  object_type_desc = 'Table', schema_name = OBJECT_SCHEMA_NAME(object_id), 
	object_name = name
FROM	sys.tables
WHERE	is_memory_optimized = 1 UNION ALL
SELECT	'Table Type', SCHEMA_NAME(schema_id), name
FROM	sys.table_types
WHERE	is_memory_optimized = 1 UNION ALL
SELECT	so.type_desc, OBJECT_SCHEMA_NAME(sasm.object_id), OBJECT_NAME(sasm.object_id)
FROM	sys.all_sql_modules sasm
        JOIN sys.objects so ON so.object_id = sasm.object_id
WHERE	uses_native_compilation = 1;

-- 20-6
/*
Get the database and object of all In-Memory objects on the server
that are currently loaded in memory.
*/
SELECT	ca2.database_id, database_name = DB_NAME(ca2.database_id), dt1.object_type_desc, 
	    ca2.object_id, object_name = OBJECT_NAME(ca2.object_id, ca2.database_id)
FROM	sys.dm_os_loaded_modules
	    CROSS APPLY (SELECT REPLACE(REPLACE(SUBSTRING(name, CHARINDEX('xtp_', name), 8000), '.dll', ''), '_', '.')) ca1(filename)
	    CROSS APPLY (SELECT 	CONVERT(CHAR(1), PARSENAME(ca1.filename, 3)), 
				                CONVERT(INTEGER, PARSENAME(ca1.filename, 2)), 
				                CONVERT(INTEGER, PARSENAME(ca1.filename, 1))
		) ca2(object_type, database_id, object_id)
	    JOIN (VALUES ('t', 'Table'), ('v', 'Table Type'), ('p', 'Procedure')) 
		    dt1(object_type, object_type_desc) ON dt1.object_type = ca2.object_type
WHERE	description = 'XTP Native DLL';

-- 20-7
/* 
Use of natively compiled stored procedures with parameter issues
can be detected through the XEvent natively_compiled_proc_slow_parameter_passing, 
with reason=named_parameters or reason=parameter_conversion.
*/
CREATE EVENT SESSION [In-Memory Slow Parameter Passing] ON SERVER 
ADD EVENT sqlserver.natively_compiled_proc_slow_parameter_passing(
    ACTION(sqlserver.database_id,sqlserver.database_name,sqlserver.sql_text)) 
ADD TARGET package0.ring_buffer
WITH (STARTUP_STATE=OFF)
GO


ALTER EVENT SESSION [In-Memory Slow Parameter Passing] 
ON SERVER
STATE = start;

/*
To test this, we need a procedure with parameters.
*/
CREATE PROCEDURE dbo.imProcWithParams
@Rows INTEGER = 1
WITH NATIVE_COMPILATION, SCHEMABINDING, EXECUTE AS OWNER
AS
BEGIN ATOMIC WITH (TRANSACTION ISOLATION LEVEL = SNAPSHOT, LANGUAGE = N'us_english')
	DECLARE @TV dbo.imTV;
	WHILE @Rows > 0
	BEGIN
		INSERT INTO @TV VALUES (@Rows);
		SET @Rows -= 1;
	END;
	SELECT Col1 FROM @TV;
END;
GO

-- now execute the procedure a few times
EXECUTE dbo.imProcWithParams 5; -- no issues
GO
EXECUTE dbo.imProcWithParams '5'; -- data type conversion
GO
EXECUTE dbo.imProcWithParams @Rows = 5; -- named parameter
GO
EXECUTE dbo.imProcWithParams @Rows = '5'; -- named parameter and data type conversion
GO

-- query the ring buffer for the results
SELECT	/* extra columns not included in the book
        n.value('(event/@name)[1]', 'varchar(50)') AS event_name,
        n.value('(event/@package)[1]', 'varchar(50)') AS package_name,
        DATEADD(hh, DATEDIFF(hh, GETUTCDATE(), CURRENT_TIMESTAMP), 
            n.value('(event/@timestamp)[1]', 'datetime2')) AS [timestamp],
        n.value('(event/action[@name="database_id"]/value)[1]', 'int') as [database_id], */
	    n.value('(event/action[@name="database_name"]/value)[1]', 'sysname') AS [database_name],
	    --n.value('(event/data[@name="object_id"]/value)[1]', 'int') as [object_id],
	    n.value('(event/data[@name="reason"]/text)[1]', 'varchar(100)') as [reason],
	    n.value('(event/data[@name="parameter_name"]/value)[1]', 'sysname') as [parameter_name],
	    n.value('(event/action[@name="sql_text"]/value)[1]', 'varchar(max)') as [sql_text]
FROM
(   SELECT td.query('.') as n
    FROM 
    (   SELECT CAST(target_data AS XML) as target_data
        FROM sys.dm_xe_sessions AS s    
        JOIN sys.dm_xe_session_targets AS t
            ON s.address = t.event_session_address
        WHERE s.name = 'In-Memory Slow Parameter Passing'
            AND t.target_name = 'ring_buffer'
    ) AS sub
    CROSS APPLY target_data.nodes('RingBufferTarget/event') AS q(td)
) AS tab;

