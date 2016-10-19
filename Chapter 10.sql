SET NOCOUNT ON;
-- recipe 10.1
SELECT 'GETDATE()' AS [Function],           GETDATE() AS [Value];
SELECT 'CURRENT_TIMESTAMP'AS [Function],    CURRENT_TIMESTAMP AS [Value];
SELECT 'GETUTCDATE()' AS [Function],        GETUTCDATE() AS [Value];
SELECT 'SYSDATETIME()' AS [Function],       SYSDATETIME() AS [Value];
SELECT 'SYSUTCDATETIME()' AS [Function],    SYSUTCDATETIME() AS [Value];
SELECT 'SYSDATETIMEOFFSET()' AS [Function], SYSDATETIMEOFFSET() AS [Value];



-- recipe 10.2
SELECT SWITCHOFFSET(SYSDATETIMEOFFSET(), '+03:00');


-- recipe 10.3
SELECT  TODATETIMEOFFSET(GETDATE(), '-05:00') AS [Eastern Time Zone Time],
       	SYSDATETIMEOFFSET() [Current System Time];


-- recipe 10.4
SELECT DATEADD(YEAR, -1, '2009-04-02T00:00:00');


-- recipe 10.5
SELECT  TOP (5)
       	ProductID,
       	GETDATE() AS Today,
       	EndDate,
       	DATEDIFF(MONTH, EndDate, GETDATE()) AS ElapsedMonths
FROM 	Production.ProductCostHistory
WHERE   EndDate IS NOT NULL
ORDER BY ProductID;


WITH cteDates (StartDate, EndDate) AS 
(
SELECT  CONVERT(DATETIME2, '2010-12-31T23:59:59.9999999'), 
        CONVERT(DATETIME2, '2011-01-01T00:00:00.0000000')
)
SELECT  StartDate,
        EndDate,
        DATEDIFF(YEAR, StartDate, EndDate) AS Years,
        DATEDIFF(QUARTER, StartDate, EndDate) AS Quarters,
        DATEDIFF(MONTH, StartDate, EndDate) AS Months,
        DATEDIFF(DAY, StartDate, EndDate) AS Days,
        DATEDIFF(HOUR, StartDate, EndDate) AS Hours,
        DATEDIFF(MINUTE, StartDate, EndDate) AS Minutes,
        DATEDIFF(SECOND, StartDate, EndDate) AS Seconds,
        DATEDIFF(MILLISECOND, StartDate, EndDate) AS Milliseconds,
        DATEDIFF(MICROSECOND, StartDate, EndDate) AS MicroSeconds
FROM    cteDates;



-- recipe 10.6
DECLARE @StartDate DATETIME2 = '2012-01-01T18:25:42.9999999',
        @EndDate   DATETIME2 = '2012-06-15T13:12:11.8675309';

WITH cte AS
(
SELECT  DATEDIFF(SECOND, @StartDate, @EndDate) AS ElapsedSeconds,
        DATEDIFF(SECOND, @StartDate, @EndDate)/60 AS ElapsedMinutes,
        DATEDIFF(SECOND, @StartDate, @EndDate)/3600 AS ElapsedHours,
        DATEDIFF(SECOND, @StartDate, @EndDate)/86400 AS ElapsedDays
)
SELECT  @StartDate AS StartDate,
        @EndDate AS EndDate,
        CONVERT(VARCHAR(10), ElapsedDays) + ':' +
        CONVERT(VARCHAR(10), ElapsedHours%24) + ':' +
        CONVERT(VARCHAR(10), ElapsedMinutes%60) + ':' +
        CONVERT(VARCHAR(10), ElapsedSeconds%60) AS [ElapsedTime (D:H:M:S)]
FROM    cte;



-- recipe 10.7
SELECT  TOP (5)
        ProductID,
        EndDate,
        DATENAME(MONTH, EndDate) AS MonthName,
        DATENAME(WEEKDAY, EndDate) AS WeekDayName
FROM    Production.ProductCostHistory
WHERE   EndDate IS NOT NULL
ORDER BY ProductID;



-- recipe 10.8
SELECT  TOP (5)
        ProductID,
        EndDate,
        DATEPART(YEAR, EndDate) AS [Year],
        DATEPART(MONTH, EndDate) AS [Month],
        DATEPART(DAY, EndDate) AS [Day]
FROM    Production.ProductCostHistory
WHERE   EndDate IS NOT NULL
ORDER BY ProductID;



-- recipe 10.9
SELECT  MyData,
        ISDATE(MyData) AS IsADate
FROM    ( VALUES ( 'IsThisADate'), 
                 ( '2012-02-14'), 
                 ( '2012-01-01T00:00:00'),
                 ( '2012-12-31T23:59:59.9999999') ) dt (MyData);



-- recipe 10.10
SELECT  MyData,
        EOMONTH(MyData) AS LastDayOfThisMonth,
        EOMONTH(MyData, 1) AS LastDayOfNextMonth
FROM    (VALUES ('2012-02-14T00:00:00' ),
                ('2012-01-01T00:00:00'),
                ('2012-12-31T23:59:59.9999999')) dt(MyData);



-- recipe 10.11
SELECT  'DateFromParts' AS ConversionType, 
        DATEFROMPARTS(2012, 8, 15) AS [Value];
SELECT  'TimeFromParts' AS ConversionType, 
        TIMEFROMPARTS(18, 25, 32, 5, 1) AS [Value];
SELECT  'SmallDateTimeFromParts' AS ConversionType, 
        SMALLDATETIMEFROMPARTS(2012, 8, 15, 18, 25) AS [Value];
SELECT  'DateTimeFromParts' AS ConversionType, 
        DATETIMEFROMPARTS(2012, 8, 15, 18, 25, 32, 450) AS [Value];
SELECT  'DateTime2FromParts' AS ConversionType, 
        DATETIME2FROMPARTS(2012, 8, 15, 18, 25, 32, 5, 7) AS [Value];
SELECT  'DateTimeOffsetFromParts' AS ConversionType, 
        DATETIMEOFFSETFROMPARTS(2012, 8, 15, 18, 25, 32, 5, 4, 0, 7) AS [Value];



SELECT TIMEFROMPARTS(18, 25, 32, 5, 1);
SELECT TIMEFROMPARTS(18, 25, 32, 5, 2);
SELECT TIMEFROMPARTS(18, 25, 32, 5, 3);
SELECT TIMEFROMPARTS(18, 25, 32, 5, 4);
SELECT TIMEFROMPARTS(18, 25, 32, 5, 5);
SELECT TIMEFROMPARTS(18, 25, 32, 5, 6);
SELECT TIMEFROMPARTS(18, 25, 32, 5, 7);
SELECT TIMEFROMPARTS(18, 25, 32, 50, 2);
SELECT TIMEFROMPARTS(18, 25, 32, 500, 3);



-- recipe 10.12
DECLARE @MyDate DATETIME2 = '2012-01-01T18:25:42.9999999',
        @Base   DATETIME =  '1900-01-01T00:00:00',
        @Base2  DATETIME =  '2000-01-01T00:00:00';

-- Solution 1
SELECT  MyDate,
       	DATEADD(YEAR,   DATEDIFF(YEAR,    @Base, MyDate), @Base) AS [FirstDayOfYear],
        DATEADD(MONTH,  DATEDIFF(MONTH,   @Base, MyDate), @Base) AS [FirstDayOfMonth],
        DATEADD(QUARTER,DATEDIFF(QUARTER, @Base, MyDate), @Base) AS [FirstDayOfQuarter]
FROM    (VALUES ('1981-01-17T00:00:00'),
                ('1961-11-23T00:00:00'),
                ('1960-07-09T00:00:00'),
                ('1980-07-11T00:00:00'),
                ('1983-01-05T00:00:00'),
                ('2006-11-27T00:00:00'),
                ('2013-08-03T00:00:00')) dt (MyDate);

SELECT  'StartOfHour' AS ConversionType, 
        DATEADD(HOUR,   DATEDIFF(HOUR,   @Base, @MyDate), @Base) AS DateResult
UNION ALL
SELECT  'StartOfMinute', 
        DATEADD(MINUTE, DATEDIFF(MINUTE, @Base, @MyDate), @Base) 
UNION ALL
SELECT  'StartOfSecond', 
        DATEADD(SECOND, DATEDIFF(SECOND, @Base2, @MyDate), @Base2);



-- solution 2
SELECT  MyDate,
       	DATETIMEFROMPARTS(ca.Yr, 1,     1, 0, 0, 0, 0) AS FirstDayOfYear,
       	DATETIMEFROMPARTS(ca.Yr, ca.Mn, 1, 0, 0, 0, 0) AS FirstDayOfMonth,
       	DATETIMEFROMPARTS(ca.Yr, ca.Qt, 1, 0, 0, 0, 0) AS FirstDayOfQuarter
FROM    (VALUES ('1981-01-17T00:00:00'),
                ('1961-11-23T00:00:00'),
                ('1960-07-09T00:00:00'),
                ('1980-07-11T00:00:00'),
                ('1983-01-05T00:00:00'),
                ('2006-11-27T00:00:00'),
                ('2013-08-03T00:00:00')) dt (MyDate)
CROSS APPLY (SELECT DATEPART(YEAR, dt.MyDate) AS Yr,
                    DATEPART(MONTH, dt.MyDate) AS Mn,
                    ((CEILING(MONTH(dt.MyDate)/3.0)*3)-2) AS Qt
             ) ca;
WITH cte AS
(
SELECT  DATEPART(YEAR, @MyDate) AS Yr,
       	DATEPART(MONTH, @MyDate) AS Mth,
       	DATEPART(DAY, @MyDate) AS Dy,
      	DATEPART(HOUR, @MyDate) AS Hr,
      	DATEPART(MINUTE, @MyDate) AS Mn,
      	DATEPART(SECOND, @MyDate) AS Sec
)
SELECT  'StartOfHour' AS ConversionType,
       	DATETIMEFROMPARTS(cte.Yr, cte.Mth, cte.Dy, cte.Hr, 0, 0, 0) AS DateResult
FROM    cte
UNION ALL
SELECT  'StartOfMinute', 
        DATETIMEFROMPARTS(cte.Yr, cte.Mth, cte.Dy, cte.Hr, cte.Mn, 0, 0)
FROM    cte
UNION ALL
SELECT  'StartOfSecond', 
       	DATETIMEFROMPARTS(cte.Yr, cte.Mth, cte.Dy, cte.Hr, cte.Mn, cte.Sec, 0)
FROM    cte;


-- solution 3
SELECT  CONVERT(CHAR(10), ca.MyDate, 121) AS MyDate,
       	CAST(FORMAT(ca.MyDate, 'yyyy-01-01') AS DATETIME) AS FirstDayOfYear,
       	CAST(FORMAT(ca.MyDate, 'yyyy-MM-01') AS DATETIME) AS FirstDayOfMonth
FROM 	(VALUES ('1981-01-17T00:00:00'),
                ('1961-11-23T00:00:00'),
                ('1960-07-09T00:00:00'),
                ('1980-07-11T00:00:00'),
                ('1983-01-05T00:00:00'),
                ('2006-11-27T00:00:00'),
                ('2013-08-03T00:00:00')) dt (MyDate)
CROSS APPLY (SELECT CAST(dt.MyDate AS DATE)) AS ca(MyDate);

SELECT  'StartOfHour' AS ConversionType,
       	FORMAT(@MyDate, 'yyyy-MM-dd HH:00:00.000') AS DateResult
UNION ALL
SELECT  'StartOfMinute',
        FORMAT(@MyDate, 'yyyy-MM-dd HH:mm:00.000')
UNION ALL
SELECT  'StartOfSecond',
       	FORMAT(@MyDate, 'yyyy-MM-dd HH:mm:ss.000');



-- recipe 10.13
DECLARE @Base DATETIME = '1900-01-01T00:00:00';
WITH cteExpenses AS 
(
SELECT  ca.FirstOfMonth,
        SUM(ExpenseAmount) AS MonthlyExpenses
FROM    ( VALUES ('2012-01-15T00:00:00', 1250.00),
                 ('2012-01-28T00:00:00', 750.00), 
                 ('2012-03-01T00:00:00', 1475.00),
                 ('2012-03-23T00:00:00', 2285.00), 
                 ('2012-04-01T00:00:00', 1650.00),
                 ('2012-04-22T00:00:00', 1452.00), 
                 ('2012-06-15T00:00:00', 1875.00),
                 ('2012-07-23T00:00:00', 2125.00) ) dt (ExpenseDate, ExpenseAmount)
CROSS APPLY (SELECT DATEADD(MONTH, 
                    DATEDIFF(MONTH, @Base, ExpenseDate), @Base) ) ca (FirstOfMonth)
GROUP BY  ca.FirstOfMonth
), cteMonths AS 
(
SELECT  DATEFROMPARTS(2012, M, 1) AS FirstOfMonth
FROM    ( VALUES (1), (2),  (3),  (4), 
                 (5), (6),  (7),  (8), 
                 (9), (10), (11), (12) ) Months (M)
)
SELECT  CAST(FirstOfMonth AS DATE) AS FirstOfMonth,
       	MonthlyExpenses
FROM    cteExpenses
UNION ALL
SELECT  m.FirstOfMonth,
        0
FROM    cteMonths M
        LEFT JOIN cteExpenses e
            ON M.FirstOfMonth = e.FirstOfMonth
WHERE   e.FirstOfMonth IS NULL
ORDER BY FirstOfMonth;



-- recipe 10.14
IF OBJECT_ID('dbo.Calendar') IS NULL
CREATE TABLE dbo.Calendar (
  		[Date] DATE CONSTRAINT PK_Calendar PRIMARY KEY CLUSTERED,
  		FirstDayOfYear DATE,
  		LastDayOfYear DATE,
  		FirstDayOfMonth DATE,
  		LastDayOfMonth DATE,
  		FirstDayOfWeek DATE,
  		LastDayOfWeek DATE,
  		DayOfWeekName NVARCHAR(20),
  		IsWeekDay BIT,
  		IsWeekEnd BIT);
GO
DECLARE @Base  DATETIME = '1900-01-01T00:00:00',
        @Start DATETIME = '2000-01-01T00:00:00';
INSERT INTO dbo.Calendar 
SELECT 	TOP (9497)
       		ca.Date,
       		cy.FirstDayOfYear,
       		cyl.LastDayOfYear,
       		cm.FirstDayOfMonth,
       		cml.LastDayOfMonth,
       		cw.FirstDayOfWeek,
       		cwl.LastDayOfWeek,
       		cd.DayOfWeekName,
       		cwd.IsWeekDay,
       		CAST(cwd.IsWeekDay - 1 AS BIT) AS IsWeekEnd
FROM        (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 0))
             FROM sys.all_columns t1
             CROSS JOIN sys.all_columns t2) dt (RN)
CROSS APPLY (SELECT DATEADD(DAY, RN-1, @Start)) AS ca(Date)
CROSS APPLY (SELECT DATEADD(YEAR, DATEDIFF(YEAR, @Base, ca.Date), @Base)) AS cy(FirstDayOfYear)
CROSS APPLY (SELECT DATEADD(DAY, -1, DATEADD(YEAR, 1, cy.FirstDayOfYear))) AS cyl(LastDayOfYear)
CROSS APPLY (SELECT DATEADD(MONTH, DATEDIFF(MONTH, @Base, ca.Date), @Base)) AS cm(FirstDayOfMonth)
CROSS APPLY (SELECT DATEADD(DAY, -1, DATEADD(MONTH, 1, cm.FirstDayOfMonth))) AS cml(LastDayOfMonth)
CROSS APPLY (SELECT DATEADD(DAY,-(DATEPART(weekday ,ca.Date)-1),ca.Date)) AS cw(FirstDayOfWeek)
CROSS APPLY (SELECT DATEADD(DAY, 6, cw.FirstDayOfWeek)) AS cwl(LastDayOfWeek)
CROSS APPLY (SELECT DATENAME(weekday, ca.Date)) AS cd(DayOfWeekName)
CROSS APPLY (SELECT CASE WHEN cd.DayOfWeekName 
                         IN ('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday')
                         THEN 1 
                         ELSE 0 
                    END) AS cwd(IsWeekDay);
GO

WITH cte AS
(
SELECT  FirstDayOfMonth,
        Date,
       	RN = ROW_NUMBER() OVER (PARTITION BY FirstDayOfMonth ORDER BY Date)
FROM   	dbo.Calendar
WHERE   DayOfWeekName = 'Thursday'
)
SELECT 	Date
FROM   	cte
WHERE   RN = 3
AND     FirstDayOfMonth = '2012-11-01T00:00:00';

SELECT  c1.Date
FROM    dbo.Calendar c1 -- prior week
        JOIN dbo.Calendar c2 -- current week
        	ON c1.FirstDayOfWeek = DATEADD(DAY, -7, c2.FirstDayOfWeek)
WHERE   c1.DayOfWeekName = 'Friday'
AND     c2.Date = CAST(GETDATE() AS DATE);




-- recipe 10.15
WITH cte AS 
(
SELECT  edh.BusinessEntityID,
        c.FirstDayOfMonth
FROM    HumanResources.EmployeeDepartmentHistory AS edh
        JOIN dbo.Calendar AS c
            ON c.Date BETWEEN edh.StartDate
                AND ISNULL(edh.EndDate, GETDATE())
GROUP BY edh.BusinessEntityID,
         c.FirstDayOfMonth
)
SELECT  FirstDayOfMonth,
        COUNT(*) AS EmployeeQty
FROM    cte
GROUP BY FirstDayOfMonth
ORDER BY FirstDayOfMonth;

IF OBJECT_ID('dbo.Calendar') IS NOT NULL DROP TABLE dbo.Calendar;



-- recipe 10.16
SELECT 'sysdatetime' AS ConversionType, 126 AS Style,
       	CONVERT(varchar(30), SYSDATETIME(), 126) AS [Value] UNION ALL
SELECT 'sysdatetime', 127,
       	CONVERT(varchar(30), SYSDATETIME(), 127) UNION ALL
SELECT 'getdate', 126,
       	CONVERT(varchar(30), GETDATE(), 126) UNION ALL
SELECT 'getdate', 127,
       	 CONVERT(varchar(30), GETDATE(), 127);
