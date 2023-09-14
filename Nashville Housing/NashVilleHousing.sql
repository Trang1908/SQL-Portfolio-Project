--- Read the dataset
SELECT *
FROM NashVilleHousing;


--------------------------------
--- Standardise DATE format of column 'SaleDate'

--- Create a new column named 'SaleDateConverted' 
ALTER TABLE NashVilleHousing
ADD SaleDateConverted DATE;

UPDATE NashVilleHousing
SET SaleDateConverted = CONVERT(DATE, SaleDate);

--- Delete unused column 'SaleDate'
ALTER TABLE NashVilleHousing
DROP COLUMN SaleDate;


--------------------------------
--- Populate the PropertyAddress data

--- Check any relationship between 'ParcelID' and 'PropertyAddress'
SELECT *
FROM NashVilleHousing
ORDER BY ParcelID;

--- Check any NULL values of column 'PropertyAddress'
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,
ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashVilleHousing a
INNER JOIN NashVilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashVilleHousing a
INNER JOIN NashVilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;


--------------------------------
--- Break column 'PropertyAddress' into individual columns (Address and City)

ALTER TABLE NashVilleHousing
ADD PropertyAddressSplit VARCHAR(123);

UPDATE NashVilleHousing
SET PropertyAddressSplit = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1);

ALTER TABLE NashVilleHousing
ADD PropertyCity VARCHAR(123);

UPDATE NashVilleHousing
SET PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1,
LEN(PropertyAddress));


--------------------------------------
--- Break column 'OwnerAddress' into individual columns (Address, City, and State)
ALTER TABLE NashVilleHousing
ADD OwnerAddressSplit VARCHAR(123),
OwnerCity VARCHAR(123),
OwnerState VARCHAR(123);

UPDATE NashVilleHousing
SET OwnerAddressSplit = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

--- Drop unused column 'OwnerAddress'
ALTER TABLE NashVilleHousing
DROP COLUMN OwnerAddress;


-------------------------------------------
--- Check distinct values of column 'SoldAsVacant'
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashVilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;

--- Change 'Y' and 'N' values into 'Yes' and 'No' in 'SoldAsVacant' column
SELECT SoldAsVacant,
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END
FROM NashVilleHousing;

UPDATE NashVilleHousing
SET SoldAsVacant = 
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END;


-------------------------------------------------
--- Remove duplicates
WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID,
			 PropertyAddress,
			 LegalReference,
			 SaleDateConverted
			 ORDER BY
				UniqueID
				) row_num
FROM NashVilleHousing
)
--DELETE
--FROM RowNumCTE
--WHERE row_num > 1
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;
