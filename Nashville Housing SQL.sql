select *
from [NashVille Housing].dbo.Main_DB


--------------------------------------------------------------------- Cleanning The Data ---------------------------------------------------------------------
---------- update SaleDate Filed From DateTime To Date ----------
	-- See Why We Need The Convertion
Select SaleDate, CONVERT(Date,SaleDate)
From [NashVille Housing].dbo.Main_DB

	-- Create The New Column
alter table dbo.main_db
add SalesDateConverted Date

	-- Add The Convertaed Data To The New Column
update [NashVille Housing].dbo.Main_DB
set SalesDateConverted = CONVERT(Date,SaleDate)

	-- See The Old And New Columns
select SaleDate, SalesDateConverted
from [NashVille Housing].dbo.Main_DB



---------- Populate Property Address data ----------
	-- When The PropertyAddress Is NULL And We Have The Same ParcelID In Other Property We Can Copy The Address.
select * 
from [NashVille Housing].dbo.Main_DB
where PropertyAddress is null
order by ParcelID

	-- Find The Right Match
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from [NashVille Housing].dbo.Main_DB a
join [NashVille Housing].dbo.Main_DB b
on  a.ParcelID = b.ParcelID and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

	-- Update The Column In Our Table
update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from [NashVille Housing].dbo.Main_DB a
join [NashVille Housing].dbo.Main_DB b
on  a.ParcelID = b.ParcelID and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


---------- Breaking The PropertyAddress To Address And City Using SUBSTRING() ----------
select PropertyAddress 
from [NashVille Housing].dbo.Main_DB

	-- Check How To Break The PropertyAddress To Address And City 
 select PropertyAddress, 
SUBSTRING(PropertyAddress, 1, charindex(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, charindex(',', PropertyAddress)+1, len(PropertyAddress)) as City
from [NashVille Housing].dbo.Main_DB

	-- Alter The Table And Insert The Result Into Two New Varchar Columns
alter table dbo.main_db
add PropertySpllitAddress varchar(255)

update dbo.main_db
set PropertySpllitAddress = SUBSTRING(PropertyAddress, 1, charindex(',', PropertyAddress)-1)

alter table dbo.main_db
add PropertySpllitCity varchar(255)

update dbo.main_db
set PropertySpllitCity = SUBSTRING(PropertyAddress, charindex(',', PropertyAddress)+1, len(PropertyAddress))

	-- Check The Results
select PropertyAddress, PropertySpllitAddress, PropertySpllitCity
from [NashVille Housing].dbo.Main_DB


---------- Breaking The OwnerAddress To Address, City And State Using Parsename() ----------
select OwnerAddress
from [NashVille Housing].dbo.Main_DB

	-- Since The Parsename Looks For '.' We Need To "Help" It To Look For ',' Instead
select 
OwnerAddress,
parsename(replace(OwnerAddress, ',', '.'),3),
parsename(replace(OwnerAddress, ',', '.'),2),
parsename(replace(OwnerAddress, ',', '.'),1)
from [NashVille Housing].dbo.Main_DB

	-- Alter The Table And Insert The Result Into Three New Varchar Columns
alter table dbo.main_db
add OwnerAddressSpllitAddress varchar(255)

update dbo.main_db
set OwnerAddressSpllitAddress = parsename(replace(OwnerAddress, ',', '.'),3)

alter table dbo.main_db
add OwnerAddressSpllitCity varchar(255)

update dbo.main_db
set OwnerAddressSpllitCity = parsename(replace(OwnerAddress, ',', '.'),2)

alter table dbo.main_db
add OwnerAddressSpllitState varchar(255)

update dbo.main_db
set OwnerAddressSpllitState = parsename(replace(OwnerAddress, ',', '.'),1)

	-- Check The Results
select OwnerAddress, OwnerAddressSpllitAddress, OwnerAddressSpllitCity, OwnerAddressSpllitState
from [NashVille Housing].dbo.Main_DB


---------- Change The Y & N To Yes & No In The SoldAsVacant Column Using Case Statment

select distinct(SoldAsVacant), count(SoldAsVacant)
from [NashVille Housing].dbo.Main_DB
group by SoldAsVacant
order by 2 desc

	-- Build The Case Statment
select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
end
from [NashVille Housing].dbo.Main_DB

	-- Update The Table With The Case Statment
update dbo.main_db
set SoldAsVacant = 
	case when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
	end
from [NashVille Housing].dbo.Main_DB


---------- Remove Duplicates Using CTE
	-- Buid The CTE
with RowNumCTE as(
select *,
ROW_NUMBER() over(
	partition by parcelID, propertyaddress, saleprice, saledate, legalreference
	order by uniqueid) row_num
from [NashVille Housing].dbo.Main_DB
--order by ParcelID
)
select *
from RowNumCTE
where row_num > 1
order by propertyaddress

	-- Delete Duplicated Data

with RowNumCTE as(
select *,
ROW_NUMBER() over(
	partition by parcelID, propertyaddress, saleprice, saledate, legalreference
	order by uniqueid) row_num
from [NashVille Housing].dbo.Main_DB
)
delete
from RowNumCTE
where row_num > 1


---------- Delete Unused Columns

alter table [NashVille Housing].dbo.Main_DB
drop column owneraddress, taxdistrict, propertyaddress, saledate

----------------------------------------------------------------------------------------------------------------------

select * from dbo.Main_DB
order by SalesDateConverted desc

-- Find Total Sale, Average Sales And Average Profit Per Sale Each Year & City That Has More Then 10 Sales In It
SELECT year(SalesDateConverted) as SaleYear, PropertySpllitCity, format(sum(saleprice),'#,#') as TotalSales, format(avg(saleprice),'#,#') as AverageSalesValue,
	  format(avg(saleprice) - avg(totalvalue),'#,#') as AverageProfitPerSale, format(count(saleprice),'#,#') as NumberOfSales
from dbo.Main_DB
group by year(SalesDateConverted), PropertySpllitCity
having count(saleprice) > 10
order by SaleYear


-- House And Room Average Value Per Year, Number Of BedRooms And Acreage Size Group
select 
year(SalesDateConverted) as SaleYear, bedrooms,
case 
	when Acreage < 0.2 then '0 - 0.199'
	when Acreage < 0.4 then '0.2 - 0.399'
	when Acreage < 0.6 then '0.4 - 0.599'
	when Acreage < 0.8 then '0.6 - 0.799'
	else '0.8+'
end as AcreageGroup,
		count(saleprice) as Count, round(avg(Acreage),3) as AverageAcreage, format(avg(saleprice),'#,#') as AverageSales, 
	    format((avg(saleprice) / bedrooms),'#,#') as RoomPrice

from dbo.Main_DB
group by year(SalesDateConverted), bedrooms,
case 
	when Acreage < 0.2 then '0 - 0.199'
	when Acreage < 0.4 then '0.2 - 0.399'
	when Acreage < 0.6 then '0.4 - 0.599'
	when Acreage < 0.8 then '0.6 - 0.799'
	else '0.8+'
end
having bedrooms >0
order by year(SalesDateConverted) , bedrooms ,AcreageGroup


-- Owner Sales And Profit By Year

select OwnerName, year(SalesDateConverted) as SaleYear, count(OwnerName) as NumberOfSales, format(sum(saleprice),'#,#') as TotalSales, format(sum(saleprice) - sum(totalvalue),'#,#') as TotalProfit
from dbo.Main_DB
group by year(SalesDateConverted), OwnerName
having OwnerName is not null
order by OwnerName, year(SalesDateConverted)




