/*

Cleaning Data in SQL Queries

*/

Select *
From Nashville.dbo.NashvilleHousing

-- Standardizing the Date Format


Select SaleDateConverted, CONVERT(Date,SaleDate)
From Nashville.dbo.NashvilleHousing

Update NashvilleHousing
Set SaleDate = CONVERT(Date,SaleDate)

Alter Table NashvilleHousing
Add SaleDateConverted Date; 

Update NashvilleHousing
Set SaleDateConverted = CONVERT(Date,SaleDate)


-- Populating Property Address Data

Select *
From Nashville.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From Nashville.dbo.NashvilleHousing a
JOIN Nashville.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From Nashville.dbo.NashvilleHousing a
JOIN Nashville.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


-- Breaking Out Address into Individual Columns (City, Address, State) using Substring

Select PropertyAddress
From Nashville.dbo.NashvilleHousing

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
From Nashville.dbo.NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255); 

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255); 

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Select *
From Nashville.dbo.NashvilleHousing

-- Owner Address using parsename

Select OwnerAddress
From Nashville.dbo.NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From Nashville.dbo.NashvilleHousing

Alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255); 

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255); 

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

Alter Table NashvilleHousing
Add OwnerSplitState Nvarchar(255); 

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

Select *
From Nashville.dbo.NashvilleHousing


-- Change Y and N to Yes and No in "Sold as Vacant" Field

Select Distinct (SoldasVacant), Count(SoldasVacant)
From Nashville.dbo.NashvilleHousing
Group by SoldasVacant
order by 2


Select SoldasVacant
, Case When SoldasVacant = 'Y' then 'Yes'
       When SoldasVacant = 'N' then 'No'
	   Else SoldasVacant
	   End
From Nashville.dbo.NashvilleHousing

Update NashvilleHousing
SET SoldasVacant = Case When SoldasVacant = 'Y' then 'Yes'
       When SoldasVacant = 'N' then 'No'
	   Else SoldasVacant
	   End

-- Removing Duplicates Using a CTE

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
	             PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
				
From Nashville.dbo.NashvilleHousing
--Order by ParcelID
)
Delete 
From RowNumCTE
Where row_num > 1

-- Succesfully Deleted 104 Rows

-- Deleting Unused Columns

Select *
From Nashville.dbo.NashvilleHousing

ALTER TABLE Nashville.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE Nashville.dbo.NashvilleHousing
DROP COLUMN SaleDate
