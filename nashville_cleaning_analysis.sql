use nashvillehouse

select * 
from nashville
------------------------------
DELETE T
FROM
( SELECT	* , 
			DupRank = ROW_NUMBER() OVER (
              PARTITION BY	ParcelID,
							PropertyAddress,
							SalePrice,
							SaleDate,
							LegalReference,
							OwnerName,
							OwnerAddress
              ORDER BY (SELECT NULL)
            )
FROM nashville
) AS T
WHERE DupRank > 1
------------------------------

select SaleDate, CONVERT(date, SaleDate)
from nashville

alter table nashville
add SalesDateConverted Date;

Update nashville
SET SalesDateConverted = CONVERT(Date,SaleDate)
------------------------------
select	UniqueID,
		OwnerName, 
		REPLACE( REPLACE( REPLACE(PropertyAddress, '    ', ' '), '   ', ' '), '  ', ' ') as PropertyAdddressTrimmed, 
		REPLACE( REPLACE( REPLACE(OwnerAddress, '    ', ' '), '   ', ' '), '  ', ' ') as OwnerAddressTrimmed
into #temp_dates
from nashville
where OwnerAddress is not null and PropertyAddress is not null

with dates_cte as (
select	UniqueID,
		OwnerName,
		PropertyAdddressTrimmed,
		reverse(substring(REVERSE(OwnerAddressTrimmed), CHARINDEX(',', REVERSE(OwnerAddressTrimmed)) + 1, len(OwnerAddressTrimmed))) as OwnerSplit,
		CASE WHEN PropertyAdddressTrimmed = reverse(substring(REVERSE(OwnerAddressTrimmed), CHARINDEX(',', REVERSE(OwnerAddressTrimmed)) + 1, len(OwnerAddressTrimmed))) THEN '1' ELSE '0' END AS MyDesiredResult
from #temp_dates
)
select UniqueID, OwnerName, PropertyAdddressTrimmed, OwnerSplit, MyDesiredResult 
from dates_cte
where MyDesiredResult = 0
order by PropertyAdddressTrimmed
------------------------------

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From nashville
Group by SoldAsVacant
order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From nashville

Update nashville
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
						When SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
						END
------------------------------
select *
from nashville
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From nashville a
JOIN nashville b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From nashville a
JOIN nashville b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

select *
from nashville
where PropertyAddress is null
order by ParcelID
------------------------------

select PropertyAddress
from nashville

select	PropertyAddress, 
		SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as PropertyStreet,		
		SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as PropertyCity
from nashville

ALTER TABLE nashville
Add PropertyStreet Nvarchar(255), PropertyCity Nvarchar(255);

Update nashville
SET PropertyStreet = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ),
	PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

------------------------------


Select OwnerAddress
From nashville


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From nashville

ALTER TABLE nashville
Add OwnerSplitAddress Nvarchar(255), 
	OwnerSplitState Nvarchar(255), 
	OwnerSplitCity Nvarchar(255);

Update nashville
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
	OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
	OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



------------------------------
ALTER TABLE nashville
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict, SaleDate
