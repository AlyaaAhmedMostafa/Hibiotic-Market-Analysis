Select *
From [dbo].[Hibiotic]Pharma


-- OVERALL DATA SUMMARY: Core sales, volume, price, and date range for all records
SELECT
    COUNT(*) AS total_transactions,
    SUM(units_sold) AS total_units_sold,
    SUM(sales_egp) AS total_sales_egp,
    AVG(price_per_unit_egp) AS avg_price_per_unit,
    MIN(date) AS first_date,
    MAX(date) AS last_date
FROM [dbo].[Hibiotic]Pharma;

-- DISTRIBUTOR PERFORMANCE: Ranking distributors by sales, units sold, and realized price
SELECT distributor, 
       SUM(sales_egp) AS total_sales,
       SUM(units_sold) AS total_units,
       ROUND(SUM(sales_egp) / SUM(units_sold), 2) AS avg_sales_per_unit
FROM [dbo].[Hibiotic]Pharma
GROUP BY distributor
ORDER BY total_sales DESC;

-- PACK SIZE PERFORMANCE: Total sales and quantity sold per pack size configuration
SELECT pack_size, 
       SUM(sales_egp) AS total_sales,
       SUM(units_sold) AS total_units
FROM [dbo].[Hibiotic]Pharma
GROUP BY pack_size
ORDER BY total_sales DESC;

-- CONCENTRATION PERFORMANCE: Total sales and quantity sold by product concentration
SELECT concentration, 
       SUM(sales_egp) AS total_sales,
       SUM(units_sold) AS total_units
FROM [dbo].[Hibiotic]Pharma
GROUP BY concentration
ORDER BY total_sales DESC;

-- Price Point Analysis: Summarizes total sales and units sold by each unique price per unit to identify top sales-generating price levels.
SELECT price_per_unit_egp, 
       SUM(sales_egp) AS total_sales,
       SUM(units_sold) AS total_units
FROM [dbo].[Hibiotic]Pharma
GROUP BY price_per_unit_egp
ORDER BY total_sales DESC;

-- PROMOTIONAL CAMPAIGN IMPACT: Sales and transaction count with/without promo flags
SELECT 
    promotion_flag, 
    SUM(sales_egp) AS total_sales, 
	ROUND(100.0 * SUM(sales_egp) / SUM(SUM(sales_egp)) OVER (), 2) AS percent_sales,
    COUNT(*) AS transaction_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS percent_transactions
FROM [dbo].[Hibiotic]Pharma
GROUP BY promotion_flag;


-- COMPETITIVE LANDSCAPE: Number of transactions, Competitor sales and related sales when competitors are present
SELECT competitor_name, 
       COUNT(*) AS encounter_count, 
	   SUM (Competitors_Sales_Track) AS competitors_Sales,
       SUM(sales_egp) AS related_sales
FROM [dbo].[Hibiotic]Pharma
WHERE competitor_present = 'Yes'
GROUP BY competitor_name
ORDER BY encounter_count DESC;

-- PRESCRIPTION vs OTC IMPACT: Sales and units divided by whether a prescription is required
SELECT 
    prescription_required, 
    SUM(sales_egp) AS total_sales,
	ROUND(100.0 * SUM(sales_egp) / SUM(SUM(sales_egp)) OVER (), 2) AS percent_sales,
    SUM(units_sold) AS total_units,
    ROUND(100.0 * SUM(units_sold) / SUM(SUM(units_sold)) OVER (), 2) AS percent_units
FROM [dbo].[Hibiotic]Pharma
GROUP BY prescription_required;


-- PRICING & Sales EFFICIENCY: Average list price and realized price per distributor
SELECT distributor,
       AVG(price_per_unit_egp) AS avg_list_price,
       SUM(sales_egp) / SUM(units_sold) AS effective_price_realized
FROM [dbo].[Hibiotic]Pharma
GROUP BY distributor
ORDER BY effective_price_realized DESC;

-- ANNUAL SALES AGGREGATES: Total units, EGP sales, and average price per year
SELECT Year,
       SUM(units_sold) AS total_units,
       SUM(sales_egp) AS total_sales,
       AVG(price_per_unit_egp) AS avg_unit_price
FROM [dbo].[Hibiotic]Pharma
GROUP BY Year
ORDER BY Year;

--  QUARTERLY PERFORMANCE TRENDS: Quarterly sales, prior quarter comparison, and growth rates
SELECT year, quarter, 
       SUM(sales_egp) AS quarterly_sales,
       LAG(SUM(sales_egp)) OVER (ORDER BY year, quarter) AS previous_quarter_sales,
       ROUND(
          (SUM(sales_egp) - LAG(SUM(sales_egp)) OVER (ORDER BY year, quarter)) 
          / NULLIF(LAG(SUM(sales_egp)) OVER (ORDER BY year, quarter), 0) * 100, 2
       ) AS growth_rate
FROM [dbo].[Hibiotic]Pharma
GROUP BY year, quarter
ORDER BY year, quarter;

--  MONTHLY PRICE & VOLUME CHARACTERISTICS: Summary statistics (min, max) for monthly prices and units
WITH monthly AS (
  SELECT YEAR(date) AS yr, MONTH(date) AS m,
         AVG(price_per_unit_egp) AS avg_price,
         SUM(units_sold) AS total_units
  FROM [dbo].[Hibiotic]Pharma
  GROUP BY YEAR(date), MONTH(date)
)
SELECT 
       COUNT(*) AS months_count,
       MIN(avg_price) AS min_price, 
       MAX(avg_price) AS max_price,
       MIN(total_units) AS min_units, 
       MAX(total_units) AS max_units
FROM monthly;






