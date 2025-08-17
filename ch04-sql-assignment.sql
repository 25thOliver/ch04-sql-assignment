-- Section 1 – Core SQL Concepts 
-- Q1: Write a SQL query to list all customers located in Nairobi. Show only full_name and location.
select ci.full_name, ci.location
from customer_info ci 
where ci.location = 'Nairobi';

-- Q2: Write a SQL query to display each customer along with the products they purchased. Include full_name, product_name, and price.
select ci.full_name, p.product_name, p.price 
from products p 
join customer_info ci on p.customer_id = ci.customer_id;

-- Q3: Write a SQL query to find the total sales amount for each customer. Display full_name and the total amount spent, sorted in descending order.
select ci.full_name, sum(s.total_sales) as total_spent
from sales s 
join customer_info ci on s.customer_id = ci.customer_id 
group by ci.full_name 
order by total_spent desc;

-- Q4: Write a SQL query to find all customers who have purchased products priced above 10,000.
select ci.full_name, p.product_name, p.price, p.price 
from products p 
join customer_info ci on p.customer_id = ci.customer_id
where p.price > 10000;

-- Q5: Write a SQL query to find the top 3 customers with the highest total sales.
select ci.full_name, sum(s.total_sales) as highest_total_sales
from sales s 
join customer_info ci on s.customer_id = ci.customer_id 
group by ci.full_name 
order by highest_total_sales DESC 
limit 3;


-- Section 2 – Advanced SQL Techniques
-- Q6: Write a CTE that calculates the average sales per customer and then returns customers whose total sales are above that average.
with CustomerSales as (
	select ci.customer_id, ci.full_name, sum(s.total_sales) as total_sales
	from customer_info ci 
	join sales s on ci.customer_id = s.customer_id 
	group by ci.customer_id, ci.full_name 
),
Avg_Sales as (
	select avg(total_sales) as avg_sales from CustomerSales
)
select cs.full_name, cs.total_sales
from CustomerSales cs, Avg_Sales a
where cs.total_sales > a.avg_sales;

-- Q7: Write a Window Function query that ranks products by their total sales in descending order. Display product_name, total_sales, and rank.
select p.product_name,
sum(s.total_sales) as total_sales,
rank() over (order by sum(s.total_sales) desc) as sales_rank
from products p 
join sales s on p.product_id = s.product_id 
group by p.product_name;

-- Q8: Create a View called high_value_customers that lists all customers with total sales greater than 15,000.
create view high_value_customers as
select ci.customer_id, ci.full_name, sum(s.total_sales) as total_sales
from customer_info ci 
join sales s on ci.customer_id = s.customer_id 
group by ci.customer_id, ci.full_name 
having sum(s.total_sales ) > 15000;

-- usage
select * from high_value_customers hvc;

-- Q9: Create a Stored Procedure that accepts a location as input and returns all customers and their total spending from that location.
create procedure GetCustomerByLocation(in loc varchar(90))
begin
	select ci.full_name, ci.location, sum(s.total_sales) as total_spent
	from customer_info ci
	join sales s on ci.customer_id = s.customer_id
	where ci.location = loc
	group by ci.full_name, ci.location;
end;

-- usage
CALL  GetCustomerByLocation('Nairobi');


-- Q10: Write a recursive query to display all sales transactions in order by sales_id, along with a running total of sales.
with recursive SalesCTE as (
	-- Anchor member: first row
	select s.sales_id, s.total_sales, s.total_sales as running_total
	from sales s
	where s.sales_id = (select min(sales_id) from sales)
	
	union all
	
	-- Recursive member: next rows
	select s.sales_id, s.total_sales, sc.running_total + s.total_sales
	from sales s
	join SalesCTE sc on s.sales_id = sc.sales_id + 1
)
select * from SalesCTE;


-- Section 3 – Query Optimization & Execution Plans
-- Q11: The following query is running slowly:
-- SELECT * FROM sales WHERE total_sales > 5000;
-- Explain two changes you would make to improve its performance and then write the optimized SQL query.

-- original query:
select * from sales s where total_sales > 5000;

-- 1. Create an index on `total_sales` so filtering doesn't require a full table scan.
create index idx_sales_total on sales(total_sales);

-- 2. Select only needed columns instead of `SELECT *`. This reduces I/O
-- and memory usage. For instance, if we only need sales_id, customer_id, and total_sales
-- we avoi pulling unnecessary columns.
-- Optimized query
select sales_id, customer_id, total_sales
from sales s 
where s.total_sales > 5000;

-- Q12: Create an index on a column that would improve queries filtering by customer location, then write a query to test the improvement.

-- 1. Create the index(on location in customer_info)
create index idx_customer_location on customer_info(location);

-- 2. Query to test improvement (before the index, MYSQL scans all rows; after, it uses the index)
explain select full_name, location
from customer_info
where location = 'Nairobi';


-- Section 4 – Data Modeling
-- Q13: Redesign the given schema into 3rd Normal Form (3NF) and provide the new CREATE TABLE statements.

-- Customers
create table customers (
customer_id int primary key,
full_name varchar(120) not null,
location varchar(90) not null
);

-- Products
create table products_table (
product_id int primary key,
product_name varchar(120) not null,
price decimal(10, 2) not null,
parent_product_id int null,
foreign key (parent_product_id) references products(product_id)
);

-- 










































































