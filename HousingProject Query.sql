-- Cleaning Data in SQL Queries

USE PortfolioProject

SELECT PropertyAddress FROM NashvilleHousing
--ORDER BY ParcelID


--Standardize Date Format

SELECT SaleDateConverted, CONVERT(DATE,SaleDate) AS SaleDate
FROM NashvilleHousing


--UPDATE NashvilleHousing
--SET SaleDate = CONVERT(DATE,SaleDate)


ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(DATE,SaleDate);


--------------------------------------------------------------------------------------------



--Populate Property Address data



SELECT * 
FROM NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) 
FROM NashvilleHousing a
JOIN NashvilleHousing b 
ON a.ParcelID=b.ParcelID
AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b 
ON a.ParcelID=b.ParcelID
AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress IS NULL



-------------------------------------------------------------------------------------------------

--Breaking out Address into individual Columns (Address, City, State)



SELECT PropertyAddress
FROM NashvilleHousing
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID


SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,  
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS Address
FROM NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255)

UPDATE NashvilleHousing
SET PropertySplitCity= SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


SELECT *
FROM NashvilleHousing



SELECT OwnerAddress
FROM NashvilleHousing


SELECT
PARSENAME(REPLACE(OwnerAddress,',', '.'), 3) Address,
PARSENAME(REPLACE(OwnerAddress,',', '.'), 2) City,
PARSENAME(REPLACE(OwnerAddress,',', '.'), 1) State
FROM NashvilleHousing;



ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress=PARSENAME(REPLACE(OwnerAddress,',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitCity=PARSENAME(REPLACE(OwnerAddress,',', '.'), 2) 

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR (255)

UPDATE NashvilleHousing
SET OwnerSplitState=PARSENAME(REPLACE(OwnerAddress,',', '.'), 1)


SELECT *
FROM NashvilleHousing




-------------------------------------------------------------------------------------------


--Change Y and N to Yes and No in 'Sold as Vacant' field


SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
CASE WHEN SoldAsVacant ='Y' THEN 'Yes'
     WHEN SoldAsVacant ='N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant ='Y' THEN 'Yes'
     WHEN SoldAsVacant ='N' THEN 'No'
	 ELSE SoldAsVacant
	 END




------------------------------------------------------------------------------------------------------------------------------


--Remove Duplicates



WITH RowNumCTE AS (
SELECT *,
     ROW_NUMBER() OVER (
	 PARTITION BY ParcelID,
	 PropertyAddress,
	 SalePrice,
	 SaleDate,
	 LegalReference
	 ORDER BY
	     UniqueID
		 ) row_num

FROM NashvilleHousing
)
DELETE * FROM RowNumCTE
WHERE row_num >1
--ORDER BY PropertyAddress




--------------------------------------------------------------------------------------------------------------------

--Delete unused columns


SELECT * FROM NashvilleHousing


ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict


ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate
