CREATE DATABASE amazon;

USE amazon;

CREATE TABLE amazon_data
(
    Invoice_ID VARCHAR(30) NOT NULL,
    Branch VARCHAR(5) NOT NULL,
    City VARCHAR(30) NOT NULL,
    Customer_type VARCHAR(30) NOT NULL,
    Gender VARCHAR(10) NOT NULL,
    Product_line VARCHAR(100) NOT NULL,
    Unit_price DECIMAL(10, 2) NOT NULL,
    Quantity INT NOT NULL,
    Tax_5_Percent FLOAT NOT NULL,
    Total DECIMAL(10, 2) NOT NULL,
    Date DATE NOT NULL,
    Time TIME NOT NULL,
    Payment VARCHAR(30) NOT NULL,
    COGS DECIMAL(10, 2) NOT NULL,
    Gross_margin_percentage FLOAT NOT NULL,
    Gross_income DECIMAL(10, 2) NOT NULL,
    Rating FLOAT NOT NULL
);

SELECT * FROM amazon.amazon_data;

-- Add column timeofday varchar(10)

ALTER TABLE amazon_data
ADD COLUMN timeofday VARCHAR(10);

SET sql_safe_updates = 0;

-- Updating Values in timeofday column

UPDATE amazon.amazon_data
SET timeofday = CASE
    WHEN TIME(Time) BETWEEN '00:00:00' AND '11:59:59' THEN 'Morning'
    WHEN TIME(Time) BETWEEN '12:00:00' AND '17:59:59' THEN 'Afternoon'
    ELSE 'Evening'
END;

-- Add column dayname varchar (10)

ALTER TABLE amazon.amazon_data
ADD COLUMN dayname VARCHAR(10);

-- Updating values in dayname

UPDATE amazon.amazon_data
SET dayname = CASE
    WHEN DAYNAME(Date) = 'Monday' THEN 'Mon'
    WHEN DAYNAME(Date) = 'Tuesday' THEN 'Tue'
    WHEN DAYNAME(Date) = 'Wednesday' THEN 'Wed'
    WHEN DAYNAME(Date) = 'Thursday' THEN 'Thu'
    WHEN DAYNAME(Date) = 'Friday' THEN 'Fri'
    WHEN DAYNAME(Date) = 'Saturday' THEN 'Sat'
    WHEN DAYNAME(Date) = 'Sunday' THEN 'Sun'
END;

-- Add column monthname varchar (10)

ALTER TABLE amazon.amazon_data
ADD COLUMN monthname VARCHAR(10);


-- Updating values in monthname

UPDATE amazon.amazon_data
SET monthname = CASE
    WHEN MONTHNAME(Date) = 'January' THEN 'Jan'
    WHEN MONTHNAME(Date) = 'February' THEN 'Feb'
    WHEN MONTHNAME(Date) = 'March' THEN 'Mar'
    WHEN MONTHNAME(Date) = 'April' THEN 'Apr'
    WHEN MONTHNAME(Date) = 'May' THEN 'May'
    WHEN MONTHNAME(Date) = 'June' THEN 'Jun'
    WHEN MONTHNAME(Date) = 'July' THEN 'Jul'
    WHEN MONTHNAME(Date) = 'August' THEN 'Aug'
    WHEN MONTHNAME(Date) = 'September' THEN 'Sep'
    WHEN MONTHNAME(Date) = 'October' THEN 'Oct'
    WHEN MONTHNAME(Date) = 'November' THEN 'Nov'
    WHEN MONTHNAME(Date) = 'December' THEN 'Dec'
END;


-- 1. What is the count of distinct cities in the dataset?

SELECT DISTINCT
    City
FROM
    amazon.amazon_data;


-- 2. For each branch, what is the corresponding city?

SELECT DISTINCT
    Branch, City
FROM
    amazon.amazon_data;


-- 3. What is the count of distinct product lines in the dataset?

SELECT 
    COUNT(DISTINCT (Product_line)) AS distinct_product_lines
FROM
    amazon.amazon_data;


-- 4.Which payment method occurs most frequently?

SELECT 
    Payment, COUNT(*) AS frequent_payments_count
FROM
    amazon.amazon_data
GROUP BY Payment
ORDER BY frequent_payments_count DESC;


-- 5. Which product line has the highest sales?

SELECT 
    Product_line, COUNT(*) AS total_sales
FROM
    amazon.amazon_data
GROUP BY Product_line
ORDER BY total_sales DESC
LIMIT 1;


-- 6.How much revenue is generated each month?

SELECT 
    monthname, SUM(Total) AS revenue
FROM
    amazon.amazon_data
GROUP BY monthname
ORDER BY revenue DESC;


-- 7.In which month did the cost of goods sold reach its peak?

SELECT 
    monthname, SUM(COGS) AS total_cogs
FROM
    amazon.amazon_data
GROUP BY monthname
ORDER BY total_cogs DESC;


-- 8. Which product line generated the highest revenue?

SELECT 
    Product_line, SUM(total) AS highest_revenue
FROM
    amazon.amazon_data
GROUP BY Product_line
ORDER BY highest_revenue DESC;


-- 9.In which city was the highest revenue recorded?

SELECT 
    City, SUM(total) AS highest_revenue
FROM
    amazon.amazon_data
GROUP BY City
ORDER BY highest_revenue DESC;


-- 10. Which product line incurred the highest Value Added Tax?

SELECT 
    Product_line, SUM(Tax_5_Percent) AS Total_vat
FROM
    amazon.amazon_data
GROUP BY Product_line
ORDER BY Total_vat DESC;


-- 11. For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad".

SELECT 
    Product_line,
    SUM(Total) AS total_sales,
    CASE
        WHEN
            SUM(total) > (SELECT 
                    AVG(total_sales)
                FROM
                    (SELECT 
                        Product_line, SUM(Total) AS total_sales
                    FROM
                        amazon.amazon_data
                    GROUP BY Product_line) AS subquery)
        THEN
            'Good'
        ELSE 'bad'
    END AS sales_status
FROM
    amazon.amazon_data
GROUP BY Product_line
ORDER BY total_sales DESC;


-- 12. Identify the branch that exceeded the average number of products sold.

SELECT 
    Branch, SUM(Quantity) AS total_quantity
FROM
    amazon.amazon_data
GROUP BY Branch
HAVING SUM(Quantity) > (SELECT 
        AVG(Quantity)
    FROM
        amazon.amazon_data);
        
        
-- 13. Which product line is most frequently associated with each gender?

SELECT 
    Product_line, Gender, COUNT(*) AS product_line_count
FROM
    amazon.amazon_data
GROUP BY Gender , Product_line
ORDER BY product_line_count DESC;


-- 14. Calculate the average rating for each product line.

SELECT 
    Product_line, AVG(Rating) AS avg_rating
FROM
    amazon.amazon_data
GROUP BY Product_line
ORDER BY avg_rating DESC;


-- 15. Count the sales occurrences for each time of day on every weekday.

SELECT 
    timeofday, dayname, COUNT(*) AS sales_occurence
FROM
    amazon.amazon_data
WHERE
    dayname IN ('Mon' , 'Tue', 'Wed', 'Thu', 'Fri')
GROUP BY timeofday , dayname
ORDER BY sales_occurence DESC;


-- 16. Identify the customer type contributing the highest revenue.

SELECT 
    Customer_type, SUM(Total) AS highest_revenue
FROM
    amazon.amazon_data
GROUP BY Customer_type
ORDER BY highest_revenue DESC
LIMIT 1;


-- 17. Determine the city with the highest VAT percentage.

SELECT 
    City,
    SUM(Tax_5_Percent) AS highest_vat,
    SUM(Total) AS total_sales,
    (SUM(Tax_5_Percent) / SUM(Total)) * 100 AS vat_percentage
FROM
    amazon.amazon_data
GROUP BY City
ORDER BY vat_percentage DESC
LIMIT 1;


-- 18. Identify the customer type with the highest VAT payments.

SELECT 
    Customer_type, SUM(Tax_5_Percent) AS highest_vat_payments
FROM
    amazon.amazon_data
GROUP BY Customer_type
ORDER BY highest_vat_payments DESC
LIMIT 1;


-- 19. What is the count of distinct customer types in the dataset?

SELECT 
    COUNT(DISTINCT (Customer_type)) AS distinct_customers
FROM
    amazon.amazon_data;
    
    
-- 20. What is the count of distinct payment methods in the dataset?

SELECT 
    COUNT(DISTINCT (Payment)) AS distinct_payment
FROM
    amazon.amazon_data;


-- 21. Which customer type occurs most frequently?

SELECT 
    Customer_type,
    COUNT(Customer_type) AS frequent_customer_type
FROM
    amazon.amazon_data
GROUP BY Customer_type
ORDER BY frequent_customer_type DESC;


-- 22. Identify the customer type with the highest purchase frequency.

SELECT 
    Customer_type, COUNT(*) AS highest_purchase
FROM
    amazon.amazon_data
GROUP BY Customer_type
ORDER BY highest_purchase DESC
LIMIT 1;


-- 23. Determine the predominant gender among customers.

SELECT 
    Gender, COUNT(*) AS predominant_gender
FROM
    amazon.amazon_data
GROUP BY Gender
ORDER BY predominant_gender DESC
LIMIT 1;


-- 24. Examine the distribution of genders within each branch.

SELECT 
    Branch, Gender, COUNT(*) AS gender_count
FROM
    amazon.amazon_data
GROUP BY Branch, Gender
ORDER BY gender_count DESC;


-- 25. Identify the time of day when customers provide the most ratings.

SELECT 
    timeofday, COUNT(Rating) AS rating_count
FROM
    amazon.amazon_data
GROUP BY timeofday
ORDER BY rating_count DESC
LIMIT 1;


-- 26. Determine the time of day with the highest customer ratings for each branch.

SELECT 
    Branch, timeofday, AVG(Rating) AS average_rating
FROM
    amazon.amazon_data
GROUP BY Branch , timeofday
ORDER BY average_rating DESC;


-- 27. Identify the day of the week with the highest average ratings.

SELECT 
    dayname, AVG(Rating) AS highest_average_rating
FROM
    amazon.amazon_data
GROUP BY dayname
ORDER BY highest_average_rating DESC
LIMIT 1;


-- 28. Determine the day of the week with the highest average ratings for each branch.

SELECT 
    Branch, dayname, AVG(Rating) AS avg_rating
FROM
    amazon.amazon_data
GROUP BY Branch , dayname
ORDER BY avg_rating DESC;


















