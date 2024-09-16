-- CREATE DATABASE unified_mentor;

USE unified_mentor;

#create a table of bird_strike and import the values 
/* bird_strike table 
-- CREATE TABLE bird_strike(
-- record_id INT PRIMARY KEY,
-- airport_name VARCHAR(220),
-- altitude_bin VARCHAR(30),
-- aircraft_model VARCHAR(60),
-- wildlife_number_struck_actual INT,
-- effect_impact_to_flight VARCHAR(30),
-- flight_date DATE,
-- effect_indicated_damage VARCHAR(30),
-- aircraft_airline VARCHAR(90),
-- origin_state VARCHAR(45),
-- phase_of_flight VARCHAR(30),
-- conditions_precipitation VARCHAR(45),
-- conditions_sky VARCHAR(30),
-- wildlife_species VARCHAR(90),
-- pilot_warned_of_wildlife CHAR(3),
-- total_cost INT,
-- feet_above_ground FLOAT
-- );
*/

SELECT * FROM bird_strike;

#create a table countries that referes to the origin state
/* countries table
CREATE TABLE countries(
origin_state VARCHAR(45) PRIMARY KEY,
country VARCHAR(45)
);
*/
SELECT * FROM countries;

#add a foreign key to show the reference (not mandatory)
/*
-- ALTER TABLE bird_strike
-- ADD CONSTRAINT fk_origin_state FOREIGN KEY (origin_state) REFERENCES countries(origin_state);
*/

-- ------------------------------------------------ CASE STUDY ----------------------------------------------------------------------------

/*Visuals Depicting the Number of Bird Strikes
*/
with total as(
SELECT 
	DISTINCT EXTRACT(YEAR FROM flight_date) AS `year`,
    SUM(wildlife_number_struck_actual) OVER(PARTITION BY EXTRACT(YEAR FROM flight_date)) AS total_birds_strike
FROM
	bird_strike) select sum(total_birds_strike) from total;


/*Yearly Analysis & Bird Strikes in the US
*/
with total as(
SELECT 
    EXTRACT(YEAR FROM flight_date) AS `year`,
    SUM(wildlife_number_struck_actual) AS total_bird_strike_in_USA
FROM
    bird_strike bs
        INNER JOIN
    countries c ON bs.origin_state = c.origin_state
WHERE
    country = 'United States'
GROUP BY `year`
ORDER BY `year`) select sum(total_bird_strike_in_USA) from total;


/*Top 10 US Airlines in terms of having encountered bird strikes
*/

SELECT 
	DISTINCT aircraft_airline,
    SUM(wildlife_number_struck_actual) OVER(PARTITION BY aircraft_airline) AS total_bird_strike
FROM
	bird_strike
ORDER BY
	total_bird_strike DESC
LIMIT 10;

/*Airports with most incidents of bird strikes – Top 50
*/

SELECT 
	DISTINCT airport_name,
    SUM(wildlife_number_struck_actual) OVER(PARTITION BY airport_name) AS total_bird_strike
FROM
	bird_strike
ORDER BY total_bird_strike DESC
LIMIT 50;

/*Yearly Cost Incurred due to Bird Strikes:
*/

WITH yearly_cost AS (	
	SELECT 
		DISTINCT EXTRACT(YEAR FROM flight_date) AS `year`,
		SUM(total_cost) OVER(PARTITION BY EXTRACT(YEAR FROM flight_date)) AS cost_per_year
	FROM
		bird_strike
	-- ORDER BY cost_per_year DESC
)
SELECT 
	`year`,
    CONCAT('$', FORMAT(cost_per_year,0)) AS cost
FROM 
	yearly_cost;

/*When do most bird strikes occur?
*/


SELECT 
    conditions_sky,
    SUM(wildlife_number_struck_actual) OVER(PARTITION BY conditions_sky) AS total_bird_strike
FROM
	bird_strike
ORDER BY
	total_bird_strike DESC;
    
SELECT 
	DISTINCT conditions_precipitation,
    SUM(wildlife_number_struck_actual) OVER(PARTITION BY conditions_precipitation) AS total_bird_strike
FROM
	bird_strike
ORDER BY
	total_bird_strike DESC;
    




-- SELECT 
-- 	DISTINCT EXTRACT(YEAR FROM flight_date) AS `year`,
--     EXTRACT(MONTH FROM flight_date) AS `month`,
--     EXTRACT(WEEK FROM flight_date) AS `week`,
--     conditions_sky,
--     SUM(wildlife_number_struck_actual) OVER(PARTITION BY conditions_sky, EXTRACT(WEEK FROM flight_date), EXTRACT(MONTH FROM flight_date), EXTRACT(YEAR FROM flight_date)) AS total_bird_strike
-- FROM
-- 	bird_strike
-- ORDER BY 
-- 	`year`, `month`, `week`, total_bird_strike DESC;
	
    
/*Altitude of aeroplanes at the time of strike
*/

SELECT 
	DISTINCT altitude_bin AS altitude,
    SUM(wildlife_number_struck_actual) OVER(PARTITION BY altitude_bin) AS total_bird_strike
FROM
	bird_strike
ORDER BY
	total_bird_strike DESC;


/*Phase of flight at the time of the strike.
*/

SELECT 
	DISTINCT phase_of_flight phase_of_flight,
    SUM(wildlife_number_struck_actual) OVER(PARTITION BY phase_of_flight) AS total_bird_strike
FROM 
	bird_strike
ORDER BY 
	total_bird_strike DESC;

/*Average Altitude of the aeroplanes in different phases at the time of strike
*/

SELECT 
	DISTINCT phase_of_flight,
    ROUND(AVG(feet_above_ground) OVER(PARTITION BY phase_of_flight),2) AS altitude_average,
    SUM(wildlife_number_struck_actual) OVER(PARTITION BY phase_of_flight) AS bird_strike
 FROM
	bird_strike
ORDER BY 
	bird_strike DESC;

/*Effect of Bird Strikes & Impact on Flight
*/

SELECT 
	DISTINCT effect_impact_to_flight AS impact_on_flight,
    effect_indicated_damage,
    SUM(wildlife_number_struck_actual) OVER(PARTITION BY effect_indicated_damage, effect_impact_to_flight) AS total_bird_strike
FROM
	bird_strike
ORDER BY
	total_bird_strike DESC;

/*Effect of Strike at Different Altitude
*/

SELECT 
	DISTINCT altitude_bin AS altitude,
    effect_indicated_damage,
    SUM(wildlife_number_struck_actual) OVER(PARTITION BY effect_indicated_damage, altitude_bin) AS total_bird_strike
FROM
	bird_strike
ORDER BY
	altitude, total_bird_strike DESC;


/*Were Pilots Informed? & Prior Warning and Effect of Strike Relation
*/

SELECT 
	DISTINCT pilot_warned_of_wildlife,
    effect_indicated_damage,
    SUM(wildlife_number_struck_actual) OVER(PARTITION BY effect_indicated_damage, pilot_warned_of_wildlife) AS total_birds
FROM
	bird_strike
ORDER BY 
	total_birds DESC;

























