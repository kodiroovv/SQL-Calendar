
IF OBJECT_ID('dbo.CALENDAR', 'U') IS NOT NULL
DROP TABLE dbo.CALENDAR;
CREATE  TABLE CALENDAR (calendar_date date)


DECLARE @startdate varchar(100), @enddate varchar(100)
SET @enddate= FORMAT(GETDATE(),'MM-dd-yyyy')
SET @startdate = FORMAT(DATEADD(MONTH, -3, GETDATE()),'MM-dd-yyyy')
SET @startdate = FORMAT(DATEADD(MONTH, DATEDIFF(MONTH,0,@startdate),0),'MM-dd-yyyy')
--SELECT  @startdate, @enddate

WHILE @startdate <= @enddate 
	BEGIN 	
	INSERT INTO CALENDAR VALUES(@startdate)
	SET @startdate = FORMAT(DATEADD(day,1,@startdate),'MM-dd-yyyy')
	END
--SELECT  @startdate, @enddate
--SELECT * FROM CALENDAR
;WITH C AS
(
SELECT calendar_date,
	   YEAR(calendar_date)  AS YEAR, 
	   MONTH(calendar_date) AS MONTH, 
	   DATENAME(MONTH, calendar_date) AS MONTHNAME,
	   DATENAME(ISOWK, calendar_date) AS ISOWK,
	   DATENAME(WEEKDAY, calendar_date) AS WKDAY,
	   DAY(calendar_date)   AS DAY
FROM CALENDAR
), 
CALENDAR AS 
(
	SELECT MONTHNAME, ISOWK, [Monday],[Tuesday],[Wednesday],[Thursday],[Friday],[Saturday],[Sunday]
	FROM  
	(
	 SELECT  MONTHNAME, ISOWK , WKDAY, DAY
	 FROM C
		) AS SourceTable  
	 PIVOT  
	(  
	  MAX(DAY) 
	  FOR WKDAY IN ([Monday],[Tuesday],[Wednesday],[Thursday],[Friday],[Saturday],[Sunday])  
	) AS PivotTable
),
CALENDAR_FINAL AS
(
SELECT MONTHNAME, 
	   IsNull(Format([Monday]    ,'##'),' ') as [Monday],   
	   IsNull(Format([Tuesday]   ,'##'),' ') as [Tuesday],  
	   IsNull(Format([Wednesday] ,'##'),' ') as [Wednesday],
	   IsNull(Format([Thursday]  ,'##'),' ') as [Thursday], 
	   IsNull(Format([Friday]    ,'##'),' ') as [Friday],   
	   IsNull(Format([Saturday]  ,'##'),' ') as [Saturday],
	   IsNull(Format([Sunday]    ,'##'),' ') as [Sunday],   
	   ROW_NUMBER() OVER(ORDER BY ISOWK,MONTHNAME DESC) AS RW
FROM CALENDAR 
)
SELECT MONTHNAME
	   [Monday],[Tuesday],[Wednesday],[Thursday],[Friday],[Saturday],[Sunday]
FROM CALENDAR_FINAL
-- WHERE MONTHNAME = DATENAME(MONTH, DATEADD(MONTH, -1, GETDATE()))
	/* IF YOU WANT TO SEE LASTMONTHS CALENDAR YOU CAN UNCOMMENT ROW ABOVE */
ORDER BY RW

