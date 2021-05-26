--Cleaning data in SQL queries (Guided by Alex Freberg)

Select *
From PortofolioProject1..NashvilleHousing

--Standardize date format

Select SaleDateConverted, CONVERT(date, SaleDate)
From PortofolioProject1.dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(date, SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

--Populate Property Address Data

Select *
From PortofolioProject1.dbo.NashvilleHousing
--Where PropertyAddress is null
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortofolioProject1.dbo.NashvilleHousing a
JOIN PortofolioProject1.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortofolioProject1.dbo.NashvilleHousing a
JOIN PortofolioProject1.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


--Breaking out address into individual columns (address, city, state)

Select PropertyAddress
From PortofolioProject1.dbo.NashvilleHousing
--Where PropertyAddress is null
--Order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address
 , SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) as Address
 --CHARINDEX(',',PropertyAddress)

From PortofolioProject1.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))

Select *
From PortofolioProject1.dbo.NashvilleHousing

--Use the same method for Owner Address columns


Select OwnerAddress
From PortofolioProject1.dbo.NashvilleHousing

Select
Parsename(Replace(OwnerAddress, ',',  '.') , 3)
, Parsename(Replace(OwnerAddress, ',',  '.') , 2)
, Parsename(Replace(OwnerAddress, ',',  '.') , 1)
From PortofolioProject1.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = Parsename(Replace(OwnerAddress, ',',  '.') , 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = Parsename(Replace(OwnerAddress, ',',  '.') , 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = Parsename(Replace(OwnerAddress, ',',  '.') , 1)

Select *
From PortofolioProject1.dbo.NashvilleHousing


--Change Y and N to Yes and No in "Sold As Vacant" field

Select Distinct(SoldAsVacant), count(SoldAsVacant)
From PortofolioProject1.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
, Case when SoldAsVacant = 'Y' Then 'Yes'
	   when SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
	   END
From PortofolioProject1.dbo.NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = Case when SoldAsVacant = 'Y' Then 'Yes'
	   when SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
	   END


--Remove duplicates


With Row_Num_CTE As(
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

From PortofolioProject1.dbo.NashvilleHousing
--Order By ParcelID
)

Select *
From Row_Num_CTE
Where row_num > 1
Order by PropertyAddress

Select *
From PortofolioProject1.dbo.NashvilleHousing

-- Delete unused columns

Select *
From PortofolioProject1.dbo.NashvilleHousing

ALTER TABLE PortofolioProject1.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortofolioProject1.dbo.NashvilleHousing
DROP COLUMN SaleDate