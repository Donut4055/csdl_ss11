USE Chinook;

-- 2) Tạo VIEW View_Track_Details
CREATE VIEW View_Track_Details AS
SELECT 
    t.TrackId, 
    t.Name AS Track_Name, 
    a.Title AS Album_Title, 
    ar.Name AS Artist_Name, 
    t.UnitPrice
FROM Track t
JOIN Album a ON t.AlbumId = a.AlbumId
JOIN Artist ar ON a.ArtistId = ar.ArtistId
WHERE t.UnitPrice > 0.99;

-- Hiển thị VIEW
SELECT * FROM View_Track_Details;

-- 3) Tạo VIEW View_Customer_Invoice
CREATE VIEW View_Customer_Invoice AS
SELECT 
    c.CustomerId, 
    CONCAT(c.LastName, ' ', c.FirstName) AS FullName,
    c.Email, 
    SUM(i.Total) AS Total_Spending, 
    CONCAT(e.LastName, ' ', e.FirstName) AS Support_Rep
FROM Customer c
JOIN Invoice i ON c.CustomerId = i.CustomerId
JOIN Employee e ON c.SupportRepId = e.EmployeeId
GROUP BY c.CustomerId
HAVING Total_Spending > 50;

-- Hiển thị VIEW
SELECT * FROM View_Customer_Invoice;

-- 4) Tạo VIEW View_Top_Selling_Tracks
CREATE VIEW View_Top_Selling_Tracks AS
SELECT 
    t.TrackId, 
    t.Name AS Track_Name, 
    g.Name AS Genre_Name, 
    SUM(il.Quantity) AS Total_Sales
FROM Track t
JOIN InvoiceLine il ON t.TrackId = il.TrackId
JOIN Genre g ON t.GenreId = g.GenreId
GROUP BY t.TrackId
HAVING Total_Sales > 10;

-- Hiển thị VIEW
SELECT * FROM View_Top_Selling_Tracks;

-- 5) Tạo BTREE INDEX trên cột Name trong Track
CREATE INDEX idx_Track_Name ON Track (Name);

-- Tìm kiếm bài hát có từ khóa "Love"
SELECT * FROM Track WHERE Name LIKE '%Love%';

-- Kiểm tra hiệu suất
EXPLAIN SELECT * FROM Track WHERE Name LIKE '%Love%';

-- 6) Tạo INDEX trên cột Total trong Invoice
CREATE INDEX idx_Invoice_Total ON Invoice (Total);

-- Tìm hóa đơn có tổng tiền từ 20 đến 100
SELECT * FROM Invoice WHERE Total BETWEEN 20 AND 100;

-- Kiểm tra hiệu suất
EXPLAIN SELECT * FROM Invoice WHERE Total BETWEEN 20 AND 100;

-- 7) Tạo stored procedure GetCustomerSpending
DELIMITER $$
CREATE PROCEDURE GetCustomerSpending(IN CustomerId INT)
BEGIN
    SELECT COALESCE(Total_Spending, 0) AS TotalSpent 
    FROM View_Customer_Invoice 
    WHERE CustomerId = CustomerId;
END $$
DELIMITER ;

-- Gọi stored procedure
CALL GetCustomerSpending(1);

-- 8) Tạo stored procedure SearchTrackByKeyword
DELIMITER $$
CREATE PROCEDURE SearchTrackByKeyword(IN p_Keyword VARCHAR(255))
BEGIN
    SELECT * FROM Track WHERE Name LIKE CONCAT('%', p_Keyword, '%');
END $$
DELIMITER ;

-- Gọi procedure với từ khóa "lo"
CALL SearchTrackByKeyword('lo');

-- 9) Tạo stored procedure GetTopSellingTracks
DELIMITER $$
CREATE PROCEDURE GetTopSellingTracks(IN p_MinSales INT, IN p_MaxSales INT)
BEGIN
    SELECT * FROM View_Top_Selling_Tracks 
    WHERE Total_Sales BETWEEN p_MinSales AND p_MaxSales;
END $$
DELIMITER ;

-- Gọi procedure
CALL GetTopSellingTracks(15, 50);

-- 10) Xóa tất cả VIEW, INDEX, PROCEDURE
DROP VIEW IF EXISTS View_Track_Details;
DROP VIEW IF EXISTS View_Customer_Invoice;
DROP VIEW IF EXISTS View_Top_Selling_Tracks;
DROP INDEX IF EXISTS idx_Track_Name ON Track;
DROP INDEX IF EXISTS idx_Invoice_Total ON Invoice;
DROP PROCEDURE IF EXISTS GetCustomerSpending;
DROP PROCEDURE IF EXISTS SearchTrackByKeyword;
DROP PROCEDURE IF EXISTS GetTopSellingTracks;
