--Cleaning Data

Select *
From dbo.NashvilleHousing

--Date Format

Select SaleDateConverted, CONVERT(Date, SaleDate)
From dbo.NashvilleHousing

Update dbo.NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE dbo.NashvilleHousing
Add SaleDateConverted Date;

Update dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

--Populate Property Address

Select *
From dbo.NashvilleHousing
--Where PropertyAddress is NULL
Order BY ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From dbo.NashvilleHousing a
JOIN dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is NULL

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From dbo.NashvilleHousing a
JOIN dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is NULL
Where a.PropertyAddress is NULL

--Breaking out address into individual columns(Address, City, State)

Select PropertyAddress
From dbo.NashvilleHousing
--Where PropertyAddress is NULL
--Order BY ParcelID

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1 , LEN(PropertyAddress)) as Address

From dbo.NashvilleHousing

ALTER TABLE dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE dbo.NashvilleHousing
Add PropertySplitCIty Nvarchar(255);

Update dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1 , LEN(PropertyAddress))

Select *
From dbo.NashvilleHousing


Select OwnerAddress
From dbo.NashvilleHousing


Select
PARSENAME(replace(OwnerAddress,',','.') , 3)
,PARSENAME(replace(OwnerAddress,',','.') , 2)
,PARSENAME(replace(OwnerAddress,',','.') , 1)
From dbo.NashvilleHousing



ALTER TABLE dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',','.') , 3)

ALTER TABLE dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(replace(OwnerAddress,',','.') , 2)

ALTER TABLE dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(replace(OwnerAddress,',','.') , 1)


Select *
From dbo.NashvilleHousing

--Change Y an N to Yes and No in "Sold as Vacant" field

Select Distinct(soldasvacant), Count(soldasvacant)
From dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2



Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	ELSE SoldAsVacant
	END
From dbo.NashvilleHousing


Update dbo.NashvilleHousing
Set SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	ELSE SoldAsVacant
	END


--Remove Duplicates

With RowNumCTE as(
Select * ,
	Row_Number() Over (
	partition by ParcelId,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				Order by
				UniqueId
				) row_num 

From dbo.NashvilleHousing
--order by ParcelID
)
Select * 
From RowNumCTE
Where row_num > 1
--order by PropertyAddress
