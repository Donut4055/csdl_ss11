

use sakila;

-- 2) Hãy tạo một VIEW có tên view_long_action_movies để hiển thị danh sách các bộ phim thuộc thể loại "Action" 
-- và có thời lượng trên 100 phút. Cần sử dụng bảng sử dụng: film, film_category, category
create view view_long_action_movies as
select 
    f.film_id,
    f.title,
    f.description,
    f.length,
    c.name as category_name
from film f
join film_category fc on f.film_id = fc.film_id
join category c on fc.category_id = c.category_id
where c.name = 'Action' and f.length > 100;

-- 3) Hãy tạo một VIEW có tên view_texas_customers để hiển thị danh sách khách hàng sống tại Texas 
-- và đã từng thuê phim ít nhất một lần. Cần sử dụng bảng sử dụng: customer, address, rental
create view view_texas_customers as
select 
    c.customer_id,
    c.first_name,
    c.last_name,
    ci.city
from customer c
join address a on c.address_id = a.address_id
join city ci on a.city_id = ci.city_id
join rental r on c.customer_id = r.customer_id
where ci.city = 'Texas'
group by c.customer_id, c.first_name, c.last_name, ci.city;


-- 4) Hãy tạo một VIEW có tên view_high_value_staff để hiển thị danh sách nhân viên đã xử lý các giao dịch thanh toán có tổng giá trị trên 100$. 
-- Cần sử dụng bảng  staff, payment
create view view_high_value_staff as
select 
    s.staff_id,
    s.first_name,
    s.last_name,
    sum(p.amount) as total_payment
from staff s
join payment p on s.staff_id = p.staff_id
group by s.staff_id, s.first_name, s.last_name
having total_payment > 100;


-- 5) Hãy tạo một FULLTEXT INDEX có tên idx_film_title_description trên cột title và description trong bảng film. 
-- Mục đích của INDEX này là giúp tối ưu hóa việc tìm kiếm các bộ phim theo từ khóa trong tiêu đề hoặc mô tả phim.
create fulltext index idx_film_title_description 
on film (title, description);

-- 6) Hãy tạo một HASH INDEX có tên idx_rental_inventory_id trên cột inventory_id trong bảng rental. 
-- INDEX này giúp tối ưu hóa việc tìm kiếm các bản ghi dựa trên inventory_id, giúp tăng tốc độ truy vấn tìm kiếm các bản ghi theo giá trị chính xác.
create index idx_rental_inventory_id 
on rental (inventory_id) using hash;

-- 7) Tìm danh sách các bộ phim thuộc thể loại "Action" có thời lượng trên 100 phút và trong tiêu đề 
-- hoặc mô tả phim phải chứa từ khóa "War" không (dùng view_long_action_movies và FULLTEXT INDEX).
select * 
from view_long_action_movies 
where match(title, description) against('War' in natural language mode);

-- 8) Hãy viết một Stored Procedure có tên GetRentalByInventory để tìm các giao dịch thuê phim (rental) dựa trên inventory_id.
create index idx_rental_inventory_id 
on rental (inventory_id) using hash;

delimiter //

drop procedure if exists get_rental_by_inventory //
create procedure get_rental_by_inventory(in p_inventory_id int)
begin
    select rental_id, rental_date, inventory_id, customer_id, return_date, staff_id
    from rental
    where inventory_id = p_inventory_id;
end //

delimiter ;

call get_rental_by_inventory(5);


-- 9) Hãy xóa hết các index, store procedure, và view vừa khởi tạo ở trên

-- Xóa INDEX
drop index idx_film_title_description on film;
drop index idx_rental_inventory_id on rental;

-- Xóa VIEW
drop view if exists view_texas_customers;
drop view if exists view_high_value_staff;
drop view if exists view_long_action_movies;

-- Xóa STORED PROCEDURE
drop procedure if exists GetRentalByInventory;
