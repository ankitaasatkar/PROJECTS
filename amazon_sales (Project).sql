------ Amazon Sales Data Analysis ----------
-- Overview of Dataset --
-- The data consists of sales record of three cities/branch in Myanmar 
-- which are Naypyitaw, Yangon, Mandalay which took place in first quarter of year 2019 --
-- the data consists of 1000 rows and 17 columns --


-- Objective of Project --
-- The major aim of this project is to gain insight into the sales data of Amazon --
-- and to understand the different factors that affect sales of the different branches --

create database project;
use project;

select * from amazon 
limit 10;

use projects;

select * from amazon;

--  checking null values and datatypes of columns --
describe amazon;

select count(*) as count_of_null_values from amazon_sales 
where null;

-- Feature Engineering --
-- adding new columns timeofday, dayname, monthname by extracting values from date and time column --
-- this will help to analyse sales based on month, day of week, time of day --- 

select * from amazon;
SET SQL_SAFE_UPDATES = 0;

alter table amazon
add time_of_day varchar(15) not null;

update amazon set time_of_day =
case 
	when hour(time) between 06 and 11 then 'Morning'
	when hour(time) between 12 and 17 then 'Afternoon'
	else 'Evening'
end;

alter table amazon
add day_name varchar(10) not null;

update amazon set day_name =
(select  dayname(date));

alter table amazon
add month_name varchar(10) not null;

update amazon set month_name =
(select monthname(date)); 

select * from amazon limit 10;

select * from amazon;
-- Exploratory Data Analysis --
-- step.1] Creating new table named Amazon Sales by adding correct column names, datatypes, constraints while copying values from demo table Amazon --

create table amazon_sales2
(invoice_id varchar(30) primary key not null,
branch varchar(5) not null,
city varchar(30) not null,
customer_type varchar(30) not null,
gender varchar(10) not null,
product_line varchar(100) not null,
unit_price decimal(10,2) not null,
quantity int not null,
vat float not null,
total decimal(10,2) not null,
date date not null,
time time not null,
payment_method varchar(20) not null,
cogs decimal(10,2) not null,
gross_margin_percentage float not null,
gross_income decimal(10,2) not null,
rating decimal(3,1) not null,
time_of_day varchar(15) not null,
day_name varchar(10) not null,
month_name varchar(10) not null);

insert into amazon_sales
(select * from amazon_sales2);

select * from amazon_sales2;

---- Checking size of table, count of null values, unique values  in columns --

select count(*) as total_columns from information_schema.columns
where table_name ='amazon_sales2';


select count(*) as total_rows from amazon_sales2;

select count(*) as null_values from amazon_sales2 where null;


--  checking unique values in each categorical column -- 
select distinct(branch) branch from amazon_sales;
select distinct(city) city from amazon_sales;
select distinct(customer_type) customer_type from amazon_sales2;
select distinct(gender) gender from amazon_sales;
select distinct(product_line) product_line from amazon_sales2;
select distinct(payment_method) payment_method from amazon_sales;
select distinct(time_of_day) time_of_day from amazon_sales;
select distinct(day_name) day_name from amazon_sales;
select distinct(month_name) month_name from amazon_sales;
#-------------------------------------------------------------------------------------------------------#


-- Answering Questions --

# 1. What is the count of distinct cities in the dataset?
select count(distinct(city)) from amazon;

# 2. For each branch, what is the corresponding city?
select distinct city, branch from amazon;

# 3. What is the count of distinct product lines in the dataset?
select count(distinct('product line')) from amazon;

# 4. Which payment method occurs most frequently?
select 'payment method', count(*) as occurance from amazon
group by 'payment method'
order by occurance desc; 

# 5. Which product line has the highest sales?
select 'product line', sum(quantity) as total_sales from amazon 
group by 'product line' 
order by total_sales desc;

# 6. How much revenue is generated each month?
select month_name, sum(total) as monthly_revenue$ from amazon
group by month_name
order by monthly_revenue$ desc;

# 7. In which month did the cost of goods sold reach its peak?
select month_name, sum(cogs) as cost_of_goods_sold from amazon
group by month_name
order by cost_of_goods_sold desc;

# 8. Which product line generated the highest revenue?

select 'product line', sum(total) as total_revenue$ from amazon 
group by 'product_line' 
order by total_revenue$ desc;

# 9. In which city was the highest revenue recorded?

select city, sum(total) as revenue$ from amazon
group by city
order by revenue$ desc;

# 10. Which product line incurred the highest Value Added Tax?
select product_line, max(vat)  as highest_vat  from amazon
group by product_line
order by highest_vat desc;

# 11. For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."
select 'product line', sum(total) as revenue, 
case 
	when sum(total) > (select sum(total)/count(distinct('product line')) from amazon) then 'Good'
    else 'Bad'
end performance
from amazon
group by 'product line';

#12. Identify the branch that exceeded the average number of products sold.
select branch, sum(quantity) as product_sold from amazon
group by branch
having product_sold > (select sum(quantity)/count(distinct branch) as avg_quantity from amazon);

#13. Which product line is most frequently associated with each gender?
with new as 
(select gender, 'product line', count(*) as count from amazon
group by gender, 'product line'),

 max_count as 
(select max(count) from new group by gender)

select * from new 
where count in (select * from max_count) limit 2;

#14. Calculate the average rating for each product line.

select 'product line', avg(rating) as avg_rating from amazon
group by 'product line'; 

#15. Count the sales occurrences for each time of day on every weekday.

select day_name, time_of_day, count(*) sales from amazon 
group by day_name, time_of_day
order by field(day_name, 'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'), 
field(time_of_day, 'Morning', 'Afternoon', 'Evening');
        
#16. Identify the customer type contributing the highest revenue.
select 'customer type', sum(total) as revenue from amazon
group by 'customer_type'
order by revenue desc;

#17. Determine the city with the highest VAT percentage.
select city, max(vat) as vatpercentage from amazon
group by city 
order by vatpercentage desc; 

#18. Identify the customer type with the highest VAT payments.
select 'customer type', max(vat) as 'vat percentage' from amazon
group by 'customer type' 
order by 'vat percentage' desc;

#19. What is the count of distinct customer types in the dataset?
select count(distinct('customer type')) as count_distinct_customer_type from amazon;

#20. What is the count of distinct payment methods in the dataset?
select count(distinct('payment method')) as count_distinct_payment from amazon;

#21. Which customer type occurs most frequently?
select 'customer type', count(*) as count from amazon
group by 'customer type'
order by count desc;

#22. Identify the customer type with the highest purchase frequency.

select 'customer type', sum(total) as 'purchase frequency' from amazon
group by 'customer type'
order by 'purchase frequency' desc;

#23. Determine the predominant gender among customers.

select gender, count(*) as count from amazon
group by gender 
order by count desc;

#24. Examine the distribution of genders within each branch.
 
select branch, gender, count(*) as count from amazon
group by branch, gender 
order by branch, gender;

#25. Identify the time of day when customers provide the most ratings.

select time_of_day, count(rating) as rating_count from amazon
group by time_of_day
order by rating_count desc;

#26. Determine the time of day with the highest customer ratings for each branch.

select branch, time_of_day, max(rating) highest_rating from amazon
group by branch, time_of_day
having highest_rating = (select max(x.max) from (select branch, time_of_day, max(rating) max from amazon
group by branch, time_of_day) as x where x.branch= amazon_sales.branch)
order by branch;

#27. Identify the day of the week with the highest average ratings.

select day_name, avg(rating) as avg_rating from amazon
group by day_name
order by avg_rating desc;

#28. Determine the day of the week with the highest average ratings for each branch.
with avg_rating as
(select branch, day_name, avg(rating) avg_rat from amazon
group by branch, day_name),
max_rating as 
(select max(avg_rat) from avg_rating group by branch)
select branch, day_name, avg_rat as highest_avg_rat from avg_rating where avg_rat in (select * from max_rating);



-- Findings from Amazon Sales Dataset --

#### Product Analysis: ###
-- Highest Sales Product Line: Electronic Accessories (Units Sold:971) --
-- Highest Revenue Product Line: Food and Beverages ($ 56144.96)--
-- Lowest Sales Product Line: Health and Beauty (Unit Sold: 854) --
-- Lowest Revenue Product Line: Health and Beauty ($ 49193.84) --

#### Sales Analysis: ####
-- Month With Highest Revenue: January ($ 116292.11) --
-- City & Branch With Highest Revenue: Naypyitaw[C] ($ 110568.86)--
-- Month With Lowest Revenue: February ($ 97219.58) --
-- City & Branch With Lowest Revenue: Mandalay[B] ($ 106198.00) --
-- Peak Sales Time Of Day: Afternoon --
-- Peak Sales Day Of Week: Saturday --

#### Customer Analysis: ####
-- Most Predominant Gender: Female --
-- Most Predominant Customer Type: Member --
-- Highest Revenue Gender: Female ($ 167883.26) --
-- Highest Revenue Customer Type: Member ($ 164223.81) --
-- Most Popular Product Line (Male): Health and Beauty --
-- Most Popular Product Line (Female): Fashion Accessories --
-- Distribution Of Members Based On Gender: Male(240) Female(261) --
-- Sales Male: 2641 units --
-- Sales Female: 2869 units --
