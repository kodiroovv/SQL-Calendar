# SQL-Calendar
This dynamic Calendar: Which shows last 3 months from today.

/* 
  This Part of the code is used declaring values to start and enddates.
  Startdate takes values getdate() - 3 months from firstday of the month.
  Enddate takes todays date
  
  Dates formatted 'MM-dd-yyyy' format - (MONTH-DAY-YEAR)
*/

DECLARE @startdate varchar(100), @enddate varchar(100)
SET @enddate= FORMAT(GETDATE(),'MM-dd-yyyy')
SET @startdate = FORMAT(DATEADD(MONTH, -3, GETDATE()),'MM-dd-yyyy')
SET @startdate = FORMAT(DATEADD(MONTH, DATEDIFF(MONTH,0,@startdate),0),'MM-dd-yyyy')
SELECT  @startdate, @enddate

/*
  In this part of the code used while loop function to generate dates 
  between start and end dates and inserted them Calendar Table
*/

WHILE @startdate <= @enddate 
	BEGIN 	
	INSERT INTO CALENDAR VALUES(@startdate)
	SET @startdate = FORMAT(DATEADD(day,1,@startdate),'MM-dd-yyyy')
	END
  
/*
  ;WITH common table expression (CTE) is the final step of puzzle.
  CTE is used in order to make format values and making them view of
  real life calendar. 
    There is used: Pivot relational operator, Different kinds of date formatters,
    ISNULL and ROW_NUMBER().
  
*/


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

