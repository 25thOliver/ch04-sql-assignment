# CH04 SQL Assignment - Complete Solutions

This repository contains solutions to 15 comprehensive SQL tasks covering core concepts, advanced techniques, query optimization, and data modeling. Each solution demonstrates best practices and includes detailed explanations.

## Table of Contents
1. [Section 1: Core SQL Concepts](#section-1-core-sql-concepts)
2. [Section 2: Advanced SQL Techniques](#section-2-advanced-sql-techniques)
3. [Section 3: Query Optimization & Execution Plans](#section-3-query-optimization--execution-plans)
4. [Section 4: Data Modeling](#section-4-data-modeling)

---

## Section 1: Core SQL Concepts

### Q1: Customer Location Filter
**Task:** Write a SQL query to list all customers located in Nairobi. Show only full_name and location.

**Solution Approach:**
- Simple SELECT with WHERE clause filtering
- Limited column selection for efficiency
- Direct equality comparison for location

```sql
select ci.full_name, ci.location
from customer_info ci 
where ci.location = 'Nairobi';
```

**Key Learning:** Basic filtering and column selection in SQL.

### Q2: Customer-Product Relationship
**Task:** Display each customer along with the products they purchased. Include full_name, product_name, and price.

**Solution Approach:**
- INNER JOIN between products and customer_info tables
- Joins on customer_id foreign key relationship
- Multi-table data retrieval

```sql
select ci.full_name, p.product_name, p.price 
from products p 
join customer_info ci on p.customer_id = ci.customer_id;
```

**Key Learning:** Understanding table relationships and INNER JOINs.

### Q3: Customer Total Sales Analysis
**Task:** Find the total sales amount for each customer. Display full_name and total amount spent, sorted in descending order.

**Solution Approach:**
- JOIN sales and customer_info tables
- GROUP BY customer to aggregate sales
- SUM function for total calculation
- ORDER BY for descending sort

```sql
select ci.full_name, sum(s.total_sales) as total_spent
from sales s 
join customer_info ci on s.customer_id = ci.customer_id 
group by ci.full_name 
order by total_spent desc;
```

**Key Learning:** Aggregation functions and grouping data.

### Q4: High-Value Product Purchases
**Task:** Find all customers who have purchased products priced above 10,000.

**Solution Approach:**
- JOIN products and customer_info tables
- WHERE clause with price threshold
- Multiple column selection including price validation

```sql
select ci.full_name, p.product_name, p.price, p.price 
from products p 
join customer_info ci on p.customer_id = ci.customer_id
where p.price > 10000;
```

**Key Learning:** Conditional filtering with numeric comparisons.

### Q5: Top 3 Customers by Sales
**Task:** Find the top 3 customers with the highest total sales.

**Solution Approach:**
- JOIN sales and customer_info tables
- GROUP BY and SUM for aggregation
- ORDER BY DESC for ranking
- LIMIT clause for top N results

```sql
select ci.full_name, sum(s.total_sales) as highest_total_sales
from sales s 
join customer_info ci on s.customer_id = ci.customer_id 
group by ci.full_name 
order by highest_total_sales DESC 
limit 3;
```

**Key Learning:** Ranking and limiting results for top N queries.

---

## Section 2: Advanced SQL Techniques

### Q6: Common Table Expression (CTE) for Above-Average Sales
**Task:** Create a CTE that calculates the average sales per customer and returns customers whose total sales are above that average.

**Solution Approach:**
- Multiple CTEs: CustomerSales and Avg_Sales
- First CTE aggregates sales per customer
- Second CTE calculates overall average
- Final query compares individual totals to average

```sql
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
```

**Key Learning:** CTEs for complex multi-step calculations and data comparison.

### Q7: Window Function for Product Ranking
**Task:** Create a Window Function query that ranks products by their total sales in descending order.

**Solution Approach:**
- JOIN products and sales tables
- GROUP BY product for sales aggregation
- RANK() window function with ORDER BY
- Window function provides ranking without additional queries

```sql
select p.product_name,
sum(s.total_sales) as total_sales,
rank() over (order by sum(s.total_sales) desc) as sales_rank
from products p 
join sales s on p.product_id = s.product_id 
group by p.product_name;
```

**Key Learning:** Window functions for analytical queries and ranking.

### Q8: View Creation for High-Value Customers
**Task:** Create a View called high_value_customers that lists all customers with total sales greater than 15,000.

**Solution Approach:**
- CREATE VIEW statement for reusable query logic
- JOIN and GROUP BY for customer sales aggregation
- HAVING clause for post-aggregation filtering
- View encapsulates complex business logic

```sql
create view high_value_customers as
select ci.customer_id, ci.full_name, sum(s.total_sales) as total_sales
from customer_info ci 
join sales s on ci.customer_id = s.customer_id 
group by ci.customer_id, ci.full_name 
having sum(s.total_sales ) > 15000;

-- Usage example
select * from high_value_customers hvc;
```

**Key Learning:** Views for encapsulating complex queries and business logic.

### Q9: Stored Procedure for Location-Based Analysis
**Task:** Create a Stored Procedure that accepts a location as input and returns all customers and their total spending from that location.

**Solution Approach:**
- CREATE PROCEDURE with input parameter
- Dynamic filtering based on location parameter
- JOIN and GROUP BY for customer aggregation
- Parameterized queries for reusability

```sql
create procedure GetCustomerByLocation(in loc varchar(90))
begin
	select ci.full_name, ci.location, sum(s.total_sales) as total_spent
	from customer_info ci
	join sales s on ci.customer_id = s.customer_id
	where ci.location = loc
	group by ci.full_name, ci.location;
end;

-- Usage example
CALL GetCustomerByLocation('Nairobi');
```

**Key Learning:** Stored procedures for parameterized, reusable database operations.

### Q10: Recursive Query for Running Totals
**Task:** Write a recursive query to display all sales transactions in order by sales_id, along with a running total of sales.

**Solution Approach:**
- Recursive CTE with anchor and recursive members
- Anchor: first row (minimum sales_id)
- Recursive: subsequent rows with running total calculation
- Self-join on sequential sales_id values

```sql
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
```

**Key Learning:** Recursive CTEs for hierarchical data and running calculations.

---

## Section 3: Query Optimization & Execution Plans

### Q11: Query Performance Optimization
**Task:** Optimize a slow-running query: `SELECT * FROM sales WHERE total_sales > 5000;`

**Problem Analysis:**
- Using SELECT * retrieves unnecessary columns
- No index on total_sales causes full table scan
- Poor I/O efficiency

**Solution Approach:**
1. **Create Index:** Add index on total_sales column for faster filtering
2. **Column Selection:** Select only required columns instead of SELECT *

```sql
-- 1. Create index for faster filtering
create index idx_sales_total on sales(total_sales);

-- 2. Optimized query with specific columns
select sales_id, customer_id, total_sales
from sales s 
where s.total_sales > 5000;
```

**Performance Benefits:**
- Index eliminates full table scan
- Reduced I/O with specific column selection
- Lower memory usage
- Faster query execution

### Q12: Index Creation and Testing
**Task:** Create an index on customer location and write a query to test the improvement.

**Solution Approach:**
- Index on location column for customer_info table
- Use EXPLAIN to analyze query execution plan
- Compare performance before and after index creation

```sql
-- 1. Create index on location
create index idx_customer_location on customer_info(location);

-- 2. Test query with EXPLAIN
explain select full_name, location
from customer_info
where location = 'Nairobi';
```

**Key Learning:** Index strategy and query execution plan analysis.

---

## Section 4: Data Modeling

### Q13: Database Normalization to 3NF
**Task:** Redesign the given schema into 3rd Normal Form (3NF).

**Normalization Principles Applied:**
- **1NF:** Atomic values, no repeating groups
- **2NF:** No partial dependencies on composite keys
- **3NF:** No transitive dependencies

**Redesigned Schema:**

```sql
-- Customers table (normalized)
create table customers (
customer_id int primary key,
full_name varchar(120) not null,
location varchar(90) not null
);

-- Products table with hierarchy support
create table products_table (
product_id int primary key,
product_name varchar(120) not null,
price decimal(10, 2) not null,
parent_product_id int null,
foreign key (parent_product_id) references products(product_id)
);

-- Sales table with proper relationships
create table sales_table (
sales_id int primary key,
customer_id int not null,
product_id int not null,
quantity int not null,
sales_date date not null,
foreign key (customer_id) references customers(customer_id),
foreign key (product_id) references products_table(product_id)
);
```

**Benefits:** Eliminates data redundancy, ensures data integrity, reduces storage space.

### Q14: Star Schema Design for Analytics
**Task:** Create a Star Schema design for analyzing sales by product and customer location.

**Design Approach:**
- **Fact Table:** Central table with metrics and foreign keys
- **Dimension Tables:** Descriptive attributes for analysis
- **Optimized for OLAP:** Fast aggregation and reporting queries

```sql
-- Dimension Tables
CREATE TABLE dim_customer (
    customer_id INT PRIMARY KEY,
    full_name VARCHAR(120),
    location VARCHAR(90)
);

CREATE TABLE dim_product (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(120),
    category VARCHAR(90),
    price DECIMAL(10,2)
);

CREATE TABLE dim_date (
    date_id DATE PRIMARY KEY,
    year INT,
    quarter INT,
    month INT,
    day INT,
    weekday VARCHAR(20)
);

-- Fact Table
create table fact_sales (
sales_id int primary key,
customer_id int,
product_id int,
sales_date date,
quantity int,
total_amount decimal(12, 2),
foreign key (customer_id) references dim_customer(customer_id),
foreign key (product_id) references dim_product(product_id)
);
```

**Benefits:** Optimized for analytical queries, fast aggregations, intuitive business model.

### Q15: Denormalization for Reporting Performance
**Task:** Demonstrate denormalization to improve reporting query performance.

**Scenario Analysis:**
- **Problem:** Multiple JOINs in reporting queries cause performance issues
- **Solution:** Pre-join frequently accessed data into single table
- **Trade-off:** Storage redundancy vs. query performance

**Denormalized Structure:**

```sql
create table sales_report (
sales_id int primary key,
customer_id int,
full_name varchar(120),
location varchar(90),
product_id int,
product_name varchar(120),
category varchar(90),
price decimal(10, 2),
quantity int,
total_amount decimal(12, 2),
sales_date date
);
```

**Benefits:**
- Eliminates complex JOINs in reporting queries
- Faster read performance for analytics
- Simplified query logic for business users
- Reduced CPU overhead

**Trade-offs:**
- Increased storage requirements
- Data redundancy
- Complex update procedures
- Potential data inconsistency risks

---

## Key Concepts Demonstrated

### Core SQL Skills
- **Filtering and Sorting:** WHERE clauses, ORDER BY
- **Aggregation:** SUM, COUNT, GROUP BY, HAVING
- **Table Relationships:** INNER JOIN, foreign keys
- **Data Limiting:** LIMIT, TOP N queries

### Advanced Techniques
- **Common Table Expressions (CTEs):** Complex multi-step queries
- **Window Functions:** Analytical functions for ranking and running totals
- **Views:** Encapsulating business logic
- **Stored Procedures:** Parameterized, reusable database operations
- **Recursive Queries:** Hierarchical data processing

### Performance Optimization
- **Indexing Strategy:** Improving query performance
- **Query Optimization:** Column selection and execution plans
- **Execution Plan Analysis:** Using EXPLAIN for performance tuning

### Data Modeling
- **Database Normalization:** 1NF, 2NF, 3NF principles
- **Star Schema Design:** Data warehousing and analytics
- **Denormalization:** Performance vs. storage trade-offs

---

## Repository Structure
```
ch04-sql-assignment/
├── README.md                 # This documentation
├── sql-scripts/
│   ├── section1-core.sql    # Core SQL concepts (Q1-Q5)
│   ├── section2-advanced.sql # Advanced techniques (Q6-Q10)
│   ├── section3-optimization.sql # Query optimization (Q11-Q12)
│   └── section4-modeling.sql # Data modeling (Q13-Q15)
└── schema/
    ├── normalized-schema.sql # 3NF database design
    ├── star-schema.sql      # Data warehouse design
    └── denormalized-reporting.sql # Reporting optimization
```

This assignment demonstrates comprehensive SQL skills from basic querying to advanced database design and optimization techniques essential for modern data management and analytics.
