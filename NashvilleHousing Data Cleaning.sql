SELECT *
FROM NashvilleHousing

-- Populate Property Address data
SELECT propertyaddress
FROM NashvilleHousing
WHERE propertyaddress IS NULL

SELECT a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, COALESCE(a.propertyaddress,b.propertyaddress)
FROM NashvilleHousing as a
JOIN NashvilleHousing AS b
ON a.parcelid = b.parcelid
AND a.uniqueid <> b.uniqueid
WHERE a.propertyaddress IS NULL

UPDATE NashvilleHousing
SET propertyaddress = COALESCE(a.propertyaddress,b.propertyaddress)
FROM NashvilleHousing AS a
JOIN NashvilleHousing AS b
ON a.parcelid = b.parcelid
AND a.uniqueid <> b.uniqueid
WHERE a.propertyaddress IS NULL

-- Breaking out Address into individual columns (Address, City, State)
SELECT propertyaddress
FROM NashvilleHousing

SELECT
SUBSTRING(propertyaddress, 1,  POSITION(',' IN propertyaddress)-1) AS Address,
SUBSTRING(propertyaddress, POSITION(',' IN propertyaddress)+1, LENGTH(propertyaddress))AS Address
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD propertysplitaddress VARCHAR(255)

UPDATE NashvilleHousing
SET propertysplitaddress = SUBSTRING(propertyaddress, 1,  POSITION(',' IN propertyaddress)-1)

ALTER TABLE NashvilleHousing
ADD propertysplitcity VARCHAR(255)

UPDATE NashvilleHousing
SET propertysplitcity = SUBSTRING(propertyaddress, POSITION(',' IN propertyaddress)+1, LENGTH(propertyaddress))

SELECT
SPLIT_PART(owneraddress,',',1),
SPLIT_PART(owneraddress,',',2),
SPLIT_PART(owneraddress,',',3)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD ownersplitaddress VARCHAR(255)

UPDATE NashvilleHousing
SET ownersplitaddress = SPLIT_PART(owneraddress,',',1)

ALTER TABLE NashvilleHousing
ADD ownersplitcity VARCHAR(255)

UPDATE NashvilleHousing
SET ownersplitcity = SPLIT_PART(owneraddress,',',2)

ALTER TABLE NashvilleHousing
ADD ownersplitstate VARCHAR(255)

UPDATE NashvilleHousing
SET ownersplitstate = SPLIT_PART(owneraddress,',',3)

SELECT DISTINCT(soldasvacant), COUNT(soldasvacant)
FROM NashvilleHousing
GROUP BY soldasvacant
ORDER BY soldasvacant

-- Remove Duplicates
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY parcelid,
				propertyaddress,
				saleprice,
				saledate,
				legalreference
				ORDER BY
					uniqueid
						) AS row_num
FROM NashvilleHousing
)
DELETE
FROM NashvilleHousing
USING RowNumCTE
WHERE row_num > 1

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY parcelid,
				propertyaddress,
				saleprice,
				saledate,
				legalreference
				ORDER BY
					uniqueid
						) AS row_num
FROM NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1 
ORDER BY propertyaddress

