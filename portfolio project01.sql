
----Cleaning Data in SQL Queries


select *
from [P.p].dbo.Nashville

------------------------------------------------------------------------------------------------

---- Standardize Date Format

select saledateconverted, convert(date,SaleDate)
from [P.p].dbo.Nashville

update [P.p].dbo.Nashville
set SaleDate = convert(date, SaleDate)

alter table [P.p].dbo.Nashville
add saledateconverted date;

update [P.p].dbo.Nashville
set saledateconverted = convert(date, SaleDate)

----------------------------------------------------------------------------------------

-- Populate Property Address data

select *
from [P.p].dbo.Nashville
----where PropertyAddress is null
order by ParcelID

select a.ParcelID,a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyaddress,b.propertyaddress)
from [P.p].dbo.Nashville a
join [P.p].dbo.Nashville b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null 

update a
set PropertyAddress = ISNULL(a.propertyaddress,b.propertyaddress)
from [P.p].dbo.Nashville a
join [P.p].dbo.Nashville b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null 

----------------------------------------------------------------------------------
-- Breaking out Address into Individual Columns (Address, City, State)

select propertyaddress
from [P.p].dbo.Nashville
------where PropertyAddress is null
------order by ParcelID

select 
SUBSTRING (propertyaddress, 1,CHARINDEX(',', PropertyAddress)-1) as address
,SUBSTRING (propertyaddress ,CHARINDEX(',', PropertyAddress)+1 , len(propertyaddress)) as address
from [P.p].dbo.Nashville


alter table [P.p].dbo.Nashville
add propertysplitaddress nvarchar(255);

update [P.p].dbo.Nashville
set propertysplitaddress = SUBSTRING (propertyaddress, 1,CHARINDEX(',', PropertyAddress)-1)

alter table [P.p].dbo.Nashville
add propertysplitcity nvarchar(255);

update [P.p].dbo.Nashville
set propertysplitcity = SUBSTRING (propertyaddress ,CHARINDEX(',', PropertyAddress)+1 , len(propertyaddress))


select *
from [P.p].dbo.Nashville


select owneraddress
from [P.p].dbo.Nashville


select
parsename(replace(owneraddress,',', '.'),3)
,parsename(replace(owneraddress,',','.'),2)
,parsename(replace(owneraddress,',','.'),1)
from [P.p]..Nashville


alter table [P.p].dbo.Nashville
add ownersplitcity nvarchar(255);

update [P.p].dbo.Nashville
set ownersplitcity = parsename(replace(owneraddress,',','.'),2)


alter table [P.p].dbo.Nashville
add ownersplitaddress nvarchar(255);

update [P.p].dbo.Nashville
set ownersplitaddress = parsename(replace(owneraddress,',', '.'),3)


alter table [P.p].dbo.Nashville
add ownersplitstate nvarchar(255);

update [P.p].dbo.Nashville
set ownersplitstate = parsename(replace(owneraddress,',','.'),1)

select *
from [P.p].dbo.Nashville

-------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(soldasvacant), count(soldasvacant)
from  [P.p].dbo.Nashville
group by SoldAsVacant
order by 2


select soldasvacant
,case when soldasvacant = 'Y' then 'Yes'
     when soldasvacant = 'N' then 'No'
	 else soldasvacant
	 end
from [P.p].dbo.Nashville

update [P.p].dbo.Nashville
set soldasvacant = case when soldasvacant = 'Y' then 'Yes'
     when soldasvacant = 'N' then 'No'
	 else soldasvacant
	 end


------------------------------------------------------------------------------------------

-- Remove Duplicates

with RowNumCTE as (
select *,
         Row_number() over (
		 Partition by 
		              propertyaddress,
					  saleprice,
					  saledate,
					  legalreference
					  order by 
					     uniqueID
					  ) row_num

from [P.p]..Nashville
----order by ParcelID
)
select *
from RowNumCTE
where row_num > 1
---order by PropertyAddress

----------------------------------------------------------------------------------------------

-- Delete Unused Columns

select *
from [P.p].dbo.Nashville

alter table [P.p].dbo.Nashville
drop column owneraddress, taxdistrict, propertyaddress

alter table [P.p].dbo.Nashville
drop column saledate

