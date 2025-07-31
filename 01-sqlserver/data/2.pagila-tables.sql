

-- ==================================================
-- SET TARGET DATABASE
USE pagila;


-- --------------------------------------------------
-- DROP IF EXISTS BLOCK (SAFE RESET BEFORE CREATE)
IF OBJECT_ID('actor', 'U') IS NOT NULL
    DROP TABLE actor;


-- ==================================================
-- CREATE TABLE ACTOR (
CREATE TABLE actor (
    actor_id INT IDENTITY(1,1) PRIMARY KEY,
    first_name NVARCHAR(45) NOT NULL,
    last_name NVARCHAR(45) NOT NULL,
    last_update DATETIME2 NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- --------------------------------------------------
-- DROP IF EXISTS BLOCK (SAFE RESET BEFORE CREATE)
IF OBJECT_ID('language', 'U') IS NOT NULL
    DROP TABLE language;


-- ==================================================
-- CREATE TABLE LANGUAGE (
CREATE TABLE language (
    language_id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(20) NOT NULL,
    last_update DATETIME2 NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- --------------------------------------------------
-- DROP IF EXISTS BLOCK (SAFE RESET BEFORE CREATE)
IF OBJECT_ID('film', 'U') IS NOT NULL 
    DROP TABLE film;


-- ==================================================
-- CREATE TABLE FILM (
CREATE TABLE film (
    film_id INT IDENTITY(1,1) PRIMARY KEY,
    title NVARCHAR(255) NOT NULL,
    description NVARCHAR(MAX),
    release_year INT,
    language_id INT NOT NULL,
    rental_duration INT NOT NULL DEFAULT 3,
    rental_rate DECIMAL(4,2) NOT NULL DEFAULT 4.99,
    length INT,
    replacement_cost DECIMAL(5,2) NOT NULL DEFAULT 19.99,
    rating VARCHAR(10) CHECK (rating IN ('G', 'PG', 'PG-13', 'R', 'NC-17')),
    last_update DATETIME2 NOT NULL DEFAULT CURRENT_TIMESTAMP,
    special_features NVARCHAR(255),
    fulltext NVARCHAR(MAX),

    CONSTRAINT fk_film_language FOREIGN KEY (language_id) REFERENCES language(language_id)
);


-- --------------------------------------------------
-- DROP IF EXISTS BLOCK (SAFE RESET BEFORE CREATE)
IF OBJECT_ID('film_actor', 'U') IS NOT NULL 
    DROP TABLE film_actor;


-- ==================================================
-- CREATE TABLE FILM_ACTOR (
CREATE TABLE film_actor (
    actor_id INT NOT NULL,
    film_id INT NOT NULL,
    last_update DATETIME2 NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (actor_id, film_id),
    FOREIGN KEY (actor_id) REFERENCES actor(actor_id),
    FOREIGN KEY (film_id) REFERENCES film(film_id)
);


-- --------------------------------------------------
-- DROP IF EXISTS BLOCK (SAFE RESET BEFORE CREATE)
IF OBJECT_ID('category', 'U') IS NOT NULL 
    DROP TABLE category;


-- ==================================================
-- CREATE TABLE CATEGORY (
CREATE TABLE category (
    category_id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(25) NOT NULL,
    last_update DATETIME2 NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- --------------------------------------------------
-- DROP IF EXISTS BLOCK (SAFE RESET BEFORE CREATE)
IF OBJECT_ID('film_category', 'U') IS NOT NULL 
    DROP TABLE film_category;


-- ==================================================
-- CREATE TABLE FILM_CATEGORY (
CREATE TABLE film_category (
    film_id INT NOT NULL,
    category_id INT NOT NULL,
    last_update DATETIME2 NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (film_id, category_id),
    FOREIGN KEY (film_id) REFERENCES film(film_id),
    FOREIGN KEY (category_id) REFERENCES category(category_id)
);


-- --------------------------------------------------
-- DROP IF EXISTS BLOCK (SAFE RESET BEFORE CREATE)
IF OBJECT_ID('store', 'U') IS NOT NULL 
    DROP TABLE store;


-- ==================================================
-- CREATE TABLE STORE (
CREATE TABLE store (
    store_id INT IDENTITY(1,1) PRIMARY KEY,
    manager_staff_id INT NOT NULL,
    address_id INT NOT NULL,
    last_update DATETIME2 NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- --------------------------------------------------
-- DROP IF EXISTS BLOCK (SAFE RESET BEFORE CREATE)
IF OBJECT_ID('address', 'U') IS NOT NULL 
    DROP TABLE address;


-- ==================================================
-- CREATE TABLE ADDRESS (
CREATE TABLE address (
    address_id INT IDENTITY(1,1) PRIMARY KEY,
    address NVARCHAR(50) NOT NULL,
    address2 NVARCHAR(50),
    district NVARCHAR(20) NOT NULL,
    city_id INT NOT NULL,
    postal_code NVARCHAR(10),
    phone NVARCHAR(20) NOT NULL,
    last_update DATETIME2 NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- --------------------------------------------------
-- DROP IF EXISTS BLOCK (SAFE RESET BEFORE CREATE)
IF OBJECT_ID('city', 'U') IS NOT NULL 
    DROP TABLE city;


-- ==================================================
-- CREATE TABLE CITY (
CREATE TABLE city (
    city_id INT IDENTITY(1,1) PRIMARY KEY,
    city NVARCHAR(50) NOT NULL,
    country_id INT NOT NULL,
    last_update DATETIME2 NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- --------------------------------------------------
-- DROP IF EXISTS BLOCK (SAFE RESET BEFORE CREATE)
IF OBJECT_ID('country', 'U') IS NOT NULL 
    DROP TABLE country;


-- ==================================================
-- CREATE TABLE COUNTRY (
CREATE TABLE country (
    country_id INT IDENTITY(1,1) PRIMARY KEY,
    country NVARCHAR(50) NOT NULL,
    last_update DATETIME2 NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- --------------------------------------------------
-- DROP IF EXISTS BLOCK (SAFE RESET BEFORE CREATE)
IF OBJECT_ID('customer', 'U') IS NOT NULL 
    DROP TABLE customer;


-- ==================================================
-- CREATE TABLE CUSTOMER (
CREATE TABLE customer (
    customer_id INT IDENTITY(1,1) PRIMARY KEY,
    store_id INT NOT NULL,
    first_name NVARCHAR(45) NOT NULL,
    last_name NVARCHAR(45) NOT NULL,
    email NVARCHAR(50),
    address_id INT NOT NULL,
    active BIT NOT NULL DEFAULT 1,
    create_date DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    last_update DATETIME2 DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (store_id) REFERENCES store(store_id),
    FOREIGN KEY (address_id) REFERENCES address(address_id)
);


-- --------------------------------------------------
-- DROP IF EXISTS BLOCK (SAFE RESET BEFORE CREATE)
IF OBJECT_ID('inventory', 'U') IS NOT NULL 
    DROP TABLE inventory;


-- ==================================================
-- CREATE TABLE INVENTORY (
CREATE TABLE inventory (
    inventory_id INT IDENTITY(1,1) PRIMARY KEY,
    film_id INT NOT NULL,
    store_id INT NOT NULL,
    last_update DATETIME2 NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (film_id) REFERENCES film(film_id),
    FOREIGN KEY (store_id) REFERENCES store(store_id)
);


-- --------------------------------------------------
-- DROP IF EXISTS BLOCK (SAFE RESET BEFORE CREATE)
IF OBJECT_ID('rental', 'U') IS NOT NULL 
    DROP TABLE rental;


-- ==================================================
-- CREATE TABLE RENTAL (
CREATE TABLE rental (
    rental_id INT IDENTITY(1,1) PRIMARY KEY,
    rental_date DATETIME2 NOT NULL,
    inventory_id INT NOT NULL,
    customer_id INT NOT NULL,
    return_date DATETIME2,
    staff_id INT NOT NULL,
    last_update DATETIME2 NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (inventory_id) REFERENCES inventory(inventory_id),
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
    -- FOREIGN KEY (staff_id) to be added after staff table is created
);


-- --------------------------------------------------
-- DROP IF EXISTS BLOCK (SAFE RESET BEFORE CREATE)
IF OBJECT_ID('payment', 'U') IS NOT NULL 
    DROP TABLE payment;


-- ==================================================
-- CREATE TABLE PAYMENT (
CREATE TABLE payment (
    payment_id INT IDENTITY(1,1) PRIMARY KEY,
    customer_id INT NOT NULL,
    staff_id INT NOT NULL,
    rental_id INT,
    amount DECIMAL(5,2) NOT NULL,
    payment_date DATETIME2 NOT NULL,
    last_update DATETIME2 DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    FOREIGN KEY (rental_id) REFERENCES rental(rental_id)
    -- FOREIGN KEY (staff_id) to be added after staff table is created
);

-- ==================================================
-- CREATE TABLE PAYMENT (
CREATE TABLE payment_p2022_01 (
    payment_id INT IDENTITY(1,1) PRIMARY KEY,
    customer_id INT NOT NULL,
    staff_id INT NOT NULL,
    rental_id INT,
    amount DECIMAL(5,2) NOT NULL,
    payment_date DATETIME2 NOT NULL,
    last_update DATETIME2 DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    FOREIGN KEY (rental_id) REFERENCES rental(rental_id)
    -- FOREIGN KEY (staff_id) to be added after staff table is created
);

-- ==================================================
-- CREATE TABLE PAYMENT (
CREATE TABLE payment_p2022_02 (
    payment_id INT IDENTITY(1,1) PRIMARY KEY,
    customer_id INT NOT NULL,
    staff_id INT NOT NULL,
    rental_id INT,
    amount DECIMAL(5,2) NOT NULL,
    payment_date DATETIME2 NOT NULL,
    last_update DATETIME2 DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    FOREIGN KEY (rental_id) REFERENCES rental(rental_id)
    -- FOREIGN KEY (staff_id) to be added after staff table is created
);

-- ==================================================
-- CREATE TABLE PAYMENT (
CREATE TABLE payment_p2022_03 (
    payment_id INT IDENTITY(1,1) PRIMARY KEY,
    customer_id INT NOT NULL,
    staff_id INT NOT NULL,
    rental_id INT,
    amount DECIMAL(5,2) NOT NULL,
    payment_date DATETIME2 NOT NULL,
    last_update DATETIME2 DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    FOREIGN KEY (rental_id) REFERENCES rental(rental_id)
    -- FOREIGN KEY (staff_id) to be added after staff table is created
);


-- ==================================================
-- CREATE TABLE PAYMENT (
CREATE TABLE payment_p2022_04 (
    payment_id INT IDENTITY(1,1) PRIMARY KEY,
    customer_id INT NOT NULL,
    staff_id INT NOT NULL,
    rental_id INT,
    amount DECIMAL(5,2) NOT NULL,
    payment_date DATETIME2 NOT NULL,
    last_update DATETIME2 DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    FOREIGN KEY (rental_id) REFERENCES rental(rental_id)
    -- FOREIGN KEY (staff_id) to be added after staff table is created
);

-- ==================================================
-- CREATE TABLE PAYMENT (
CREATE TABLE payment_p2022_05 (
    payment_id INT IDENTITY(1,1) PRIMARY KEY,
    customer_id INT NOT NULL,
    staff_id INT NOT NULL,
    rental_id INT,
    amount DECIMAL(5,2) NOT NULL,
    payment_date DATETIME2 NOT NULL,
    last_update DATETIME2 DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    FOREIGN KEY (rental_id) REFERENCES rental(rental_id)
    -- FOREIGN KEY (staff_id) to be added after staff table is created
);

-- ==================================================
-- CREATE TABLE PAYMENT (
CREATE TABLE payment_p2022_06 (
    payment_id INT IDENTITY(1,1) PRIMARY KEY,
    customer_id INT NOT NULL,
    staff_id INT NOT NULL,
    rental_id INT,
    amount DECIMAL(5,2) NOT NULL,
    payment_date DATETIME2 NOT NULL,
    last_update DATETIME2 DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    FOREIGN KEY (rental_id) REFERENCES rental(rental_id)
    -- FOREIGN KEY (staff_id) to be added after staff table is created
);

-- ==================================================
-- CREATE TABLE PAYMENT (
CREATE TABLE payment_p2022_07 (
    payment_id INT IDENTITY(1,1) PRIMARY KEY,
    customer_id INT NOT NULL,
    staff_id INT NOT NULL,
    rental_id INT,
    amount DECIMAL(5,2) NOT NULL,
    payment_date DATETIME2 NOT NULL,
    last_update DATETIME2 DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    FOREIGN KEY (rental_id) REFERENCES rental(rental_id)
    -- FOREIGN KEY (staff_id) to be added after staff table is created
);
-- --------------------------------------------------
-- DROP IF EXISTS BLOCK (SAFE RESET BEFORE CREATE)
IF OBJECT_ID('staff', 'U') IS NOT NULL 
    DROP TABLE staff;


-- ==================================================
-- CREATE TABLE STAFF (
CREATE TABLE staff (
    staff_id INT IDENTITY(1,1) PRIMARY KEY,
    first_name NVARCHAR(45) NOT NULL,
    last_name NVARCHAR(45) NOT NULL,
    address_id INT NOT NULL,
    email NVARCHAR(50),
    store_id INT NOT NULL,
    active BIT NOT NULL DEFAULT 1,
    username NVARCHAR(16) NOT NULL,
    password NVARCHAR(40), -- nullable, per original schema
    last_update DATETIME2 NOT NULL DEFAULT CURRENT_TIMESTAMP,
    picture VARBINARY(MAX),
    FOREIGN KEY (address_id) REFERENCES address(address_id),
    FOREIGN KEY (store_id) REFERENCES store(store_id)
);

ALTER TABLE staff
ALTER COLUMN picture VARBINARY(MAX) NULL;

ALTER TABLE rental
ALTER COLUMN return_date DATETIME NULL;

ALTER TABLE film ADD original_language_id INT NULL;