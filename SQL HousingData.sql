use housing ;


--Cleaing Data in Sql queries

...........................................................................................................................................................................................

--Standardize Date Format  
select SaleDate, Convert(Date,SaleDate) from [dbo].[HousingData];

Alter table HousingData
add  SaleDateConverted date;

Update HousingData
set SaleDateConverted  = Convert(Date,SaleDate)



---Populate Property addraess Data  
select *  from [dbo].[HousingData]
--where PropertyAddress  is null
order by Parcelid;

--- replace null values in PropertyAddress  with the most populated  Property addraess Data with the same Parcelid------------------------------------------------
Select a.Parcelid, a.PropertyAddress , b.Parcelid, b.PropertyAddress, isnull(a.PropertyAddress ,b.PropertyAddress) 
from HousingData a 
join HousingData b 
on a.Parcelid = b.Parcelid
and a.uniqueId <> b.uniqueId
where a.PropertyAddress is null;

Update a 
set PropertyAddress =  isnull(a.PropertyAddress ,b.PropertyAddress)
from HousingData a 
join HousingData b 
on a.Parcelid = b.Parcelid
and a.uniqueId <> b.uniqueId 
where a.PropertyAddress is null;

-----------------------Breaking out Address Into individual columns (Address, City, state)------------------------------------------
Select substring(PropertyAddress,1, Charindex(',',PropertyAddress) -1) as Address ,
substring(PropertyAddress, Charindex(',',PropertyAddress )+1,len(PropertyAddress)) as Address 
 from HousingData;

Alter table HousingData
add PropertySplitAddress Nvarchar(255);

Update HousingData
set PropertySplitAddress= substring(PropertyAddress,1, Charindex(',',PropertyAddress) -1) 

Alter table HousingData
add PropertySplitCity Nvarchar(255);

Update HousingData
set PropertySplitCity= substring(PropertyAddress, Charindex(',',PropertyAddress )+1,len(PropertyAddress)) 

Select  * from HousingData;



--------------------------------Breaking out OwnerAddress Into individual columns (Address, City, state)----------------------------------
Select 
Parsename(replace(OwnerAddress,',','.'),3),
Parsename(replace(OwnerAddress,',','.'),2),
Parsename(replace(OwnerAddress,',','.'),1)
from HousingData;

Alter table HousingData
add OwnerSplitAddress Nvarchar(255);

Update HousingData
set OwnerSplitAddress= Parsename(replace(OwnerAddress,',','.'),3)

Alter table HousingData
add OwnerSplitCity Nvarchar(255);

Update HousingData
set OwnerSplitCity= Parsename(replace(OwnerAddress,',','.'),2)


Alter table HousingData
add OwnerSplitState Nvarchar(255);

Update HousingData
set OwnerSplitState= Parsename(replace(OwnerAddress,',','.'),1)

Select* from HousingData;


-------------------------------Change Y and N to Yes and No in "SoldAsVacant" ----------------------------------------------------------------------------------
select distinct(SoldAsVacant), count(SoldAsVacant)
from HousingData
group by SoldAsVacant
order by 2;

Select SoldAsVacant
,case
when SoldAsVacant ='Y' then 'Yes'
when SoldAsVacant ='N' then 'No'
else SoldAsVacant
end 
from HousingData; 

Update HousingData
set SoldAsVacant = 
case
when SoldAsVacant ='Y' then 'Yes'
when SoldAsVacant ='N' then 'No'
else SoldAsVacant
end


--------------------------------------------Remove Duplicates--------------------------------------------------------------------------------------
with RowNumCTE as (
select *,
Row_number() over  
(partition by  ParcelId,
               PropertyAddress,		
			   SaleDate,
			   SalePrice,
			   LegalReference
			   order by UniqueId
			   )RowNum
			  
from HousingData
)
select* from RowNumCTE
where  RowNum > 1 
order by PropertyAddress 


---------------------------------------Delete Unused columns------------------------------------------------------------------------------------
Select * from HousingData;

Alter table  HousingData 
drop column PropertyAddress,OwnerAddress, TaxDistrict, SaleDate








