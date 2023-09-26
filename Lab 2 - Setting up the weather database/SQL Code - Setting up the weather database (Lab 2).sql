USE weather_db;

-- Read the table 'cat_locations'.
SELECT * FROM cat_locations;

-- Count records in the table #cat_locations# with region description equal to Northern Ireland.
SELECT COUNT(*) FROM cat_locations WHERE region_description = 'Northern Ireland';

-- The region has the highest elevation in the 'cat_locations' table.
SELECT Region, region_description, Elevation FROM cat_locations
ORDER BY Elevation DESC LIMIT 5;

-- Read the table 'metoffice_dailyweatherdata'
SELECT * FROM metoffice_dailyweatherdata;

-- The mean visibility, temperature, windspeed, and humidity on January 4th.
SELECT AVG(visibility), AVG(temperature), AVG(windspeed), AVG(humidity)
FROM metoffice_dailyweatherdata
WHERE obs_date = '2020-01-04';

-- The average temperature per pressuretendency type.
SELECT pressuretendency, AVG(temperature) FROM metoffice_dailyweatherdata
GROUP BY pressuretendency;

-- Count records in the table 'metoffice_dailyweatherdata' where winddirection is null? Why?
SELECT COUNT(*) FROM metoffice_dailyweatherdata
WHERE winddirection IS NULL;
-- In this case, 'NULL' is string for winddirection, not NULL values.
SELECT COUNT(*) FROM metoffice_dailyweatherdata
WHERE winddirection = 'NULL';

-- The average humidity in table 'metoffice_dailyweatherdata' where temperature is between 5 and 10 degrees?
SELECT AVG(humidity) FROM metoffice_dailyweatherdata
WHERE temperature BETWEEN 5 AND 10;

-- Count records in the table 'cat_locations' where both postcode and country are NULL?
SELECT COUNT(*) FROM cat_locations
WHERE Postcode IS NULL AND Country IS NULL;
