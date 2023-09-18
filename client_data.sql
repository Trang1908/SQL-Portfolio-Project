-- Create a table called 'client_data'.
CREATE TABLE client_data (
ID INT NOT NULL PRIMARY KEY,
First_name VARCHAR(40) NOT NULL,
Last_name VARCHAR(40) NOT NULL,
Nationality VARCHAR(40),
Age FLOAT CHECK (Age > 18)
);

-- Insert records in the data base.
INSERT INTO client_data
VALUES
(1, 'John', 'S', 'British', NULL),
(2, 'Peter', 'Jackson', NULL, 20),
(3, 'Tom', 'W', NULL, 20),
(4, 'Jack', 'Patrick', 'American', 30);

-- Read the data set.
SELECT * FROM client_data

-- Add a column called 'type'  and fill the records of this column with the value '1' for the records 
-- where nationality is known, and '2' otherwise.
ALTER TABLE client_data
ADD Type INT;

UPDATE client_data
SET Type = CASE
	WHEN Nationality IS NOT NULL THEN 1
	ELSE 2
END;

-- Delete the records of the table 'client_data' where the last name is unknown.
DELETE FROM client_data
WHERE Last_name IS NULL;

-- Delete all the content from the column 'Age' without deleting the column from the schema.
UPDATE client_data
SET Age = NULL;

-- Delete table 'client_data' including the schema.
DROP TABLE client_data;