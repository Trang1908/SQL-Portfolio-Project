USE weather_db;

-- Read the dataset.
SELECT * FROM metoffice_dailyweatherdata;
SELECT * FROM cat_locations;
SELECT * FROM weathertype;

/* The average humidity and maximum visibility in Baltasound and Fair Isle per day 
using information from metoffice_dailyweatherdata and cat_location. */
SELECT met.obs_date, loc.Location, AVG(met.humidity) Average_humidity, MAX(met.visibility) Max_visibility
FROM metoffice_dailyweatherdata met
INNER JOIN cat_locations loc
ON met.LocationId = loc.LocationID
WHERE loc.Location IN('Baltasound', 'Fair Isle')
GROUP BY met.obs_date, loc.Location;

/*Label the temperature in table metoffice_dailyweatherdata to be "very cold" (temperature<=0), 
"cold" (temperature<=10) or "normal" (temperature>10). */
SELECT temperature,
CASE
	WHEN temperature <= 0 THEN 'very cold'
    WHEN temperature <= 10 THEN 'cold'
    ELSE 'normal'
END temperature_categorical
FROM metoffice_dailyweatherdata;

-- Get the number of daily windy records from table metoffice_dailyweatherdata with windspeed larger than 50.
SELECT obs_date, COUNT(LocationId) Number_daily_windy_records
FROM metoffice_dailyweatherdata
WHERE windspeed > 50
GROUP BY obs_date;

/* Generate daily weather descriptions based on table “weatherType” for each location ID in table “metoffice_dailyweatherdata”. The descriptions should be generated as:
When the weather type is exactly 'Clear night’, 'Sunny day’ or contains '%partly cloudy%’, the weather should be described as OK Weather;
When the weather type contains 'heavy’ or 'snow’, the weather should be described as Bad weather;
When the weather type contains ‘light’ or ‘Drizzle’, the weather should be described as Not that great weather;
All the other weathers should be described as No description
For each location, there should be how many hours last under each description. */
SELECT met.LocationId,
CASE
	WHEN wt.weatherType IN ('Clear night', 'Sunny day') OR wt.weatherType LIKE '%partly cloudy%' THEN 'OK weather'
    WHEN wt.weatherType LIKE '%heavy%' OR  wt.weatherType LIKE '%snow%' THEN 'Bad weather'
    WHEN wt.weatherType LIKE '%light%' OR  wt.weatherType LIKE '%Drizzle%' THEN 'Not that great weather'
    ELSE 'No description'
END Weather_description,
COUNT(DISTINCT(obs_time)) Hours_last
FROM metoffice_dailyweatherdata met
LEFT JOIN weathertype wt
ON met.weatherType = wt.weatherTypeID
GROUP BY met.LocationId, Weather_description;

/* Create windy_records view that shows the number of windy records (windspeed >= 50) per day ordered by the number of windy records. 
Display and then drop the view. */
-- Create windy_records view.
CREATE VIEW windy_records AS
SELECT obs_date, COUNT(LocationId) Number_daily_windy_records
FROM metoffice_dailyweatherdata met
WHERE windspeed >= 50
GROUP BY obs_date
ORDER BY Number_daily_windy_records DESC;

-- Read windy_records view.
SELECT * FROM windy_records;

-- Drop windy_records view.
DROP VIEW windy_records;

/* Using tables metoffice_dailyweatherdata and cat_locations create a view called carlisle_max_temperature 
that contains the max temperature for Carlisle per time of day 
(morning (time <12), afternoon (time>=12 and time <18), evening (time >=18)). 
The resulting view should contain two columns: time_of_day (morning, afternoon, noon), and max_tempreture. */

CREATE VIEW carlisle_max_temperature AS
SELECT
CASE
	WHEN HOUR(met.obs_time) < 12 THEN 'Morning'
    WHEN HOUR(met.obs_time) >= 18 THEN 'Evening'
    ELSE 'Afternoon'
END Time_of_day,
MAX(met.temperature) Max_temperature
FROM metoffice_dailyweatherdata met
INNER JOIN cat_locations loc
ON met.LocationId = loc.LocationID
WHERE loc.Location = 'Carlisle'
GROUP BY Time_of_day;

-- Read carlisle_max_temperature view.
SELECT * FROM carlisle_max_temperature;

/* Based on table metoffice_dailyweatherdata, create a view called high_pressure_percentages that returns how many cases on average we observed pressure above 1020 per day.
Your resulting view should contain obs_date (observation date), and avg_high_pressure. Note that you should work on those pressures which are not null. */
-- Create high_pressure_percentages view.
CREATE VIEW high_pressure_percentages AS 
SELECT obs_date, AVG(IF(pressure > 1020, 1, 0)) avg_high_pressure
FROM metoffice_dailyweatherdata
WHERE pressure IS NOT NULL
GROUP BY obs_date;

-- Read high_pressure_percentages view.
SELECT * FROM high_pressure_percentages;

-- Drop high_pressure_percentages view.
DROP VIEW high_pressure_percentages

/* Create a view called rainy_snowy that for each station returns a 0/1 flag if there was at least one rainy hour gives 1 otherwise 0; 
and one similar 0/1 flag if there was at least one snowy hour gives 1 otherwise 0.
You need to use table metoffice_dailyweatherdata and weatherType. The resulting view should contain three columns: locationID, at_least_one_rainy_hour, and at_least_one_snowy_hour. */
-- Create rainy_snowy view.
CREATE VIEW rainy_snowy AS
SELECT met.LocationId,
MAX(IF(wt.weatherType LIKE '%rain%', 1, 0)) at_least_one_rainy_hour,
MAX(IF(wt.weatherType LIKE '%snow%', 1, 0))  at_least_one_snowy_hour 
FROM metoffice_dailyweatherdata met
INNER JOIN weatherType wt
	ON met.weatherType = wt.weatherTypeID
GROUP BY met.LocationId;

-- Read rainy_snowy view.
SELECT * FROM rainy_snowy;

/* Create a view called snow_weather_station_counts which counts the number of weather stations that had at least one snowy hour vs none. 
You need to work on the rainy_snowy view created before. The resulting view should contain two columns snow_counts and number_of_locations. */
-- Create snow_weather_station_counts view.
CREATE VIEW snow_weather_station_counts AS
SELECT 
CASE
	WHEN at_least_one_snowy_hour = 1 THEN 'At least one snowy hour'
    ELSE 'No snowy hour'
END snow_counts,
COUNT(DISTINCT(LocationId)) number_of_locations
FROM rainy_snowy
GROUP BY snow_counts;

-- Read snow_weather_station_counts view.
SELECT * FROM snow_weather_station_counts;

/* Create a view known as rain_or_snow_weather_station that can:
Give the weather categories based on weather rainy or snowy.
If there is no snowy or rainy hours the weather category should be set as 'No rain or snow'.
Otherwise, the weather category should be set as 'Either rain or snow'.
For each weather category, count the number of weather stations. 
Please working on the rainy_snowy view. The resulting view should contain two columns: 'weather_categorisation' and 'number_of_stations'. */
-- Create rain_or_snow_weather_station view.
CREATE VIEW rain_or_snow_weather_station AS
SELECT 
CASE
	WHEN at_least_one_rainy_hour = 0 AND at_least_one_snowy_hour = 0 THEN 'No rain or snow'
    ELSE 'Either rain or snow'
END weather_categorisation,
COUNT(DISTINCT(LocationId)) number_of_stations
FROM rainy_snowy
GROUP BY weather_categorisation;

-- Read rain_or_snow_weather_station view.
SELECT * FROM rain_or_snow_weather_station;