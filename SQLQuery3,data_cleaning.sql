/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [UniqueID ]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
      ,[SaleDateConverted]
  FROM [covid_project].[dbo].[NashvilleHousing]

  --------------------------------------------------------------------------
  /*
Cleaning Data in SQL Queries
*/

SELECT *
FROM covid_project.dbo.NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

SELECT SaleDateConverted, CONVERT(DATE,SaleDate)
FROM covid_project.dbo.NashvilleHousing

update NashvilleHousing
SET SaleDate = CONVERT(date,SaleDate)

--if that does not update

ALTER TABLE NashvilleHousing
add SaleDateConverted Date;

update NashvilleHousing
set SaleDateConverted = CONVERT(date,SaleDate)





 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT *
FROM covid_project.dbo.NashvilleHousing
--where PropertyAddress is null
ORDER BY ParcelID

/*SELECT a.ParcelID, b.ParcelID, a.PropertyAddress, b.PropertyAddress
FROM covid_project.dbo.NashvilleHousing a
JOIN covid_project.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null*/

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From covid_project.dbo.NashvilleHousing a
JOIN covid_project.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From covid_project.dbo.NashvilleHousing a
JOIN covid_project.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null
   


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM covid_project.dbo.NashvilleHousing
--where PropertyAddress is null
--ORDER BY ParcelID


SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1,LEN(PropertyAddress)) as Address
FROM covid_project.dbo.NashvilleHousing 


ALTER TABLE NashvilleHousing
add PropertySpiltAddress  Nvarchar(255);

update NashvilleHousing
set PropertySpiltAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
add PropertySpiltCity Nvarchar(255);

update NashvilleHousing
set PropertySpiltCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1,LEN(PropertyAddress))


SELECT *
FROM covid_project.dbo.NashvilleHousing



SELECT OwnerAddress
FROM covid_project.dbo.NashvilleHousing
--WHERE OwnerAddress is not null

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
FROM covid_project.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
add OwnerSpiltAddress  Nvarchar(255);

update NashvilleHousing
set OwnerSpiltAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)


ALTER TABLE NashvilleHousing
add OwnerSpiltCity Nvarchar(255);

update NashvilleHousing
set OwnerSpiltCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

ALTER TABLE NashvilleHousing
add OwnerSpiltState  Nvarchar(255);

update NashvilleHousing
set OwnerSpiltState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)


SELECT *
FROM covid_project.dbo.NashvilleHousing





--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant)
FROM covid_project.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 else SoldAsVacant
	 END
FROM covid_project.dbo.NashvilleHousing


update NashvilleHousing
set SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 else SoldAsVacant
	 END
FROM covid_project.dbo.NashvilleHousing



-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates


WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY parcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					uniqueID
					)row_num

FROM covid_project.dbo.NashvilleHousing
--ORDER BY ParcelID
)
SELECT *  
FROM RowNumCTE
WHERE row_num > 1
--order by PropertyAddress

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT *
FROM covid_project.dbo.NashvilleHousing

ALTER TABLE covid_project.dbo.NashvilleHousing
DROP COLUMN PropertyAddress,TaxDistrict,OwnerAddress

ALTER TABLE covid_project.dbo.NashvilleHousing
DROP COLUMN SaleDate

















-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO