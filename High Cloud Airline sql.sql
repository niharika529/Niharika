use highcloudairlines;
show tables;
select * from maindata;
describe maindata;


-- "1.calcuate the following fields from the Year	Month (#)	Day  fields ( First Create a Date Field from Year , Month , Day fields)"
--   A.Year
--   B.Monthno
--   C.Monthfullname
--   D.Quarter(Q1,Q2,Q3,Q4)
--   E. YearMonth ( YYYY-MMM)
--   F. Weekdayno
--   G.Weekdayname
--   H.FinancialMOnth
--   I. Financial Quarter 

create table Calender (
`date_column` DATE NOT NULL,
year int,
month int,
day int,
week int,
monthname varchar(50),
weekday int,
yearmonth varchar(50),
dayname varchar(50),
Quarters varchar(50),
Financial_Months varchar(50),
Financial_Quarter varchar(50));

INSERT INTO calendar (`Date`)
SELECT STR_TO_DATE(CONCAT(day, '-', `Month (#)`, '-', year), '%d-%m-%Y') AS date
FROM maindata;

ALTER TABLE maindata
ADD COLUMN Date date;

SET SQL_SAFE_UPDATES = 0;

UPDATE maindata
SET `Date` = STR_TO_DATE(CONCAT(day, '-', `Month (#)`, '-', year), '%d-%m-%Y');

SELECT * FROM calender;
alter table calender 
rename column date_column to Date;

insert into Calender (Date, year,month,day,week,monthname,weekday,yearmonth,dayname,Quarters,Financial_Months,Financial_Quarter)
select
Date as Date,
year(Date) as year,
month(Date) as month,
day(Date) as day,
week(Date) as week,
monthname(Date) as monthname,
dayofweek(Date) as weekday,
concat(year(Date),'-',monthname(Date))as yearmonth,
dayname(Date) as dayname,

case
when monthname(Date) in ('January','February','March') then 'Q1'
when monthname(Date) in ('April','May','june') then 'Q2'
when monthname(Date) in ('July','August','September') then 'Q3'
else 'Q4' end as Quarters,

case
when monthname(Date)='January' then 'FM10'
when monthname(Date)='February' then 'FM11'
when monthname(Date)='March' then 'FM12'
when monthname(Date)='April' then 'FM1'
when monthname(Date)='May' then 'FM2'
when monthname(Date)='June' then 'FM3'
when monthname(Date)='July' then 'FM4'
when monthname(Date)='August' then 'FM5'
when monthname(Date)='September' then 'FM6'
when monthname(Date)='October' then 'FM7'
when monthname(Date)='November' then 'FM8'
when monthname(Date)='December' then 'FM9'
end as Financial_months,

case 
when monthname(Date) in ('January','February','March') then 'FQ4'
when monthname(Date) in ('April','May','june') then 'FQ1'
when monthname(Date) in ('July','August','September') then 'FQ2'
else 'FQ3' end as Financial_Quarter

from maindata;

select * from calender;

-- 2. Find the load Factor percentage on a yearly , Quarterly , Monthly basis ( Transported passengers / Available seats)
SELECT YEAR(date) AS Year, 
       ROUND(SUM(`# Transported Passengers`) / SUM(`# Available Seats`) * 100, 2) AS Load_Factor
FROM maindata
WHERE YEAR(date) IS NOT NULL
GROUP BY YEAR(date);

SELECT CONCAT('Q', QUARTER(date)) AS Quarter, 
       ROUND(SUM(`# Transported Passengers`) / SUM(`# Available Seats`) * 100, 2) AS Load_Factor
FROM maindata
WHERE QUARTER(date) IS NOT NULL
GROUP BY CONCAT('Q', QUARTER(date))
ORDER BY CONCAT('Q', QUARTER(date));

SELECT MonthName, Load_Factor 
FROM (
    SELECT MONTHNAME(date) AS MonthName, 
           MONTH(date) AS MonthNumber, 
           ROUND(SUM(`# Transported Passengers`) / SUM(`# Available Seats`) * 100, 2) AS Load_Factor
    FROM maindata
    WHERE MONTHNAME(date) IS NOT NULL
    GROUP BY MONTHNAME(date), MONTH(date)
    ORDER BY MONTH(date)
) AS subquery;


-- 3. Find the load Factor percentage on a Carrier Name basis ( Transported passengers / Available seats)
select `Carrier Name`,sum(`# Transported Passengers`),sum(`# Available Seats`),
(sum(`# Transported Passengers`)/sum(`# Available Seats`)*100)
as "Load_Factor" from maindata group by `Carrier Name` order by load_factor desc;

-- 4. Identify Top 10 Carrier Names based passengers preference 
select `Carrier Name`,sum(`# Transported Passengers`) as "Top_10_Carrier_names_based_on_passenger"
from maindata group by `Carrier Name` order by sum(`# Transported Passengers`) desc limit 10;

-- 5. Display top Routes ( from-to City) based on Number of Flights 
select `From - To City`,count(`From - To City`) as "Number_of_flight" from maindata
group by `From - To City` order by count(`From - To City`) desc limit 10;

-- 6. Identify the how much load factor is occupied on Weekend vs Weekdays.
SELECT 
    CASE 
        WHEN DAYOFWEEK(date) IN (1, 7) THEN 'Weekend' 
        ELSE 'Weekday' 
    END AS DayType, 
    ROUND(SUM(`# Transported Passengers`) / SUM(`# Available Seats`) * 100, 2) AS Load_Factor
FROM maindata
GROUP BY DayType;

-- 7. Identify number of flights based on Distance group
SELECT d.`Distance Interval`, COUNT(distance) AS Total_Distance 
FROM maindata m
JOIN `distance groups` d
ON m.`%Distance Group ID` = d.`%Distance Group ID`
GROUP BY d.`Distance Interval`
ORDER BY Total_Distance DESC;




