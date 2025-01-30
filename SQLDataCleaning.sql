SELECT*
FROM [Portfolio Project]..NashvilleHousing

--STANDARDIZE DATE FORMAT

SELECT SaleDate, CONVERT(Date,SaleDate)
FROM [Portfolio Project]..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)
FROM [Portfolio Project]..NashvilleHousing

ALTER TABLE [Portfolio Project]..NashvilleHousing
ADD SaleDateConverted date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)
FROM [Portfolio Project]..NashvilleHousing

SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM [Portfolio Project]..NashvilleHousing


--Populate property adress

SELECT*
FROM [Portfolio Project]..NashvilleHousing
WHERE PropertyAddress is null
ORDER BY ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Portfolio Project]..NashvilleHousing a
JOIN [Portfolio Project]..NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Portfolio Project]..NashvilleHousing a
JOIN [Portfolio Project]..NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


--Breaking Out Adress Into Indivisual Collums

-- 1st Breaking The collum

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) AS Adress,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress)) AS Adress
FROM [Portfolio Project]..NashvilleHousing

--Adding the split colums

ALTER TABLE [Portfolio Project]..NashvilleHousing
ADD SplitAdress NVARCHAR(255);

UPDATE [Portfolio Project]..NashvilleHousing
SET SplitAdress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE [Portfolio Project]..NashvilleHousing
ADD SplitCity NVARCHAR(255);

UPDATE [Portfolio Project]..NashvilleHousing
SET SplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress))

--Final result

SELECT PropertyAddress, SplitAdress, SplitCity
FROM [Portfolio Project]..NashvilleHousing

--Different Approach

SELECT OwnerAddress,
PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 3) AS OwnerSplitAdress,
PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 2) AS OwnerSplitCity,
PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 1) AS OwnerSplitState
FROM [Portfolio Project]..NashvilleHousing

--Now adding the split collums into the table

ALTER TABLE [Portfolio Project]..NashvilleHousing
ADD OwnerSplitAdress NVARCHAR(255);

UPDATE [Portfolio Project]..NashvilleHousing
SET OwnerSplitAdress = PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 3)

ALTER TABLE [Portfolio Project]..NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE [Portfolio Project]..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 2)

ALTER TABLE [Portfolio Project]..NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE [Portfolio Project]..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 1)


--Final result

SELECT OwnerAddress, OwnerSplitAdress, OwnerSplitCity, OwnerSplitState
FROM [Portfolio Project]..NashvilleHousing


-- CHANGE Y AND N TO YES AND NO IN 'SOLDASVACANT' SECTION

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM [Portfolio Project]..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM [Portfolio Project]..NashvilleHousing

--updating the table

UPDATE [Portfolio Project]..NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END

--Final result
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM [Portfolio Project]..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


--REMOVE DUPLICATES

WITH RowNumCTE AS(
SELECT*,
ROW_NUMBER () OVER(
    PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	ORDER BY UniqueID) as row_num
FROM [Portfolio Project]..NashvilleHousing
)

SELECT*
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

--DELETE THE DUPLICATES

WITH RowNumCTE AS(
SELECT*,
ROW_NUMBER () OVER(
    PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	ORDER BY UniqueID) as row_num
FROM [Portfolio Project]..NashvilleHousing
)

DELETE
FROM RowNumCTE
WHERE row_num > 1


--DELETE UNUSED COLLUMNS


SELECT*
FROM [Portfolio Project]..NashvilleHousing

ALTER TABLE [Portfolio Project]..NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, SaleDate
