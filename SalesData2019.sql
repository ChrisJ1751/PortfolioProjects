
-- Removing null rows found within each table.

Delete From Sales_January_2019 Where OrderID IS NULL
Delete From Sales_February_2019 Where OrderID IS NULL
Delete From Sales_March_2019 Where OrderID IS NULL
Delete From Sales_April_2019 Where OrderID IS NULL
Delete From Sales_May_2019 Where OrderID IS NULL
Delete From Sales_June_2019 Where OrderID IS NULL
Delete From Sales_July_2019 Where OrderID IS NULL
Delete From Sales_August_2019 Where OrderID IS NULL
Delete From Sales_September_2019 Where OrderID IS NULL
Delete From Sales_October_2019 Where OrderID IS NULL
Delete From Sales_November_2019 Where OrderID IS NULL
Delete From Sales_December_2019 Where OrderID IS NULL

-- Combining all Sales Tables into one full table 'AllSalesData' using Unions

Select *
	Into AllSalesData2
From
(
Select *
From Sales_January_2019
Union
Select *
From Sales_February_2019
Union
Select *
From Sales_March_2019
Union
Select *
From Sales_April_2019
Union
Select *
From Sales_May_2019
Union
Select *
From Sales_June_2019
Union
Select *
From Sales_July_2019
Union
Select *
From Sales_August_2019
Union
Select *
From Sales_September_2019
Union
Select *
From Sales_October_2019
Union
Select *
From Sales_November_2019
Union
Select *
From Sales_December_2019
) a

-- Converting Month format into singular value for future queries

Select OrderID, Product, QuantityOrdered, PriceEach, PurchaseAddress, Month(OrderDate) As OrderMonth, 
Into AllSalesDataConverted
From AllSalesData2

--Returing Results from new 'AllSalesDataConverted' Table

Select *
From AllSalesDataConverted

-- Parsing Out Address

Select PurchaseAddress
From AllSalesDataConverted

Select
PARSENAME(Replace(PurchaseAddress, ',', '.'), 3),
PARSENAME(Replace(PurchaseAddress, ',', '.'), 2),
PARSENAME(Replace(PurchaseAddress, ',', '.'), 1)
From AllSalesDataConverted

Alter Table AllSalesDataConverted
Add PurchaseSplitAddress Nvarchar(255);

Update AllSalesDataConverted
Set PurchaseSplitAddress = PARSENAME(Replace(PurchaseAddress, ',', '.'), 3)

Alter Table AllSalesDataConverted
Add PurchaseSplitCity Nvarchar(255);

Update AllSalesDataConverted
Set PurchaseSplitCity = PARSENAME(Replace(PurchaseAddress, ',', '.'), 2) 

Alter Table AllSalesDataConverted
Add PurchaseSplitState Nvarchar(255);

Update AllSalesDataConverted
Set PurchaseSplitState = PARSENAME(Replace(PurchaseAddress, ',', '.'), 1) 

-- Checking Updated Table

Select *
From AllSalesDataConverted


-- Finding the total amount of sales across the entire year

Select Sum(QuantityOrdered) as TotalSales, ROUND(Sum(PriceEach), 2) as TotalPrice
From AllSalesDataConverted


-- What is the monthly revenue?

Select Sum(QuantityOrdered) as TotalSales, ROUND(Sum(PriceEach), 2) as TotalPrice
From AllSalesDataConverted
Group By OrderMonth

-- Best and Worst Selling Products

Select Sum(QuantityOrdered) as TotalSales, ROUND(Sum(PriceEach), 2) as TotalPrice, Product
From AllSalesDataConverted
Group By Product
Order By 1,2

-- Best Selling City by Averages

Select PurchaseSplitCity, Sum(QuantityOrdered) as TotalSales, ROUND(Sum(PriceEach), 2) as TotalPrice
From AllSalesDataConverted
Group By PurchaseSplitCity
Order By TotalSales

-- Creating Views for later visualization

Create View ProductsSold as
Select Sum(QuantityOrdered) as TotalSales, ROUND(Sum(PriceEach), 2) as TotalPrice, Product
From AllSalesDataConverted
Group By Product

Create View QuantitySoldByCity as
Select PurchaseSplitCity, Sum(QuantityOrdered) as TotalSales, ROUND(Sum(PriceEach), 2) as TotalPrice
From AllSalesDataConverted
Group By PurchaseSplitCity

Create View MonthlyRevenue as
Select Sum(QuantityOrdered) as TotalSales, ROUND(Sum(PriceEach), 2) as TotalPrice
From AllSalesDataConverted
Group By OrderMonth








