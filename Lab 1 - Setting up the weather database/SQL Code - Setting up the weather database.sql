-- Read data set.
SELECT * FROM cat_locations;

-- Fill records where the country column is null with the value "UK".
-- Display the first 5 records with Country IS NULL.
SELECT * FROM cat_locations WHERE Country IS NULL LIMIT 5;
-- Change them
UPDATE cat_locations SET Country = 'UK' WHERE Country IS NULL;
-- Check any NULL values in Country
SELECT * FROM cat_locations WHERE country IS NULL;

-- Delete the rows from table tempW where rainfall is null
-- Display the records with rainfall IS NULL.
SELECT * FROM tempw WHERE rainfall IS NULL;
-- Delete them.
DELETE FROM tempw WHERE rainfall IS NULL;

-- From this table also delete the timestamp column from the schema.
ALTER TABLE tempw DROP timestamp;