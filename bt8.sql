USE Sakila;

-- 2) Tạo VIEW view_long_action_movies
CREATE VIEW view_long_action_movies AS
SELECT 
    f.film_id, 
    f.title, 
    f.length, 
    c.name AS category_name
FROM film f
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
WHERE c.name = 'Action' AND f.length > 100;

-- 3) Tạo VIEW view_texas_customers
CREATE VIEW view_texas_customers AS
SELECT 
    c.customer_id, 
    c.first_name, 
    c.last_name, 
    a.city
FROM customer c
JOIN address a ON c.address_id = a.address_id
JOIN rental r ON c.customer_id = r.customer_id
WHERE a.district = 'Texas'
GROUP BY c.customer_id;

-- 4) Tạo VIEW view_high_value_staff
CREATE VIEW view_high_value_staff AS
SELECT 
    s.staff_id, 
    s.first_name, 
    s.last_name, 
    SUM(p.amount) AS total_payment
FROM staff s
JOIN payment p ON s.staff_id = p.staff_id
GROUP BY s.staff_id
HAVING total_payment > 100;

-- 5) Tạo FULLTEXT INDEX trên title và description trong film
CREATE FULLTEXT INDEX idx_film_title_description ON film (title, description);

-- 6) Tạo HASH INDEX trên inventory_id trong rental
CREATE INDEX idx_rental_inventory_id USING HASH ON rental (inventory_id);

-- 7) Tìm danh sách phim Action trên 100 phút và có từ khóa "War"
SELECT * FROM view_long_action_movies 
WHERE MATCH(title, description) AGAINST('War' IN NATURAL LANGUAGE MODE);

-- 8) Tạo stored procedure GetRentalByInventory
DELIMITER $$
CREATE PROCEDURE GetRentalByInventory(IN inventory_id INT)
BEGIN
    SELECT * FROM rental WHERE inventory_id = inventory_id;
END $$
DELIMITER ;

-- Gọi procedure
CALL GetRentalByInventory(1);

-- 9) Xóa tất cả VIEW, INDEX, PROCEDURE
DROP VIEW IF EXISTS view_long_action_movies;
DROP VIEW IF EXISTS view_texas_customers;
DROP VIEW IF EXISTS view_high_value_staff;
DROP INDEX IF EXISTS idx_film_title_description ON film;
DROP INDEX IF EXISTS idx_rental_inventory_id ON rental;
DROP PROCEDURE IF EXISTS GetRentalByInventory;
