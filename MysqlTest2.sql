---------------------------------------------------------------------------------------------------------
-- TEST
---------------------------------------------------------------------------------------------------------
use  northwind;

-- 1. Order Subtotals

select OrderId, formate (sum(unitprice * quantity *(1-discount)),2)as Subtotal
from order_details
group by OrderID
Order by OrderID;



-- 2. Sales by Year

select distinct date(ShippedDate) as ShippedDate,
orderId,
sum(quantity * unitprice) as Subtotal,
year(ShippedDate) as Year
from order_details
right join orders
using(orderId)
group by shippedDate;


-- 3. Employee Sales by Country

select 
	country,
    lastName,
    firstName,
    date(shippedDate) as shippedDate,
    orderId,
    sum(unitprice * quantity) as sale_amount
from Employees
join orders
using(employeeid)
join order_details
using(orderId)
group by orderId;


-- 4. Alphabetical List of Products

select
	productId,
    productName,
    supplierId,
    categoryId,
    quantityperunit,
    products.unitprice
from products
join order_details
using(productId)
group by productid
order by productname;


-- 5. Current Product List

select distinct
	productId,
    productName
from products
group by productId;


-- 6. Order Details Extended

select distinct y.OrderID, 
    y.ProductID, 
    x.ProductName, 
    y.UnitPrice, 
    y.Quantity, 
    y.Discount, 
    round(y.UnitPrice * y.Quantity * (1 - y.Discount), 2) as ExtendedPrice
from Products x
inner join Order_Details y on x.ProductID = y.ProductID
order by y.OrderID;


--  7. Sales by Category

select 
	categoryid,
    categoryname,
    productname,
    sum(quantityperunit * unitprice) as productsales
from categories
join products
using(categoryid)
group by  categoryid;


-- 8. Ten Most Expensive Products

select
	productName as Ten_most_expensive_product,
    unitPrice
from products
order by unitprice desc
limit 10;


-- 9. Products by Category
select
	categoryname,
    productName,
    quantityperunit,
    unitsInStock,
    discontinued
from categories
join products
using(categoryid


-- 10. Customers and Suppliers by City.

select City, CompanyName, ContactName, 'Customers' as Relationship 
from Customers
union
select City, CompanyName, ContactName, 'Suppliers'
from Suppliers
order by City, CompanyName;

-- 11. Products Above Average Price

select ProductName, UnitPrice
from Products
where UnitPrice > (	-- inner query
					select avg(UnitPrice) 
                    from Products
                    )
order by UnitPrice;

-- 12. Product Sales for 1997

select  cat.CategoryName, 
    prd.ProductName, 
    format(sum(ordd.UnitPrice * ordd.Quantity * ( 1- ordd.Discount)),2) as ProductSales,
    concat('Qtr', quarter(ords.ShippedDate)) as ShippedQuarter
from Categories as cat
join Products as prd
using(CategoryID)
join Order_Details as ordd
using(ProductID)
join Orders as ords 
using(OrderID)
where ords.ShippedDate between date('1997-01-01') and date('1997-12-31')
group by cat.CategoryName, 
    prd.ProductName,
    concat('Qtr ', quarter(ords.ShippedDate))
order by cat.CategoryName, 
    prd.ProductName,
    ShippedQuarter;

-- 13. Category Sales for 1997

select CategoryName,  format(sum(ProductSales), 2) as CategorySales
from
	(
		select  cat.CategoryName, 
		prd.ProductName, 
		format(sum(ordd.UnitPrice * ordd.Quantity * ( 1- ordd.Discount)),2) as ProductSales,
		concat('Qtr', quarter(ords.ShippedDate)) as ShippedQuarter
	from Categories as cat
	join Products as prd
	using(CategoryID)
	join Order_Details as ordd
	using(ProductID)
	join Orders as ords 
	using(OrderID)
	where ords.ShippedDate between date('1997-01-01') and date('1997-12-31')
	group by cat.CategoryName, 
			prd.ProductName,
		concat('Qtr ', quarter(ords.ShippedDate))
	order by cat.CategoryName, 
			prd.ProductName,
			ShippedQuarter
						) as cate
	group by CategoryName;
    
-- 14. Quarterly Orders by Product

select prd.ProductName, 
       cus.CompanyName, 
    year(OrderDate) as OrderYear,
    format(sum(case quarter(ord.OrderDate) 
    when '1' 
        then ordd.UnitPrice * ordd.Quantity * (1-ordd.Discount) 
        else 0 
        end), 0) "Qtr 1",
    format(sum(case quarter(ord.OrderDate) 
    when '2' 
		 then ordd.UnitPrice * ordd.Quantity * (1-ordd.Discount) 
         else 0 
         end), 0) "Qtr 2",
    format(sum(case quarter(ord.OrderDate) 
    when '3' 
		 then ordd.UnitPrice * ordd.Quantity * (1-ordd.Discount) 
         else 0 
         end), 0) "Qtr 3",
    format(sum(case quarter(ord.OrderDate) 
    when '4' 
        then ordd.UnitPrice * ordd.Quantity * (1-ordd.Discount)
        else 0
        end), 0) "Qtr 4"
from Products as prd 
join Order_Details as ordd  
using(ProductID )
join Orders as ord
 using(OrderID)
join Customers as cus
 using(CustomerID)
where ord.OrderDate between date('1997-01-01') and date('1997-12-31')
group by prd.ProductName, 
         cus.CompanyName, 
		 year(OrderDate)
order by prd.ProductName, cus.CompanyName;

-- 15. Invoice

select b.ShipName, 
    b.ShipAddress, 
    b.ShipCity, 
    b.ShipRegion, 
    b.ShipPostalCode, 
    b.ShipCountry, 
    b.CustomerID, 
    c.CompanyName, 
    c.Address, 
    c.City, 
    c.Region, 
    c.PostalCode, 
    c.Country, 
    concat(d.FirstName, ' ', d.LastName) as Salesperson, 
	b.OrderID, 
    b.OrderDate, 
    b.RequiredDate, 
    b.ShippedDate, 
    a.CompanyName, 
    e.ProductID, 
    f.ProductName, 
    e.UnitPrice, 
    e.Quantity, 
    e.Discount,
    e.UnitPrice * e.Quantity * (1 - e.Discount) as ExtendedPrice,
    b.Freight
from Shippers as a 
join Orders as b 
on a.ShipperID = b.ShipVia 
join Customers as c
using(CustomerID )
join Employees as d 
using(EmployeeID)
join Order_Details as e 
using(OrderID)
join Products as f 
using(ProductID)
order by b.ShipName;

-- 16. Number of units in stock by category and supplier continent

select c.CategoryName as "Product Category", 
       case 
       when s.Country in 
                 ('UK','Spain','Sweden','Germany','Norway',
                  'Denmark','Netherlands','Finland','Italy','France')
            then 'Europe'
		    when s.Country in ('USA','Canada','Brazil') 
            then 'America'
				else 'Asia-Pacific'
			end as "Supplier Continent", 
        sum(p.UnitsInStock) as UnitsInStock
from Suppliers as s 
inner join Products as p 
using(SupplierID)
inner join Categories as c 
using(CategoryID)
group by c.CategoryName, 
         case 
         when s.Country in 
                 ('UK','Spain','Sweden','Germany','Norway',
                  'Denmark','Netherlands','Finland','Italy','France')
              then 'Europe'
		 when s.Country in ('USA','Canada','Brazil') 
              then 'America'
				else 'Asia-Pacific'
			end;