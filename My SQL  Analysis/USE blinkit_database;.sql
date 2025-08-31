USE blinkit_database;

SET SQL_SAFE_UPDATES = 0;

-- data cleaning
UPDATE blinkit_grocerry
SET item_fat_content = 
CASE 
    WHEN item_fat_content IN ('low fat', 'LF') THEN 'Low Fat'
    WHEN item_fat_content IN ('regular', 'reg') THEN 'Regular'
    ELSE item_fat_content
END;

SELECT DISTINCT(item_fat_content) FROM blinkit_grocerry;

-- KPI requirements

-- 1. TOTAL SALES
SELECT ROUND(SUM(sales)/100000,2) AS total_sales_lakhs
FROM blinkit_grocerry;

-- 2. AVERAGE SALES
SELECT ROUND(AVG(sales),0) AS avg_sales
FROM blinkit_grocerry;

-- 3. NO OF ITEMS
SELECT COUNT(*) AS No_of_Orders
FROM blinkit_grocerry;

-- 4. AVG RATING
SELECT CAST(AVG(Rating) AS DECIMAL(10,1)) AS Avg_Rating
FROM blinkit_grocerry;

-- Granular requirements 

-- 1. Total Sales by Item Type
SELECT Item_Type, CAST(SUM(Sales) AS DECIMAL(10,2)) AS Total_Sales
FROM blinkit_grocerry
GROUP BY Item_Type
ORDER BY Total_Sales DESC;

-- 2. Impact of Fat Content on Sales
SELECT Item_Fat_Content, COUNT(*) AS Num_Items, SUM(Sales) AS Total_Sales, AVG(Sales) AS Avg_Sales
FROM blinkit_grocerry
GROUP BY Item_Fat_Content;


-- 3. Top 10 Selling Products
SELECT Item_Identifier, SUM(Sales) AS Total_Sales
FROM blinkit_grocerry
GROUP BY Item_Identifier
ORDER BY Total_Sales DESC
LIMIT 10;

-- 4. Sales by Outlet Type
SELECT Outlet_Type, SUM(Sales) AS Total_Sales, AVG(Sales) AS Avg_Sales
FROM blinkit_grocerry
GROUP BY Outlet_Type
ORDER BY Total_Sales DESC;

-- 5. High Visibility Items but Low Sales
SELECT Item_Identifier, Item_Visibility, Sales
FROM blinkit_grocerry
WHERE Item_Visibility > 0.15
ORDER BY Sales ASC
LIMIT 10;

-- 6. Outlet Size vs Sales
SELECT Outlet_Size, SUM(Sales) AS Total_Sales, AVG(Sales) AS Avg_Sales
FROM blinkit_grocerry
GROUP BY Outlet_Size
ORDER BY Total_Sales DESC;

-- 7. Category-wise Average Sales
SELECT Item_Type, AVG(Sales) AS Avg_Sales, SUM(Sales) AS Total_Sales
FROM blinkit_grocerry
GROUP BY Item_Type
ORDER BY Avg_Sales DESC;

-- 8. Top 5 Categories in Each Outlet Type (Window Function)
SELECT *
FROM (
    SELECT Outlet_Type, Item_Type, SUM(Sales) AS Total_Sales,
           RANK() OVER (PARTITION BY Outlet_Type ORDER BY SUM(Sales) DESC) AS RankInOutlet
    FROM blinkit_grocerry
    GROUP BY Outlet_Type, Item_Type
) AS ranked_data
WHERE RankInOutlet <= 5;


-- 9. Find Items with Different Ratings in Different Outlets
SELECT a.Item_Identifier,
       a.Item_Type,
       a.Outlet_Identifier AS Outlet_A,
       a.Rating AS Rating_A,
       b.Outlet_Identifier AS Outlet_B,
       b.Rating AS Rating_B
FROM blinkit_grocerry a
JOIN blinkit_grocerry b
     ON a.Item_Identifier = b.Item_Identifier
    AND a.Outlet_Identifier <> b.Outlet_Identifier
WHERE a.Rating <> b.Rating;

-- 10. Percentage of Sales by Outlet Size
SELECT 
    Outlet_Size, 
    CAST(SUM(Sales) AS DECIMAL(10,2)) AS Total_Sales,
    CAST((SUM(Sales) * 100.0 / SUM(SUM(Sales)) OVER()) AS DECIMAL(10,2)) AS Sales_Percentage
FROM blinkit_grocerry
GROUP BY Outlet_Size
ORDER BY Total_Sales DESC;

-- 11. Sales by Outlet Location
SELECT Outlet_Location_Type, 
       CAST(SUM(Sales) AS DECIMAL(10,2)) AS Total_Sales
FROM blinkit_grocerry
GROUP BY Outlet_Location_Type
ORDER BY Total_Sales DESC;

-- 12. All Metrics by Outlet Type
SELECT Outlet_Type, 
       CAST(SUM(Sales) AS DECIMAL(10,2)) AS Total_Sales,
       CAST(AVG(Sales) AS DECIMAL(10,0)) AS Avg_Sales,
       COUNT(*) AS No_Of_Items,
       CAST(AVG(Rating) AS DECIMAL(10,2)) AS Avg_Rating,
       CAST(AVG(Item_Visibility) AS DECIMAL(10,2)) AS Avg_Visibility
FROM blinkit_grocerry
GROUP BY Outlet_Type
ORDER BY Total_Sales DESC;
