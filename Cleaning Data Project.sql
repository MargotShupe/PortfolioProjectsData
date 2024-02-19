--Nashville Data Cleaning 
/* Cleaning Data */

SELECT * 
FROM PortfolioProject..['Nashville HData$']

/* Standarize Date Format */

SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM PortfolioProject..['Nashville HData$']

UPDATE ['Nashville HData$']
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE ['Nashville HData$']
ADD SaleDateConverted Date;

UPDATE ['Nashville HData$']
SET SaleDateConverted = CONVERT(Date,SaleDate)

/* Pupulate Property Address data */

SELECT *
FROM PortfolioProject..['Nashville HData$']
-- WHERE PropertyAddress IS NULL
ORDER BY ParcelID

-- We need to create a self join 
CREATING THE SELF JOIN 
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject..['Nashville HData$'] a
JOIN PortfolioProject..['Nashville HData$'] b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject..['Nashville HData$'] a
JOIN PortfolioProject..['Nashville HData$'] b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL













/* Breaking out Address into individual columns (Address, City, State) */

SELECT PropertyAddress
FROM PortfolioProject..['Nashville HData$']
-- WHERE PropertyAddress IS NULL
--ORDER BY ParcelID






The comma is a delimiter that helps us separate values 


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN (PropertyAddress)) AS Address

FROM PortfolioProject..['Nashville HData$']


To add new columns to our table we need to first alter the table and the set the values


ALTER TABLE ['Nashville HData$']
ADD PropertySplitAddress NVARCHAR(255);

UPDATE ['Nashville HData$']
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) 


ALTER TABLE ['Nashville HData$']
ADD PropertySplitCity NVARCHAR(255);

UPDATE ['Nashville HData$']
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN (PropertyAddress)) 


Now we need to split our  Owner address information 
PARSENAME do things backwards so 3 is satate, 2 is city and 1 is street 
SELECT *
FROM PortfolioProject..['Nashville HData$']


SELECT OwnerAddress
FROM PortfolioProject..['Nashville HData$']

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject..['Nashville HData$']


ALTER TABLE ['Nashville HData$']
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE ['Nashville HData$']
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


ALTER TABLE ['Nashville HData$']
ADD OwnerSplitCity NVARCHAR(255);

UPDATE ['Nashville HData$']
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


ALTER TABLE ['Nashville HData$']
ADD OwnerSplitState NVARCHAR(255);

UPDATE ['Nashville HData$']
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


/*SELECT *
FROM PortfolioProject..['Nashville HData$'] All this SELECT are to run and confirmed all the changes we made were done, we don't need it in our final project 
*/ 

-- Change Y and N to Yes and No in "Sold as Vacant" field Removing duplicates
DISTINT to see if the property is sold or not 
Then we use the CASE statement to only have either yes or no 

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..['Nashville HData$']
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END
FROM PortfolioProject..['Nashville HData$']


UPDATE ['Nashville HData$']
SET SoldAsVacant = 
	CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END









-- Remove Duplicates .. The partition has to be on things that are unique in each row 
By using a CTE
ROW_NUMBER and OVER to do the partition in unique rows, all this query has to be run together.

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice, 
				 SaleDate,
				 LegalReference
	ORDER BY 
			UniqueID) row_num
FROM PortfolioProject..['Nashville HData$']
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress

SELECT *
FROM PortfolioProject..['Nashville HData$']





-- Delete Unused Columns


SELECT *
FROM PortfolioProject..['Nashville HData$']

ALTER TABLE PortfolioProject..['Nashville HData$']
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject..['Nashville HData$']
DROP COLUMN SaleDate
