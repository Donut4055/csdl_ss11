USE chinook;
-- 3) Tạo VIEW View_Album_Artist để kết hợp thông tin từ bảng Album và Artist
CREATE VIEW View_Album_Artist AS
SELECT 
    Album.AlbumId, 
    Album.Title AS Album_Title, 
    Artist.Name AS Artist_Name
FROM Album
JOIN Artist ON Album.ArtistId = Artist.ArtistId;

-- 4) Tạo VIEW View_Customer_Spending để tính tổng chi tiêu của từng khách hàng
CREATE VIEW View_Customer_Spending AS
SELECT 
    Customer.CustomerId, 
    Customer.FirstName, 
    Customer.LastName, 
    Customer.Email, 
    COALESCE(SUM(Invoice.Total), 0) AS Total_Spending
FROM Customer
LEFT JOIN Invoice ON Customer.CustomerId = Invoice.CustomerId
GROUP BY Customer.CustomerId, Customer.FirstName, Customer.LastName, Customer.Email;

-- 5) Tạo INDEX trên LastName của bảng Employee
CREATE INDEX idx_Employee_LastName ON Employee(LastName);

-- Truy vấn tìm kiếm nhân viên có LastName là 'King' và kiểm tra hiệu suất bằng EXPLAIN
EXPLAIN SELECT * FROM Employee WHERE LastName = 'King';

-- 6) Tạo Stored Procedure GetTracksByGenre
DELIMITER //
CREATE PROCEDURE GetTracksByGenre(IN GenreId INT)
BEGIN
    SELECT 
        Track.TrackId, 
        Track.Name AS Track_Name, 
        Album.Title AS Album_Title, 
        Artist.Name AS Artist_Name
    FROM Track
    JOIN Album ON Track.AlbumId = Album.AlbumId
    JOIN Artist ON Album.ArtistId = Artist.ArtistId
    WHERE Track.GenreId = GenreId;
END //
DELIMITER ;

-- Gọi Stored Procedure GetTracksByGenre với một GenreId bất kỳ
CALL GetTracksByGenre(1);

-- 7) Tạo Stored Procedure GetTrackCountByAlbum
DELIMITER //
CREATE PROCEDURE GetTrackCountByAlbum(IN p_AlbumId INT, OUT Total_Tracks INT)
BEGIN
    SELECT COUNT(*) INTO Total_Tracks
    FROM Track
    WHERE AlbumId = p_AlbumId;
END //
DELIMITER ;

-- Gọi Stored Procedure GetTrackCountByAlbum với một AlbumId bất kỳ
SET @TotalTracks = 0;
CALL GetTrackCountByAlbum(1, @TotalTracks);
SELECT @TotalTracks AS Total_Tracks;

-- 8) Xóa tất cả các VIEW, PROCEDURE và INDEX vừa tạo
DROP VIEW IF EXISTS View_Album_Artist;
DROP VIEW IF EXISTS View_Customer_Spending;
DROP INDEX idx_Employee_LastName ON Employee;
DROP PROCEDURE IF EXISTS GetTracksByGenre;
DROP PROCEDURE IF EXISTS GetTrackCountByAlbum;
