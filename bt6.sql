USE SAKILA;

-- 3) Tạo VIEW view_film_category để lấy danh sách phim và thể loại
CREATE VIEW view_film_category AS
SELECT 
    f.film_id, 
    f.title, 
    c.name AS category_name
FROM film f
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id;

-- 4) Tạo VIEW view_high_value_customers để lấy danh sách khách hàng có tổng thanh toán > 100$
CREATE VIEW view_high_value_customers AS
SELECT 
    c.customer_id, 
    c.first_name, 
    c.last_name, 
    SUM(p.amount) AS total_payment
FROM customer c
JOIN payment p ON c.customer_id = p.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING total_payment > 100;

-- 5) Tạo INDEX idx_rental_rental_date trên cột rental_date trong bảng rental
CREATE INDEX idx_rental_rental_date ON rental(rental_date);

-- Truy vấn tìm kiếm các giao dịch thuê phim vào ngày "2005-06-14"
EXPLAIN SELECT * FROM rental WHERE rental_date = '2005-06-14';

-- 6) Tạo Stored Procedure CountCustomerRentals
DELIMITER //
CREATE PROCEDURE CountCustomerRentals(IN customer_id INT, OUT rental_count INT)
BEGIN
    SELECT COUNT(*) INTO rental_count
    FROM rental
    WHERE customer_id = customer_id;
END //
DELIMITER ;

-- Gọi Stored Procedure CountCustomerRentals với một customer_id bất kỳ
SET @rental_count = 0;
CALL CountCustomerRentals(1, @rental_count);
SELECT @rental_count AS rental_count;

-- 7) Tạo Stored Procedure GetCustomerEmail
DELIMITER //
CREATE PROCEDURE GetCustomerEmail(IN customer_id INT, OUT customer_email VARCHAR(50))
BEGIN
    SELECT email INTO customer_email
    FROM customer
    WHERE customer_id = customer_id;
END //
DELIMITER ;

-- Gọi Stored Procedure GetCustomerEmail với một customer_id bất kỳ
SET @customer_email = '';
CALL GetCustomerEmail(1, @customer_email);
SELECT @customer_email AS customer_email;

-- 8) Xóa các INDEX, VIEW và Stored Procedure vừa tạo
DROP VIEW IF EXISTS view_film_category;
DROP VIEW IF EXISTS view_high_value_customers;
DROP INDEX idx_rental_rental_date ON rental;
DROP PROCEDURE IF EXISTS CountCustomerRentals;
DROP PROCEDURE IF EXISTS GetCustomerEmail;
