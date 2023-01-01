/*

Cleaning Data in SQL 

*/


select *
from PortfolioProject..NashvilleHousing


-- standardize Date format

select SaleDatenew, CONVERT(date, SaleDate)
from PortfolioProject..NashvilleHousing

update NashvilleHousing
set SaleDate = CONVERT(date, SaleDate)

alter table Nashvillehousing
add saledatenew date

update NashvilleHousing
set SaleDatenew = CONVERT(date, SaleDate)

-- populate property address data correctly

select ParcelID, PropertyAddress
from PortfolioProject..NashvilleHousing
where PropertyAddress is null

select a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, isnull(a.propertyaddress, b.propertyaddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set propertyaddress = isnull(a.propertyaddress, b.propertyaddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- Breaking out Address into individual columns

select propertyaddress
from PortfolioProject..NashvilleHousing

select 
substring(PropertyAddress, 1, charindex(',', propertyaddress) -1) as address,
substring(propertyaddress, charindex(',', propertyaddress) +1, LEN(Propertyaddress)) as address
from portfolioproject..nashvillehousing

alter table Nashvillehousing
add propertysplitaddress nvarchar(255)

update NashvilleHousing
set propertysplitaddress = substring(PropertyAddress, 1, charindex(',', propertyaddress) -1)

alter table Nashvillehousing
add propertysplitcity nvarchar(255)

update NashvilleHousing
set propertysplitcity = substring(propertyaddress, charindex(',', propertyaddress) +1, LEN(Propertyaddress))

-- Populate the OwnerAddress Correctly by splitting into different columns

select *
from PortfolioProject..NashvilleHousing

select 
PARSENAME(replace(owneraddress, ',', '.'), 3),
PARSENAME(replace(owneraddress, ',', '.'), 2),
PARSENAME(replace(owneraddress, ',', '.'), 1)

from PortfolioProject..NashvilleHousing

alter table Nashvillehousing
add OwnersplitAddress nvarchar(255),
OwnersplitCity nvarchar(255),
OwnersplitState nvarchar(255)

update NashvilleHousing
set OwnersplitAddress = PARSENAME(replace(owneraddress, ',', '.'), 3),
OwnersplitCity = PARSENAME(replace(owneraddress, ',', '.'), 2),
OwversplitState = PARSENAME(replace(owneraddress, ',', '.'), 1)

select *
from PortfolioProject..NashvilleHousing

-- Replace 'Y' with Yes and "N" with 'No'

select SoldAsVacant
, case when SoldAsVacant = 'y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end
from PortfolioProject..NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end

-- Remove Duplicates

with RowNumCTE as (
select *, 
	ROW_NUMBER() over (partition by parcelid,
									propertyaddress,
									saleprice,
									saledate,
									legalreference
									Order by uniqueid)
									row_num
from PortfolioProject..NashvilleHousing)

select *
from RowNumCTE 
where row_num > 1

---Delete Unused Columns

select *
from PortfolioProject..NashvilleHousing

alter table PortfolioProject..NashvilleHousing
drop column owneraddress, taxdistrict, propertyaddress, saledate