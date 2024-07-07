/* 

Cleaning  data in SQL queries

*/

Select * 
From public.property_data

--------- Check Date

Select saledate
From public.property_data

--------- Populate property address

Select *
From public.property_data
where propertyaddress is null
order by parcelId

Select original.parcelId, original.propertyaddress, updated.parcelId, updated.propertyaddress, COALESCE(original.propertyaddress, updated.propertyaddress)
From public.property_data as original
JOIN public.property_data as updated
 on original.parcelId = updated.parcelId
 AND original.uniqueid <> updated.uniqueid
where original.propertyaddress is null;

UPDATE property_data
SET propertyaddress = COALESCE(original.propertyaddress, updated.propertyaddress)
From public.property_data as original
JOIN public.property_data as updated
 on original.parcelId = updated.parcelId
 AND original.uniqueid <> updated.uniqueid
where original.propertyaddress is null;

-----------Address into individual columns (Address, City, State)

Select propertyaddress
From public.property_data

SELECT
SUBSTRING(propertyaddress, 1, POSITION(',' IN propertyaddress)-1) as address,
SUBSTRING(propertyaddress, POSITION(',' IN propertyaddress)+1, LENGTH(propertyaddress)) as CITY
From public.property_data

ALTER TABLE property_data
ADD propertysplitaddress varchar;

UPDATE property_data
SET propertysplitaddress = SUBSTRING(propertyaddress, 1, POSITION(',' IN propertyaddress)-1);

ALTER TABLE property_data
ADD propertysplitcity varchar;

UPDATE property_data
SET propertysplitcity = SUBSTRING(propertyaddress, POSITION(',' IN propertyaddress)+1, LENGTH(propertyaddress));

Select *
From public.property_data

-------Fix owner address
Select owneraddress
From public.property_data
where owneraddress is not null;



SELECT 
TRIM(SPLIT_PART(REPLACE(owneraddress, ',', '.'), '.', 1)) AS address,
TRIM(SPLIT_PART(REPLACE(owneraddress, ',', '.'), '.', 2)) AS city,
TRIM(SPLIT_PART(REPLACE(owneraddress, ',', '.'), '.', 3)) AS state
FROM 
public.property_data
WHERE 
owneraddress IS NOT NULL;

ALTER TABLE property_data
ADD ownersplitaddress varchar;

UPDATE property_data
SET ownersplitaddress = TRIM(SPLIT_PART(REPLACE(owneraddress, ',', '.'), '.', 1));

ALTER TABLE property_data
ADD ownersplitcity varchar;

UPDATE property_data
SET ownersplitcity = TRIM(SPLIT_PART(REPLACE(owneraddress, ',', '.'), '.', 2));

ALTER TABLE property_data
ADD ownersplitstate varchar;

UPDATE property_data
SET ownersplitstate = TRIM(SPLIT_PART(REPLACE(owneraddress, ',', '.'), '.', 3));

Select *
From public.property_data

---------Check solasvacant, try case
Select soldasvacant
From public.property_data


SELECT DISTINCT(SoldAsVacant), Count(SoldAsVacant),
 CASE When SoldAsVacant = true THEN 'N'
 ELSE SoldAsVacant
 END
FROM public.property_data
Group by SoldAsVacant

-------Remove duplicates

Select *
From public.property_data


WITH rowNumCTE as (
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY parcelId, 
				 propertyaddress,
				 salePrice,
				 saleDate,
		   	 	 legalreference
				 Order By 
					uniqueId
	) row_num
From public.property_data
--order by parcelId
)
DELETE FROM public.property_data
USING rowNumCTE
WHERE public.property_data.uniqueId = rowNumCTE.uniqueId
AND rowNumCTE.row_num > 1;


WITH rowNumCTE as (
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY parcelId, 
				 propertyaddress,
				 salePrice,
				 saleDate,
		   	 	 legalreference
				 Order By 
					uniqueId
	) row_num
From public.property_data
--order by parcelId
)
Select *
From rowNumCTE


----- DELETE Unused columns

Select *
From public.property_data

ALTER TABLE public.property_data
DROP COLUMN TaxDistrict
