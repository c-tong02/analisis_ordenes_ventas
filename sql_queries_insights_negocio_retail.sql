CREATE TABLE df_orders (
	[order_id] int primary key,
	[order_date] date,
	[ship_mode] varchar(20),
	[segment] varchar(20),
	[country] varchar(20),
	[city] varchar(20),
	[state] varchar(20),
	[postal_code] varchar(20),
	[region] varchar(20),
	[category] varchar(20),
	[sub_category] varchar(20),
	[product_id] varchar(20),
	[quantity] int,
	[discount] decimal(7,2),
	[sale_price] decimal(7,2),
	[profit] decimal(7,2))

select * from df_orders

-- encuentra los 10 productos que más ganancia generan
SELECT top 10 product_id, SUM(sale_price) as sales
FROM df_orders
GROUP BY product_id
ORDER BY SUM(profit) DESC


-- encuentra los 5 productos más vendidos en cada region
WITH cte as (
SELECT region, product_id, SUM(quantity) as quantity
FROM df_orders
GROUP BY region, product_id)
SELECT * FROM (
SELECT *
, ROW_NUMBER() OVER (PARTITION BY region ORDER BY quantity DESC) as rn
FROM cte) A
WHERE rn <= 5


-- compara el crecimiento en ventas mes a mes para 2022 y 2023. ej: enero 2022 vs enero 2023
WITH cte AS (
SELECT YEAR(order_date) as order_year, MONTH(order_date) as order_month, SUM(sale_price) as sales
FROM df_orders
GROUP BY YEAR(order_date), MONTH(order_date)
--ORDER BY YEAR(order_date), MONTH(order_date)
	)
SELECT order_month,
	SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS '2022',
	SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS '2023'
FROM cte
GROUP BY order_month
ORDER BY order_month


-- para cada categoría, qué mes tiene las ventas más altas
WITH cte AS (
SELECT category, YEAR(order_date) as order_year, MONTH(order_date) as order_month, SUM(sale_price) as sales
FROM df_orders
GROUP BY category, YEAR(order_date), MONTH(order_date)
	)
SELECT * FROM (
SELECT *,
	ROW_NUMBER() OVER (PARTITION BY category ORDER BY sales DESC) AS rn
FROM cte) A
WHERE rn = 1


-- qué subcategoría tiene el mayor crecimiento en margen del 2023 comparado al 2022
WITH cte AS (
SELECT sub_category, YEAR(order_date) as order_year, SUM(profit) as profit
FROM df_orders
GROUP BY sub_category, YEAR(order_date)
	)
SELECT TOP 1 *, (profit_2023 - profit_2022)/profit_2022*100 as crecimiento FROM(
SELECT sub_category,
	SUM(CASE WHEN order_year = 2022 THEN profit ELSE 0 END) AS profit_2022,
	SUM(CASE WHEN order_year = 2023 THEN profit ELSE 0 END) AS profit_2023
FROM cte
GROUP BY sub_category) A
ORDER BY crecimiento DESC

