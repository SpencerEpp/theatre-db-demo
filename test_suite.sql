-- =====================================
-- TEST SUITE FOR THEATRE DB
-- =====================================
-- AddDuesInstallment
CALL AddDuesInstallment(1, 50.00, '2024-10-01');
CALL AddDuesInstallment(9999, 'abc', '2024-10-01'); -- invalid amount
CALL AddDuesInstallment(1, 0.01, '2024-01-01'); -- min amount
CALL AddDuesInstallment(1, 999999.99, '2025-12-31'); -- high amount
CALL AddDuesInstallment(1, -10.00, '2024-01-01'); -- negative amount
CALL AddDuesInstallment('abc', 25.00, '2024-01-01'); -- invalid dues ID
CALL AddDuesInstallment(1, 25.00, 'invalid-date'); -- bad date
-- AddPlayToProduction
CALL AddPlayToProduction(1, 1);
CALL AddPlayToProduction(9999, 1); -- bad play
CALL AddPlayToProduction(2, 1); -- different valid play
CALL AddPlayToProduction(1, 9999); -- bad production
CALL AddPlayToProduction(NULL, 1); -- null play ID
CALL AddPlayToProduction(1, NULL); -- null production ID
-- AddProductionExpense
CALL AddProductionExpense(1, 'Props', 200.00);
CALL AddProductionExpense(NULL, '', -100);
CALL AddProductionExpense(1, 'Costume', 0);
CALL AddProductionExpense(1, 'Set', 99999.99);
CALL AddProductionExpense(1, 'Overbudget', -500);
CALL AddProductionExpense('x', 'Invalid', 100);
-- AssignMemberToMeeting
CALL AssignMemberToMeeting(1, 1);
CALL AssignMemberToMeeting(9999, 1);
CALL AssignMemberToMeeting(1, 9999);
CALL AssignMemberToMeeting(NULL, 1);
CALL AssignMemberToMeeting(1, NULL);
-- AssignMemberToProduction
CALL AssignMemberToProduction(1, 1, 'Director');
CALL AssignMemberToProduction(2, 9999, 'Stage Crew');
CALL AssignMemberToProduction(9999, 1, 'Ghost Role');
CALL AssignMemberToProduction(2, 2, 'Actor'); -- new combo
CALL AssignMemberToProduction(1, 1, NULL);
CALL AssignMemberToProduction(1, NULL, 'Actor');
-- CancelReservation
CALL CancelReservation(1, 1, 'Conflict');
CALL CancelReservation(NULL, NULL, 'No data');
CALL CancelReservation(1, 1, ''); -- empty reason
CALL CancelReservation(1, 1, REPEAT('A', 1000)); -- long reason
-- CheckSeatAvailability
CALL CheckSeatAvailability(1);
CALL CheckSeatAvailability(9999);
CALL CheckSeatAvailability(NULL);
CALL CheckSeatAvailability('invalid');
-- CreateDuesRecord
CALL CreateDuesRecord(2, 75.00);
CALL CreateDuesRecord(2, -75.00);
CALL CreateDuesRecord(NULL, NULL);
CALL CreateDuesRecord(1, 0);
CALL CreateDuesRecord(NULL, 50);
CALL CreateDuesRecord(1, NULL);
CALL CreateDuesRecord(9999, 50);
-- CreateMeeting
CALL CreateMeeting('Cast Debrief', '2024-10-15');
CALL CreateMeeting('', NULL);
CALL CreateMeeting('', '2024-12-01');
CALL CreateMeeting('Planning', NULL);
CALL CreateMeeting(NULL, '2024-12-01');
CALL CreateMeeting(REPEAT('A', 1000), 'invalid-date');
-- CreateMember
CALL CreateMember('Frank', 'frank@org.com', '999-999-9999');
CALL CreateMember('Valid User', 'valid@example.com', '123-456-7890');
CALL CreateMember('', 'no_name@example.com', '123-456-7890');
CALL CreateMember('No Email', '', '123-456-7890');
CALL CreateMember(NULL, 'null_name@example.com', '123-456-7890');
CALL CreateMember('Name', 'invalid_email', 'no-phone');
-- CreatePatron
CALL CreatePatron('Daisy Viewer', 'daisy@view.org');
CALL CreatePatron(NULL, NULL);
CALL CreatePatron('Test', '');
CALL CreatePatron('', 'test@email.com');
CALL CreatePatron(REPEAT('A', 1000), 'x@x.com');
-- CreatePlay
CALL CreatePlay('New Play Title', 'Short description', 120.00);
CALL CreatePlay('', 'Empty title', 100.00);
CALL CreatePlay('Valid', '', 100);
CALL CreatePlay('Valid', 'Valid', -10);
CALL CreatePlay('A'*256, 'Overflow title', 100);
-- CreateProduction
CALL CreateProduction('Spring Show', '2025-04-01', '2025-06-01');
CALL CreateProduction('New Show', '2025-01-01', '2025-02-01');
CALL CreateProduction('', '2025-01-01', '2025-02-01');
CALL CreateProduction('No Start', NULL, '2025-02-01');
CALL CreateProduction('No End', '2025-01-01', NULL);
CALL CreateProduction('Backwards', '2025-02-01', '2025-01-01');
-- CreateSeat
CALL CreateSeat('C1', 'Upper', 3);
CALL CreateSeat('', '', NULL);
CALL CreateSeat('', 'Main', 1);
CALL CreateSeat('A1', '', 1);
CALL CreateSeat('A1', 'Main', NULL);
CALL CreateSeat('A1', 'Main', 'Row');
-- CreateSponsor
CALL CreateSponsor('DonorCorp', 'donate@corp.com');
CALL CreateSponsor(NULL, NULL);
CALL CreateSponsor('', 'email@domain.com');
CALL CreateSponsor('Valid Sponsor', NULL);
CALL CreateSponsor(NULL, 'contact@site.com');
-- CreateTicket
CALL CreateTicket(2, 1, 30.00);
CALL CreateTicket(NULL, NULL, NULL);
CALL CreateTicket(NULL, 1, 20.00);
CALL CreateTicket(1, NULL, 20.00);
CALL CreateTicket(1, 1, -5.00);
CALL CreateTicket(1, 1, 'price');
-- DeleteDuesRecord
CALL DeleteDuesRecord(1);
CALL DeleteDuesRecord(NULL);
CALL DeleteDuesRecord('A');
CALL DeleteDuesRecord(9999);
-- DeleteMeeting
CALL DeleteMeeting(1);
CALL DeleteMeeting(NULL);
CALL DeleteMeeting('A');
CALL DeleteMeeting(9999);
-- DeleteMember
CALL DeleteMember(2);
CALL DeleteMember(NULL);
CALL DeleteMember('A');
CALL DeleteMember(9999);
-- DeletePatron
CALL DeletePatron(1);
CALL DeletePatron(NULL);
CALL DeletePatron('A');
CALL DeletePatron(9999);
-- DeletePlay
CALL DeletePlay(1);
CALL DeletePlay(NULL);
CALL DeletePlay('A');
CALL DeletePlay(9999);
-- DeleteProduction
CALL DeleteProduction(1);
CALL DeleteProduction(NULL);
CALL DeleteProduction('A');
CALL DeleteProduction(9999);
-- DeleteSeat
CALL DeleteSeat(1);
CALL DeleteSeat(NULL);
CALL DeleteSeat('A');
CALL DeleteSeat(9999);
-- DeleteSponsor
CALL DeleteSponsor(1);
CALL DeleteSponsor(NULL);
CALL DeleteSponsor('A');
CALL DeleteSponsor(9999);
-- LinkSponsorToProduction
CALL LinkSponsorToProduction(1, 1, 250.00);
CALL LinkSponsorToProduction(1, 1, -100.00);
CALL LinkSponsorToProduction(1, 1, 0);
CALL LinkSponsorToProduction(NULL, 1, 250);
CALL LinkSponsorToProduction(1, NULL, 250);
-- ListTicketsForProduction
CALL ListTicketsForProduction(1);
CALL ListTicketsForProduction(NULL);
CALL ListTicketsForProduction('A');
CALL ListTicketsForProduction(9999);
-- PurchaseTicket
CALL PurchaseTicket(1, 1, 25.00);
CALL PurchaseTicket(2, 1, 99999.99);
CALL PurchaseTicket(2, 1, 0);
CALL PurchaseTicket(2, 1, -10);
CALL PurchaseTicket(2, 9999, 25.00);
CALL PurchaseTicket(9999, 1, 25.00);
-- ReleaseTicket
CALL ReleaseTicket(1);
CALL ReleaseTicket(NULL);
CALL ReleaseTicket('A');
CALL ReleaseTicket(9999);
-- RemoveMemberFromMeeting
CALL RemoveMemberFromMeeting(1, 1);
CALL RemoveMemberFromMeeting(1, NULL);
CALL RemoveMemberFromMeeting(NULL, 1);
CALL RemoveMemberFromMeeting(9999, 9999);
-- RemoveMemberFromProduction
CALL RemoveMemberFromProduction(2, 1, 'Stage Crew');
CALL RemoveMemberFromProduction(1, 1, 'Actor');
CALL RemoveMemberFromProduction(1, 1, NULL);
CALL RemoveMemberFromProduction(NULL, 1, 'Crew');
CALL RemoveMemberFromProduction(9999, 1, 'Crew');
-- ReserveTicket
CALL ReserveTicket(2, 1);
CALL ReserveTicket(1, 1);
CALL ReserveTicket(NULL, 1);
CALL ReserveTicket(1, NULL);
CALL ReserveTicket(9999, 9999);
-- SmartTicketPurchase
CALL SmartTicketPurchase(1, 1);
CALL SmartTicketPurchase(NULL, 1);
CALL SmartTicketPurchase(1, NULL);
CALL SmartTicketPurchase(9999, 9999);
-- SuggestAlternateSeats
CALL SuggestAlternateSeats(1);
CALL SuggestAlternateSeats(NULL);
CALL SuggestAlternateSeats('A');
CALL SuggestAlternateSeats(9999);
-- UndoDuesInstallment
CALL UndoDuesInstallment(1);
CALL UndoDuesInstallment(NULL);
CALL UndoDuesInstallment('A');
CALL UndoDuesInstallment(9999);
-- UndoPlayFromProduction
CALL UndoPlayFromProduction(1, 1);
CALL UndoPlayFromProduction(NULL, 1);
CALL UndoPlayFromProduction(1, NULL);
CALL UndoPlayFromProduction(9999, 9999);
-- UndoProductionExpense
CALL UndoProductionExpense(1);
CALL UndoProductionExpense(NULL);
CALL UndoProductionExpense('A');
CALL UndoProductionExpense(9999);
-- UndoTicketPurchase
CALL UndoTicketPurchase(1);
CALL UndoTicketPurchase(NULL);
CALL UndoTicketPurchase('A');
CALL UndoTicketPurchase(9999);
-- UnlinkSponsorFromProduction
CALL UnlinkSponsorFromProduction(1, 1);
CALL UnlinkSponsorFromProduction(NULL, 1);
CALL UnlinkSponsorFromProduction(1, NULL);
CALL UnlinkSponsorFromProduction(9999, 9999);
-- UpdateMeeting
CALL UpdateMeeting(1, 'Final Prep', '2024-10-20');
CALL UpdateMeeting(NULL, 'Updated', '2024-12-15');
CALL UpdateMeeting(1, '', '2024-12-15');
CALL UpdateMeeting(1, 'Meeting', NULL);
CALL UpdateMeeting(9999, 'Ghost', '2024-12-15');
-- UpdateMember
CALL UpdateMember(1, 'Alice Final', 'afinal@example.com', '888-888-8888');
CALL UpdateMember(NULL, 'Name', 'email', 'phone');
CALL UpdateMember(1, '', 'email', 'phone');
CALL UpdateMember(1, 'Name', '', 'phone');
CALL UpdateMember(1, 'Name', 'email', '');
CALL UpdateMember(9999, 'Ghost', 'email', 'phone');
-- UpdatePatron
CALL UpdatePatron(1, 'Charlie New', 'new@charlie.com');
CALL UpdatePatron(NULL, 'Name', 'email');
CALL UpdatePatron(1, '', 'email');
CALL UpdatePatron(1, 'Name', '');
CALL UpdatePatron(9999, 'Ghost', 'email');
-- UpdatePlay
CALL UpdatePlay(1, 'Hamlet Final', 'Final version');
CALL UpdatePlay(1, REPEAT('A', 1000), REPEAT('A', 1000));
CALL UpdatePlay(1, '', '');
CALL UpdatePlay(9999, '', '');
CALL UpdatePlay(1, NULL, NULL);
-- UpdateProduction
CALL UpdateProduction(1, 'Fall Updated', '2024-10-05', '2024-12-10');
CALL UpdateProduction(NULL, 'Title', '2024-01-01', '2024-02-01');
CALL UpdateProduction(1, '', '2024-01-01', '2024-02-01');
CALL UpdateProduction(1, 'Title', NULL, '2024-02-01');
CALL UpdateProduction(1, 'Title', '2024-02-01', NULL);
CALL UpdateProduction(9999, 'Ghost', '2024-01-01', '2024-02-01');
-- UpdateSeat
CALL UpdateSeat(2, 'C1-updated', 'Upper', 3);
CALL UpdateSeat(NULL, 'A1', 'Main', 1);
CALL UpdateSeat(1, '', 'Main', 1);
CALL UpdateSeat(1, 'A1', '', 1);
CALL UpdateSeat(1, 'A1', 'Main', NULL);
CALL UpdateSeat(9999, 'Ghost', 'Zone', 1);
-- UpdateSponsor
CALL UpdateSponsor(1, 'Trust Updated', 'new@trust.org');
CALL UpdateSponsor(NULL, 'Name', 'email');
CALL UpdateSponsor(1, '', 'email');
CALL UpdateSponsor(1, 'Name', '');
CALL UpdateSponsor(9999, 'Ghost', 'email');
-- UpdateTicketPrice
CALL UpdateTicketPrice(1, 35.00);
CALL UpdateTicketPrice(NULL, 25.00);
CALL UpdateTicketPrice(1, -5.00);
CALL UpdateTicketPrice(9999, 25.00);
-- UpdateTicketStatus
CALL UpdateTicketStatus(1, 'Sold');
CALL UpdateTicketStatus(NULL, 'Reserved');
CALL UpdateTicketStatus(1, '');
CALL UpdateTicketStatus(9999, 'Reserved');

-- REPORT TESTS
-- GetPlayListingReport
CALL GetPlayListingReport();
-- GetMemberDuesReport
CALL GetMemberDuesReport();
-- GetPatronReport
CALL GetPatronReport(1);
CALL GetPatronReport(NULL);
CALL GetPatronReport('A');
CALL GetPatronReport(9999);
-- GetTicketSalesReport
CALL GetTicketSalesReport(1);
CALL GetTicketSalesReport(NULL);
CALL GetTicketSalesReport('A');
CALL GetTicketSalesReport(9999);
-- GetMemberParticipation
CALL GetMemberParticipation(1);
CALL GetMemberParticipation(NULL);
CALL GetMemberParticipation('A');
CALL GetMemberParticipation(9999);
-- GetProductionFinancialSummary
CALL GetProductionFinancialSummary(1);
CALL GetProductionFinancialSummary(NULL);
CALL GetProductionFinancialSummary('A');
CALL GetProductionFinancialSummary(9999);
-- GetProductionCastAndCrew
CALL GetProductionCastAndCrew(1);
CALL GetProductionCastAndCrew(NULL);
CALL GetProductionCastAndCrew('A');
CALL GetProductionCastAndCrew(9999);
-- GetProductionSponsors
CALL GetProductionSponsors(1);
CALL GetProductionSponsors(NULL);
CALL GetProductionSponsors('A');
CALL GetProductionSponsors(9999);

-- TRIGGER TESTS
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

-- FUNCTION TEST
CALL GetTotalPaidForDues(1);
CALL GetTotalPaidForDues(NULL);
CALL GetTotalPaidForDues('A');
CALL GetTotalPaidForDues(9999);