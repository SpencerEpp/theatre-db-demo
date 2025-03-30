-- ========================================================================================
-- INFO BLOCK
--
--
--
-- ========================================================================================

-- ========================================================================================
-- Setup (Drop everything cleanly)
-- ========================================================================================
DROP TRIGGER IF EXISTS trg_AddPlayCostTransaction;
DROP TRIGGER IF EXISTS trg_AutoTransactionOnDuesPayment;
DROP TRIGGER IF EXISTS trg_TicketPurchaseTransaction;
DROP TRIGGER IF EXISTS trg_DeleteDuesPaymentTransaction;
DROP TRIGGER IF EXISTS trg_DeleteTicketTransaction;
DROP TRIGGER IF EXISTS trg_ReleaseTicketTransaction;
DROP TRIGGER IF EXISTS trg_DeleteSponsorContributionTransaction;
DROP TRIGGER IF EXISTS trg_DeletePlayCostTransaction;
DROP TRIGGER IF EXISTS trg_SponsorContributionIncomeOnInsert;

-- DB procedures
DROP PROCEDURE IF EXISTS CreatePlay;
DROP PROCEDURE IF EXISTS UpdatePlay;
DROP PROCEDURE IF EXISTS DeletePlay;
DROP PROCEDURE IF EXISTS CreateMember;
DROP PROCEDURE IF EXISTS UpdateMember;
DROP PROCEDURE IF EXISTS DeleteMember;
DROP PROCEDURE IF EXISTS AssignMemberToProduction;
DROP PROCEDURE IF EXISTS RemoveMemberFromProduction;
DROP PROCEDURE IF EXISTS CreateProduction;
DROP PROCEDURE IF EXISTS UpdateProduction;
DROP PROCEDURE IF EXISTS DeleteProduction;
DROP PROCEDURE IF EXISTS LinkSponsorToProduction;
DROP PROCEDURE IF EXISTS UnlinkSponsorFromProduction;
DROP PROCEDURE IF EXISTS CreateTicket;
DROP PROCEDURE IF EXISTS ReleaseTicket;
DROP PROCEDURE IF EXISTS UpdateTicketStatus;
DROP PROCEDURE IF EXISTS UpdateTicketPrice;
DROP PROCEDURE IF EXISTS CancelReservation;
DROP PROCEDURE IF EXISTS CreateSponsor;
DROP PROCEDURE IF EXISTS UpdateSponsor;
DROP PROCEDURE IF EXISTS DeleteSponsor;
DROP PROCEDURE IF EXISTS CreatePatron;
DROP PROCEDURE IF EXISTS UpdatePatron;
DROP PROCEDURE IF EXISTS DeletePatron;
DROP PROCEDURE IF EXISTS CreateMeeting;
DROP PROCEDURE IF EXISTS UpdateMeeting;
DROP PROCEDURE IF EXISTS DeleteMeeting;
DROP PROCEDURE IF EXISTS AssignMemberToMeeting;
DROP PROCEDURE IF EXISTS RemoveMemberFromMeeting;
DROP PROCEDURE IF EXISTS CreateDuesRecord;
DROP PROCEDURE IF EXISTS DeleteDuesRecord;
DROP PROCEDURE IF EXISTS CheckSeatAvailability;
DROP PROCEDURE IF EXISTS ReserveTicket;
DROP PROCEDURE IF EXISTS CreateSeat;
DROP PROCEDURE IF EXISTS UpdateSeat;
DROP PROCEDURE IF EXISTS DeleteSeat;
DROP PROCEDURE IF EXISTS AddPlayToProduction;
DROP PROCEDURE IF EXISTS UndoPlayFromProduction;
DROP PROCEDURE IF EXISTS AddProductionExpense;
DROP PROCEDURE IF EXISTS UndoProductionExpense;
DROP PROCEDURE IF EXISTS AddDuesInstallment;
DROP PROCEDURE IF EXISTS UndoDuesInstallment;
DROP PROCEDURE IF EXISTS PurchaseTicket;
DROP PROCEDURE IF EXISTS UndoTicketPurchase;
DROP PROCEDURE IF EXISTS ListTicketsForProduction;
DROP PROCEDURE IF EXISTS GetMemberParticipation;
DROP PROCEDURE IF EXISTS GetProductionFinancialSummary;

-- Report procedures
DROP PROCEDURE IF EXISTS GetPlayListingReport;
DROP PROCEDURE IF EXISTS GetProductionCastAndCrew;
DROP PROCEDURE IF EXISTS GetProductionSponsors;
DROP PROCEDURE IF EXISTS GetPatronReport;
DROP PROCEDURE IF EXISTS GetTicketSalesReport;
DROP PROCEDURE IF EXISTS GetMemberDuesReport;
DROP PROCEDURE IF EXISTS SuggestAlternateSeats;
DROP PROCEDURE IF EXISTS SmartTicketPurchase;

DROP FUNCTION IF EXISTS GetTotalPaidForDues;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS Financial_Transaction;
DROP TABLE IF EXISTS Member_Meeting;
DROP TABLE IF EXISTS Meeting;
DROP TABLE IF EXISTS Ticket;
DROP TABLE IF EXISTS Seat;
DROP TABLE IF EXISTS Patron;
DROP TABLE IF EXISTS Production_Sponsor;
DROP TABLE IF EXISTS Sponsor;
DROP TABLE IF EXISTS DuesPayment;
DROP TABLE IF EXISTS DuesOwed;
DROP TABLE IF EXISTS Member_Production;
DROP TABLE IF EXISTS Member;
DROP TABLE IF EXISTS Production_Play;
DROP TABLE IF EXISTS Production;
DROP TABLE IF EXISTS Play;
SET FOREIGN_KEY_CHECKS = 1;

-- ========================================================================================
-- DDL Statements
-- ========================================================================================

-- Creating the Play table
CREATE TABLE Play (
    PlayID INT PRIMARY KEY AUTO_INCREMENT,
    Title VARCHAR(100) NOT NULL,
    Author VARCHAR(255),
    Genre VARCHAR(100) NOT NULL,
    NumberOfActs TINYINT UNSIGNED NOT NULL,
    Cost DECIMAL(12,2) NOT NULL
);

-- Creating the Production table
CREATE TABLE Production (
    ProductionID INT PRIMARY KEY AUTO_INCREMENT,
    ProductionDate DATE NOT NULL -- ,
--    TotalCost DECIMAL(12,2) GENERATED ALWAYS AS (
--         (SELECT COALESCE(SUM(p.Cost), 0)
--          FROM Production_Play pp
--          JOIN Play p ON pp.PlayID = p.PlayID
--          WHERE pp.ProductionID = Production.ProductionID)
--         + 
--         (SELECT COALESCE(SUM(ft.Amount), 0)
--          FROM Financial_Transaction ft
--          WHERE ft.ProductionID = Production.ProductionID AND ft.Type = 'E' AND ft.PlayID IS NULL)
--     ) STORED
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
    MemberID INT PRIMARY KEY AUTO_INCREMENT,
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
    SponsorID INT PRIMARY KEY AUTO_INCREMENT,
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
    PatronID INT PRIMARY KEY AUTO_INCREMENT,
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
    TicketID INT PRIMARY KEY AUTO_INCREMENT,
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
    MeetingID INT PRIMARY KEY AUTO_INCREMENT,
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
CREATE TABLE Financial_Transaction (
    TransactionID INT PRIMARY KEY AUTO_INCREMENT,
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



-- ========================================================================================
-- Scripts NOTE: The below has not been tested yet from scripts to the end. (March 28th 10pm)
-- ========================================================================================

-- ========================================================================================
-- Procedures
-- ========================================================================================

-- CREATE PLAY
DELIMITER //
CREATE PROCEDURE CreatePlay (
    IN in_Title VARCHAR(100),
    IN in_Author VARCHAR(255),
    IN in_Genre VARCHAR(100),
    IN in_NumberOfActs TINYINT UNSIGNED,
    IN in_Cost DECIMAL(12,2)
)
BEGIN
    INSERT INTO Play (Title, Author, Genre, NumberOfActs, Cost)
    VALUES (in_Title, in_Author, in_Genre, in_NumberOfActs, in_Cost);
END //
DELIMITER ;

-- UPDATE PLAY
DELIMITER //
CREATE PROCEDURE UpdatePlay ( 
    IN in_PlayID INT,
    IN in_Title VARCHAR(100),
    IN in_Author VARCHAR(255),
    IN in_Genre VARCHAR(100),
    IN in_NumberOfActs TINYINT UNSIGNED,
    IN in_Cost DECIMAL(12,2)
)
BEGIN
    UPDATE Play
    SET
        Title = in_Title,
        Author = in_Author,
        Genre = in_Genre,
        NumberOfActs = in_NumberOfActs,
        Cost = in_Cost
    WHERE PlayID = in_PlayID;
END //
DELIMITER ;

-- DELETE PLAY
DELIMITER //
CREATE PROCEDURE DeletePlay (
    IN in_PlayID INT
)
BEGIN
    DELETE FROM Play
    WHERE PlayID = in_PlayID;
END //
DELIMITER ;

-- CREATE MEMBER
DELIMITER //
CREATE PROCEDURE CreateMember (
    IN in_Name VARCHAR(255),
    IN in_Email VARCHAR(100),
    IN in_Phone VARCHAR(20),
    IN in_Address VARCHAR(100),
    IN in_Role VARCHAR(100)
)
BEGIN
    INSERT INTO Member (Name, Email, Phone, Address, Role)
    VALUES (in_Name, in_Email, in_Phone, in_Address, in_Role);
END //
DELIMITER ;

-- UPDATE MEMBER
DELIMITER //
CREATE PROCEDURE UpdateMember (
    IN in_MemberID INT,
    IN in_Name VARCHAR(255),
    IN in_Email VARCHAR(100),
    IN in_Phone VARCHAR(20),
    IN in_Address VARCHAR(100),
    IN in_Role VARCHAR(100)
)
BEGIN
    UPDATE Member
    SET Name = in_Name,
        Email = in_Email,
        Phone = in_Phone,
        Address = in_Address,
        Role = in_Role
    WHERE MemberID = in_MemberID;
END //
DELIMITER ;

-- DELETE MEMBER
DELIMITER //
CREATE PROCEDURE DeleteMember (
    IN in_MemberID INT
)
BEGIN
    DELETE FROM Member WHERE MemberID = in_MemberID;
END //
DELIMITER ;

-- ASSIGN MEMBER TO PRODUCTION
DELIMITER //
CREATE PROCEDURE AssignMemberToProduction (
    IN in_MemberID INT,
    IN in_ProductionID INT,
    IN in_Role VARCHAR(100)
)
BEGIN
    INSERT INTO Member_Production (MemberID, ProductionID, Role)
    VALUES (in_MemberID, in_ProductionID, in_Role);
END //
DELIMITER ;

-- REMOVE MEMBER FROM PRODUCTION
DELIMITER //
CREATE PROCEDURE RemoveMemberFromProduction (
    IN in_MemberID INT,
    IN in_ProductionID INT
)
BEGIN
    DELETE FROM Member_Production
    WHERE MemberID = in_MemberID AND ProductionID = in_ProductionID;
END //
DELIMITER ;

-- CREATE PRODUCTION
DELIMITER //
CREATE PROCEDURE CreateProduction (
    IN in_ProductionDate DATE
)
BEGIN
    INSERT INTO Production (ProductionDate)
    VALUES (in_ProductionDate);
END //
DELIMITER ;

-- UPDATE PRODUCTION
DELIMITER //
CREATE PROCEDURE UpdateProduction (
    IN in_ProductionID INT,
    IN in_ProductionDate DATE
)
BEGIN
    UPDATE Production
    SET ProductionDate = in_ProductionDate
    WHERE ProductionID = in_ProductionID;
END //
DELIMITER ;

-- DELETE PRODUCTION
DELIMITER //
CREATE PROCEDURE DeleteProduction (
    IN in_ProductionID INT
)
BEGIN
    DELETE FROM Production WHERE ProductionID = in_ProductionID;
END //
DELIMITER ;

-- LINK SPONSOR TO PRODUCTION
DELIMITER //
CREATE PROCEDURE LinkSponsorToProduction (
    IN in_SponsorID INT,
    IN in_ProductionID INT,
    IN in_Amount DECIMAL(12,2)
)
BEGIN
    INSERT INTO Production_Sponsor (SponsorID, ProductionID, ContributionAmount)
    VALUES (in_SponsorID, in_ProductionID, in_Amount);
END //
DELIMITER ;

-- UNLINK SPONSOR FROM PRODUCTION
DELIMITER //
CREATE PROCEDURE UnlinkSponsorFromProduction (
    IN in_SponsorID INT,
    IN in_ProductionID INT
)
BEGIN
    DELETE FROM Production_Sponsor
    WHERE SponsorID = in_SponsorID AND ProductionID = in_ProductionID;
END //
DELIMITER ;

-- CREATE TICKET
DELIMITER //
CREATE PROCEDURE CreateTicket (
    IN in_ProductionID INT,
    IN in_SeatID INT,
    IN in_Price DECIMAL(6,2),
    IN in_ReservationDeadline DATE
)
BEGIN
    INSERT INTO Ticket (ProductionID, SeatID, Price, Status, ReservationDeadline)
    VALUES (in_ProductionID, in_SeatID, in_Price,'A', in_ReservationDeadline);
END //
DELIMITER ;

-- RELEASE TICKET (unassigns patron & sets available)
DELIMITER //
CREATE PROCEDURE ReleaseTicket (
    IN in_TicketID INT
)
BEGIN
    UPDATE Ticket
    SET Status = 'A',
        PatronID = NULL
    WHERE TicketID = in_TicketID;
END //
DELIMITER ;

-- UPDATE TICKET STATUS
DELIMITER //
CREATE PROCEDURE UpdateTicketStatus (
    IN in_TicketID INT,
    IN in_Status ENUM('S', 'A')
)
BEGIN
    UPDATE Ticket
    SET Status = in_Status
    WHERE TicketID = in_TicketID;
END //
DELIMITER ;

-- UPDATE TICKET PRICE
DELIMITER //
CREATE PROCEDURE UpdateTicketPrice (
    IN in_TicketID INT,
    IN in_NewPrice DECIMAL(6,2)
)
BEGIN
    UPDATE Ticket
    SET Price = in_NewPrice
    WHERE TicketID = in_TicketID;
END //
DELIMITER ;

-- CANCEL RESERVATION
DELIMITER //
CREATE PROCEDURE CancelReservation (
    IN in_TicketID INT
)
BEGIN
    UPDATE Ticket
    SET PatronID = NULL,
        Status = 'A'
    WHERE TicketID = in_TicketID;
END //
DELIMITER ;

-- CREATE SPONSOR
DELIMITER //
CREATE PROCEDURE CreateSponsor (
    IN in_Name VARCHAR(255),
    IN in_Type ENUM('C', 'I') -- C = Company, I = Individual
)
BEGIN
    INSERT INTO Sponsor (Name, Type)
    VALUES (in_Name, in_Type);
END //
DELIMITER ;

-- UPDATE SPONSOR
DELIMITER //
CREATE PROCEDURE UpdateSponsor (
    IN in_SponsorID INT,
    IN in_Name VARCHAR(255),
    IN in_Type ENUM('C', 'I')
)
BEGIN
    UPDATE Sponsor
    SET Name = in_Name,
        Type = in_Type
    WHERE SponsorID = in_SponsorID;
END //
DELIMITER ;

-- DELETE SPONSOR
DELIMITER //
CREATE PROCEDURE DeleteSponsor (
    IN in_SponsorID INT
)
BEGIN
    DELETE FROM Sponsor
    WHERE SponsorID = in_SponsorID;
END //
DELIMITER ;

-- CREATE PATRON
DELIMITER //
CREATE PROCEDURE CreatePatron (
    IN in_Name VARCHAR(255),
    IN in_Email VARCHAR(100),
    IN in_Address VARCHAR(100)
)
BEGIN
    INSERT INTO Patron (Name, Email, Address)
    VALUES (in_Name, in_Email, in_Address);
END //
DELIMITER ;

-- UPDATE PATRON
DELIMITER //
CREATE PROCEDURE UpdatePatron (
    IN in_PatronID INT,
    IN in_Name VARCHAR(255),
    IN in_Email VARCHAR(100),
    IN in_Address VARCHAR(100)
)
BEGIN
    UPDATE Patron
    SET Name = in_Name,
        Email = in_Email,
        Address = in_Address
    WHERE PatronID = in_PatronID;
END //
DELIMITER ;

-- DELETE PATRON
DELIMITER //
CREATE PROCEDURE DeletePatron (
    IN in_PatronID INT
)
BEGIN
    DELETE FROM Patron
    WHERE PatronID = in_PatronID;
END //
DELIMITER ;

-- CREATE MEETING
DELIMITER //
CREATE PROCEDURE CreateMeeting (
    IN in_Type ENUM('F', 'S'), -- F = Fall, S = Spring
    IN in_Date DATE
)
BEGIN
    INSERT INTO Meeting (Type, Date)
    VALUES (in_Type, in_Date);
END //
DELIMITER ;

-- UPDATE MEETING
DELIMITER //
CREATE PROCEDURE UpdateMeeting (
    IN in_MeetingID INT,
    IN in_Type ENUM('F', 'S'),
    IN in_Date DATE
)
BEGIN
    UPDATE Meeting
    SET Type = in_Type,
        Date = in_Date
    WHERE MeetingID = in_MeetingID;
END //
DELIMITER ;

-- DELETE MEETING
DELIMITER //
CREATE PROCEDURE DeleteMeeting (
    IN in_MeetingID INT
)
BEGIN
    DELETE FROM Meeting WHERE MeetingID = in_MeetingID;
END //
DELIMITER ;

-- ASSIGN MEMBER TO MEETING
DELIMITER //
CREATE PROCEDURE AssignMemberToMeeting (
    IN in_MemberID INT,
    IN in_MeetingID INT
)
BEGIN
    INSERT INTO Member_Meeting (MemberID, MeetingID)
    VALUES (in_MemberID, in_MeetingID);
END //
DELIMITER ;

-- REMOVE MEMBER FROM MEETING
DELIMITER //
CREATE PROCEDURE RemoveMemberFromMeeting (
    IN in_MemberID INT,
    IN in_MeetingID INT
)
BEGIN
    DELETE FROM Member_Meeting
    WHERE MemberID = in_MemberID AND MeetingID = in_MeetingID;
END //
DELIMITER ;

-- CREATE DUES RECORD
DELIMITER //
CREATE PROCEDURE CreateDuesRecord (
    IN in_MemberID INT,
    IN in_Year YEAR,
    IN in_TotalAmount DECIMAL(6,2)
)
BEGIN
    INSERT INTO DuesOwed (MemberID, Year, TotalDue)
    VALUES (in_MemberID, in_Year, in_TotalAmount);
END //
DELIMITER ;

-- DELETE DUES RECORD
DELIMITER //
CREATE PROCEDURE DeleteDuesRecord (
    IN in_DuesID INT
)
BEGIN
    DELETE FROM DuesOwed WHERE DuesID = in_DuesID;
END //
DELIMITER ;

-- CHECK SEAT AVAILABILITY
DELIMITER //
CREATE PROCEDURE CheckSeatAvailability (
    IN in_ProductionID INT,
    IN in_SeatID INT
)
BEGIN
    SELECT Status, PatronID, ReservationDeadline
    FROM Ticket
    WHERE ProductionID = in_ProductionID AND SeatID = in_SeatID;
END //
DELIMITER ;

-- RESERVE TICKET
DELIMITER //
CREATE PROCEDURE ReserveTicket (
    IN in_TicketID INT,
    IN in_PatronID INT,
    IN in_Deadline DATE
)
BEGIN
    UPDATE Ticket
    SET PatronID = in_PatronID,
        Status = 'A',
        ReservationDeadline = in_Deadline
    WHERE TicketID = in_TicketID;
END //
DELIMITER ;

-- CREATE SEAT
DELIMITER //
CREATE PROCEDURE CreateSeat (
    IN in_SeatRow CHAR(1),
    IN in_Number TINYINT
)
BEGIN
    INSERT INTO Seat (SeatRow, Number)
    VALUES (in_SeatRow, in_Number);
END //
DELIMITER ;

-- UPDATE SEAT
DELIMITER //
CREATE PROCEDURE UpdateSeat (
    IN in_SeatID INT,
    IN in_SeatRow CHAR(1),
    IN in_Number TINYINT
)
BEGIN
    UPDATE Seat
    SET SeatRow = in_SeatRow,
        Number = in_Number
    WHERE SeatID = in_SeatID;
END //
DELIMITER ;

-- DELETE SEAT
DELIMITER //
CREATE PROCEDURE DeleteSeat (
    IN in_SeatID INT
)
BEGIN
    DELETE FROM Seat WHERE SeatID = in_SeatID;
END //
DELIMITER ;

-- ADD PLAY TO PRODUCTION
DELIMITER //
CREATE PROCEDURE AddPlayToProduction (
    IN in_ProductionID INT,
    IN in_PlayID INT
)
BEGIN
    IF EXISTS (
        SELECT 1 FROM Production_Play
        WHERE ProductionID = in_ProductionID AND PlayID = in_PlayID
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'This play is already linked to the production.';
    ELSE
        INSERT INTO Production_Play (ProductionID, PlayID)
        VALUES (in_ProductionID, in_PlayID);
    END IF;
END //
DELIMITER ;

-- REMOVE PLAY FROM PRODUCTION
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

-- ADD EXPENSE TO PRODUCTION
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

-- REMOVE EXPENSE FROM PRODUCTION
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

-- ADD DUES INSTALLMENT
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

-- REMOVE INSTALLMENT
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

-- REMOVE TICKET PURCHASE
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

-- LIST TICKETS FOR PRODUCTION
DELIMITER //
CREATE PROCEDURE ListTicketsForProduction (
    IN in_ProductionID INT
)
BEGIN
    SELECT 
        t.TicketID,
        s.SeatRow,
        s.Number AS SeatNumber,
        t.Price,
        t.Status,
        t.ReservationDeadline,
        p.Name AS PatronName,
        p.Email AS PatronEmail
    FROM Ticket t
    JOIN Seat s ON t.SeatID = s.SeatID
    LEFT JOIN Patron p ON t.PatronID = p.PatronID
    WHERE t.ProductionID = in_ProductionID;
END //
DELIMITER ;

-- GET MEMBER PARTICIPATION
DELIMITER //
CREATE PROCEDURE GetMemberParticipation (
    IN in_MemberID INT
)
BEGIN
    SELECT 
        'Production' AS ActivityType,
        p.ProductionID,
        p.ProductionDate,
        mp.Role,
        NULL AS MeetingID,
        NULL AS MeetingType,
        NULL AS MeetingDate
    FROM Member_Production mp
    JOIN Production p ON mp.ProductionID = p.ProductionID
    WHERE mp.MemberID = in_MemberID

    UNION

    SELECT 
        'Meeting' AS ActivityType,
        NULL AS ProductionID,
        NULL AS ProductionDate,
        NULL AS Role,
        mm.MeetingID,
        m.Type,
        m.Date
    FROM Member_Meeting mm
    JOIN Meeting m ON mm.MeetingID = m.MeetingID
    WHERE mm.MemberID = in_MemberID;
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

-- =========================
-- REPORT PROCEDURES
-- =========================

-- Play Listing Report
DELIMITER //
CREATE PROCEDURE GetPlayListingReport()
BEGIN
    SELECT 
        Genre,
        Author,
        COUNT(*) AS TotalPlays,
        AVG(Cost) AS AverageLicensingCost,
        SUM(NumberOfActs) AS TotalActs
    FROM Play
    GROUP BY Genre, Author
    ORDER BY Genre, Author;
END //
DELIMITER ;

-- Program - Cast and Crew
DELIMITER //
CREATE PROCEDURE GetProductionCastAndCrew(IN in_ProductionID INT)
BEGIN
    SELECT 
        m.Name,
        m.Email,
        m.Role AS DefaultRole,
        mp.Role AS ProductionRole
    FROM Member_Production mp
    JOIN Member m ON mp.MemberID = m.MemberID
    WHERE mp.ProductionID = in_ProductionID
    ORDER BY mp.Role, m.Name;
END //
DELIMITER ;

-- Program - Sponsors
DELIMITER //
CREATE PROCEDURE GetProductionSponsors(IN in_ProductionID INT)
BEGIN
    SELECT 
        s.Name,
        s.Type,
        ps.ContributionAmount
    FROM Production_Sponsor ps
    JOIN Sponsor s ON ps.SponsorID = s.SponsorID
    WHERE ps.ProductionID = in_ProductionID;

    SELECT 
        COUNT(*) AS TotalSponsors,
        SUM(ContributionAmount) AS TotalContributions,
        SUM(CASE WHEN s.Type = 'C' THEN ps.ContributionAmount ELSE 0 END) AS CompanyContributions,
        SUM(CASE WHEN s.Type = 'I' THEN ps.ContributionAmount ELSE 0 END) AS IndividualContributions
    FROM Production_Sponsor ps
    JOIN Sponsor s ON ps.SponsorID = s.SponsorID
    WHERE ps.ProductionID = in_ProductionID;
END //
DELIMITER ;

-- Patron Report
DELIMITER //
CREATE PROCEDURE GetPatronReport(IN in_PatronID INT)
BEGIN
    SELECT 
        p.Name,
        p.Email,
        p.Address,
        COUNT(t.TicketID) AS TicketsPurchased,
        SUM(t.Price) AS TotalSpent
    FROM Patron p
    LEFT JOIN Ticket t ON p.PatronID = t.PatronID
    WHERE p.PatronID = in_PatronID
    GROUP BY p.PatronID;

    SELECT 
        t.TicketID,
        t.ProductionID,
        t.SeatID,
        t.Price,
        t.Status,
        t.ReservationDeadline
    FROM Ticket t
    WHERE t.PatronID = in_PatronID;
END //
DELIMITER ;

-- Ticket Sales Report
DELIMITER //
CREATE PROCEDURE GetTicketSalesReport(IN in_ProductionID INT)
BEGIN
    SELECT 
        t.TicketID,
        s.SeatRow,
        s.Number AS SeatNumber,
        t.Price,
        t.Status,
        p.Name AS Buyer
    FROM Ticket t
    JOIN Seat s ON t.SeatID = s.SeatID
    LEFT JOIN Patron p ON t.PatronID = p.PatronID
    WHERE t.ProductionID = in_ProductionID
    ORDER BY s.SeatRow, s.Number;

    SELECT 
        COUNT(*) AS TotalTickets,
        SUM(CASE WHEN t.Status = 'S' THEN 1 ELSE 0 END) AS SoldTickets,
        SUM(CASE WHEN t.Status = 'S' THEN t.Price ELSE 0 END) AS TotalRevenue,
        ROUND(AVG(t.Price), 2) AS AverageTicketPrice
    FROM Ticket t
    WHERE t.ProductionID = in_ProductionID;
END //
DELIMITER ;

-- Member Dues Report
DELIMITER //
CREATE PROCEDURE GetMemberDuesReport()
BEGIN
    SELECT 
        m.MemberID,
        m.Name,
        m.Email,
        d.Year,
        d.TotalDue,
        IFNULL(GetTotalPaidForDues(d.DuesID), 0) AS PaidSoFar,
        (d.TotalDue - IFNULL(GetTotalPaidForDues(d.DuesID), 0)) AS RemainingBalance
    FROM DuesOwed d
    JOIN Member m ON d.MemberID = m.MemberID
    WHERE d.TotalDue > IFNULL(GetTotalPaidForDues(d.DuesID), 0)
    ORDER BY d.Year, m.Name;
END //
DELIMITER ;

-- =========================================
-- SMART TICKET PURCHASE + FALLBACK SUPPORT
-- =========================================

-- Smart multi-seat ticket purchase
DELIMITER //
CREATE PROCEDURE SmartTicketPurchase(
    IN in_ProductionID INT,
    IN in_PatronID INT,
    IN in_SeatIDs TEXT, -- e.g. '[1,2,3]'
    IN in_Deadline DATE,
    IN in_Price DECIMAL(6,2)
)
BEGIN
    -- === 1. Declare variables ===
    DECLARE seat_id INT;
    DECLARE ticket_id INT;
    DECLARE done INT DEFAULT FALSE;

    -- === 2. Declare cursor ===
    DECLARE seat_cursor CURSOR FOR 
        SELECT CAST(value AS UNSIGNED) 
        FROM JSON_TABLE(in_SeatIDs, '$[*]' COLUMNS(value INT PATH '$')) AS jt;

    -- === 3. Declare handlers ===
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- === 4. Setup temp error table ===
    DROP TEMPORARY TABLE IF EXISTS TempErrors;
    CREATE TEMPORARY TABLE TempErrors (
        Message VARCHAR(255)
    );

    -- === 5. Open and process cursor ===
    OPEN seat_cursor;
    seat_loop: LOOP
        FETCH seat_cursor INTO seat_id;
        IF done THEN LEAVE seat_loop; END IF;

        -- Check if the seat is available
        SELECT TicketID INTO ticket_id
        FROM Ticket
        WHERE ProductionID = in_ProductionID AND SeatID = seat_id AND Status = 'A'
        LIMIT 1;

        IF ticket_id IS NOT NULL THEN
            UPDATE Ticket
            SET PatronID = in_PatronID,
                Price = in_Price,
                Status = 'S',
                ReservationDeadline = in_Deadline
            WHERE TicketID = ticket_id;

            INSERT INTO Financial_Transaction (Type, Amount, Date, TicketID, ProductionID, Description)
            VALUES ('I', in_Price, CURRENT_DATE, ticket_id, in_ProductionID, 'Smart Ticket Purchase');
        ELSE
            INSERT INTO TempErrors (Message)
            VALUES (CONCAT('Seat ID ', seat_id, ' is not available.'));
        END IF;
    END LOOP;
    CLOSE seat_cursor;

    -- Return all errors
    SELECT * FROM TempErrors;
END //
DELIMITER ;


-- Suggest fallback seats based on row/number ordering
DELIMITER //
CREATE PROCEDURE SuggestAlternateSeats(
    IN in_ProductionID INT,
    IN in_SeatCount INT
)
BEGIN
    SELECT t.SeatID, s.SeatRow, s.Number
    FROM Ticket t
    JOIN Seat s ON t.SeatID = s.SeatID
    WHERE t.ProductionID = in_ProductionID
      AND t.Status = 'A'
    ORDER BY s.SeatRow, s.Number
    LIMIT in_SeatCount;
END //
DELIMITER ;



-- ========================================================================================
-- Triggers
-- ========================================================================================

-- Trigger: Automatically create transaction when play added to production 
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

-- Trigger: Automatically create transaction on dues payment
DELIMITER //
CREATE TRIGGER trg_AutoTransactionOnDuesPayment
AFTER INSERT ON DuesPayment
FOR EACH ROW
BEGIN
    DECLARE totalPaid DECIMAL(10,2);
    DECLARE totalDue DECIMAL(10,2);
    SET totalPaid = GetTotalPaidForDues(NEW.DuesID);
    SELECT TotalDue INTO totalDue
    FROM DuesOwed
    WHERE DuesID = NEW.DuesID;
    IF totalPaid > totalDue THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Installment exceeds total dues for the year';
    END IF;
    INSERT INTO Financial_Transaction (Type, Amount, Date, DuesPaymentID, Description) 
    VALUES ('I', NEW.AmountPaid, NEW.PaymentDate, NEW.PaymentID, CONCAT('Auto: Dues payment installment'));
END //
DELIMITER ;

-- Trigger: Automatically log income transaction on ticket sale
DELIMITER //
CREATE TRIGGER trg_TicketPurchaseTransaction
AFTER UPDATE ON Ticket
FOR EACH ROW
BEGIN
    IF OLD.Status != 'S' AND NEW.Status = 'S' THEN
        INSERT INTO Financial_Transaction (Type, Amount, Date, TicketID, ProductionID, Description)
        VALUES ('I', NEW.Price, CURRENT_DATE, NEW.TicketID, NEW.ProductionID, 'Ticket Purchase (trigger)');
    END IF;
END //
DELIMITER ;

-- Trigger: Delete linked transaction when dues payment is deleted
DELIMITER //
CREATE TRIGGER trg_DeleteDuesPaymentTransaction
BEFORE DELETE ON DuesPayment
FOR EACH ROW
BEGIN
    DELETE FROM Financial_Transaction
    WHERE DuesPaymentID = OLD.PaymentID;
END //
DELIMITER ;

-- Trigger: Delete financial transaction when a ticket is deleted
DELIMITER //
CREATE TRIGGER trg_DeleteTicketTransaction
BEFORE DELETE ON Ticket
FOR EACH ROW
BEGIN
    DELETE FROM Financial_Transaction
    WHERE TicketID = OLD.TicketID;
END //
DELIMITER ;

-- Trigger: Delete financial transaction if ticket is "released" (sold → available)
DELIMITER //
CREATE TRIGGER trg_ReleaseTicketTransaction
BEFORE UPDATE ON Ticket
FOR EACH ROW
BEGIN
    IF OLD.Status = 'S' AND NEW.Status = 'A' THEN
        DELETE FROM Financial_Transaction
        WHERE TicketID = OLD.TicketID;
    END IF;
END //
DELIMITER ;

-- Trigger: Delete financial transaction if a sponsor contribution is removed
DELIMITER //
CREATE TRIGGER trg_DeleteSponsorContributionTransaction
BEFORE DELETE ON Production_Sponsor
FOR EACH ROW
BEGIN
    DELETE FROM Financial_Transaction
    WHERE SponsorID = OLD.SponsorID AND ProductionID = OLD.ProductionID
    AND Amount = OLD.ContributionAmount AND Type = 'I';
END //
DELIMITER ;

-- Trigger: Delete play cost transaction if play is removed from production
DELIMITER //
CREATE TRIGGER trg_DeletePlayCostTransaction
BEFORE DELETE ON Production_Play
FOR EACH ROW
BEGIN
    DELETE FROM Financial_Transaction
    WHERE ProductionID = OLD.ProductionID
      AND Description LIKE 'Base licensing cost for play added%'
      AND PlayID = OLD.PlayID;
END //
DELIMITER ;

-- Trigger: Automatically logs an income transaction when sponsor linked to production
DELIMITER //
CREATE TRIGGER trg_SponsorContributionIncomeOnInsert
AFTER INSERT ON Production_Sponsor
FOR EACH ROW
BEGIN
    INSERT INTO Financial_Transaction (Type, Amount, Date, SponsorID, ProductionID, Description)
    VALUES ('I', NEW.ContributionAmount, CURRENT_DATE, NEW.SponsorID, NEW.ProductionID, 'Sponsor contribution (trigger)');
END //
DELIMITER ;


-- ========================================================================================
-- Views
-- ========================================================================================

-- View all plays with author, genre and act count
CREATE VIEW vw_PlayListing AS
SELECT 
    PlayID, 
    Title, 
    Author, 
    Genre, 
    NumberOfActs
FROM Play;


-- View list members and roles for each production
CREATE VIEW vw_CastCrewByProduction AS
SELECT 
    mp.ProductionID,
    p.ProductionDate,
    m.MemberID,
    m.Name AS MemberName,
    m.Email,
    mp.Role AS ProductionRole
FROM Member_Production mp
JOIN Production p ON mp.ProductionID = p.ProductionID
JOIN Member m ON mp.MemberID = m.MemberID;


-- View sponsor names and amounts by production
CREATE VIEW vw_SponsorContributions AS
SELECT 
    ps.ProductionID,
    s.SponsorID,
    s.Name AS SponsorName,
    s.Type,
    ps.ContributionAmount
FROM Production_Sponsor ps
JOIN Sponsor s ON ps.SponsorID = s.SponsorID;


-- View patron name, tickets purchased and productions
CREATE VIEW vw_PatronHistory AS
SELECT 
    pat.PatronID,
    pat.Name AS PatronName,
    t.TicketID,
    t.ProductionID,
    prod.ProductionDate,
    t.SeatID,
    t.Price,
    t.Status,
    t.ReservationDeadline
FROM Patron pat
LEFT JOIN Ticket t ON pat.PatronID = t.PatronID
LEFT JOIN Production prod ON t.ProductionID = prod.ProductionID;


-- View seat info, price and patron per production
CREATE VIEW vw_TicketSalesByProduction AS
SELECT 
    t.ProductionID,
    t.TicketID,
    s.SeatRow,
    s.Number AS SeatNumber,
    t.Price,
    t.Status,
    p.Name AS PatronName,
    p.Email AS PatronEmail
FROM Ticket t
JOIN Seat s ON t.SeatID = s.SeatID
LEFT JOIN Patron p ON t.PatronID = p.PatronID;


-- View member contact info and dues status(paid/not paid)
CREATE VIEW vw_MemberDuesStatus AS
SELECT 
    m.MemberID,
    m.Name,
    m.Email,
    m.Phone,
    m.Address,
    d.Year,
    d.TotalDue,
    IFNULL(
      (SELECT SUM(AmountPaid) FROM DuesPayment WHERE DuesID = d.DuesID), 0
    ) AS PaidSoFar,
    CASE 
      WHEN IFNULL((SELECT SUM(AmountPaid) FROM DuesPayment WHERE DuesID = d.DuesID), 0) >= d.TotalDue 
        THEN 'Paid' 
      ELSE 'Not Paid' 
    END AS DuesStatus
FROM Member m
JOIN DuesOwed d ON m.MemberID = d.MemberID;


-- View income and expenses per production
CREATE VIEW vw_ProductionBalanceSheet AS
SELECT 
    p.ProductionID,
    p.ProductionDate,
    COALESCE(SUM(CASE WHEN ft.Type = 'I' THEN ft.Amount END), 0) AS TotalIncome,
    COALESCE(SUM(CASE WHEN ft.Type = 'E' THEN ft.Amount END), 0) AS TotalExpenses,
    COALESCE(SUM(CASE WHEN ft.Type = 'I' THEN ft.Amount END), 0) - 
    COALESCE(SUM(CASE WHEN ft.Type = 'E' THEN ft.Amount END), 0) AS NetBalance
FROM Production p
LEFT JOIN Financial_Transaction ft ON p.ProductionID = ft.ProductionID
GROUP BY p.ProductionID, p.ProductionDate;


-- ========================================================================================
-- Reports
-- ========================================================================================



-- ========================================================================================
-- Supporting Code
-- ========================================================================================

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
