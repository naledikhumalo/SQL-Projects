/*
Cleaning Data in SQL Queries
*/

SELECT *
FROM HousingData

-------------------------------------------------------------------------------------------------------------------
                                  -- Standardize Data Format

SELECT SaleDate, CONVERT(DATE,SaleDate)
FROM HousingData  

ALTER TABLE HousingData
ADD SaleDateConverted DATE;

UPDATE HousingData
SET SaleDateConverted = CONVERT(DATE,SaleDate) 

-------------------------------------------------------------------------------------------------------------------
                                   -- Populate Property Address Data

SELECT PropertyAddress
FROM HousingData
WHERE PropertyAddress is NUll


SELECT a.UniqueID, a.ParcelID, a.PropertyAddress, b.UniqueID, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM HousingData a
JOIN HousingData b
ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is NULL


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM HousingData a
JOIN HousingData b
ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is NULL

-------------------------------------------------------------------------------------------------------------------
                                   --Breaking PropertyAddress into Individual Columns

SELECT PropertyAddress
FROM HousingData

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
       SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS City
FROM HousingData

ALTER TABLE HousingData                           -- adding new address column
ADD NewPropertyAddress NVARCHAR(100)

UPDATE HousingData                                
SET NewPropertyAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE HousingData                          -- adding new city column
ADD NewPropertyCity NVARCHAR(100)

Update HousingData
SET NewPropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

-- Breaking OwnerAddress
SELECT OwnerAddress
FROM HousingData

SELECT PARSENAME(REPLACE(OwnerAddress, ',','.'), 3),
       PARSENAME(REPLACE(OwnerAddress, ',','.'), 2),
       PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
FROM HousingData

ALTER TABLE HousingData             -- Adding new owner address column
ADD NewOwnerAddress NVARCHAR(100)

Update HousingData
SET NewOwnerAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)

ALTER TABLE HousingData             -- Adding new owner city column
ADD NewOwnerCity NVARCHAR(100)

Update HousingData
SET NewOwnerCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)

ALTER TABLE HousingData              -- Adding new owner state column
ADD NewOwnerState NVARCHAR(100)

Update HousingData
SET NewOwnerState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)

------------------------------------------------------------------------------------------------------------------- 
                                  -- Change Y and N to Yes and No in "Sold as Vacant" field

 SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
 FROM HousingData
 GROUP BY SoldAsVacant
 

 SELECT SoldAsVacant,
 CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
      WHEN SoldAsVacant = 'N' THEN 'NO'
	  ELSE SoldAsVacant
	  END
FROM HousingData

UPDATE HousingData
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
      WHEN SoldAsVacant = 'N' THEN 'NO'
	  ELSE SoldAsVacant
	  END

-------------------------------------------------------------------------------------------------------------------
                                    -- Remove Duplicates

WITH RowNumCTE AS(        -- checking for duplicates
SELECT *,
      ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) row_num
FROM HousingData
)
SELECT *
FROM RowNumCTE
WHERE row_num> 1
ORDER BY PropertyAddress

WITH RowNumCTE AS(        --  deleting duplicates
SELECT *,
      ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) row_num
FROM HousingData
)
DELETE
FROM RowNumCTE
WHERE row_num> 1

-------------------------------------------------------------------------------------------------------------------
                                    -- Delete Unused Columns

ALTER TABLE HousingData
DROP COLUMN OwnerAddress, PropertyAddress

ALTER TABLE HousingData
DROP COLUMN SaleDate

SELECT *
FROM HousingData

-------------------------------------------------------------------------------------------------------------------



