SET NOCOUNT ON;
GO
USE master;
GO

EXECUTE xp_create_subdir 'C:\Apress';

IF DB_ID('MegaCorpData') IS NOT NULL DROP DATABASE MegaCorpData;
GO

CREATE DATABASE MegaCorpData
ON PRIMARY
(NAME = 'MegaCorpData',
 FILENAME = 'C:\Apress\MegaCorpData.MDF',
 SIZE = 4MB,
 MAXSIZE = UNLIMITED,
 FILEGROWTH = 1MB)
LOG ON
(NAME = 'MegaCorpData_Log',
 FILENAME = 'C:\Apress\MegaCorpData.LDF',
 SIZE = 3MB,
 MAXSIZE = UNLIMITED,
 FILEGROWTH = 1MB);
GO

-- recipe 15.1
ALTER DATABASE MegaCorpData ADD FILEGROUP hitfg1;
ALTER DATABASE MegaCorpData ADD FILEGROUP hitfg2;
ALTER DATABASE MegaCorpData ADD FILEGROUP hitfg3;
ALTER DATABASE MegaCorpData ADD FILEGROUP hitfg4;

ALTER DATABASE MegaCorpData 
ADD FILE (NAME = mchitfg1, 
          FILENAME = 'C:\Apress\mc_hitfg1.ndf', 
          SIZE = 1MB) 
TO FILEGROUP hitfg1;
ALTER DATABASE MegaCorpData 
ADD FILE (NAME = mchitfg2, 
          FILENAME = 'C:\Apress\mc_hitfg2.ndf', 
          SIZE = 1MB) 
TO FILEGROUP hitfg2;
ALTER DATABASE MegaCorpData 
ADD FILE (NAME = mchitfg3, 
          FILENAME = 'C:\Apress\mc_hitfg3.ndf', 
          SIZE = 1MB) 
TO FILEGROUP hitfg3;
ALTER DATABASE MegaCorpData 
ADD FILE (NAME = mchitfg4, 
          FILENAME = 'C:\Apress\mc_hitfg4.ndf', 
          SIZE = 1MB) 
TO FILEGROUP hitfg4;

USE MegaCorpData;
GO
CREATE PARTITION FUNCTION HitsDateRange (datetime)
AS RANGE LEFT FOR VALUES ('2006-01-01T00:00:00', '2007-01-01T00:00:00', '2008-01-01T00:00:00');

CREATE PARTITION SCHEME HitDateRangeScheme
AS PARTITION HitsDateRange
TO (hitfg1, hitfg2, hitfg3, hitfg4);

CREATE TABLE dbo.WebSiteHits (
    WebSiteHitID BIGINT NOT NULL IDENTITY(1, 1), 
    WebSitePage VARCHAR(255) NOT NULL,
    HitDate DATETIME NOT NULL,
    CONSTRAINT PK_WebSiteHits PRIMARY KEY CLUSTERED (WebSiteHitId, HitDate)
)
ON [HitDateRangeScheme] (HitDate);



-- recipe 15.2
INSERT  dbo.WebSiteHits (WebSitePage, HitDate)
VALUES  ('Home Page', '2007-10-22T00:00:00'),
        ('Home Page', '2006-10-02T00:00:00'),
        ('Sales Page', '2008-05-09T00:00:00'),
        ('Sales Page', '2000-03-04T00:00:00');

SELECT  WebSitePage,
        HitDate,
        $PARTITION.HitsDateRange (HitDate) AS [Partition]
FROM    dbo.WebSiteHits;


-- recipe 15.3
ALTER PARTITION SCHEME HitDateRangeScheme NEXT USED [PRIMARY];
GO

ALTER PARTITION FUNCTION HitsDateRange () SPLIT RANGE ('2009-01-01T00:00:00');
GO

INSERT  dbo.WebSiteHits
        (WebSitePage, HitDate)
VALUES  ('Sales Page', '2009-03-04T00:00:00');

SELECT  WebSitePage,
        HitDate,
        $PARTITION.HitsDateRange (HitDate) AS [Partition]
FROM    dbo.WebSiteHits;


-- recipe 15.4
ALTER PARTITION FUNCTION HitsDateRange () MERGE RANGE ('2007-01-01T00:00:00');
GO

SELECT  WebSitePage,
        HitDate,
        $PARTITION.HitsDateRange(HitDate) Partition
FROM    dbo.WebSiteHits;


-- recipe 15.5
SELECT  p.partition_id,
        p.object_id,
        p.partition_number
FROM    sys.partitions AS p
WHERE   p.partition_id IS NOT NULL
AND     p.object_id = OBJECT_ID('dbo.WebSiteHits');


-- recipe 15.6
SELECT  t.name AS TableName,
        i.name AS IndexName,
        p.partition_number AS [Part#],
        f.type_desc,
        CASE WHEN f.boundary_value_on_right = 1 THEN 'RIGHT' ELSE 'LEFT' END AS BoundaryType,
        r.boundary_id,
        r.value AS BoundaryValue
FROM    sys.tables AS t
        JOIN sys.indexes AS i
            ON t.object_id = i.object_id
        JOIN sys.partitions AS p
            ON i.object_id = p.object_id
               AND i.index_id = p.index_id
        JOIN sys.partition_schemes AS s
            ON i.data_space_id = s.data_space_id
        JOIN sys.partition_functions AS f
            ON s.function_id = f.function_id
        LEFT JOIN sys.partition_range_values AS r
            ON f.function_id = r.function_id
               AND r.boundary_id = p.partition_number
WHERE   t.object_id = OBJECT_ID('dbo.WebSiteHits')
AND     i.type <= 1
ORDER BY p.partition_number;


-- recipe 15.7
SELECT  t.object_id AS Object_ID,
        t.name AS TableName,
        ic.column_id AS PartitioningColumnID,
        c.name AS PartitioningColumnName
FROM    sys.tables AS t
        JOIN sys.indexes AS i
            ON t.object_id = i.object_id
        JOIN sys.partition_schemes AS ps
            ON ps.data_space_id = i.data_space_id
        JOIN sys.index_columns AS ic
            ON ic.object_id = i.object_id
               AND ic.index_id = i.index_id
               AND ic.partition_ordinal > 0
        JOIN sys.columns AS c
            ON t.object_id = c.object_id
               AND ic.column_id = c.column_id
WHERE   t.object_id = OBJECT_ID('dbo.WebSiteHits')
AND     i.type <= 1;


-- recipe 15.8
SELECT  PartitionSchemaName,
        NextUsedPartition = FileGroupName
FROM    (SELECT FileGroupName = FG.name,
                PartitionSchemaName = PS.name,
                RANK() OVER (PARTITION BY PS.name ORDER BY DDS.destination_id) AS dest_rank
         FROM   sys.partition_schemes PS
                JOIN sys.destination_data_spaces AS DDS
                    ON DDS.partition_scheme_id = PS.data_space_id
                JOIN sys.filegroups AS FG
                    ON FG.data_space_id = DDS.data_space_id
                LEFT JOIN sys.partition_range_values AS PRV
                    ON PRV.boundary_id = DDS.destination_id
                       AND PRV.function_id = PS.function_id
         WHERE  PRV.value IS NULL
        ) AS a
WHERE   dest_rank = 2;


-- recipe 15.9
CREATE TABLE dbo.WebSiteHitsHistory
       (
        WebSiteHitID BIGINT NOT NULL IDENTITY,
        WebSitePage VARCHAR(255) NOT NULL,
        HitDate DATETIME NOT NULL,
        CONSTRAINT PK_WebSiteHitsHistory PRIMARY KEY (WebSiteHitID, HitDate)
       )
ON     [HitDateRangeScheme](HitDate);
GO

ALTER TABLE dbo.WebSiteHits SWITCH PARTITION 1 TO dbo.WebSiteHitsHistory PARTITION 1;
GO

SELECT  WebSitePage,
        HitDate,
        $PARTITION.HitsDateRange(HitDate) Partition
FROM    dbo.WebSiteHits;
SELECT  WebSitePage,
        HitDate,
        $PARTITION.HitsDateRange(HitDate) Partition
FROM    dbo.WebSiteHitsHistory;


-- recipe 15.10
IF OBJECT_ID('dbo.WebSiteHitsImport','U') IS NOT NULL DROP TABLE dbo.WebSiteHitsImport;
GO
CREATE TABLE dbo.WebSiteHitsImport
       (
        WebSiteHitID BIGINT NOT NULL IDENTITY,
        WebSitePage VARCHAR(255) NOT NULL,
        HitDate DATETIME NOT NULL,
        CONSTRAINT PK_WebSiteHitsImport PRIMARY KEY (WebSiteHitID, HitDate),
        CONSTRAINT CK_WebSiteHitsImport CHECK (HitDate <= '2006-01-01T00:00:00')
       )
ON hitfg1;
GO
INSERT INTO dbo.WebSiteHitsImport (WebSitePage, HitDate)
VALUES ('Sales Page', '2005-06-01T00:00:00'),
       ('Main Page', '2005-06-01T00:00:00');
GO

-- partition 1 is empty – move data to this partition
ALTER TABLE dbo.WebSiteHitsImport SWITCH TO dbo.WebSiteHits PARTITION 1;
GO

-- see the data
SELECT  WebSiteHitId,
        WebSitePage,
        HitDate,
        $PARTITION.HitsDateRange(HitDate) Partition
FROM    dbo.WebSiteHits;
SELECT  WebSiteHitId,
        WebSitePage,
        HitDate,
        $PARTITION.HitsDateRange(HitDate) Partition
FROM    dbo.WebSiteHitsImport;


-- recipe 15.11
ALTER TABLE dbo.WebSiteHits SWITCH PARTITION 1 TO dbo.WebSiteHitsImport;
GO

-- see the data
SELECT  WebSiteHitId,
        WebSitePage,
        HitDate,
        $PARTITION.HitsDateRange(HitDate) Partition
FROM    dbo.WebSiteHits;
SELECT  WebSiteHitId,
        WebSitePage,
        HitDate,
        $PARTITION.HitsDateRange(HitDate) Partition
FROM    dbo.WebSiteHitsImport;


-- recipe 15.12
ALTER TABLE dbo.WebSiteHits SET (LOCK_ESCALATION = AUTO);


-- recipe 15.13
DROP TABLE dbo.WebSiteHits;
DROP TABLE dbo.WebSiteHitsHistory;
DROP PARTITION SCHEME HitDateRangeScheme;
DROP PARTITION FUNCTION HitsDateRange;


-- recipe 15.14

-- recipe 15.15
CREATE TABLE dbo.DataCompressionTest
       (
        JobPostinglD INT NOT NULL IDENTITY PRIMARY KEY CLUSTERED,
        CandidatelD INT NOT NULL,
        JobDESC CHAR(2000) NOT NULL
       )
WITH (DATA_COMPRESSION = ROW);
GO

CREATE TABLE dbo.ArchiveJobPosting
       (
        JobPostinglD INT NOT NULL IDENTITY PRIMARY KEY CLUSTERED,
        CandidatelD INT NOT NULL,
        JobDESC CHAR(2000) NOT NULL
       );
GO

INSERT  dbo.ArchiveJobPosting
        (CandidatelD,
         JobDESC)
VALUES (CAST(RAND() * 10 AS INT),
        REPLICATE('a', 50))
GO 100000

EXECUTE sp_estimate_data_compression_savings 
    @schema_name = 'dbo', 
    @object_name = 'ArchiveJobPosting', 
    @index_id = NULL, 
    @partition_number = NULL, 
    @data_compression = 'ROW';

EXECUTE sp_estimate_data_compression_savings 
    @schema_name = 'dbo', 
    @object_name = 'ArchiveJobPosting', 
    @index_id = NULL, 
    @partition_number = NULL, 
    @data_compression = 'PAGE';

ALTER TABLE dbo.ArchiveJobPosting REBUILD WITH (DATA_COMPRESSION = PAGE);

CREATE PARTITION FUNCTION pfn_ArchivePart(int) 
AS RANGE LEFT FOR VALUES (50000, 100000, 150000);
GO
CREATE PARTITION SCHEME psc_ArchivePart
AS PARTITION pfn_ArchivePart
TO (hitfg1, hitfg2, hitfg3, hitfg4);
GO
CREATE TABLE dbo.ArchiveJobPosting_V2
       (
        JobPostingID INT NOT NULL IDENTITY PRIMARY KEY CLUSTERED,
        CandidateID INT NOT NULL,
        JobDesc CHAR(2000) NOT NULL
       )
ON     psc_ArchivePart(JobPostingID)
WITH (
    DATA_COMPRESSION = PAGE ON PARTITIONS (1 TO 3),
    DATA_COMPRESSION = ROW ON PARTITIONS (4));
GO

ALTER TABLE dbo.ArchiveJobPosting_V2
REBUILD PARTITION = 4
WITH (DATA_COMPRESSION = PAGE);
GO

--recipe 15.16
IF OBJECT_ID('dbo.HeapTest') IS NOT NULL DROP TABLE dbo.HeapTest;
CREATE TABLE dbo.HeapTest
(
	HeapTest VARCHAR(1000)
);
GO
INSERT INTO dbo.HeapTest (HeapTest)
VALUES ('Test');
GO 10000
SELECT  index_type_desc,
        fragment_count,
        page_count,
        forwarded_record_count
FROM    sys.dm_db_index_physical_stats(DB_ID(), DEFAULT, DEFAULT, DEFAULT, 'DETAILED')
WHERE   object_id = OBJECT_ID('dbo.HeapTest');
GO
UPDATE dbo.HeapTest
SET HeapTest = REPLICATE('Test',250);
GO
SELECT  index_type_desc,
        fragment_count,
        page_count,
        forwarded_record_count
FROM    sys.dm_db_index_physical_stats(DB_ID(), DEFAULT, DEFAULT, DEFAULT, 'DETAILED')
WHERE   object_id = OBJECT_ID('dbo.HeapTest');
GO
ALTER TABLE dbo.HeapTest REBUILD;
GO

SELECT  index_type_desc,
        fragment_count,
        page_count,
        forwarded_record_count
FROM    sys.dm_db_index_physical_stats(DB_ID(), DEFAULT, DEFAULT, DEFAULT, 'DETAILED')
WHERE   object_id = OBJECT_ID('dbo.HeapTest');
GO


-- cleanup
USE master;
GO
IF DB_ID('MegaCorpData') IS NOT NULL DROP DATABASE MegaCorpData;
GO
