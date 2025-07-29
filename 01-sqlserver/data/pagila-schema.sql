

-- ==================================================
-- SET TARGET DATABASE
USE pagila;

-- --------------------------------------------------
-- ADDING FOREIGN KEY CONSTRAINT
ALTER TABLE city
ADD CONSTRAINT fk_city_country FOREIGN KEY (country_id) REFERENCES country(country_id);


-- --------------------------------------------------
-- ADDING FOREIGN KEY CONSTRAINT
ALTER TABLE address
ADD CONSTRAINT fk_address_city FOREIGN KEY (city_id) REFERENCES city(city_id);

-- --------------------------------------------------
-- ADDING FOREIGN KEY CONSTRAINT
ALTER TABLE store
ADD CONSTRAINT fk_store_staff FOREIGN KEY (manager_staff_id) REFERENCES staff(staff_id);


-- --------------------------------------------------
-- ADDING FOREIGN KEY CONSTRAINT
ALTER TABLE rental
ADD CONSTRAINT fk_rental_staff FOREIGN KEY (staff_id) REFERENCES staff(staff_id);


-- --------------------------------------------------
-- ADDING FOREIGN KEY CONSTRAINT
ALTER TABLE payment
ADD CONSTRAINT fk_payment_staff FOREIGN KEY (staff_id) REFERENCES staff(staff_id);

-- Index on customer last name

-- --------------------------------------------------
-- INDEX CREATION FOR PERFORMANCE
CREATE INDEX idx_customer_last_name ON customer(last_name);

-- Index on film title

-- --------------------------------------------------
-- INDEX CREATION FOR PERFORMANCE
CREATE INDEX idx_film_title ON film(title);

-- Index on inventory (film_id, store_id)

-- --------------------------------------------------
-- INDEX CREATION FOR PERFORMANCE
CREATE INDEX idx_inventory_film_store ON inventory(film_id, store_id);

-- Index on rental (customer_id)

-- --------------------------------------------------
-- INDEX CREATION FOR PERFORMANCE
CREATE INDEX idx_rental_customer_id ON rental(customer_id);

-- Index on payment (customer_id)

-- --------------------------------------------------
-- INDEX CREATION FOR PERFORMANCE
CREATE INDEX idx_payment_customer_id ON payment(customer_id);

----


-- --------------------------------------------------
-- DROP IF EXISTS BLOCK (SAFE RESET BEFORE CREATE)
IF OBJECT_ID('staff_list', 'V') IS NOT NULL 
    DROP VIEW staff_list;


-- ==================================================
-- CREATE VIEW STAFF_LIST AS (VIEW)
CREATE VIEW staff_list AS
SELECT
    s.staff_id AS ID,
    s.first_name + ' ' + s.last_name AS name,
    a.address AS address,
    a.address2 AS address2,
    a.district AS district,
    c.city AS city,
    co.country AS country,
    a.postal_code AS postal_code,
    a.phone AS phone,
    CASE WHEN s.store_id = 1 THEN 'Store 1' ELSE 'Store 2' END AS store,
    CASE WHEN s.active = 1 THEN 'Yes' ELSE 'No' END AS active
FROM staff s
JOIN address a ON s.address_id = a.address_id
JOIN city c ON a.city_id = c.city_id
JOIN country co ON c.country_id = co.country_id;


-- --------------------------------------------------
-- DROP IF EXISTS BLOCK (SAFE RESET BEFORE CREATE)
IF OBJECT_ID('customer_list', 'V') IS NOT NULL 
    DROP VIEW customer_list;


-- ==================================================
-- CREATE VIEW CUSTOMER_LIST AS (VIEW)
CREATE VIEW customer_list AS
SELECT
    cu.customer_id AS ID,
    cu.first_name + ' ' + cu.last_name AS name,
    a.address AS address,
    a.address2 AS address2,
    a.district AS district,
    c.city AS city,
    co.country AS country,
    a.postal_code AS postal_code,
    a.phone AS phone,
    CASE WHEN cu.store_id = 1 THEN 'Store 1' ELSE 'Store 2' END AS store,
    CASE WHEN cu.active = 1 THEN 'Yes' ELSE 'No' END AS active
FROM customer cu
JOIN address a ON cu.address_id = a.address_id
JOIN city c ON a.city_id = c.city_id
JOIN country co ON c.country_id = co.country_id;


-- --------------------------------------------------
-- DROP IF EXISTS BLOCK (SAFE RESET BEFORE CREATE)
IF OBJECT_ID('film_list', 'V') IS NOT NULL 
    DROP VIEW film_list;


-- ==================================================
-- CREATE VIEW FILM_LIST AS (VIEW)
CREATE VIEW film_list AS
SELECT
    f.film_id AS FID,
    f.title,
    f.description,
    c.name AS category,
    f.rental_rate AS price,
    f.length,
    f.rating,
    f.special_features
FROM film f
LEFT JOIN film_category fc ON f.film_id = fc.film_id
LEFT JOIN category c ON fc.category_id = c.category_id;


-- --------------------------------------------------
-- DROP IF EXISTS BLOCK (SAFE RESET BEFORE CREATE)
IF OBJECT_ID('nicer_but_slower_film_list', 'V') IS NOT NULL 
    DROP VIEW nicer_but_slower_film_list;


-- ==================================================
-- CREATE VIEW NICER_BUT_SLOWER_FILM_LIST AS (VIEW)
CREATE VIEW nicer_but_slower_film_list AS
SELECT
    f.film_id AS FID,
    f.title,
    f.description,
    c.name AS category,
    f.rental_rate AS price,
    f.length,
    f.rating,
    f.special_features,
    l.name AS language
FROM film f
LEFT JOIN film_category fc ON f.film_id = fc.film_id
LEFT JOIN category c ON fc.category_id = c.category_id
JOIN language l ON f.language_id = l.language_id;


-- --------------------------------------------------
-- DROP IF EXISTS BLOCK (SAFE RESET BEFORE CREATE)
IF OBJECT_ID('sales_by_store', 'V') IS NOT NULL 
    DROP VIEW sales_by_store;


-- ==================================================
-- CREATE VIEW SALES_BY_STORE AS (VIEW)
CREATE VIEW sales_by_store AS
SELECT
    co.country,
    ci.city,
    s.store_id,
    SUM(p.amount) AS total_sales
FROM payment p
JOIN rental r ON p.rental_id = r.rental_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN store s ON i.store_id = s.store_id
JOIN address a ON s.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN country co ON ci.country_id = co.country_id
GROUP BY co.country, ci.city, s.store_id;


-- --------------------------------------------------
-- DROP IF EXISTS BLOCK (SAFE RESET BEFORE CREATE)
IF OBJECT_ID('sales_by_film_category', 'V') IS NOT NULL 
    DROP VIEW sales_by_film_category;


-- ==================================================
-- CREATE VIEW SALES_BY_FILM_CATEGORY AS (VIEW)
CREATE VIEW sales_by_film_category AS
SELECT
    c.name AS category,
    SUM(p.amount) AS total_sales
FROM payment p
JOIN rental r ON p.rental_id = r.rental_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
GROUP BY c.name;


-- --------------------------------------------------
-- DROP IF EXISTS BLOCK (SAFE RESET BEFORE CREATE)
IF OBJECT_ID('actor_info', 'V') IS NOT NULL 
    DROP VIEW actor_info;


-- ==================================================
-- CREATE VIEW ACTOR_INFO AS (VIEW)
CREATE VIEW actor_info AS
SELECT
    a.actor_id,
    a.first_name,
    a.last_name,
    STRING_AGG(f.title, ', ') AS film_info
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id
JOIN film f ON fa.film_id = f.film_id
GROUP BY a.actor_id, a.first_name, a.last_name;


-- --------------------------------------------------
-- DROP IF EXISTS BLOCK (SAFE RESET BEFORE CREATE)
IF OBJECT_ID('customer_summary', 'V') IS NOT NULL 
    DROP VIEW customer_summary;


-- ==================================================
-- CREATE VIEW CUSTOMER_SUMMARY AS (VIEW)
CREATE VIEW customer_summary AS
SELECT
    cu.customer_id,
    cu.first_name,
    cu.last_name,
    COUNT(DISTINCT r.rental_id) AS total_rentals,
    COUNT(DISTINCT p.payment_id) AS total_payments,
    SUM(p.amount) AS total_amount_paid
FROM customer cu
LEFT JOIN rental r ON cu.customer_id = r.customer_id
LEFT JOIN payment p ON cu.customer_id = p.customer_id
GROUP BY cu.customer_id, cu.first_name, cu.last_name;


-- --------------------------------------------------
-- DROP IF EXISTS BLOCK (SAFE RESET BEFORE CREATE)
IF OBJECT_ID('film_stats', 'V') IS NOT NULL 
    DROP VIEW film_stats;


-- ==================================================
-- CREATE VIEW FILM_STATS AS (VIEW)
CREATE VIEW film_stats AS
SELECT
    f.film_id,
    f.title,
    COUNT(r.rental_id) AS times_rented
FROM film f
LEFT JOIN inventory i ON f.film_id = i.film_id
LEFT JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY f.film_id, f.title;


-- --------------------------------------------------
-- DROP IF EXISTS BLOCK (SAFE RESET BEFORE CREATE)
IF OBJECT_ID('inventory_in_stock', 'FN') IS NOT NULL 
    DROP FUNCTION inventory_in_stock;


-- ==================================================
-- USER-DEFINED FUNCTION CREATION
EXEC('

-- ==================================================
-- USER-DEFINED FUNCTION CREATION
CREATE FUNCTION inventory_in_stock (
    @film_id INT,
    @store_id INT
)
RETURNS BIT
AS
BEGIN
    DECLARE @count INT;
    DECLARE @result BIT;

    SELECT @count = COUNT(*)
    FROM inventory i
    LEFT JOIN rental r ON i.inventory_id = r.inventory_id AND r.return_date IS NULL
    WHERE i.film_id = @film_id AND i.store_id = @store_id;

    SET @result = CASE WHEN @count > 0 THEN 1 ELSE 0 END;

    RETURN @result;
END
');


-- --------------------------------------------------
-- DROP IF EXISTS BLOCK (SAFE RESET BEFORE CREATE)
IF OBJECT_ID('last_day', 'FN') IS NOT NULL 
    DROP FUNCTION last_day;


-- ==================================================
-- USER-DEFINED FUNCTION CREATION
EXEC('

-- ==================================================
-- USER-DEFINED FUNCTION CREATION
CREATE FUNCTION last_day (
    @in_date DATE
)
RETURNS DATE
AS
BEGIN
    RETURN EOMONTH(@in_date);
END
');


-- --------------------------------------------------
-- DROP IF EXISTS BLOCK (SAFE RESET BEFORE CREATE)
IF OBJECT_ID('rewards_report', 'V') IS NOT NULL 
    DROP VIEW rewards_report;


-- ==================================================
-- CREATE VIEW REWARDS_REPORT AS (VIEW)
CREATE VIEW rewards_report AS
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    a.address,
    a.postal_code,
    a.phone,
    city.city,
    country.country,
    SUM(p.amount) AS total_amount
FROM customer c
JOIN payment p ON c.customer_id = p.customer_id
JOIN address a ON c.address_id = a.address_id
JOIN city ON a.city_id = city.city_id
JOIN country ON city.country_id = country.country_id
GROUP BY
    c.customer_id, c.first_name, c.last_name, c.email,
    a.address, a.postal_code, a.phone,
    city.city, country.country
HAVING SUM(p.amount) > 100;

