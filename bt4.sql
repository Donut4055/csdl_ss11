USE session_11;

DELIMITER //

-- 2. UpdateSalaryByID
CREATE PROCEDURE UpdateSalaryByID(IN EmployeeID INT, OUT NewSalary DECIMAL(10,2))
BEGIN
    DECLARE CurrentSalary DECIMAL(10,2);

    SELECT Salary INTO CurrentSalary FROM Employees WHERE EmployeeID = EmployeeID;

    IF CurrentSalary < 20000000 THEN
        SET NewSalary = CurrentSalary * 1.1;
    ELSE
        SET NewSalary = CurrentSalary * 1.05;
    END IF;
    
    UPDATE Employees 
    SET Salary = NewSalary
    WHERE EmployeeID = EmployeeID;
END //

DELIMITER ;

DELIMITER //

-- 3. GetLoanAmountByCustomerID
CREATE PROCEDURE LoanAmount(IN CustomerID INT, OUT TotalLoan DECIMAL(15,2))
BEGIN
    SELECT COALESCE(SUM(LoanAmount), 0) INTO TotalLoan
    FROM loans l
    WHERE l.CustomerID = CustomerID
    GROUP BY l.CustomerID;
END //

DELIMITER ;

DELIMITER //

-- 4. DeleteAccountIfLowBalance
CREATE PROCEDURE DeleteAccountIfLowBalance(IN AccountID INT)
BEGIN
    DECLARE balance DECIMAL(15,2);

    SELECT Balance INTO balance FROM Accounts WHERE AccountID = AccountID;
    
    IF balance < 1000000 THEN
        DELETE FROM Accounts WHERE AccountID = AccountID;
        SELECT 'Tài khoản đã bị xóa.' AS Message;
    ELSE
        SELECT 'Không thể xóa tài khoản do số dư quá cao.' AS Message;
    END IF;
END //

DELIMITER ;

DELIMITER //

-- 5. TransferMoney
CREATE PROCEDURE TransferMoney(IN SenderID INT, IN ReceiverID INT, OUT FinalAmount DECIMAL(15,2))
BEGIN
    DECLARE senderBalance DECIMAL(15,2);
    DECLARE TransferAmount DECIMAL(15,2);

    SELECT Balance INTO senderBalance FROM Accounts WHERE AccountID = SenderID;
    
    IF senderBalance >= 2000000 THEN
        SET TransferAmount = 2000000;
        UPDATE Accounts SET Balance = Balance - TransferAmount WHERE AccountID = SenderID;
        UPDATE Accounts SET Balance = Balance + TransferAmount WHERE AccountID = ReceiverID;
    ELSE
        SET TransferAmount = 0;
    END IF;

    SET FinalAmount = TransferAmount;
END //

DELIMITER ;

-- 6. Gọi các Stored Procedure
SET @NewSalary = 0;
CALL UpdateSalaryByID(4, @NewSalary);
SELECT @NewSalary AS UpdatedSalary;

SET @TotalLoan = 0;
CALL LoanAmount(2, @TotalLoan);
SELECT @TotalLoan AS TotalLoan;

CALL DeleteAccountIfLowBalance(8);

CALL TransferMoney(1, 3, @FinalTransferredAmount);
SELECT @FinalTransferredAmount AS FinalTransferredAmount;

-- 7. Xóa các thủ tục
DROP PROCEDURE IF EXISTS UpdateSalaryByID;
DROP PROCEDURE IF EXISTS LoanAmount;
DROP PROCEDURE IF EXISTS DeleteAccountIfLowBalance;
DROP PROCEDURE IF EXISTS TransferMoney;


