USE weather_db;

-- Read dataset.
SELECT * FROM metoffice_dailyweatherdata;
SELECT * FROM metoffice_forecast_text;
SELECT * FROM timezone;
SELECT * FROM zones;
SELECT * FROM cat_locations;

-- Working on the table metoffice_dailyweatherdata, picking out those records with the temperature beyond the range of [-1, 11].
SELECT *
FROM metoffice_dailyweatherdata
WHERE temperature NOT BETWEEN -1 AND 11 LIMIT 10;

-- Working on the table metoffice_forecast_text, return all the records with an added column check_for_digits. The new column check_for_digits returns an 0, 1 flag for whether the text in the 'forecastText' contains one or more digits.
ALTER TABLE metoffice_forecast_text
ADD check_for_digits INT;

UPDATE metoffice_forecast_text
SET check_for_digits = 
CASE
	WHEN forecastText REGEXP '[0-9]' THEN 1
    ELSE 0
END;

/* Working on the metoffice_dailyweatherdata. Return a resulting table with two columns: one column contains all the windspeed, 
another one known as max_wind contains the maximum windspeed computed from this table. */
SELECT windspeed, (SELECT MAX(windspeed) FROM metoffice_dailyweatherdata) max_wind
FROM metoffice_dailyweatherdata LIMIT 10;

/* Working on the table metoffice_dailyweatherdata. For each locationID, compute the maximum temperature (max_temperature). 
Based on this result, filtering those locationIDs and maximum temperatures with max_temperature larger than 10. */
SELECT t1.LocationId, t1.max_temperature FROM
(SELECT LocationId, MAX(temperature) max_temperature
FROM metoffice_dailyweatherdata
GROUP BY LocationId) t1
WHERE t1.max_temperature > 10 LIMIT 10;

-- Working on tables zones and timezone. Picking out records from zones whose zone_id are within the range of unique zone_id numbers in table timezone.
SELECT * FROM zones
INNER JOIN (SELECT DISTINCT(zone_id)
FROM timezone) t1
	ON zones.zone_id = t1.zone_id
LIMIT 10;

-- Working on the table “cat_locations”. Picking out all the records with “Latitude” smaller than those records with location to be “London”.
SELECT *
FROM cat_locations
WHERE Latitude < (SELECT Latitude
FROM cat_locations 
WHERE Location = 'London')
LIMIT 10;

/* Working on the table "zones". Find out those zone names (zone_name) which contain more than two details (delimited by /). 
Examples records: America/Indiana/Marengo. */
SELECT zone_name FROM 
(SELECT zone_name, zone_name REGEXP '^[_a-zA-Z]+/[_a-zA-Z]+/' Checking
FROM zones) t1
WHERE Checking = 1;

-- Working on the table “metoffice_dailyweatherdata”. Return one column which computes the difference between temperature and the average temperature (temperature minus the average temperature). */
SELECT temperature - (SELECT AVG(temperature) FROM metoffice_dailyweatherdata) difference_temperature
FROM metoffice_dailyweatherdata;