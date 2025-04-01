-- ==================================================================
-- TEST SUITE FOR THEATRE DB
-- 
-- Note: Each call only has one instance of the call be sure to test
--       all possible invalid inputs along with the valid call. i.e.
--       chars when its expecting ints, nulls, improper lengths etc. 
-- ==================================================================

-- AddDuesInstallment
CALL AddDuesInstallment(1, '2025-10-01', 50.00);
-- Dues installment uses Year instead of date.
-- Member can overpay their dues.
-- Day has off by one error 10 shows up as 9

-- AddPlayToProduction
CALL AddPlayToProduction(1, 1);
-- Same error outlined in todo 

-- AddProductionExpense
CALL AddProductionExpense(200.00, '2025-10-01', 1, 'Description');
-- Can add expense of any date (propbaly should allow users to add expenses to past dates for record keeping)
-- Date can be null shouldnt be allowed
-- Day has off by one error 10 shows up as 9

-- (Working) AssignMemberToMeeting
CALL AssignMemberToMeeting(1, 1);

-- (Working) AssignMemberToProduction
CALL AssignMemberToProduction(1, 1, 'Director');

-- (Working) CancelReservation
CALL CancelReservation(1);

-- CheckSeatAvailability
CALL CheckSeatAvailability(1,10); -- Avalible
CALL CheckSeatAvailability(4, 3); -- Sold
-- should return the ticketID as well

-- CreateDuesRecord
CALL CreateDuesRecord(2, '2025', 75.00);
-- Error message says 'recorded' should say 'created'
-- Limited to creating dues for this year or next year, shouldnt be a limitation

-- CreateMeeting
CALL CreateMeeting('Cast Debrief', '2024-10-15');
-- Use CHAR(1) instead of enum for proper error message being passed.
-- Day has off by one error 10 shows up as 9

-- (Working) CreateMember
CALL CreateMember('Frank', 'frank@org.com', '999-999-9999', 'Address', 'Role');

-- (Working) CreatePatron
CALL CreatePatron('Daisy Viewer', 'daisy@view.org', 'Address');

-- (Working) CreatePlay
CALL CreatePlay('New Play Title', 'Auth', 'Spooky', 1, 120.00);

-- CreateProduction
CALL CreateProduction('2025-06-01');
-- Day has off by one error 10 shows up as 9

-- CreateSeat
CALL CreateSeat('C', 10);
-- Error Code: 1364. Field 'SeatID' doesn't have a default value
-- If a seat already exists then proper error message displayed

-- CreateSponsor
CALL CreateSponsor('DonorCorp', 'I');
-- Use in_type != C or in_type != I for proper error message
-- The enum provides a truncated error if in_type not in enum rather than proper error message

-- CreateTicket
CALL CreateTicket(1, 1, 30.00, '2025-06-01');
-- Day has off by one error 10 shows up as 9

-- DeleteDuesRecord
CALL DeleteDuesRecord(1);
-- double check that when a due is deleted the amount is added back to due owed

-- (Working) DeleteMeeting
CALL DeleteMeeting(1);

-- (Working) DeleteMember
CALL DeleteMember(1);

-- (Working) DeletePatron
CALL DeletePatron(1);

-- DeletePlay
CALL DeletePlay(1);
-- Once production_play table is fixed check that this deletion cascades.

-- (Working) DeleteProduction
CALL DeleteProduction(1);

-- (Working) DeleteSeat
CALL DeleteSeat(1);

-- (Working) DeleteSponsor
CALL DeleteSponsor(1);

-- (Working) LinkSponsorToProduction
CALL LinkSponsorToProduction(1, 1, 250.00);

-- (Working) ListTicketsForProduction
CALL ListTicketsForProduction(1);

-- PurchaseTicket
CALL PurchaseTicket(1, 1, NULL, 25.00);
-- Can purchase ticket multiple times

-- (Working) ReleaseTicket
CALL ReleaseTicket(1);

-- (Working) RemoveMemberFromMeeting
CALL RemoveMemberFromMeeting(1, 1);

-- (Working) RemoveMemberFromProduction
CALL RemoveMemberFromProduction(1, 1);

-- ReserveTicket
CALL ReserveTicket(2, 1, '2025-06-01');
-- Day has off by one error 10 shows up as 9

-- SmartTicketPurchase (gonna delete and integrate suggest alternate seat into purchase ticket)

-- SuggestAlternateSeats
CALL SuggestAlternateSeats(1,1);
-- returns an empty table 

-- (Working) UndoDuesInstallment
CALL UndoDuesInstallment(1);

-- UndoPlayFromProduction
CALL UndoPlayFromProduction(1, 1);
-- Once play_production table working test this

-- UndoProductionExpense
CALL UndoProductionExpense(1);
-- Change error message to not have 'or ...'
-- Also change function name in all three files to just UndoExpense (not production specific uses TransactionID)

-- (Working) UndoTicketPurchase
CALL UndoTicketPurchase(1);

-- (Working) UnlinkSponsorFromProduction
CALL UnlinkSponsorFromProduction(1, 1);

-- UpdateMeeting
CALL UpdateMeeting(1, 'F', '2025-10-20');
-- Day has off by one error 10 shows up as 9

-- (Working) UpdateMember
CALL UpdateMember(1, 'Alice Final', 'afinal@example.com', '888-888-8888', 'Address', 'Role');

-- (Working) UpdatePatron
CALL UpdatePatron(1, 'Charlie New', 'new@charlie.com', 'Address');

-- (Working) UpdatePlay
CALL UpdatePlay(1, 'Hamlet Final', 'Author', 'Genre', 1, 100);

-- UpdateProduction
CALL UpdateProduction(1, '2024-12-10');
-- Day has off by one error 10 shows up as 9

-- UpdateSeat
CALL UpdateSeat(2, 'C', 3);
-- Seat ID should be auto_increment

-- UpdateSponsor
CALL UpdateSponsor(1, 'Trust Updated', 'C');
-- change away from enum for proper error messaging

-- (Working) UpdateTicketPrice
CALL UpdateTicketPrice(1, 35.00);

-- UpdateTicketStatus
CALL UpdateTicketStatus(1, 'S');
-- change away from enum for proper error messaging

-- REPORT TESTS
-- (Working) GetPlayListingReport
CALL GetPlayListingReport();

-- (Working) GetMemberDuesReport
CALL GetMemberDuesReport();

-- (Working) GetPatronReport
CALL GetPatronReport(1);

-- (Working) GetTicketSalesReport
CALL GetTicketSalesReport(1);

-- (Working) GetMemberParticipation
CALL GetMemberParticipation(1);

-- (Working) GetProductionFinancialSummary (params are additional search features)
CALL GetProductionFinancialSummary(NULL, NULL, NULL);

-- (Working) GetProductionCastAndCrew
CALL GetProductionCastAndCrew(1);

-- (Working) GetProductionSponsors
CALL GetProductionSponsors(1);
-- maybe add a way to see what sponsors currently only $ amounts

-- TRIGGER TESTS (Working, but double check)
-- Trigger: trg_AddPlayCostTransaction
INSERT INTO Production_Play (Play_ID, Production_ID) VALUES (1, 1);
-- Trigger: trg_AutoTransactionOnDuesPayment
INSERT INTO Dues_Installment (Dues_ID, Amount, Payment_Date) VALUES (1, 50.00, NOW());
-- Trigger: trg_TicketPurchaseTransaction
INSERT INTO Ticket (Seat_ID, Patron_ID, Purchase_Date, Status) VALUES (1, 1, NOW(), 'Sold');
-- Trigger: trg_DeleteDuesPaymentTransaction
DELETE FROM Dues_Installment WHERE Dues_ID = 1 LIMIT 1;
-- Trigger: trg_DeleteTicketTransaction
DELETE FROM Ticket WHERE Patron_ID = 1 LIMIT 1;
-- Trigger: trg_ReleaseTicketTransaction
UPDATE Ticket SET Status = 'Released' WHERE Seat_ID = 1;
-- Trigger: trg_DeleteSponsorContributionTransaction
DELETE FROM Sponsor_Contribution WHERE Sponsor_ID = 1 LIMIT 1;
-- Trigger: trg_DeletePlayCostTransaction
DELETE FROM Production_Play WHERE Play_ID = 1 AND Production_ID = 1;
-- Trigger: trg_SponsorContributionIncomeOnInsert
INSERT INTO Sponsor_Contribution (Sponsor_ID, Production_ID, Amount) VALUES (1, 1, 300.00);

-- FUNCTION TEST (Cant call a function like this idk how to do it)
CALL GetTotalPaidForDues(1);
CALL GetTotalPaidForDues(NULL);
CALL GetTotalPaidForDues('A');
CALL GetTotalPaidForDues(9999);

-- Views (Working)
SELECT * FROM vw_PlayListing;
SELECT * FROM vw_CastCrewByProduction;
SELECT * FROM vw_SponsorContributions;
SELECT * FROM vw_PatronHistory;
SELECT * FROM vw_TicketSalesByProduction;
SELECT * FROM vw_MemberDuesStatus;
SELECT * FROM vw_ProductionBalanceSheet;
SELECT * FROM vw_TicketSummary