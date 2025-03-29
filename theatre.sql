--========================================================================================
-- INFO BLOCK
--
--
--
--========================================================================================

--========================================================================================
-- Setup (Drop everything cleanly)
--========================================================================================
DROP TRIGGER IF EXISTS trg_AddPlayCostTransaction;
DROP TRIGGER IF EXISTS trg_AutoTransactionOnDuesPayment;

DROP PROCEDURE IF EXISTS AddPlayToProduction;
DROP PROCEDURE IF EXISTS UndoPlayFromProduction;
DROP PROCEDURE IF EXISTS AddProductionExpense;
DROP PROCEDURE IF EXISTS UndoProductionExpense;
DROP PROCEDURE IF EXISTS AddDuesInstallment;
DROP PROCEDURE IF EXISTS UndoDuesInstallment;
DROP PROCEDURE IF EXISTS PurchaseTicket;
DROP PROCEDURE IF EXISTS UndoTicketPurchase;
DROP PROCEDURE IF EXISTS GetProductionFinancialSummary;

DROP FUNCTION IF EXISTS GetTotalPaidForDues;

DROP TABLE IF EXISTS
    Financial_Transaction,
    Member_Meeting,
    Meeting,
    Ticket,
    Seat,
    Patron,
    Production_Sponsor,
    Sponsor,
    DuesPayment,
    DuesOwed,
    Member_Production,
    Member,
    Production_Play,
    Production,
    Play;

--========================================================================================
-- DDL Statements
--========================================================================================

-- Creating the Play table
CREATE TABLE Play (
    PlayID INT PRIMARY KEY,
    Title VARCHAR(100) NOT NULL,
    Author VARCHAR(255),
    Genre VARCHAR(100) NOT NULL,
    NumberOfActs TINYINT UNSIGNED NOT NULL,
    Cost DECIMAL(12,2) NOT NULL
);

-- Creating the Production table
CREATE TABLE Production (
    ProductionID INT PRIMARY KEY,
    ProductionDate DATE NOT NULL,
    TotalCost DECIMAL(12,2) GENERATED ALWAYS AS (
        (SELECT COALESCE(SUM(p.Cost), 0)
         FROM Production_Play pp
         JOIN Play p ON pp.PlayID = p.PlayID
         WHERE pp.ProductionID = Production.ProductionID)
        + 
        (SELECT COALESCE(SUM(ft.Amount), 0)
         FROM Financial_Transaction ft
         WHERE ft.ProductionID = Production.ProductionID AND ft.Type = 'E' AND ft.PlayID IS NULL)
    ) STORED
);

-- Creating the Production_Play table for M:N relationship
CREATE TABLE Production_Play (
    ProductionID INT,
    PlayID INT,
    PRIMARY KEY (ProductionID, PlayID),
    FOREIGN KEY (ProductionID) REFERENCES Production(ProductionID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (PlayID) REFERENCES Play(PlayID) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Creating the Member table
CREATE TABLE Member (
    MemberID INT PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    Email VARCHAR(100) UNIQUE,
    Phone VARCHAR(20),
    Address VARCHAR(100),
    Role VARCHAR(100)
);

-- Creating the Member_Production table for M:N relationship
CREATE TABLE Member_Production (
    MemberID INT,
    ProductionID INT,
    Role VARCHAR(100),
    PRIMARY KEY (MemberID, ProductionID),
    FOREIGN KEY (MemberID) REFERENCES Member(MemberID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (ProductionID) REFERENCES Production(ProductionID) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Creating the Dues tables to support payment in full or by installment
CREATE TABLE DuesOwed (
    DuesID INT PRIMARY KEY AUTO_INCREMENT,
    MemberID INT NOT NULL,
    Year YEAR NOT NULL,
    TotalDue DECIMAL(6,2) NOT NULL,
    FOREIGN KEY (MemberID) REFERENCES Member(MemberID) ON DELETE CASCADE ON UPDATE CASCADE,
    UNIQUE(MemberID, Year)
);

CREATE TABLE DuesPayment (
    PaymentID INT PRIMARY KEY AUTO_INCREMENT,
    DuesID INT NOT NULL,
    AmountPaid DECIMAL(6,2) NOT NULL,
    PaymentDate DATE NOT NULL DEFAULT (CURRENT_DATE),
    FOREIGN KEY (DuesID) REFERENCES DuesOwed(DuesID) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Creating the Sponsor table
CREATE TABLE Sponsor (
    SponsorID INT PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    Type ENUM('C', 'I') NOT NULL -- ‘C’ for company, ‘I’ for individual 
);

-- Creating the Production_Sponsor table for M:N relationship
CREATE TABLE Production_Sponsor (
    ProductionID INT,
    SponsorID INT,
    ContributionAmount DECIMAL(12,2) NOT NULL,
    PRIMARY KEY (ProductionID, SponsorID),
    FOREIGN KEY (ProductionID) REFERENCES Production(ProductionID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (SponsorID) REFERENCES Sponsor(SponsorID) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Creating the Patron table
CREATE TABLE Patron (
    PatronID INT PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    Email VARCHAR(100) UNIQUE,
    Address VARCHAR(100)
);

-- Creating the Seat table (Weak Entity)
CREATE TABLE Seat (
    SeatID INT PRIMARY KEY,
    SeatRow CHAR(1) NOT NULL CHECK (SeatRow BETWEEN 'A' AND 'Z'),
    Number TINYINT UNSIGNED NOT NULL CHECK (Number BETWEEN 1 AND 50)
);

-- Creating the Ticket table
CREATE TABLE Ticket (
    TicketID INT PRIMARY KEY,
    ProductionID INT NOT NULL,
    PatronID INT NULL, -- NULL if unassigned or released
    SeatID INT NOT NULL,
    Price DECIMAL(6,2) NOT NULL,
    Status ENUM('S', 'A') NOT NULL, -- ‘S’ for sold, ‘A’ for avalible
    ReservationDeadline DATE NULL,
    FOREIGN KEY (ProductionID) REFERENCES Production(ProductionID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (PatronID) REFERENCES Patron(PatronID) ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (SeatID) REFERENCES Seat(SeatID) ON DELETE CASCADE ON UPDATE CASCADE,
    UNIQUE (ProductionID, SeatID) -- Prevent duplicate ticket entries per production/seat
);

-- Creating the Meeting table
CREATE TABLE Meeting (
    MeetingID INT PRIMARY KEY,
    Type ENUM('F', 'S') NOT NULL,
    Date DATE NOT NULL
);

-- Creating the Member_Meeting table for M:N relationship
CREATE TABLE Member_Meeting (
    MemberID INT,
    MeetingID INT,
    PRIMARY KEY (MemberID, MeetingID),
    FOREIGN KEY (MemberID) REFERENCES Member(MemberID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (MeetingID) REFERENCES Meeting(MeetingID) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Creating the Financial_Transaction table
CREATE TABLE Transaction (
    TransactionID INT PRIMARY KEY,
    Type ENUM('I', 'E') NOT NULL, -- 'I' for Income, 'E' for Expense
    Amount DECIMAL(12,2) NOT NULL,
    Date DATE NOT NULL,
    Description VARCHAR(255) NULL,
    DuesPaymentID INT NULL,
    TicketID INT NULL,
    SponsorID INT NULL,
    ProductionID INT NULL,
    FOREIGN KEY (DuesPaymentID) REFERENCES DuesPayment(PaymentID) ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (TicketID) REFERENCES Ticket(TicketID) ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (SponsorID) REFERENCES Sponsor(SponsorID) ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (ProductionID) REFERENCES Production(ProductionID) ON DELETE SET NULL ON UPDATE CASCADE
);



--========================================================================================
-- Scripts NOTE: The below has not been tested yet from scripts to the end. (March 28th 10pm)
--========================================================================================

--========================================================================================
-- Procedures
--========================================================================================

-- This procedure can add a play to a production
DELIMITER //
CREATE PROCEDURE AddPlayToProduction (
    IN in_ProductionID INT,
    IN in_PlayID INT
)
BEGIN
    -- Prevent duplicate insert
    IF EXISTS (
        SELECT 1 FROM Production_Play
        WHERE ProductionID = in_ProductionID AND PlayID = in_PlayID
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'This play is already linked to the production.';
    END IF;

    -- Add the play to the production (triggers the base cost transaction)
    INSERT INTO Production_Play (ProductionID, PlayID)
    VALUES (in_ProductionID, in_PlayID);
END //
DELIMITER ;

-- Undoes adding a play to a production, the procedure above
DELIMITER //
CREATE PROCEDURE UndoPlayFromProduction (
    IN in_ProductionID INT,
    IN in_PlayID INT
)
BEGIN
    -- Delete associated base cost transaction
    DELETE FROM Financial_Transaction
    WHERE ProductionID = in_ProductionID
      AND Description LIKE 'Base licensing cost for play added%'
      AND Amount = (SELECT Cost FROM Play WHERE PlayID = in_PlayID);

    -- Remove the play from the production
    DELETE FROM Production_Play
    WHERE ProductionID = in_ProductionID AND PlayID = in_PlayID;
END //
DELIMITER ;

-- This procedure allows users to input a production expense which may not be a part of the base cost
DELIMITER //
CREATE PROCEDURE AddProductionExpense (
    IN in_Amount DECIMAL(12,2),
    IN in_Date DATE,
    IN in_ProductionID INT,
    IN in_Description VARCHAR(255)
)
BEGIN
    INSERT INTO Financial_Transaction (Type, Amount, Date, ProductionID, Description)
    VALUES ('E', in_Amount, IFNULL(in_Date, CURRENT_DATE), in_ProductionID, in_Description);
END //
DELIMITER ;

-- Undoes a production transaction, the procedure above
DELIMITER //
CREATE PROCEDURE UndoProductionExpense (
    IN in_TransactionID INT
)
BEGIN
    DELETE FROM Financial_Transaction
    WHERE TransactionID = in_TransactionID
    AND Type = 'E';
END //
DELIMITER ;

-- This procedure allows users to add a dues installment to pay off portions of their dues rather than one payment per year.
DELIMITER //
CREATE PROCEDURE AddDuesInstallment (
    IN in_MemberID INT,
    IN in_Year YEAR,
    IN in_Amount DECIMAL(6,2)
)
BEGIN
    DECLARE existingDuesID INT;
    DECLARE totalPaid DECIMAL(10,2);
    DECLARE totalDue DECIMAL(10,2);

    -- Check if dues record already exists
    SELECT DuesID INTO existingDuesID
    FROM DuesOwed
    WHERE MemberID = in_MemberID AND Year = in_Year;

    -- If not, create it with a default total (e.g., $100.00 — customizable)
    IF existingDuesID IS NULL THEN
        INSERT INTO DuesOwed (MemberID, Year, TotalDue)
        VALUES (in_MemberID, in_Year, 100.00);
        SET existingDuesID = LAST_INSERT_ID();
    END IF;

    -- Get current total paid and total due
    SET totalPaid = GetTotalPaidForDues(existingDuesID);
    SELECT TotalDue INTO totalDue
    FROM DuesOwed
    WHERE DuesID = existingDuesID;

    -- Validate: installment must not exceed remaining amount
    IF totalPaid + in_Amount > totalDue THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Installment exceeds remaining dues for the year';
    END IF;

    -- Record the installment
    INSERT INTO DuesPayment (DuesID, AmountPaid)
    VALUES (existingDuesID, in_Amount);

    -- Link to Financial Transaction
    INSERT INTO Financial_Transaction (Type, Amount, Date, DuesPaymentID, Description)
    VALUES ('I', in_Amount, CURRENT_DATE, LAST_INSERT_ID(), CONCAT('Dues installment for year ', in_Year));
END //
DELIMITER ;

-- This procedure undoes installment payments, the above procedure
DELIMITER //
CREATE PROCEDURE UndoDuesInstallment (
    IN in_PaymentID INT
)
BEGIN
    -- Delete the associated financial transaction
    DELETE FROM Financial_Transaction
    WHERE DuesPaymentID = in_PaymentID;

    -- Delete the dues payment
    DELETE FROM DuesPayment
    WHERE PaymentID = in_PaymentID;
END //
DELIMITER ;

-- Allows for patrons or general public to purchase tickets, patrons may have preferred seats which are reserved first until a specified date.
DELIMITER //
CREATE PROCEDURE PurchaseTicket (
    IN in_ProductionID INT,
    IN in_SeatID INT,
    IN in_BuyerPatronID INT, -- NULL if general public
    IN in_Price DECIMAL(6,2)
)
BEGIN
    DECLARE ticketID INT;
    DECLARE currentStatus ENUM('S','A');
    DECLARE currentPatronID INT;
    DECLARE reservationDeadline DATE;

    -- Look up the ticket record
    SELECT TicketID, Status, PatronID, ReservationDeadline
    INTO ticketID, currentStatus, currentPatronID, reservationDeadline
    FROM Ticket
    WHERE ProductionID = in_ProductionID AND SeatID = in_SeatID;

    -- Reject if already sold
    IF currentStatus = 'S' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Seat is already sold.';
    END IF;

    -- Reject if reserved and deadline not passed and buyer is not the assigned patron
    IF currentPatronID IS NOT NULL AND currentPatronID != in_BuyerPatronID AND (reservationDeadline IS NULL OR reservationDeadline >= CURRENT_DATE) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Seat is currently reserved for another patron.';
    END IF;

    -- Proceed with purchase
    UPDATE Ticket
    SET Status = 'S', PatronID = in_BuyerPatronID, Price = in_Price
    WHERE TicketID = ticketID;

    -- Log the financial transaction
    INSERT INTO Financial_Transaction (Type, Amount, Date, TicketID, ProductionID, Description) 
    VALUES ('I', in_Price, CURRENT_DATE, ticketID, in_ProductionID, 'Ticket Purchase');
END //
DELIMITER ;

-- Undoes a ticket purchase, the procedure above 
DELIMITER //
CREATE PROCEDURE UndoTicketPurchase (
    IN in_TicketID INT
)
BEGIN
    -- Mark the ticket as available again
    UPDATE Ticket
    SET Status = 'A', PatronID = NULL
    WHERE TicketID = in_TicketID;

    -- Remove the linked financial transaction
    DELETE FROM Financial_Transaction
    WHERE TicketID = in_TicketID;
END //
DELIMITER ;

-- Procedure that calculates the total cost, total income, and net balance for, a production, a date range of productions or all productions if productionID and Dates are null.
DELIMITER //
CREATE PROCEDURE GetProductionFinancialSummary (
    IN in_ProductionID INT,
    IN in_StartDate DATE,
    IN in_EndDate DATE
)
BEGIN
    SELECT
        p.ProductionID,
        p.ProductionDate,
        COALESCE(SUM(CASE WHEN ft.Type = 'I' THEN ft.Amount ELSE 0 END), 0) AS TotalIncome,
        COALESCE(SUM(CASE WHEN ft.Type = 'E' THEN ft.Amount ELSE 0 END), 0) AS TotalCost,
        COALESCE(SUM(CASE WHEN ft.Type = 'I' THEN ft.Amount ELSE 0 END), 0) -
        COALESCE(SUM(CASE WHEN ft.Type = 'E' THEN ft.Amount ELSE 0 END), 0) AS NetBalance
    FROM Production p
    LEFT JOIN Financial_Transaction ft ON ft.ProductionID = p.ProductionID
    WHERE 
        (in_ProductionID IS NULL OR p.ProductionID = in_ProductionID)
        AND (in_StartDate IS NULL OR p.ProductionDate >= in_StartDate)
        AND (in_EndDate IS NULL OR p.ProductionDate <= in_EndDate)
    GROUP BY p.ProductionID, p.ProductionDate;
END //
DELIMITER ;



--========================================================================================
-- Triggers
--========================================================================================

-- This trigger automatically generates a transaction for the play’s cost when it is added to a production 
DELIMITER //
CREATE TRIGGER trg_AddPlayCostTransaction
AFTER INSERT ON Production_Play
FOR EACH ROW
BEGIN
    DECLARE playCost DECIMAL(12,2);
    SELECT Cost INTO playCost FROM Play WHERE PlayID = NEW.PlayID;
    INSERT INTO Financial_Transaction (Type, Amount, Date, ProductionID, PlayID)
    VALUES ('E', playCost, CURRENT_DATE, NEW.ProductionID, NEW.PlayID);
END //
DELIMITER ;

-- This trigger automatically updates the total cost of a production when a play is added to it
-- DELIMITER //
-- CREATE TRIGGER trg_AddPlayCostTransaction
-- AFTER INSERT ON Production_Play
-- FOR EACH ROW
-- BEGIN
--     DECLARE playCost DECIMAL(12,2);
--     SELECT Cost INTO playCost FROM Play WHERE PlayID = NEW.PlayID;

--     INSERT INTO Financial_Transaction (Type, Amount, Date, ProductionID, Description) 
--     VALUES ('E', playCost, CURRENT_DATE, NEW.ProductionID, CONCAT('Base licensing cost for play added to production')
--     );
-- END //
-- DELIMITER ;

-- This trigger is used to create a transaction automatically when a dues payment is made.
DELIMITER //
CREATE TRIGGER trg_AutoTransactionOnDuesPayment
AFTER INSERT ON DuesPayment
FOR EACH ROW
BEGIN
    DECLARE totalPaid DECIMAL(10,2);
    DECLARE totalDue DECIMAL(10,2);

    -- Use function to get total paid so far including new payment
    SET totalPaid = GetTotalPaidForDues(NEW.DuesID);

    -- Get the total due for this dues record
    SELECT TotalDue INTO totalDue
    FROM DuesOwed
    WHERE DuesID = NEW.DuesID;

    -- Validate: total paid must not exceed total due
    IF totalPaid > totalDue THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Installment exceeds total dues for the year';
    END IF;

    -- Create associated financial transaction
    INSERT INTO Financial_Transaction (Type, Amount, Date, DuesPaymentID, Description) 
    VALUES ('I', NEW.AmountPaid, NEW.PaymentDate, NEW.PaymentID, CONCAT('Auto: Dues payment installment'));
END //
DELIMITER ;



--========================================================================================
-- Views
--========================================================================================



--========================================================================================
-- Reports
--========================================================================================



--========================================================================================
-- Supporting Code
--========================================================================================

-- Create reusable function to calculate total paid so far for a DuesID
DELIMITER //
CREATE FUNCTION GetTotalPaidForDues(in_DuesID INT) RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE total DECIMAL(10,2);
    SELECT IFNULL(SUM(AmountPaid), 0) INTO total
    FROM DuesPayment
    WHERE DuesID = in_DuesID;
    RETURN total;
END //
DELIMITER ;

-- END OF DOC
