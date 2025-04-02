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
DROP TRIGGER IF EXISTS trg_NullifyPlayCostTransaction;
DROP TRIGGER IF EXISTS trg_IncrementTotalCost;
DROP TRIGGER IF EXISTS trg_DecrementTotalCost;
DROP TRIGGER IF EXISTS trg_DecrementTotalCostOnPlayDelete;
DROP TRIGGER IF EXISTS trg_AutoTransactionOnDuesPayment;
DROP TRIGGER IF EXISTS trg_BeforeDelete_DuesPayment;
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
DROP PROCEDURE IF EXISTS UndoExpense;
DROP PROCEDURE IF EXISTS AddDuesInstallment;
DROP PROCEDURE IF EXISTS UndoDuesInstallment;
DROP PROCEDURE IF EXISTS PurchaseTicket;
DROP PROCEDURE IF EXISTS UndoTicketPurchase;

-- Report procedures
DROP PROCEDURE IF EXISTS ListTicketsForProduction; 
DROP PROCEDURE IF EXISTS GetMemberParticipation;
DROP PROCEDURE IF EXISTS GetProductionFinancialSummary;
DROP PROCEDURE IF EXISTS GetPlayListingReport;
DROP PROCEDURE IF EXISTS GetProductionCastAndCrew;
DROP PROCEDURE IF EXISTS GetProductionSponsorTotal;
DROP PROCEDURE IF EXISTS GetPatronReport;
DROP PROCEDURE IF EXISTS GetTicketSalesReport;
DROP PROCEDURE IF EXISTS GetMemberDuesReport;
DROP PROCEDURE IF EXISTS SuggestAlternateSeats;

DROP VIEW IF EXISTS vw_PlayListing;
DROP VIEW IF EXISTS vw_CastCrewByProduction;
DROP VIEW IF EXISTS vw_SponsorContributions;
DROP VIEW IF EXISTS vw_PatronHistory;
DROP VIEW IF EXISTS vw_TicketSalesByProduction;
DROP VIEW IF EXISTS vw_MemberDuesStatus;
DROP VIEW IF EXISTS vw_ProductionBalanceSheet;
DROP VIEW IF EXISTS vw_TicketSummary;

DROP FUNCTION IF EXISTS GetTotalDueForDues;
DROP FUNCTION IF EXISTS GetTotalPaidForDues;

-- This is to purge all tables therefore foreign keys dont matter
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
    Author VARCHAR(255) NOT NULL,
    Genre VARCHAR(100) NOT NULL,
    NumberOfActs TINYINT UNSIGNED NOT NULL,
    Cost DECIMAL(12,2) NOT NULL
);

-- Creating the Production table
CREATE TABLE Production (
    ProductionID INT PRIMARY KEY AUTO_INCREMENT,
    ProductionDate DATE NOT NULL,
    TimeOfProduction TIME NOT NULL,
    TotalCost DECIMAL(12,2) DEFAULT 0
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
    DuesID INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
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
    Type CHAR(1) NOT NULL -- ‘C’ for company, ‘I’ for individual 
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
    SeatID INT PRIMARY KEY AUTO_INCREMENT,
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
    Status CHAR(1) NOT NULL, -- ‘S’ for sold, ‘A’ for avalible
    ReservationDeadline DATE NULL,
    FOREIGN KEY (ProductionID) REFERENCES Production(ProductionID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (PatronID) REFERENCES Patron(PatronID) ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (SeatID) REFERENCES Seat(SeatID) ON DELETE CASCADE ON UPDATE CASCADE,
    UNIQUE (ProductionID, SeatID) -- Prevent duplicate ticket entries per production/seat
);

-- Creating the Meeting table
CREATE TABLE Meeting (
    MeetingID INT PRIMARY KEY AUTO_INCREMENT,
    Type CHAR(1) NOT NULL, -- ‘F’ for Fall, ‘S’ for Spring
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
    Type CHAR(1) NOT NULL, -- 'I' for Income, 'E' for Expense
    Amount DECIMAL(12,2) NOT NULL,
    Date DATE NOT NULL,
    Description VARCHAR(255) NULL,
    DuesPaymentID INT NULL,
    TicketID INT NULL,
    SponsorID INT NULL,
    ProductionID INT NULL,
    PlayID INT NULL,
    FOREIGN KEY (DuesPaymentID) REFERENCES DuesPayment(PaymentID) ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (TicketID) REFERENCES Ticket(TicketID) ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (SponsorID) REFERENCES Sponsor(SponsorID) ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (ProductionID) REFERENCES Production(ProductionID) ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (PlayID) REFERENCES Play(PlayID) ON DELETE SET NULL ON UPDATE CASCADE
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
    -- Validation
    IF in_Title IS NULL OR CHAR_LENGTH(in_Title) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Title is required';
    END IF;
    IF CHAR_LENGTH(in_Title) > 100 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Title cannot exceed 100 characters';
    END IF;
    IF in_Author IS NULL OR CHAR_LENGTH(in_Author) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Author is required';
    END IF;
    IF CHAR_LENGTH(in_Author) > 255 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Author cannot exceed 255 characters';
    END IF;
    IF in_Genre IS NULL OR CHAR_LENGTH(in_Genre) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Genre is required';
    END IF;
    IF CHAR_LENGTH(in_Genre) > 100 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Genre cannot exceed 100 characters';
    END IF;
    IF in_NumberOfActs IS NULL OR in_NumberOfActs < 1 OR in_NumberOfActs > 255 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'NumberOfActs must be between 1 and 255';
    END IF;
    IF in_Cost IS NULL OR in_Cost < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cost must be non-negative';
    END IF;

    -- Duplicate check
    IF EXISTS (
        SELECT 1 FROM Play
        WHERE Title = in_Title
          AND Author = in_Author
          AND Genre = in_Genre
          AND NumberOfActs = in_NumberOfActs
          AND Cost = in_Cost
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'A play with the same details already exists';
    END IF;

    -- Main logic
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
    -- Validation
    IF in_PlayID IS NULL OR in_PlayID < 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Valid PlayID is required';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Play WHERE PlayID = in_PlayID) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'PlayID does not exist';
    END IF;
    IF in_Title IS NULL OR CHAR_LENGTH(in_Title) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Title is required';
    END IF;
    IF CHAR_LENGTH(in_Title) > 100 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Title cannot exceed 100 characters';
    END IF;
    IF in_Author IS NULL OR CHAR_LENGTH(in_Author) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Author is required';
    END IF;
    IF CHAR_LENGTH(in_Author) > 255 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Author cannot exceed 255 characters';
    END IF;
    IF in_Genre IS NULL OR CHAR_LENGTH(in_Genre) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Genre is required';
    END IF;
    IF CHAR_LENGTH(in_Genre) > 100 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Genre cannot exceed 100 characters';
    END IF;
    IF in_NumberOfActs IS NULL OR in_NumberOfActs < 1 OR in_NumberOfActs > 255 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'NumberOfActs must be between 1 and 255';
    END IF;
    IF in_Cost IS NULL OR in_Cost < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cost must be non-negative';
    END IF;

    -- Main logic
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
    -- Validation
    IF in_PlayID IS NULL OR in_PlayID < 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Valid PlayID is required';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Play WHERE PlayID = in_PlayID) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'PlayID does not exist';
    END IF;

    -- Main logic
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
    -- Validation
    IF in_Name IS NULL OR CHAR_LENGTH(in_Name) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Name is required';
    END IF;
    IF CHAR_LENGTH(in_Name) > 255 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Name cannot exceed 255 characters';
    END IF;
    IF in_Email IS NULL OR CHAR_LENGTH(in_Email) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Email is required';
    END IF;
    IF CHAR_LENGTH(in_Email) > 100 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Email cannot exceed 100 characters';
    END IF;
    IF in_Phone IS NULL OR CHAR_LENGTH(in_Phone) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Phone is required';
    END IF;
    IF CHAR_LENGTH(in_Phone) > 20 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Phone cannot exceed 20 characters';
    END IF;
    IF in_Address IS NULL OR CHAR_LENGTH(in_Address) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Address is required';
    END IF;
    IF CHAR_LENGTH(in_Address) > 100 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Address cannot exceed 100 characters';
    END IF;
    IF in_Role IS NULL OR CHAR_LENGTH(in_Role) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Role is required';
    END IF;
    IF CHAR_LENGTH(in_Role) > 100 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Role cannot exceed 100 characters';
    END IF;

    -- Duplicate check
    IF EXISTS (
        SELECT 1 FROM Member
        WHERE Name = in_Name
          AND Email = in_Email
          AND Phone = in_Phone
          AND Address = in_Address
          AND Role = in_Role
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'A member with the same details already exists';
    END IF;

    -- Main logic
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
    -- Validation
    IF in_MemberID IS NULL OR in_MemberID < 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Valid MemberID is required';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Member WHERE MemberID = in_MemberID) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'MemberID does not exist';
    END IF;
    IF in_Name IS NULL OR CHAR_LENGTH(in_Name) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Name is required';
    END IF;
    IF CHAR_LENGTH(in_Name) > 255 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Name cannot exceed 255 characters';
    END IF;
    IF in_Email IS NULL OR CHAR_LENGTH(in_Email) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Email is required';
    END IF;
    IF CHAR_LENGTH(in_Email) > 100 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Email cannot exceed 100 characters';
    END IF;
    IF in_Phone IS NULL OR CHAR_LENGTH(in_Phone) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Phone is required';
    END IF;
    IF CHAR_LENGTH(in_Phone) > 20 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Phone cannot exceed 20 characters';
    END IF;
    IF in_Address IS NULL OR CHAR_LENGTH(in_Address) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Address is required';
    END IF;
    IF CHAR_LENGTH(in_Address) > 100 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Address cannot exceed 100 characters';
    END IF;
    IF in_Role IS NULL OR CHAR_LENGTH(in_Role) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Role is required';
    END IF;
    IF CHAR_LENGTH(in_Role) > 100 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Role cannot exceed 100 characters';
    END IF;

    -- Main logic
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
    -- Validation
    IF in_MemberID IS NULL OR in_MemberID < 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Valid MemberID is required';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Member WHERE MemberID = in_MemberID) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'MemberID does not exist';
    END IF;

    -- Main logic
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
    -- Validation
    IF in_MemberID IS NULL OR in_MemberID < 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Valid MemberID is required';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Member WHERE MemberID = in_MemberID) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'MemberID does not exist';
    END IF;
    IF in_ProductionID IS NULL OR in_ProductionID < 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Valid ProductionID is required';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Production WHERE ProductionID = in_ProductionID) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ProductionID does not exist';
    END IF;
    IF in_Role IS NULL OR CHAR_LENGTH(in_Role) < 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Role is required';
    END IF;
    IF CHAR_LENGTH(in_Role) > 100 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Role cannot exceed 100 characters';
    END IF;
    IF EXISTS (
        SELECT 1 FROM Member_Production
        WHERE MemberID = in_MemberID AND ProductionID = in_ProductionID
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Member is already assigned to this production';
    END IF;

    -- Main logic
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
    -- Validation
    IF in_MemberID IS NULL OR in_MemberID < 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Valid MemberID is required';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Member WHERE MemberID = in_MemberID) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'MemberID does not exist';
    END IF;
    IF in_ProductionID IS NULL OR in_ProductionID < 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Valid ProductionID is required';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Production WHERE ProductionID = in_ProductionID) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ProductionID does not exist';
    END IF;
    IF NOT EXISTS (
        SELECT 1 FROM Member_Production
        WHERE MemberID = in_MemberID AND ProductionID = in_ProductionID
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'This member is not assigned to that production';
    END IF;

    -- Main logic
    DELETE FROM Member_Production
    WHERE MemberID = in_MemberID AND ProductionID = in_ProductionID;
END //
DELIMITER ;

-- CREATE PRODUCTION
DELIMITER //
CREATE PROCEDURE CreateProduction (
    IN in_ProductionDate DATE,
    IN in_ProductionTime TIME
)
BEGIN
    -- Validation
    IF in_ProductionDate IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Production date is required';
    END IF;
    IF in_ProductionDate < CURDATE() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Production date cannot be in the past';
    END IF;
    IF in_ProductionTime IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Production time is required';
    END IF;

    -- Duplicate check
    IF EXISTS (
        SELECT 1 FROM Production
        WHERE ProductionDate = in_ProductionDate AND TimeOfProduction = in_ProductionTime
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'A production already exists for this date';
    END IF;

    -- Main logic
    INSERT INTO Production (ProductionDate, TimeOfProduction)
    VALUES (in_ProductionDate, in_ProductionTime);
END //
DELIMITER ;

-- UPDATE PRODUCTION
DELIMITER //
CREATE PROCEDURE UpdateProduction (
    IN in_ProductionID INT,
    IN in_ProductionDate DATE,
    IN in_ProductionTime TIME
)
BEGIN
    -- Validation
    IF in_ProductionID IS NULL OR in_ProductionID < 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Valid ProductionID is required';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Production WHERE ProductionID = in_ProductionID) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ProductionID does not exist';
    END IF;
    IF in_ProductionDate IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Production date is required';
    END IF;
    IF in_ProductionDate < CURDATE() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Production date cannot be in the past';
    END IF;
    IF in_ProductionTime IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Production time is required';
    END IF;

    -- Main logic
    UPDATE Production
    SET ProductionDate = in_ProductionDate AND TimeOfProduction = in_ProductionTime
    WHERE ProductionID = in_ProductionID;
END //
DELIMITER ;

-- DELETE PRODUCTION
DELIMITER //
CREATE PROCEDURE DeleteProduction (
    IN in_ProductionID INT
)
BEGIN
    -- Validation
    IF in_ProductionID IS NULL OR in_ProductionID < 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Valid ProductionID is required';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Production WHERE ProductionID = in_ProductionID) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ProductionID does not exist';
    END IF;

    -- Main logic
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
    -- Validation
    IF in_SponsorID IS NULL OR in_SponsorID < 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Valid SponsorID is required';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Sponsor WHERE SponsorID = in_SponsorID) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'SponsorID does not exist';
    END IF;
    IF in_ProductionID IS NULL OR in_ProductionID < 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Valid ProductionID is required';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Production WHERE ProductionID = in_ProductionID) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ProductionID does not exist';
    END IF;
    IF in_Amount IS NULL OR in_Amount < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Contribution amount must be non-negative';
    END IF;
    IF EXISTS (
        SELECT 1 FROM Production_Sponsor
        WHERE SponsorID = in_SponsorID AND ProductionID = in_ProductionID
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Sponsor is already linked to this production';
    END IF;

    -- Main logic
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
    -- Validation
    IF in_SponsorID IS NULL OR in_SponsorID < 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Valid SponsorID is required';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Sponsor WHERE SponsorID = in_SponsorID) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'SponsorID does not exist';
    END IF;
    IF in_ProductionID IS NULL OR in_ProductionID < 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Valid ProductionID is required';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Production WHERE ProductionID = in_ProductionID) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ProductionID does not exist';
    END IF;
    IF NOT EXISTS (
        SELECT 1 FROM Production_Sponsor
        WHERE SponsorID = in_SponsorID AND ProductionID = in_ProductionID
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Sponsor is not linked to this production';
    END IF;

    -- Main logic
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
    -- Validation
    IF in_ProductionID IS NULL OR in_ProductionID < 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Valid ProductionID is required';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Production WHERE ProductionID = in_ProductionID) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ProductionID does not exist';
    END IF;
    IF in_SeatID IS NULL OR in_SeatID < 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Valid SeatID is required';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Seat WHERE SeatID = in_SeatID) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'SeatID does not exist';
    END IF;
    IF in_Price IS NULL OR in_Price < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ticket price must be non-negative';
    END IF;
    IF in_ReservationDeadline IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Reservation deadline is required';
    END IF;
    IF in_ReservationDeadline < CURDATE() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Reservation deadline cannot be in the past';
    END IF;

    -- Duplicate check
    IF EXISTS (
        SELECT 1 FROM Ticket
        WHERE ProductionID = in_ProductionID AND SeatID = in_SeatID
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'A ticket already exists for this production and seat';
    END IF;

    -- Main logic
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
    -- Validation
    IF in_TicketID IS NULL OR in_TicketID < 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Valid TicketID is required';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Ticket WHERE TicketID = in_TicketID) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'TicketID does not exist';
    END IF;

    -- Main logic
    UPDATE Ticket
    SET Status = 'A', PatronID = NULL
    WHERE TicketID = in_TicketID;
END //
DELIMITER ;

-- UPDATE TICKET STATUS
DELIMITER //
CREATE PROCEDURE UpdateTicketStatus (
    IN in_TicketID INT,
    IN in_Status CHAR(1)
)
BEGIN
    -- Validation
    IF in_TicketID IS NULL OR in_TicketID < 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Valid TicketID is required';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Ticket WHERE TicketID = in_TicketID) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'TicketID does not exist';
    END IF;
    IF in_Status IS NULL OR in_Status NOT IN ('A', 'S') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Status must be either "A" (available) or "S" (sold)';
    END IF;

    -- Main logic
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
    -- Validation
    IF in_TicketID IS NULL OR in_TicketID < 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Valid TicketID is required';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Ticket WHERE TicketID = in_TicketID) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'TicketID does not exist';
    END IF;
    IF in_NewPrice IS NULL OR in_NewPrice < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'New price must be a non-negative value';
    END IF;

    -- Main logic
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
    -- Validation
    IF in_TicketID IS NULL OR in_TicketID < 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Valid TicketID is required';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Ticket WHERE TicketID = in_TicketID) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'TicketID does not exist';
    END IF;
    IF NOT EXISTS (
        SELECT 1 FROM Ticket
        WHERE TicketID = in_TicketID AND PatronID IS NOT NULL
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ticket is not currently reserved';
    END IF;

    -- Main logic
    UPDATE Ticket
    SET PatronID = NULL, Status = 'A'
    WHERE TicketID = in_TicketID;
END //
DELIMITER ;

-- CREATE SPONSOR
DELIMITER //
CREATE PROCEDURE CreateSponsor (
    IN in_Name VARCHAR(255),
    IN in_Type CHAR(1) -- C = Company, I = Individual
)
BEGIN
    -- Validation
    IF in_Name IS NULL OR CHAR_LENGTH(in_Name) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Sponsor name is required';
    END IF;
    IF CHAR_LENGTH(in_Name) > 255 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Sponsor name cannot exceed 255 characters';
    END IF;
    IF in_Type IS NULL OR in_Type NOT IN ('C', 'I') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Sponsor type must be either "C" (Company) or "I" (Individual)';
    END IF;

    -- Duplicate check
    IF EXISTS (
        SELECT 1 FROM Sponsor
        WHERE Name = in_Name AND Type = in_Type
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'A sponsor with this name and type already exists';
    END IF;

    -- Main logic
    INSERT INTO Sponsor (Name, Type)
    VALUES (in_Name, in_Type);
END //
DELIMITER ;

-- UPDATE SPONSOR
DELIMITER //
CREATE PROCEDURE UpdateSponsor (
    IN in_SponsorID INT,
    IN in_Name VARCHAR(255),
    IN in_Type CHAR(1)
)
BEGIN
    -- Validation
    IF in_SponsorID IS NULL OR in_SponsorID < 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Valid SponsorID is required';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Sponsor WHERE SponsorID = in_SponsorID) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'SponsorID does not exist';
    END IF;
    IF in_Name IS NULL OR CHAR_LENGTH(in_Name) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Sponsor name is required';
    END IF;
    IF CHAR_LENGTH(in_Name) > 255 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Sponsor name cannot exceed 255 characters';
    END IF;
    IF in_Type IS NULL OR in_Type NOT IN ('C', 'I') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Sponsor type must be either "C" (Company) or "I" (Individual)';
    END IF;

    -- Main logic
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
    -- Validation
    IF in_SponsorID IS NULL OR in_SponsorID < 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Valid SponsorID is required';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Sponsor WHERE SponsorID = in_SponsorID) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'SponsorID does not exist';
    END IF;

    -- Main logic
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
    -- Validation
    IF in_Name IS NULL OR CHAR_LENGTH(in_Name) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Patron name is required';
    END IF;
    IF CHAR_LENGTH(in_Name) > 255 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Patron name cannot exceed 255 characters';
    END IF;
    IF in_Email IS NULL OR CHAR_LENGTH(in_Email) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Email is required';
    END IF;
    IF CHAR_LENGTH(in_Email) > 100 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Email cannot exceed 100 characters';
    END IF;
    IF in_Address IS NULL OR CHAR_LENGTH(in_Address) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Address is required';
    END IF;
    IF CHAR_LENGTH(in_Address) > 100 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Address cannot exceed 100 characters';
    END IF;

    -- Duplicate email check
    IF EXISTS (
        SELECT 1 FROM Patron WHERE Email = in_Email
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'A patron with this email already exists';
    END IF;

    -- Main logic
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
    -- Validation
    IF in_PatronID IS NULL OR in_PatronID < 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Valid PatronID is required';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Patron WHERE PatronID = in_PatronID) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'PatronID does not exist';
    END IF;
    IF in_Name IS NULL OR CHAR_LENGTH(in_Name) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Patron name is required';
    END IF;
    IF CHAR_LENGTH(in_Name) > 255 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Patron name cannot exceed 255 characters';
    END IF;
    IF in_Email IS NULL OR CHAR_LENGTH(in_Email) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Email is required';
    END IF;
    IF CHAR_LENGTH(in_Email) > 100 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Email cannot exceed 100 characters';
    END IF;
    IF in_Address IS NULL OR CHAR_LENGTH(in_Address) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Address is required';
    END IF;
    IF CHAR_LENGTH(in_Address) > 100 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Address cannot exceed 100 characters';
    END IF;

    -- Main logic
    UPDATE Patron
    SET Name = in_Name, Email = in_Email, Address = in_Address
    WHERE PatronID = in_PatronID;
END //
DELIMITER ;

-- DELETE PATRON
DELIMITER //
CREATE PROCEDURE DeletePatron (
    IN in_PatronID INT
)
BEGIN
    -- Validation
    IF in_PatronID IS NULL OR in_PatronID < 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Valid PatronID is required';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Patron WHERE PatronID = in_PatronID) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'PatronID does not exist';
    END IF;

    -- Main logic
    DELETE FROM Patron
    WHERE PatronID = in_PatronID;
END //
DELIMITER ;

-- CREATE MEETING
DELIMITER //
CREATE PROCEDURE CreateMeeting (
    IN in_Type CHAR(1), -- F = Fall, S = Spring
    IN in_Date DATE
)
BEGIN
    -- Validation
    IF in_Type IS NULL OR in_Type NOT IN ('F', 'S') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Meeting type must be either "F" (Fall) or "S" (Spring)';
    END IF;
    IF in_Date IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Meeting date is required';
    END IF;
    IF in_Date < CURDATE() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Meeting date cannot be in the past';
    END IF;

    -- Duplicate meeting check
    IF EXISTS (
        SELECT 1 FROM Meeting WHERE Type = in_Type AND Date = in_Date
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'A meeting of this type already exists on this date';
    END IF;

    -- Main logic
    INSERT INTO Meeting (Type, Date)
    VALUES (in_Type, in_Date);
END //
DELIMITER ;

-- UPDATE MEETING
DELIMITER //
CREATE PROCEDURE UpdateMeeting (
    IN in_MeetingID INT,
    IN in_Type CHAR(1),
    IN in_Date DATE
)
BEGIN
    -- Validation
    IF in_MeetingID IS NULL OR in_MeetingID < 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Valid MeetingID is required';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Meeting WHERE MeetingID = in_MeetingID) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'MeetingID does not exist';
    END IF;
    IF in_Type IS NULL OR in_Type NOT IN ('F', 'S') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Meeting type must be either "F" (Fall) or "S" (Spring)';
    END IF;
    IF in_Date IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Meeting date is required';
    END IF;
    IF in_Date < CURDATE() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Meeting date cannot be in the past';
    END IF;

    -- Main logic
    UPDATE Meeting
    SET Type = in_Type, Date = in_Date
    WHERE MeetingID = in_MeetingID;
END //
DELIMITER ;

-- DELETE MEETING
DELIMITER //
CREATE PROCEDURE DeleteMeeting (
    IN in_MeetingID INT
)
BEGIN
    -- Validation
    IF in_MeetingID IS NULL OR in_MeetingID < 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Valid MeetingID is required';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Meeting WHERE MeetingID = in_MeetingID) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'MeetingID does not exist';
    END IF;

    -- Main logic
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
    -- Validation
    IF in_MemberID IS NULL OR in_MemberID < 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Valid MemberID is required';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Member WHERE MemberID = in_MemberID) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'MemberID does not exist';
    END IF;
    IF in_MeetingID IS NULL OR in_MeetingID < 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Valid MeetingID is required';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Meeting WHERE MeetingID = in_MeetingID) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'MeetingID does not exist';
    END IF;
    IF EXISTS (
        SELECT 1 FROM Member_Meeting
        WHERE MemberID = in_MemberID AND MeetingID = in_MeetingID
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Member is already assigned to this meeting';
    END IF;

    -- Main logic
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
    -- Validation
    IF in_MemberID IS NULL OR in_MemberID < 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Valid MemberID is required';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Member WHERE MemberID = in_MemberID) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'MemberID does not exist';
    END IF;
    IF in_MeetingID IS NULL OR in_MeetingID < 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Valid MeetingID is required';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Meeting WHERE MeetingID = in_MeetingID) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'MeetingID does not exist';
    END IF;
    IF NOT EXISTS (
        SELECT 1 FROM Member_Meeting
        WHERE MemberID = in_MemberID AND MeetingID = in_MeetingID
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'This member is not assigned to that meeting';
    END IF;

    -- Main logic
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
    -- Validation
    IF in_MemberID IS NULL OR in_MemberID < 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Valid MemberID is required';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Member WHERE MemberID = in_MemberID) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'MemberID does not exist';
    END IF;
    IF in_Year IS NULL OR in_Year < YEAR(CURDATE()) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Dues can only be created for the current year or the future';
    END IF;
    IF in_TotalAmount IS NULL OR in_TotalAmount < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Total amount due must be a non-negative value';
    END IF;

    -- Duplicate check
    IF EXISTS (
        SELECT 1 FROM DuesOwed WHERE MemberID = in_MemberID AND Year = in_Year
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Dues record for this member and year already exists';
    END IF;

    -- Main logic
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
    -- Validation
    IF in_DuesID IS NULL OR in_DuesID < 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Valid DuesID is required';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM DuesOwed WHERE DuesID = in_DuesID) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'DuesID does not exist';
    END IF;

    -- Main logic
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
    -- Validation
    IF in_ProductionID IS NULL OR in_ProductionID < 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Valid ProductionID is required';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Production WHERE ProductionID = in_ProductionID) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ProductionID does not exist';
    END IF;
    IF in_SeatID IS NULL OR in_SeatID < 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Valid SeatID is required';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Seat WHERE SeatID = in_SeatID) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'SeatID does not exist';
    END IF;
    IF NOT EXISTS (
        SELECT 1 FROM Ticket
        WHERE ProductionID = in_ProductionID AND SeatID = in_SeatID
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No ticket found for this seat in the specified production';
    END IF;

    -- Main logic
    SELECT 
        t.TicketID,
        t.Status,
        t.PatronID,
        t.ReservationDeadline,
        p.TimeOfProduction
    FROM Ticket t
    JOIN Production p ON t.ProductionID = p.ProductionID
    WHERE t.ProductionID = in_ProductionID AND t.SeatID = in_SeatID;
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
    -- Validation
    IF in_TicketID IS NULL OR in_TicketID < 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Valid TicketID is required';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Ticket WHERE TicketID = in_TicketID) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'TicketID does not exist';
    END IF;
    IF in_PatronID IS NULL OR in_PatronID < 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Valid PatronID is required';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Patron WHERE PatronID = in_PatronID) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'PatronID does not exist';
    END IF;
    IF in_Deadline IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Reservation deadline is required';
    END IF;
    IF in_Deadline < CURDATE() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Reservation deadline cannot be in the past';
    END IF;
    IF EXISTS (
        SELECT 1 FROM Ticket
        WHERE TicketID = in_TicketID AND (Status <> 'A' OR PatronID IS NOT NULL)
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ticket is not available for reservation';
    END IF;

    -- Main logic
    UPDATE Ticket
    SET PatronID = in_PatronID, Status = 'A', ReservationDeadline = in_Deadline
    WHERE TicketID = in_TicketID;
END //
DELIMITER ;

-- CREATE SEAT (A-Z, 1-50)
DELIMITER //
CREATE PROCEDURE CreateSeat (
    IN in_SeatRow CHAR(1),
    IN in_Number TINYINT
)
BEGIN
    -- Validation
    IF in_SeatRow IS NULL OR CHAR_LENGTH(in_SeatRow) <> 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'SeatRow must be a single character';
    END IF;
    IF ASCII(in_SeatRow) < ASCII('A') OR ASCII(in_SeatRow) > ASCII('Z') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'SeatRow must be a capital letter between A and Z';
    END IF;
    IF in_Number IS NULL OR in_Number < 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Seat number must be a positive integer';
    END IF;
    IF in_Number > 50 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Seat number must not exceed 50';
    END IF;

    -- Duplicate check
    IF EXISTS (
        SELECT 1 FROM Seat WHERE SeatRow = in_SeatRow AND Number = in_Number
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Seat already exists';
    END IF;

    -- Main logic
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
    -- Validation
    IF in_SeatID IS NULL OR in_SeatID < 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Valid SeatID is required';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Seat WHERE SeatID = in_SeatID) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'SeatID does not exist';
    END IF;
    IF in_SeatRow IS NULL OR CHAR_LENGTH(in_SeatRow) <> 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'SeatRow must be a single character';
    END IF;
    IF in_Number IS NULL OR in_Number < 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Seat number must be a positive integer';
    END IF;
    IF in_Number > 50 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Seat number must not exceed 50';
    END IF;
    IF EXISTS (
        SELECT 1 FROM Seat
        WHERE SeatRow = in_SeatRow AND Number = in_Number AND SeatID <> in_SeatID
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Another seat with the same row and number already exists';
    END IF;

    -- Main logic
    UPDATE Seat
    SET SeatRow = in_SeatRow, Number = in_Number
    WHERE SeatID = in_SeatID;
END //
DELIMITER ;

-- DELETE SEAT
DELIMITER //
CREATE PROCEDURE DeleteSeat (
    IN in_SeatID INT
)
BEGIN
    -- Validation
    IF in_SeatID IS NULL OR in_SeatID < 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Valid SeatID is required';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Seat WHERE SeatID = in_SeatID) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'SeatID does not exist';
    END IF;

    -- Main logic
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
    -- Validation
    IF in_ProductionID IS NULL OR in_ProductionID < 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Valid ProductionID is required';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Production WHERE ProductionID = in_ProductionID) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ProductionID does not exist';
    END IF;
    IF in_PlayID IS NULL OR in_PlayID < 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Valid PlayID is required';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Play WHERE PlayID = in_PlayID) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'PlayID does not exist';
    END IF;
    IF EXISTS (
        SELECT 1 FROM Production_Play
        WHERE ProductionID = in_ProductionID AND PlayID = in_PlayID
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'This play is already linked to the production.';
    END IF;

    -- Main logic
    INSERT INTO Production_Play (ProductionID, PlayID)
    VALUES (in_ProductionID, in_PlayID);
END //
DELIMITER ;

-- REMOVE PLAY FROM PRODUCTION
DELIMITER //
CREATE PROCEDURE UndoPlayFromProduction (
    IN in_ProductionID INT,
    IN in_PlayID INT
)
BEGIN
    -- Validation
    IF in_ProductionID IS NULL OR in_ProductionID < 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Valid ProductionID is required';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Production WHERE ProductionID = in_ProductionID) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ProductionID does not exist';
    END IF;
    IF in_PlayID IS NULL OR in_PlayID < 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Valid PlayID is required';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Play WHERE PlayID = in_PlayID) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'PlayID does not exist';
    END IF;
    IF NOT EXISTS (
        SELECT 1 FROM Production_Play
        WHERE ProductionID = in_ProductionID AND PlayID = in_PlayID
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'This play is not linked to the specified production';
    END IF;

    -- Main logic
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
    -- Validation
    IF in_Amount IS NULL OR in_Amount < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Expense amount must be a non-negative value';
    END IF;
    IF in_ProductionID IS NULL OR in_ProductionID < 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Valid ProductionID is required';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Production WHERE ProductionID = in_ProductionID) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ProductionID does not exist';
    END IF;
    IF in_Description IS NULL OR CHAR_LENGTH(in_Description) < 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Description is required';
    END IF;
    IF CHAR_LENGTH(in_Description) > 255 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Description cannot exceed 255 characters';
    END IF;
    IF in_Date IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Valid Date is required';
    END IF;

    -- Main logic
    INSERT INTO Financial_Transaction (Type, Amount, Date, ProductionID, Description)
    VALUES ('E', in_Amount, IFNULL(in_Date, CURRENT_DATE), in_ProductionID, in_Description);
END //
DELIMITER ;

-- REMOVE EXPENSE FROM PRODUCTION
DELIMITER //
CREATE PROCEDURE UndoExpense (
    IN in_TransactionID INT
)
BEGIN
    -- Validation
    IF in_TransactionID IS NULL OR in_TransactionID < 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Valid TransactionID is required';
    END IF;
    IF NOT EXISTS (
        SELECT 1 FROM Financial_Transaction
        WHERE TransactionID = in_TransactionID AND Type = 'E'
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Expense transaction not found or not of type E';
    END IF;

    -- Main logic
    DELETE FROM Financial_Transaction
    WHERE TransactionID = in_TransactionID
    AND Type = 'E';
END //
DELIMITER ;

-- ADD DUES INSTALLMENT
DELIMITER //
CREATE PROCEDURE AddDuesInstallment (
    IN in_MemberID INT,
    IN in_Date DATE,
    IN in_Amount DECIMAL(6,2)
)
BEGIN
    DECLARE existingDuesID INT DEFAULT NULL;
    DECLARE totalDue DECIMAL(10,2);
    DECLARE targetYear YEAR;

    SET targetYear = YEAR(in_Date);

    -- Validation
    IF in_MemberID IS NULL OR in_MemberID < 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Valid MemberID is required';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Member WHERE MemberID = in_MemberID) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'MemberID does not exist';
    END IF;
    IF in_Date IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Valid date is required';
    END IF;
    IF targetYear < YEAR(CURDATE()) OR targetYear > YEAR(CURDATE()) + 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Year must be the current or next calendar year';
    END IF;
    IF in_Amount IS NULL OR in_Amount <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Installment amount must be greater than zero';
    END IF;

    -- Get DuesID and TotalDue
    SELECT DuesID INTO existingDuesID
    FROM DuesOwed
    WHERE MemberID = in_MemberID AND Year = targetYear;

    IF existingDuesID IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No dues record found for this member and year';
    END IF;

    SET totalDue = GetTotalDueForDues(existingDuesID);

    -- Check for overpayment
    IF in_Amount > totalDue THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Installment exceeds remaining dues for the year';
    END IF;

    -- Subtract from TotalDue (acts as running balance)
    UPDATE DuesOwed
    SET TotalDue = TotalDue - in_Amount
    WHERE DuesID = existingDuesID;

    -- Insert Dues Payment
    INSERT INTO DuesPayment (DuesID, AmountPaid, PaymentDate)
    VALUES (existingDuesID, in_Amount, in_Date);

    -- Insert Financial Transaction
    INSERT INTO Financial_Transaction (Type, Amount, Date, DuesPaymentID, Description)
    VALUES ('I', in_Amount, in_Date, LAST_INSERT_ID(), CONCAT('Dues installment for year ', targetYear));
END //
DELIMITER ;

-- REMOVE INSTALLMENT
DELIMITER //
CREATE PROCEDURE UndoDuesInstallment (
    IN in_PaymentID INT
)
BEGIN
    -- Validation
    IF in_PaymentID IS NULL OR in_PaymentID < 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Valid PaymentID is required';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM DuesPayment WHERE PaymentID = in_PaymentID) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Dues payment does not exist';
    END IF;

    -- Main logic
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
    DECLARE currentStatus CHAR(1);
    DECLARE currentPatronID INT;
    DECLARE reservationDeadline DATE;

    -- Validation
    IF in_ProductionID IS NULL OR in_ProductionID < 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Valid ProductionID is required';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Production WHERE ProductionID = in_ProductionID) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ProductionID does not exist';
    END IF;
    IF in_SeatID IS NULL OR in_SeatID < 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Valid SeatID is required';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Seat WHERE SeatID = in_SeatID) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'SeatID does not exist';
    END IF;
    IF in_BuyerPatronID IS NOT NULL AND NOT EXISTS (
        SELECT 1 FROM Patron WHERE PatronID = in_BuyerPatronID
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Buyer PatronID does not exist';
    END IF;
    IF in_Price IS NULL OR in_Price < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ticket price must be non-negative';
    END IF;

    -- Main logic
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
    -- Validation
    IF in_TicketID IS NULL OR in_TicketID < 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Valid TicketID is required';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Ticket WHERE TicketID = in_TicketID) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'TicketID does not exist';
    END IF;
    IF NOT EXISTS (
        SELECT 1 FROM Ticket WHERE TicketID = in_TicketID AND Status = 'S'
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ticket is not currently marked as sold';
    END IF;

    -- Main logic
    -- Mark the ticket as available again
    UPDATE Ticket
    SET Status = 'A', PatronID = NULL
    WHERE TicketID = in_TicketID;

    -- Remove the linked financial transaction
    DELETE FROM Financial_Transaction
    WHERE TicketID = in_TicketID;
END //
DELIMITER ;

-- =========================
-- REPORT PROCEDURES
-- =========================

-- LIST TICKETS FOR PRODUCTION
DELIMITER //
CREATE PROCEDURE ListTicketsForProduction (
    IN in_ProductionID INT
)
BEGIN
    -- Validation
    IF in_ProductionID IS NULL OR in_ProductionID < 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Valid ProductionID is required';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Production WHERE ProductionID = in_ProductionID) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ProductionID does not exist';
    END IF;

    -- Query
    SELECT 
        t.TicketID,
        s.SeatRow,
        s.Number AS SeatNumber,
        t.Price,
        t.Status,
        t.ReservationDeadline,
        p.Name AS PatronName,
        p.Email AS PatronEmail,
        pr.TimeOfProduction
    FROM Ticket t
    JOIN Seat s ON t.SeatID = s.SeatID
    LEFT JOIN Patron p ON t.PatronID = p.PatronID
    JOIN Production pr ON t.ProductionID = pr.ProductionID
    WHERE t.ProductionID = in_ProductionID;
END //
DELIMITER ;

-- GET MEMBER PARTICIPATION
DELIMITER //
CREATE PROCEDURE GetMemberParticipation (
    IN in_MemberID INT
)
BEGIN
    -- Validation
    IF in_MemberID IS NULL OR in_MemberID < 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Valid MemberID is required';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Member WHERE MemberID = in_MemberID) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'MemberID does not exist';
    END IF;

    -- Query
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
    -- Validate ProductionID if provided
    IF in_ProductionID IS NOT NULL THEN
        IF in_ProductionID < 1 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'ProductionID must be a positive integer';
        END IF;
        IF NOT EXISTS (
            SELECT 1 FROM Production WHERE ProductionID = in_ProductionID
        ) THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'ProductionID does not exist';
        END IF;
    END IF;

    -- Validate date range if both dates are provided
    IF in_StartDate IS NOT NULL AND in_EndDate IS NOT NULL THEN
        IF in_StartDate > in_EndDate THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Start date cannot be after end date';
        END IF;
    END IF;

    -- Query
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
    -- Validation
    IF in_ProductionID IS NULL OR in_ProductionID < 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Valid ProductionID is required';
    END IF;
    IF NOT EXISTS (
        SELECT 1 FROM Production WHERE ProductionID = in_ProductionID
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ProductionID does not exist';
    END IF;

    -- Query
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
CREATE PROCEDURE GetProductionSponsorTotal(IN in_ProductionID INT)
BEGIN
    -- Validation
    IF in_ProductionID IS NULL OR in_ProductionID < 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Valid ProductionID is required';
    END IF;
    IF NOT EXISTS (
        SELECT 1 FROM Production WHERE ProductionID = in_ProductionID
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ProductionID does not exist';
    END IF;

    -- Query
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
    -- Validation
    IF in_PatronID IS NULL OR in_PatronID < 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Valid PatronID is required';
    END IF;
    IF NOT EXISTS (
        SELECT 1 FROM Patron WHERE PatronID = in_PatronID
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'PatronID does not exist';
    END IF;

    -- Query
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
        t.ReservationDeadline,
        pr.TimeOfProduction
    FROM Ticket t
    JOIN Production pr ON t.ProductionID = pr.ProductionID
    WHERE t.PatronID = in_PatronID;
END //
DELIMITER ;

-- Ticket Sales Report
DELIMITER //
CREATE PROCEDURE GetTicketSalesReport(IN in_ProductionID INT)
BEGIN
    -- Validation
    IF in_ProductionID IS NULL OR in_ProductionID < 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Valid ProductionID is required';
    END IF;
    IF NOT EXISTS (
        SELECT 1 FROM Production WHERE ProductionID = in_ProductionID
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ProductionID does not exist';
    END IF;

    -- Query
    SELECT 
        t.TicketID,
        s.SeatRow,
        s.Number AS SeatNumber,
        t.Price,
        t.Status,
        p.Name AS Buyer,
        pr.TimeOfProduction
    FROM Ticket t
    JOIN Seat s ON t.SeatID = s.SeatID
    LEFT JOIN Patron p ON t.PatronID = p.PatronID
    JOIN Production pr ON t.ProductionID = pr.ProductionID
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

-- Suggest fallback seats based on row/number ordering
DELIMITER //
CREATE PROCEDURE SuggestAlternateSeats(
    IN in_ProductionID INT,
    IN in_SeatCount INT
)
BEGIN
    -- Validation
    IF in_ProductionID IS NULL OR in_ProductionID < 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Valid ProductionID is required';
    END IF;
    IF NOT EXISTS (
        SELECT 1 FROM Production WHERE ProductionID = in_ProductionID
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ProductionID does not exist';
    END IF;
    IF in_SeatCount IS NULL OR in_SeatCount < 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Seat count must be a positive integer';
    END IF;

    -- Check availability first
    IF (SELECT COUNT(*) 
        FROM Ticket t
        WHERE t.ProductionID = in_ProductionID AND t.Status = 'A') = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No alternate seats available for this production';
    END IF;

    -- Query
    SELECT 
        t.SeatID, 
        s.SeatRow, 
        s.Number, 
        t.Price,
        pr.TimeOfProduction
    FROM Ticket t
    JOIN Seat s ON t.SeatID = s.SeatID
    JOIN Production pr ON t.ProductionID = pr.ProductionID
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
    DECLARE descText VARCHAR(255);
    
    -- Only do the insert if the Play exists
    IF EXISTS (SELECT 1 FROM Play WHERE PlayID = NEW.PlayID) THEN
        SELECT Cost INTO playCost FROM Play WHERE PlayID = NEW.PlayID;
        
        -- Only insert if the cost isn't null (just in case)
        IF playCost IS NOT NULL THEN
            SET descText = CONCAT('Added PlayID ', NEW.PlayID, ' to ProductionID ', NEW.ProductionID);
            INSERT INTO Financial_Transaction (Type, Amount, Date, Description, ProductionID, PlayID)
            VALUES ('E', playCost, CURRENT_DATE, descText, NEW.ProductionID, NEW.PlayID);
        END IF;
    END IF;
END //
DELIMITER ;

-- Trigger: Automatically nullify PlayID and ProductionID if record was removed from Production_Play
DELIMITER //
CREATE TRIGGER trg_NullifyPlayCostTransaction
BEFORE DELETE ON Production_Play
FOR EACH ROW
BEGIN
    -- Update Financial_Transaction to nullify the links, preserving the record
    UPDATE Financial_Transaction
    SET 
        PlayID = NULL,
        ProductionID = NULL,
        Description = CONCAT('Unlinked: was PlayID ', OLD.PlayID, ', ProductionID ', OLD.ProductionID)
    WHERE 
        PlayID = OLD.PlayID AND
        ProductionID = OLD.ProductionID AND
        Type = 'E'; -- optional: only touch expense entries
END //
DELIMITER ;

-- This trigger automatically updates the total cost of a production when a play is added to it
DELIMITER //
CREATE TRIGGER trg_IncrementTotalCost 
AFTER INSERT ON Production_Play
FOR EACH ROW
BEGIN
    DECLARE playCost DECIMAL(12,2);
    SELECT Cost INTO playCost FROM Play WHERE PlayID = NEW.PlayID;

    IF playCost IS NOT NULL THEN
        UPDATE Production
        SET TotalCost = TotalCost + playCost
        WHERE ProductionID = NEW.ProductionID;
    END IF;
END //
DELIMITER ;

-- This trigger automatically updates the total cost of a production when a play relationship is removed
DELIMITER //
CREATE TRIGGER trg_DecrementTotalCost
AFTER DELETE ON Production_Play
FOR EACH ROW
BEGIN
    DECLARE playCost DECIMAL(12,2);
    SELECT Cost INTO playCost FROM Play WHERE PlayID = OLD.PlayID;

    IF playCost IS NOT NULL THEN
        UPDATE Production
        SET TotalCost = GREATEST(TotalCost - playCost, 0)
        WHERE ProductionID = OLD.ProductionID;
    END IF;
END //
DELIMITER ;

-- This trigger automatically updates the total cost of a production when a play is deleted
DELIMITER //
CREATE TRIGGER trg_DecrementTotalCostOnPlayDelete
BEFORE DELETE ON Play
FOR EACH ROW
BEGIN
    DECLARE prodID INT;
    DECLARE done INT DEFAULT FALSE;
    DECLARE cur CURSOR FOR 
        SELECT ProductionID FROM Production_Play WHERE PlayID = OLD.PlayID;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO prodID;
        IF done THEN 
            LEAVE read_loop;
        END IF;

        UPDATE Production
        SET TotalCost = GREATEST(TotalCost - OLD.Cost, 0)
        WHERE ProductionID = prodID;
    END LOOP;
    CLOSE cur;
END //
DELIMITER ;

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

-- Trigger: Automatically add paid amount to totalDue
DELIMITER //
CREATE TRIGGER trg_BeforeDelete_DuesPayment
BEFORE DELETE ON DuesPayment
FOR EACH ROW
BEGIN
    UPDATE DuesOwed
    SET TotalDue = TotalDue + OLD.AmountPaid
    WHERE DuesID = OLD.DuesID;
END;
//
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
    p.Email AS PatronEmail,
    pr.TimeOfProduction
FROM Ticket t
JOIN Seat s ON t.SeatID = s.SeatID
LEFT JOIN Patron p ON t.PatronID = p.PatronID
JOIN Production pr ON t.ProductionID = pr.ProductionID;

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

-- View ticket summary for any given ticket
CREATE VIEW vw_TicketSummary AS
SELECT 
    t.TicketID,
    t.Status,
    p.Name AS Patron,
    pr.TimeOfProduction
FROM Ticket t
LEFT JOIN Patron p ON t.PatronID = p.PatronID
JOIN Production pr ON t.ProductionID = pr.ProductionID;

-- ========================================================================================
-- Supporting Code
-- ========================================================================================

-- Create reusable function to calculate remaining dues
DELIMITER //
CREATE FUNCTION GetTotalDueForDues(in_DuesID INT) RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE due DECIMAL(10,2);
    SELECT TotalDue INTO due
    FROM DuesOwed
    WHERE DuesID = in_DuesID;
    RETURN due;
END //
DELIMITER ;

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