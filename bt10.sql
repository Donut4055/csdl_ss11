

use sakila;

-- 2) Hãy tạo một UNIQUE INDEX có tên idx_unique_email trên cột email trong bảng customer.
-- Mục đích của INDEX này là đảm bảo không có hai khách hàng nào có cùng địa chỉ email.
create unique index idx_unique_email on customer (email);

-- Chạy câu lệnh dưới đây và quan sát
INSERT INTO customer (store_id, first_name, last_name, email, address_id, active, create_date)
VALUES (1, 'Dung', 'Pham', 'dungdeptroai@example.com', 6, 1, NOW());

-- 3) Hãy viết một Stored Procedure có tên CheckCustomerEmail để kiểm tra xem một email đã tồn tại trong hệ thống hay chưa.
delimiter //

drop procedure if exists CheckCustomerEmail //
create procedure CheckCustomerEmail(
    in email_input varchar(50),
    out exists_flag tinyint
)
begin
    select count(*) into exists_flag
    from customer
    where email = email_input;
    
    if exists_flag > 0 then
        set exists_flag = 1;
    else
        set exists_flag = 0;
    end if;
end //

delimiter ;

-- Tiến hành gọi thủ tục trên với một email bất kì
call CheckCustomerEmail('dungdeptroai@example.com', @exists_flag);
select @exists_flag;

-- 4) Hãy tạo một INDEX có tên idx_rental_customer_id trên cột customer_id trong bảng rental 
-- để tối ưu hóa truy vấn tìm kiếm giao dịch thuê phim của khách hàng.
create index idx_rental_customer_id 
on rental(customer_id);

-- 5) Hãy tạo một VIEW có tên view_active_customer_rentals để hiển thị danh sách các giao dịch thuê phim của khách hàng đang hoạt động. 
-- Bảng sử dụng: customer (Thông tin khách hàng), rental (Thông tin thuê phim) với những điều kiện 
create view view_active_customer_rentals as
select 
    c.customer_id,
    concat(c.first_name, ' ', c.last_name) as full_name,
    r.rental_date,
    case 
        when r.return_date is not null then 'Returned'
        else 'Not Returned'
    end as status
from customer c
join rental r on c.customer_id = r.customer_id
where c.active = 1
and r.rental_date >= '2023-01-01'
and (r.return_date is null or r.return_date >= curdate() - interval 30 day);

-- 6) Hãy tạo một INDEX có tên idx_payment_customer_id trên cột customer_id trong bảng payment 
-- để tối ưu hóa truy vấn tìm kiếm lịch sử thanh toán của khách hàng.
create index idx_payment_customer_id 
on payment(customer_id);

-- 7) Hãy tạo một VIEW có tên view_customer_payments để hiển thị danh sách khách hàng và tổng tiền thanh toán của họ. 
-- Chỉ lấy khách hàng có tổng thanh toán > 100$ và dữ liệu từ năm 2023 (payment_date >= '200-01-01'). 
-- Trong đó bảng cần sử dụng là: customer (Thông tin khách hàng), payment (Thông tin thanh toán)
create view view_customer_payments as
select 
    c.customer_id, 
    concat(c.first_name, ' ', c.last_name) as full_name, 
    sum(p.amount) as total_payment
from customer c
join payment p on c.customer_id = p.customer_id
where p.payment_date >= '2023-01-01'
group by c.customer_id, full_name
having total_payment > 100;

-- 8) Hãy viết một Stored Procedure có tên GetCustomerPaymentsByAmount để lấy danh sách khách hàng đã thanh toán 
-- từ một mức tiền nhất định trở lên(>=min_amount) và trong một khoảng thời gian cụ thể(payment_date >= date_from) 
delimiter //

drop procedure if exists GetCustomerPaymentsByAmount //
create procedure GetCustomerPaymentsByAmount(
    in min_amount decimal(10,2), 
    in date_from date
)
begin
    select * 
    from view_customer_payments
    where total_payment >= min_amount 
          and customer_id in (
              select distinct p.customer_id
              from payment p
              where p.payment_date >= date_from
          );
end //

delimiter ;

-- 9) Tiến hành xóa tất cả các VIEW, STORE PROCEDURE và INDEX như trên.

drop view if exists view_active_customer_rentals;
drop view if exists view_customer_payments;

drop procedure if exists CheckCustomerEmail;
drop procedure if exists GetCustomerPaymentsByAmount;

drop index idx_unique_email on customer;
drop index idx_rental_customer_id on rental;
drop index idx_payment_customer_id on payment;
