-- Using Microsoft The AdventureWorks2019 Sample Database
-- Source Link : https://docs.microsoft.com/en-us/sql/samples/adventureworks-install-configure?view=sql-server-ver15&tabs=ssms
-- Data Receives As Bak File Format And Uploaeded To The SQL Server
-- Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Converting Data Types

-- Convert DateTime Columns To Date In SalesOrderHeader Table

	-- Convert *OrderDate* Columns To Date In SalesOrderHeader Table
		-- See Why We Need The Convertion
	Select OrderDate, CONVERT(Date,OrderDate)
	From AdventureWorks2019.Sales.SalesOrderHeader

		-- Create The New Column
	alter table AdventureWorks2019.Sales.SalesOrderHeader
	add OrderDateConverted Date

		-- Add The Convertaed Data To The New Column
	update AdventureWorks2019.Sales.SalesOrderHeader
	set OrderDateConverted = CONVERT(Date,OrderDate)

		-- See The Old And New Columns
	select OrderDate, OrderDateConverted
	from AdventureWorks2019.Sales.SalesOrderHeader


	-- Convert *DueDate* Columns To Date In SalesOrderHeader Table
		-- See Why We Need The Convertion
	Select DueDate, CONVERT(Date,DueDate)
	From AdventureWorks2019.Sales.SalesOrderHeader

		-- Create The New Column
	alter table AdventureWorks2019.Sales.SalesOrderHeader
	add DueDateConverted Date

		-- Add The Convertaed Data To The New Column
	update AdventureWorks2019.Sales.SalesOrderHeader
	set DueDateConverted = CONVERT(Date,DueDate)

		-- See The Old And New Columns
	select DueDate, DueDateConverted
	from AdventureWorks2019.Sales.SalesOrderHeader


	-- Convert *ShipDate* Columns To Date In SalesOrderHeader Table
		-- See Why We Need The Convertion
	Select ShipDate, CONVERT(Date,ShipDate)
	From AdventureWorks2019.Sales.SalesOrderHeader

		-- Create The New Column
	alter table AdventureWorks2019.Sales.SalesOrderHeader
	add ShipDateConverted Date

		-- Add The Convertaed Data To The New Column
	update AdventureWorks2019.Sales.SalesOrderHeader
	set ShipDateConverted = CONVERT(Date,ShipDate)

		-- See The Old And New Columns
	select ShipDate, ShipDateConverted
	from AdventureWorks2019.Sales.SalesOrderHeader


	-- Convert *ModifiedDate* Columns To Date In SalesOrderHeader Table
		-- See Why We Need The Convertion
	Select ModifiedDate, CONVERT(Date,ModifiedDate)
	From AdventureWorks2019.Sales.SalesOrderHeader

		-- Create The New Column
	alter table AdventureWorks2019.Sales.SalesOrderHeader
	add ModifiedDateConverted Date

		-- Add The Convertaed Data To The New Column
	update AdventureWorks2019.Sales.SalesOrderHeader
	set ModifiedDateConverted = CONVERT(Date,ModifiedDate)

		-- See The Old And New Columns
	select ModifiedDate, ModifiedDateConverted
	from AdventureWorks2019.Sales.SalesOrderHeader


-- Find The Time Between The Order Date To Shipment Date -- {{All Orders Are Send After A 7 Days From Order Date}}
select OrderDateConverted, ShipDateconverted, DATEDIFF(day, OrderDateConverted, ShipDateconverted) as TimeToSend
from AdventureWorks2019.Sales.SalesOrderHeader
order by OrderDateConverted 


-- Find The Top 10 Most Active Customers (Count / Number Of Buyings)
select top 10 s.CustomerID, p.FirstName, p.LastName, count(s.CustomerID) as NumberOfSales, format(sum(s.TotalDue),'#,#') as TotalSalesCost, format(sum(s.TotalDue)/count(s.CustomerID),'#,#.#.#') as AverageSaleValue
from AdventureWorks2019.Sales.SalesOrderHeader s
join AdventureWorks2019.Sales.Customer c on c.CustomerID = s.CustomerID
join AdventureWorks2019.Person.Person p on p.BusinessEntityID= c.CustomerID
group by s.CustomerID, p.FirstName, p.LastName
order by count(s.CustomerID) desc


-- Find Top 10 Most Valued Customers (Sum / Spend The Most Money)
select top 10 s.CustomerID, p.FirstName, p.LastName, e.EmailAddress, pp.PhoneNumber ,count(s.CustomerID) as NumberOfSales, 
	   format(sum(s.TotalDue),'#,#') as TotalSalesCost, format(sum(s.TotalDue)/count(s.CustomerID),'#,#.#') as AverageSaleValue
from AdventureWorks2019.Sales.SalesOrderHeader s
join AdventureWorks2019.Sales.Customer c on c.CustomerID = s.CustomerID
join AdventureWorks2019.Person.Person p on p.BusinessEntityID= c.CustomerID
join AdventureWorks2019.Person.EmailAddress e on e.BusinessEntityID = p.BusinessEntityID
join AdventureWorks2019.Person.PersonPhone pp on pp.BusinessEntityID = p.BusinessEntityID
group by s.CustomerID, p.FirstName, p.LastName, e.EmailAddress, pp.PhoneNumber
order by sum(s.TotalDue) desc



-- Calculate The Most Sold Products And Use Temp Table To Calculate The Percentage
	--Rank Products By TotalProductSold
select distinct d.ProductID, p.Name, sum(d.OrderQty) as TotalProductSold, DENSE_RANK() over(order by sum(d.OrderQty) desc) as ProductTotalSalesRank
from AdventureWorks2019.Sales.SalesOrderDetail d
join AdventureWorks2019.Production.Product p on p.ProductID = d.ProductID
group by d.ProductID, p.Name, d.OrderQty
order by 3 desc

	-- Create The Temp Table #TempProductTotalSold To Store The Total Sales Of The Products
drop table if exists #TempProductTotalSold
create table #TempProductTotalSold(
ProductID int,
Name varchar(100),
ProductTotalSales int,
TotalSales int
)

	-- Insert Data To The Temp Table #TempProductTotalSold
insert into #TempProductTotalSold
select distinct d.ProductID, p.Name, sum(d.OrderQty),(select sum(d.OrderQty) from AdventureWorks2019.Sales.SalesOrderDetail d)
from AdventureWorks2019.Sales.SalesOrderDetail d
join AdventureWorks2019.Production.Product p on p.ProductID = d.ProductID
group by d.ProductID, p.Name

	-- Show Results In Temp Table
select *, format(cast(ProductTotalSales as float) / cast(TotalSales as float), 'p')as PercentOfTotalSales
from #TempProductTotalSold
order by ProductTotalSales desc



-- Show Full Product, SubProduct & Category List
select c.ProductCategoryID, c.Name as CategoryName, s.ProductSubcategoryID, s.Name as SubCategoryName,  p.ProductID, p.Name
from AdventureWorks2019.Production.Product p
join AdventureWorks2019.Production.ProductSubcategory s on s.ProductSubcategoryID = p.ProductSubcategoryID
join AdventureWorks2019.Production.ProductCategory c on c.ProductCategoryID = s.ProductCategoryID
order by 1,3,5


-- Show The Number Of Products In Each Category (To Check If The Following Pivot Is Correct)
select c.Name, count(p.ProductID) as TotalProducts
from AdventureWorks2019.Production.Product p
join AdventureWorks2019.Production.ProductSubcategory s on s.ProductSubcategoryID = p.ProductSubcategoryID
join AdventureWorks2019.Production.ProductCategory c on c.ProductCategoryID = s.ProductCategoryID
group by c.Name

	-- Pivot Of Number Of Items In Evey Category
	select * from
	(
		select p.ProductID, c.Name as CategoryName
		from AdventureWorks2019.Production.Product p
		join AdventureWorks2019.Production.ProductSubcategory s on s.ProductSubcategoryID = p.ProductSubcategoryID
		join AdventureWorks2019.Production.ProductCategory c on c.ProductCategoryID = s.ProductCategoryID 
	) t pivot ( 
			count(ProductID) for CategoryName in ([Bikes], [Components], [Clothing], [Accessories])
			  ) as CountOfProducts


-- Show In A Pivot The TotalSales Per Year
	select * from
	(
		select TotalDue, year(ShipDateConverted) as Years
		from AdventureWorks2019.Sales.SalesOrderHeader
	) t pivot ( 
			sum(TotalDue) for Years in ([2011], [2012], [2013], [2014])
			  ) as SalesPerYearPivot



-- Sort Stores By Percent Of TotalDue Of All Sales In 10.2011 
	--(Including Stores *Without* StoreID)
select c.StoreID, s.Name, soh.ShipDateConverted , format(sum(soh.TotalDue),'#,#') as SumTotalDue, 
	(select format(sum(totaldue),'#,#') from AdventureWorks2019.Sales.SalesOrderHeader where year(ShipDateConverted) = '2011' and month(ShipDateConverted) = '10') as Total_ALL ,
	round(sum(cast(soh.TotalDue as float))/(select sum(cast(totaldue as float)) from AdventureWorks2019.Sales.SalesOrderHeader where year(ShipDateConverted) = '2011' and month(ShipDateConverted) = '10') * 100,4) as PercentOfALL
from AdventureWorks2019.Sales.SalesOrderHeader soh
full join AdventureWorks2019.Sales.Customer c on c.CustomerID = soh.CustomerID
full join AdventureWorks2019.Sales.Store s on s.BusinessEntityID = c.StoreID
group by c.StoreID, s.Name, soh.ShipDateConverted
having year(soh.ShipDateConverted) = '2011' and month(soh.ShipDateConverted) = '10'
order by PercentOfALL desc



-------- Sort Stores By Percent Of TotalDue Of All Stores Sales In 10.2011 
	--(*** Only Stores *With* StoreID ***)
select c1.StoreID, s1.Name, soh1.ShipDateConverted , format(sum(soh1.TotalDue),'#,#') as SumTotalDue, 
	(select format(sum(soh2.totaldue),'#,#') 
		from AdventureWorks2019.Sales.SalesOrderHeader soh2
		full join AdventureWorks2019.Sales.Customer c2 on c2.CustomerID = soh2.CustomerID
		full join AdventureWorks2019.Sales.Store s2 on s2.BusinessEntityID = c2.StoreID
		where year(soh2.ShipDateConverted) = '2011' and month(soh2.ShipDateConverted) = '10' and s2.Name is not null) as Total_ALL ,
	round(sum(cast(soh1.TotalDue as float))  /(select sum(cast(soh2.totaldue as float))
		from AdventureWorks2019.Sales.SalesOrderHeader soh2
		full join AdventureWorks2019.Sales.Customer c2 on c2.CustomerID = soh2.CustomerID
		full join AdventureWorks2019.Sales.Store s2 on s2.BusinessEntityID = c2.StoreID
		where year(soh2.ShipDateConverted) = '2011' and month(soh2.ShipDateConverted) = '10' and s2.Name is not null) * 100,3) as PercentOfALL
from AdventureWorks2019.Sales.SalesOrderHeader soh1
full join AdventureWorks2019.Sales.Customer c1 on c1.CustomerID = soh1.CustomerID
full join AdventureWorks2019.Sales.Store s1 on s1.BusinessEntityID = c1.StoreID
group by c1.StoreID, s1.Name, soh1.ShipDateConverted
having year(soh1.ShipDateConverted) = '2011' and month(soh1.ShipDateConverted) = '10' and s1.Name is not null
order by PercentOfALL desc


-- Find Stores Without ID and Name 
select c1.StoreID, s1.Name, soh1.ShipDateConverted , format(sum(soh1.TotalDue),'#,#') as SumTotalDue, 
	(select format(sum(soh2.totaldue),'#,#') 
		from AdventureWorks2019.Sales.SalesOrderHeader soh2
		full join AdventureWorks2019.Sales.Customer c2 on c2.CustomerID = soh2.CustomerID
		full join AdventureWorks2019.Sales.Store s2 on s2.BusinessEntityID = c2.StoreID
		where year(soh2.ShipDateConverted) = '2011' and month(soh2.ShipDateConverted) = '10' and s2.Name is null) as Total_ALL ,
	sum(cast(soh1.TotalDue as float))  /(select sum(cast(soh2.totaldue as float))
		from AdventureWorks2019.Sales.SalesOrderHeader soh2
		full join AdventureWorks2019.Sales.Customer c2 on c2.CustomerID = soh2.CustomerID
		full join AdventureWorks2019.Sales.Store s2 on s2.BusinessEntityID = c2.StoreID
		where year(soh2.ShipDateConverted) = '2011' and month(soh2.ShipDateConverted) = '10' and s2.Name is null) * 100 as PercentOfALL
from AdventureWorks2019.Sales.SalesOrderHeader soh1
full join AdventureWorks2019.Sales.Customer c1 on c1.CustomerID = soh1.CustomerID
full join AdventureWorks2019.Sales.Store s1 on s1.BusinessEntityID = c1.StoreID
group by c1.StoreID, s1.Name, soh1.ShipDateConverted
having year(soh1.ShipDateConverted) = '2011' and month(soh1.ShipDateConverted) = '10' and s1.Name is null
order by PercentOfALL desc


----------Find Territory Total Sales Using CTE 
with Territory_Sales (TerID, TerTotalSales) as
	(
	select TerritoryID, sum(TotalDue) 
	from AdventureWorks2019.Sales.SalesOrderHeader
	group by TerritoryID
	)
select TerID, st.Name, cast(TerTotalSales as int) as TerTotalSales
from Territory_Sales
join AdventureWorks2019.Sales.SalesTerritory st on st.TerritoryID = Territory_Sales.TerID
order by 3 desc


-- Get Active Employees (SalariedFlag=1) Current Rate And Compare It To Job Average Rate Using CTE
with AvgRatePerJob (JobName, EmpCount , AVGRate) as
	(select e.JobTitle , count(e.JobTitle) as EmployeesInJob, avg(eph.Rate) as AvgRate
		from AdventureWorks2019.HumanResources.EmployeePayHistory eph
		join  AdventureWorks2019.HumanResources.Employee e on e.BusinessEntityID = eph.BusinessEntityID
		group by e.JobTitle , e.SalariedFlag
		having e.SalariedFlag = 1
	),
	EmpRate (EMPID, JobName ,CurrentRate) as 
	(
	select e.BusinessEntityID, e.JobTitle, max(eph.rate) as CurrentRate
		from AdventureWorks2019.HumanResources.Employee e
		join AdventureWorks2019.HumanResources.EmployeePayHistory eph on eph.BusinessEntityID = e.BusinessEntityID
		group by e.BusinessEntityID, e.JobTitle, e.SalariedFlag
		having e.SalariedFlag = 1
	)
select EmpRate.EMPID, EmpRate.JobName, EmpRate.CurrentRate , AvgRatePerJob.EmpCount, AvgRatePerJob.AVGRate
from EmpRate
join AvgRatePerJob on AvgRatePerJob.JobName = EmpRate.JobName


-- PIVOT Total Sales By CustomerID per Year
select CustomerID, [2011], [2012], [2013], [2014]
from 
(
	select year(ModifiedDateConverted) as SaleYear, CustomerID, TotalDue
	from AdventureWorks2019.Sales.SalesOrderHeader
) as Source
pivot
(
	sum(TotalDue)
	for SaleYear in ([2011], [2012], [2013], [2014])
) as pvt
