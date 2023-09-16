-- Reviewing the data
SELECT *
FROM bus_data_2021_2022

-- Adding a total rides column
CREATE VIEW [bus_data] AS
SELECT *, COALESCE(eibizua,0) + COALESCE(hakdama,0) + COALESCE(eihurim,0) + COALESCE(takin,0) AS total_rides
FROM bus_data_2021_2022


SELECT *
FROM bus_data

-- Looking for five biggest operators with the most rides in 2021-2022:
-- Eged, Kavim, Dan, Metropolin and Electra Afikim are the biggest bus operators in Israel
SELECT operator_nm, 
		SUM(total_rides) AS total_rides_per_operator
FROM bus_data
GROUP BY operator_nm
ORDER BY total_rides_per_operator DESC
OFFSET 0 ROWS FETCH FIRST 5 ROWS ONLY

-- Number and percentage of cancellations for each operator every year:
-- There's a trend that shows higher number of cancellation in 2022 compared to 2021 while having lower total number of rides
SELECT trip_year, 
		operator_nm, 
		SUM(eibizua) AS num_of_cancellations, 
		SUM(total_rides) AS total_rides_per_operator, 
        SUM(eibizua) / SUM(total_rides) * 100 AS percentage_of_cancellations
FROM bus_data
GROUP BY trip_year, operator_nm
ORDER BY operator_nm, num_of_cancellations DESC

--Comparing the total number of cancellations and total number of rides in 2021 and 2022:
-- Precentage of cancellation has increased more than 1% 
-- meaning more cancellations while there are less rides in total
SELECT trip_year, 
       SUM(eibizua) AS num_cancellations, 
	   SUM(total_rides) AS total_rides,
	   SUM(eibizua) / SUM(total_rides) * 100 AS Percentage_of_cancellations
FROM bus_data
GROUP BY trip_year
ORDER BY trip_year DESC

-- Five operators with highest percentage of cancellation through 2021-2022
SELECT operator_nm,
       SUM(eibizua) AS num_of_cancellations,
	  (SUM(eibizua) / SUM(total_rides)) * 100 AS percentage_of_cancellations
FROM bus_data
GROUP BY operator_nm
ORDER BY percentage_of_cancellations DESC
OFFSET 0 ROWS FETCH FIRST 5 ROWS ONLY

-- The percentage of cancellation through 2021-2022 of the biggest five operators we found earlier:
-- All five biggest bus operators had bigger percentage of cancellations in 2022 compared to 2021,
-- while having lower number of total rides in 2022
SELECT operator_nm,
	   trip_year,
       SUM(eibizua) AS num_of_cancellations,
	   SUM(total_rides) AS num_of_total_rides,
	   SUM(eibizua) / SUM(total_rides) * 100 AS percentage_of_cancellations
FROM bus_data
WHERE operator_nm IN ('eged', 'kavim', 'dan', 'metropolin', 'electra_Afikim')
GROUP BY operator_nm, trip_year
ORDER BY operator_nm, trip_year DESC

-- Comparing 2021 and 2022 number and percentage of abnormal rides:
-- (abnormal rides is referring to a ride not occurring, late or early)
-- More evidence showing that the percentage of abnormal rides had increased in 2022 compared to 2021,
-- while the total number of rides had decreased
SELECT trip_year,
       SUM(COALESCE(eibizua,0) + COALESCE(hakdama,0) + COALESCE(eihurim,0)) AS num_of_abnormal_rides,
	   SUM(takin) AS num_of_normal_rides,
	   SUM(total_rides) AS num_of_total_rides,
	   SUM(COALESCE(eibizua,0) + COALESCE(hakdama,0) + COALESCE(eihurim,0)) / SUM(total_rides)*100 AS percentage_of_abnormal_rides,
	   SUM(COALESCE(takin,0)) / SUM(total_rides) * 100 AS percentage_of_normal_rides
FROM bus_data
GROUP BY trip_year
ORDER BY trip_year DESC

-- Comparison of abnormalities in bus rides during winter and summer:
-- Determining winter and summer according to when we change to summer and winter clock
-- Winter months:  October, November, December, January, February, March
-- Summer months: April, May, June, July, August, September
-- No major differences are found
SELECT CASE
       WHEN trip_month IN (10,11,12,1,2,3) THEN 'winter'
	   ELSE 'summer'
	END AS season,
	   SUM(COALESCE(eibizua,0) + COALESCE(hakdama,0) + COALESCE(eihurim,0)) AS num_of_abnormal_rides,
	   SUM(takin) AS num_of_normal_rides,
	   SUM(total_rides) AS num_of_total_rides,
	   SUM(COALESCE(eibizua,0) + COALESCE(hakdama,0) + COALESCE(eihurim,0)) / SUM(total_rides)*100 AS percentage_of_abnormal_rides,
	   SUM(COALESCE(takin,0)) / SUM(total_rides) * 100 AS percentage_of_normal_rides
FROM bus_data
GROUP BY CASE
       WHEN trip_month IN (10,11,12,1,2,3) THEN 'winter'
	   ELSE 'summer'
	   END