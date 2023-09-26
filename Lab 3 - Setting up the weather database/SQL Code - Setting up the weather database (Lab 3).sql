USE weather_db;

-- Extract data from multiple sources.
SELECT 
	cat.RegionCode, 
    cat.Region,
    co.country_code,
    co.country_name
FROM 
	cat_regions AS cat, 
    country AS co;
    
-- LEFT JOIN Statement.
SELECT
	met.LocationId,
    loc.Location,
    loc.region_description,
    met.temperature,
    met.windspeed
FROM
	metoffice_dailyweatherdata AS met
LEFT JOIN 
	cat_locations AS loc
ON 
	met.LocationId = loc.LocationID;

-- LEFT JOIN Statement with NULL values.
SELECT
	met.LocationId,
    loc.Location,
    loc.region_description,
    met.temperature,
    met.windspeed
FROM
	metoffice_dailyweatherdata AS met
LEFT JOIN 
	cat_locations AS loc
ON 
	met.LocationId = loc.LocationID
WHERE loc.Location IS NULL;

-- INNER JOIN statement.
-- Return a table with the common LocationIDs.
SELECT 
	met.LocationID,
	loc.Location,
	loc.region_description,
	met.temperature,
	met.Windspeed
FROM
	metoffice_dailyweatherdata AS met
INNER JOIN
	cat_locations AS loc
ON met.LocationId = loc.LocationID;

-- Read the table 'cat_locations'.
SELECT * FROM cat_locations;

-- Read the table 'metoffice_dailyweatherdata'.
SELECT * FROM metoffice_dailyweatherdata;

-- Create a new column in the table 'cat_locations' with the name "NewDayIce". 
ALTER TABLE cat_locations
ADD NewDayIce INT;

-- For each location, the column NewDayIce should take the value 1 if the temperature was below zero when the new year changed (2020-01-01 00:00:00), 0 otherwise.
UPDATE cat_locations
SET NewDayIce = (
	SELECT IF(met.temperature < 0, 1, 0)
	FROM metoffice_dailyweatherdata AS met
	WHERE met.LocationId = cat_locations.LocationID
		AND met.obs_dateTime = '2020-01-01 00:00:00');
        
-- Return a ranked list with all location names and the average visibility.
SELECT 
	loc.Location,
	AVG(met.visibility) AS avg_visibility
FROM metoffice_dailyweatherdata AS met
INNER JOIN cat_locations AS loc
	ON met.LocationId = loc.LocationID
    GROUP BY loc.Location
	ORDER BY avg_visibility DESC;
    
-- -- Read the table 'cat_locations'.
SELECT * FROM weathertype;

-- Return all 'weatherType' distinct values of the table metoffice_dailyweatherdata.
SELECT DISTINCT(weatherType)
FROM metoffice_dailyweatherdata;

-- Return all weather data for the cases when it was foggy.
SELECT *
FROM metoffice_dailyweatherdata AS met
LEFT JOIN weathertype AS wt
	ON met.weatherType = wt.weatherTypeID
WHERE wt.weatherType = 'Fog';

-- Return the average humidity for locations 'Baltasound', 'Lerwick (S. Screen)', 'Fair Isle'.
SELECT 
	loc.Location,
	AVG(met.humidity) avg_humidity
FROM metoffice_dailyweatherdata met
INNER JOIN cat_locations loc
	ON met.locationId = loc.LocationID
WHERE loc.Location IN ('Baltasound', 'Lerwick (S. Screen)', 'Fair Isle')
GROUP BY loc.Location
ORDER BY avg_humidity DESC;

-- For the above locations, return all different weather types.
SELECT
	DISTINCT(wt.weatherType)
FROM metoffice_dailyweatherdata met
INNER JOIN cat_locations loc
	ON met.locationId = loc.LocationID
LEFT JOIN weathertype wt
	ON met.weatherType = wt.weatherTypeID
WHERE loc.Location IN ('Baltasound', 'Lerwick (S. Screen)', 'Fair Isle');

-- For each weather type, return the number of distinct locations, that this weather type occurred.
 SELECT
	DISTINCT(wt.weatherType),
    COUNT(DISTINCT(loc.Location)) count_distinct_locations
FROM metoffice_dailyweatherdata met
INNER JOIN cat_locations loc
	ON met.locationId = loc.LocationID
LEFT JOIN weathertype wt
	ON met.weatherType = wt.weatherTypeID
GROUP BY wt.weatherType
ORDER BY count_distinct_locations DESC;
    

 


