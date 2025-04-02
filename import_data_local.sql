-- =========================================================================================
--
--  Final Project
--
--  Advanced Databases: COMP 4225-001
--  Prof: Dr. Said Baadel
--
--  Students: 
--  Mohammed Arab - 201700065 - marab065@mtroyal.ca
--  Spencer Epp   - 201481162 - sepp162@mtroyal.ca
--  Henry Nguyen  - 201708407 - hnguy407@mtroyal.ca
--  Felix Yap     - 201719898 - fyap898@mtroyal.ca
--
--  Description:
--    This SQL script is used for local development and testing. It loads a sample dataset
--    into the Theatre Management System database by inserting predefined records into key 
--    tables. The script includes inserts for all of the tables in `theatre.sql`
--
--    This script does not include `DROP` or `CREATE` statements and assumes the schema has 
--    already been created using `theatre.sql`.
--
--  Usage:
--    Run this file in a local MySQL-compatible client after executing `theatre.sql`.
--    It is not intended for production use.
--
-- =========================================================================================

INSERT INTO `DuesOwed` (`MemberID`, `Year`, `TotalDue`) VALUES ('1.0', '2024.0', '100.0');
INSERT INTO `DuesOwed` (`MemberID`, `Year`, `TotalDue`) VALUES ('2.0', '2024.0', '100.0');
INSERT INTO `DuesOwed` (`MemberID`, `Year`, `TotalDue`) VALUES ('3.0', '2024.0', '100.0');
INSERT INTO `DuesOwed` (`MemberID`, `Year`, `TotalDue`) VALUES ('4.0', '2024.0', '100.0');
INSERT INTO `DuesOwed` (`MemberID`, `Year`, `TotalDue`) VALUES ('5.0', '2024.0', '100.0');
INSERT INTO `DuesOwed` (`MemberID`, `Year`, `TotalDue`) VALUES ('6.0', '2024.0', '100.0');
INSERT INTO `DuesOwed` (`MemberID`, `Year`, `TotalDue`) VALUES ('7.0', '2024.0', '100.0');
INSERT INTO `DuesOwed` (`MemberID`, `Year`, `TotalDue`) VALUES ('8.0', '2024.0', '100.0');
INSERT INTO `DuesOwed` (`MemberID`, `Year`, `TotalDue`) VALUES ('9.0', '2024.0', '100.0');
INSERT INTO `DuesOwed` (`MemberID`, `Year`, `TotalDue`) VALUES ('10.0', '2024.0', '100.0');
INSERT INTO `DuesPayment` (`DuesID`, `AmountPaid`, `PaymentDate`) VALUES ('1', '48.68', '2024-08-26');
INSERT INTO `DuesPayment` (`DuesID`, `AmountPaid`, `PaymentDate`) VALUES ('2', '33.78', '2025-03-01');
INSERT INTO `DuesPayment` (`DuesID`, `AmountPaid`, `PaymentDate`) VALUES ('3', '39.59', '2024-10-15');
INSERT INTO `DuesPayment` (`DuesID`, `AmountPaid`, `PaymentDate`) VALUES ('4', '65.36', '2024-04-14');
INSERT INTO `DuesPayment` (`DuesID`, `AmountPaid`, `PaymentDate`) VALUES ('5', '72.86', '2024-08-30');
INSERT INTO `DuesPayment` (`DuesID`, `AmountPaid`, `PaymentDate`) VALUES ('6', '42.85', '2025-03-16');
INSERT INTO `DuesPayment` (`DuesID`, `AmountPaid`, `PaymentDate`) VALUES ('7', '48.32', '2025-02-28');
INSERT INTO `DuesPayment` (`DuesID`, `AmountPaid`, `PaymentDate`) VALUES ('8', '31.86', '2024-07-15');
INSERT INTO `DuesPayment` (`DuesID`, `AmountPaid`, `PaymentDate`) VALUES ('9', '43.81', '2024-12-25');
INSERT INTO `DuesPayment` (`DuesID`, `AmountPaid`, `PaymentDate`) VALUES ('10', '99.63', '2024-05-27');
INSERT INTO `Financial_Transaction` (`Type`, `Amount`, `Date`, `Description`, `DuesPaymentID`, `TicketID`, `SponsorID`, `ProductionID`) VALUES ('E', '387.73', '2024-04-25', 'Transaction 1', '1', '1', '1', '1');
INSERT INTO `Financial_Transaction` (`Type`, `Amount`, `Date`, `Description`, `DuesPaymentID`, `TicketID`, `SponsorID`, `ProductionID`) VALUES ('E', '153.37', '2024-08-27', 'Transaction 2', '2', '2', '2', '2');
INSERT INTO `Financial_Transaction` (`Type`, `Amount`, `Date`, `Description`, `DuesPaymentID`, `TicketID`, `SponsorID`, `ProductionID`) VALUES ('I', '195.92', '2024-10-09', 'Transaction 3', '3', '3', '3', '3');
INSERT INTO `Financial_Transaction` (`Type`, `Amount`, `Date`, `Description`, `DuesPaymentID`, `TicketID`, `SponsorID`, `ProductionID`) VALUES ('E', '125.83', '2024-07-10', 'Transaction 4', '4', '4', '4', '4');
INSERT INTO `Financial_Transaction` (`Type`, `Amount`, `Date`, `Description`, `DuesPaymentID`, `TicketID`, `SponsorID`, `ProductionID`) VALUES ('E', '156.99', '2024-10-24', 'Transaction 5', '5', '5', '5', '5');
INSERT INTO `Financial_Transaction` (`Type`, `Amount`, `Date`, `Description`, `DuesPaymentID`, `TicketID`, `SponsorID`, `ProductionID`) VALUES ('I', '458.68', '2024-05-07', 'Transaction 6', '6', '6', '6', '6');
INSERT INTO `Financial_Transaction` (`Type`, `Amount`, `Date`, `Description`, `DuesPaymentID`, `TicketID`, `SponsorID`, `ProductionID`) VALUES ('E', '280.71', '2024-11-09', 'Transaction 7', '7', '7', '7', '7');
INSERT INTO `Financial_Transaction` (`Type`, `Amount`, `Date`, `Description`, `DuesPaymentID`, `TicketID`, `SponsorID`, `ProductionID`) VALUES ('I', '251.57', '2024-06-24', 'Transaction 8', '8', '8', '8', '8');
INSERT INTO `Financial_Transaction` (`Type`, `Amount`, `Date`, `Description`, `DuesPaymentID`, `TicketID`, `SponsorID`, `ProductionID`) VALUES ('E', '242.01', '2024-10-12', 'Transaction 9', '9', '9', '9', '9');
INSERT INTO `Financial_Transaction` (`Type`, `Amount`, `Date`, `Description`, `DuesPaymentID`, `TicketID`, `SponsorID`, `ProductionID`) VALUES ('E', '154.0', '2024-09-15', 'Transaction 10', '10', '10', '10', '10');
INSERT INTO `Meeting` (`Type`, `Date`) VALUES ('S', '2024-06-17');
INSERT INTO `Meeting` (`Type`, `Date`) VALUES ('F', '2024-10-29');
INSERT INTO `Meeting` (`Type`, `Date`) VALUES ('F', '2024-06-22');
INSERT INTO `Meeting` (`Type`, `Date`) VALUES ('S', '2024-10-18');
INSERT INTO `Meeting` (`Type`, `Date`) VALUES ('S', '2024-10-21');
INSERT INTO `Meeting` (`Type`, `Date`) VALUES ('S', '2024-09-30');
INSERT INTO `Meeting` (`Type`, `Date`) VALUES ('S', '2024-10-09');
INSERT INTO `Meeting` (`Type`, `Date`) VALUES ('F', '2024-05-27');
INSERT INTO `Meeting` (`Type`, `Date`) VALUES ('F', '2024-07-23');
INSERT INTO `Meeting` (`Type`, `Date`) VALUES ('F', '2025-02-26');
INSERT INTO `Member` (`Name`, `Email`, `Phone`, `Address`, `Role`) VALUES ('Adrian Deleon', 'deborahwoodward@gmail.com', '(909)750-1417', '7042 Martin Pine Suite 937 Bennettmouth, NC 09981', 'Director');
INSERT INTO `Member` (`Name`, `Email`, `Phone`, `Address`, `Role`) VALUES ('Kevin Woods', 'savagejennifer@johnson.com', '803.056.4600x370', '37908 Alexander Lodge Adamsside, WY 06450', 'Director');
INSERT INTO `Member` (`Name`, `Email`, `Phone`, `Address`, `Role`) VALUES ('Brian Leon', 'ywagner@hotmail.com', '064.132.9130', '6655 Vargas Lake Port Robert, MI 15199', 'Actor');
INSERT INTO `Member` (`Name`, `Email`, `Phone`, `Address`, `Role`) VALUES ('William Underwood', 'staceyfoley@gmail.com', '2801415674', '1725 Jeffery Fort Suite 161 Spencerfurt, KY 91964', 'Crew');
INSERT INTO `Member` (`Name`, `Email`, `Phone`, `Address`, `Role`) VALUES ('Jeffrey Keller', 'anthonyherrera@hotmail.com', '324-003-4532', '94729 Dakota Ways Apt. 127 Huffmanview, RI 38857', 'Crew');
INSERT INTO `Member` (`Name`, `Email`, `Phone`, `Address`, `Role`) VALUES ('Chad Green', 'james68@ballard.biz', '+1-354-543-9250x793', '74448 Phillip Brooks Apt. 610 Choichester, OK 10871', 'Director');
INSERT INTO `Member` (`Name`, `Email`, `Phone`, `Address`, `Role`) VALUES ('Barry Thompson', 'gibbskelly@sandoval.com', '+1-903-254-9367x671', '53910 Stafford Rue Suite 765 East Steven, IN 31201', 'Director');
INSERT INTO `Member` (`Name`, `Email`, `Phone`, `Address`, `Role`) VALUES ('Brian Phillips', 'williamsbradley@rogers-moore.com', '+1-363-679-6767', '7108 Kane Avenue South Bianca, OR 65799', 'Crew');
INSERT INTO `Member` (`Name`, `Email`, `Phone`, `Address`, `Role`) VALUES ('Lindsey Oneal', 'xharris@norris-ellison.biz', '2994601401', '249 Martinez Land Suite 049 North Caitlin, TX 70300', 'Crew');
INSERT INTO `Member` (`Name`, `Email`, `Phone`, `Address`, `Role`) VALUES ('Bruce Avila', 'melissamoreno@roth.com', '+1-810-004-7879', '41010 Grant Points North Adamhaven, NJ 18913', 'Actor');
INSERT INTO `Member_Meeting` (`MemberID`, `MeetingID`) VALUES ('1', '1');
INSERT INTO `Member_Meeting` (`MemberID`, `MeetingID`) VALUES ('2', '2');
INSERT INTO `Member_Meeting` (`MemberID`, `MeetingID`) VALUES ('3', '3');
INSERT INTO `Member_Meeting` (`MemberID`, `MeetingID`) VALUES ('4', '4');
INSERT INTO `Member_Meeting` (`MemberID`, `MeetingID`) VALUES ('5', '5');
INSERT INTO `Member_Meeting` (`MemberID`, `MeetingID`) VALUES ('6', '6');
INSERT INTO `Member_Meeting` (`MemberID`, `MeetingID`) VALUES ('7', '7');
INSERT INTO `Member_Meeting` (`MemberID`, `MeetingID`) VALUES ('8', '8');
INSERT INTO `Member_Meeting` (`MemberID`, `MeetingID`) VALUES ('9', '9');
INSERT INTO `Member_Meeting` (`MemberID`, `MeetingID`) VALUES ('10', '10');
INSERT INTO `Member_Production` (`MemberID`, `ProductionID`, `Role`) VALUES ('1', '1', 'Tech');
INSERT INTO `Member_Production` (`MemberID`, `ProductionID`, `Role`) VALUES ('2', '2', 'Support');
INSERT INTO `Member_Production` (`MemberID`, `ProductionID`, `Role`) VALUES ('3', '3', 'Lead');
INSERT INTO `Member_Production` (`MemberID`, `ProductionID`, `Role`) VALUES ('4', '4', 'Lead');
INSERT INTO `Member_Production` (`MemberID`, `ProductionID`, `Role`) VALUES ('5', '5', 'Support');
INSERT INTO `Member_Production` (`MemberID`, `ProductionID`, `Role`) VALUES ('6', '6', 'Lead');
INSERT INTO `Member_Production` (`MemberID`, `ProductionID`, `Role`) VALUES ('7', '7', 'Lead');
INSERT INTO `Member_Production` (`MemberID`, `ProductionID`, `Role`) VALUES ('8', '8', 'Lead');
INSERT INTO `Member_Production` (`MemberID`, `ProductionID`, `Role`) VALUES ('9', '9', 'Lead');
INSERT INTO `Member_Production` (`MemberID`, `ProductionID`, `Role`) VALUES ('10', '10', 'Tech');
INSERT INTO `Patron` (`Name`, `Email`, `Address`) VALUES ('Norma Freeman', 'barbarabaker@yahoo.com', '0418 Edward Valley Apt. 969 Davisland, VT 89737');
INSERT INTO `Patron` (`Name`, `Email`, `Address`) VALUES ('Susan Gates', 'rwallace@crane-williams.org', '438 Jones Freeway East Williamview, NC 81120');
INSERT INTO `Patron` (`Name`, `Email`, `Address`) VALUES ('Paul Smith', 'johnhowell@welch.com', 'PSC 8674, Box 3268 APO AP 88266');
INSERT INTO `Patron` (`Name`, `Email`, `Address`) VALUES ('Melissa Gonzales', 'amy42@choi-adkins.com', '262 Brown Village Apt. 663 Lake Dannyfort, NV 87232');
INSERT INTO `Patron` (`Name`, `Email`, `Address`) VALUES ('Eric Gibson', 'zsmith@hotmail.com', '549 Gina Locks Suite 666 Ashleyborough, LA 99934');
INSERT INTO `Patron` (`Name`, `Email`, `Address`) VALUES ('Jeffrey Jackson', 'sandra31@yahoo.com', '85189 John Square South Elizabethview, NE 13395');
INSERT INTO `Patron` (`Name`, `Email`, `Address`) VALUES ('Cynthia Melendez', 'angela78@diaz.com', '5950 Bond Island Apt. 712 East Heatherbury, ID 90351');
INSERT INTO `Patron` (`Name`, `Email`, `Address`) VALUES ('Francisco Thompson', 'suttonnina@gmail.com', '5438 Mary Springs Apt. 055 Mikaylashire, IN 95205');
INSERT INTO `Patron` (`Name`, `Email`, `Address`) VALUES ('Katie Crawford', 'josephvictoria@oliver.com', '160 Alicia Turnpike Suite 388 Perezborough, ND 12857');
INSERT INTO `Patron` (`Name`, `Email`, `Address`) VALUES ('Danielle Cox', 'hgarcia@roman.org', '61972 Clark Place Suite 388 Jenniferburgh, AK 74045');
INSERT INTO `Play` (`Title`, `Author`, `Genre`, `NumberOfActs`, `Cost`) VALUES ('Play 1', 'Cameron Cooper', 'Comedy', '1', '121.24');
INSERT INTO `Play` (`Title`, `Author`, `Genre`, `NumberOfActs`, `Cost`) VALUES ('Play 2', 'Elizabeth Lopez', 'Comedy', '2', '134.75');
INSERT INTO `Play` (`Title`, `Author`, `Genre`, `NumberOfActs`, `Cost`) VALUES ('Play 3', 'Valerie Haynes', 'Comedy', '2', '258.25');
INSERT INTO `Play` (`Title`, `Author`, `Genre`, `NumberOfActs`, `Cost`) VALUES ('Play 4', 'Brian Cole', 'Drama', '3', '140.53');
INSERT INTO `Play` (`Title`, `Author`, `Genre`, `NumberOfActs`, `Cost`) VALUES ('Play 5', 'Jacqueline Baxter', 'Drama', '3', '270.31');
INSERT INTO `Play` (`Title`, `Author`, `Genre`, `NumberOfActs`, `Cost`) VALUES ('Play 6', 'Jacqueline Warren', 'Drama', '3', '222.25');
INSERT INTO `Play` (`Title`, `Author`, `Genre`, `NumberOfActs`, `Cost`) VALUES ('Play 7', 'Kyle Benson', 'Tragedy', '3', '274.94');
INSERT INTO `Play` (`Title`, `Author`, `Genre`, `NumberOfActs`, `Cost`) VALUES ('Play 8', 'Matthew Moore', 'Tragedy', '2', '170.21');
INSERT INTO `Play` (`Title`, `Author`, `Genre`, `NumberOfActs`, `Cost`) VALUES ('Play 9', 'Natasha Garcia', 'Comedy', '2', '259.25');
INSERT INTO `Play` (`Title`, `Author`, `Genre`, `NumberOfActs`, `Cost`) VALUES ('Play 10', 'Sandra Walters', 'Tragedy', '1', '211.18');
INSERT INTO `Production` (`ProductionDate`) VALUES ('2023-12-12');
INSERT INTO `Production` (`ProductionDate`) VALUES ('2024-10-12');
INSERT INTO `Production` (`ProductionDate`) VALUES ('2023-11-03');
INSERT INTO `Production` (`ProductionDate`) VALUES ('2024-11-06');
INSERT INTO `Production` (`ProductionDate`) VALUES ('2023-12-09');
INSERT INTO `Production` (`ProductionDate`) VALUES ('2024-09-18');
INSERT INTO `Production` (`ProductionDate`) VALUES ('2024-07-27');
INSERT INTO `Production` (`ProductionDate`) VALUES ('2023-06-27');
INSERT INTO `Production` (`ProductionDate`) VALUES ('2023-12-16');
INSERT INTO `Production` (`ProductionDate`) VALUES ('2024-07-02');
INSERT INTO `Production_Play` (`ProductionID`, `PlayID`) VALUES ('1', '1');
INSERT INTO `Production_Play` (`ProductionID`, `PlayID`) VALUES ('2', '2');
INSERT INTO `Production_Play` (`ProductionID`, `PlayID`) VALUES ('3', '3');
INSERT INTO `Production_Play` (`ProductionID`, `PlayID`) VALUES ('4', '4');
INSERT INTO `Production_Play` (`ProductionID`, `PlayID`) VALUES ('5', '5');
INSERT INTO `Production_Play` (`ProductionID`, `PlayID`) VALUES ('6', '6');
INSERT INTO `Production_Play` (`ProductionID`, `PlayID`) VALUES ('7', '7');
INSERT INTO `Production_Play` (`ProductionID`, `PlayID`) VALUES ('8', '8');
INSERT INTO `Production_Play` (`ProductionID`, `PlayID`) VALUES ('9', '9');
INSERT INTO `Production_Play` (`ProductionID`, `PlayID`) VALUES ('10', '10');
INSERT INTO `Production_Sponsor` (`ProductionID`, `SponsorID`, `ContributionAmount`) VALUES ('1.0', '1.0', '286.44');
INSERT INTO `Production_Sponsor` (`ProductionID`, `SponsorID`, `ContributionAmount`) VALUES ('2.0', '2.0', '237.43');
INSERT INTO `Production_Sponsor` (`ProductionID`, `SponsorID`, `ContributionAmount`) VALUES ('3.0', '3.0', '281.47');
INSERT INTO `Production_Sponsor` (`ProductionID`, `SponsorID`, `ContributionAmount`) VALUES ('4.0', '4.0', '428.07');
INSERT INTO `Production_Sponsor` (`ProductionID`, `SponsorID`, `ContributionAmount`) VALUES ('5.0', '5.0', '344.01');
INSERT INTO `Production_Sponsor` (`ProductionID`, `SponsorID`, `ContributionAmount`) VALUES ('6.0', '6.0', '499.52');
INSERT INTO `Production_Sponsor` (`ProductionID`, `SponsorID`, `ContributionAmount`) VALUES ('7.0', '7.0', '236.82');
INSERT INTO `Production_Sponsor` (`ProductionID`, `SponsorID`, `ContributionAmount`) VALUES ('8.0', '8.0', '404.61');
INSERT INTO `Production_Sponsor` (`ProductionID`, `SponsorID`, `ContributionAmount`) VALUES ('9.0', '9.0', '343.96');
INSERT INTO `Production_Sponsor` (`ProductionID`, `SponsorID`, `ContributionAmount`) VALUES ('10.0', '10.0', '452.99');
INSERT INTO `Seat` (`SeatID`, `SeatRow`, `Number`) VALUES ('1', 'A', '1');
INSERT INTO `Seat` (`SeatID`, `SeatRow`, `Number`) VALUES ('2', 'A', '2');
INSERT INTO `Seat` (`SeatID`, `SeatRow`, `Number`) VALUES ('3', 'A', '3');
INSERT INTO `Seat` (`SeatID`, `SeatRow`, `Number`) VALUES ('4', 'A', '4');
INSERT INTO `Seat` (`SeatID`, `SeatRow`, `Number`) VALUES ('5', 'A', '5');
INSERT INTO `Seat` (`SeatID`, `SeatRow`, `Number`) VALUES ('6', 'B', '1');
INSERT INTO `Seat` (`SeatID`, `SeatRow`, `Number`) VALUES ('7', 'B', '2');
INSERT INTO `Seat` (`SeatID`, `SeatRow`, `Number`) VALUES ('8', 'B', '3');
INSERT INTO `Seat` (`SeatID`, `SeatRow`, `Number`) VALUES ('9', 'B', '4');
INSERT INTO `Seat` (`SeatID`, `SeatRow`, `Number`) VALUES ('10', 'B', '5');
INSERT INTO `Seat` (`SeatID`, `SeatRow`, `Number`) VALUES ('11', 'C', '1');
INSERT INTO `Seat` (`SeatID`, `SeatRow`, `Number`) VALUES ('12', 'C', '2');
INSERT INTO `Seat` (`SeatID`, `SeatRow`, `Number`) VALUES ('13', 'C', '3');
INSERT INTO `Seat` (`SeatID`, `SeatRow`, `Number`) VALUES ('14', 'C', '4');
INSERT INTO `Seat` (`SeatID`, `SeatRow`, `Number`) VALUES ('15', 'C', '5');
INSERT INTO `Sponsor` (`Name`, `Type`) VALUES ('Sponsor 1', 'I');
INSERT INTO `Sponsor` (`Name`, `Type`) VALUES ('Sponsor 2', 'I');
INSERT INTO `Sponsor` (`Name`, `Type`) VALUES ('Sponsor 3', 'C');
INSERT INTO `Sponsor` (`Name`, `Type`) VALUES ('Sponsor 4', 'C');
INSERT INTO `Sponsor` (`Name`, `Type`) VALUES ('Sponsor 5', 'I');
INSERT INTO `Sponsor` (`Name`, `Type`) VALUES ('Sponsor 6', 'C');
INSERT INTO `Sponsor` (`Name`, `Type`) VALUES ('Sponsor 7', 'I');
INSERT INTO `Sponsor` (`Name`, `Type`) VALUES ('Sponsor 8', 'I');
INSERT INTO `Sponsor` (`Name`, `Type`) VALUES ('Sponsor 9', 'C');
INSERT INTO `Sponsor` (`Name`, `Type`) VALUES ('Sponsor 10', 'C');
INSERT INTO `Ticket` (`ProductionID`, `PatronID`, `SeatID`, `Price`, `Status`, `ReservationDeadline`) VALUES ('1', '1', '10', '26.64', 'A', '2025-04-12');
INSERT INTO `Ticket` (`ProductionID`, `PatronID`, `SeatID`, `Price`, `Status`, `ReservationDeadline`) VALUES ('2', '2', '1', '30.51', 'A', '2025-04-09');
INSERT INTO `Ticket` (`ProductionID`, `PatronID`, `SeatID`, `Price`, `Status`, `ReservationDeadline`) VALUES ('3', '3', '2', '27.59', 'A', '2025-04-03');
INSERT INTO `Ticket` (`ProductionID`, `PatronID`, `SeatID`, `Price`, `Status`, `ReservationDeadline`) VALUES ('4', '4', '3', '17.72', 'S', '2025-04-26');
INSERT INTO `Ticket` (`ProductionID`, `PatronID`, `SeatID`, `Price`, `Status`, `ReservationDeadline`) VALUES ('5', '5', '4', '33.61', 'A', '2025-04-28');
INSERT INTO `Ticket` (`ProductionID`, `PatronID`, `SeatID`, `Price`, `Status`, `ReservationDeadline`) VALUES ('6', '6', '5', '35.27', 'S', '2025-04-23');
INSERT INTO `Ticket` (`ProductionID`, `PatronID`, `SeatID`, `Price`, `Status`, `ReservationDeadline`) VALUES ('7', '7', '6', '25.04', 'A', '2025-04-18');
INSERT INTO `Ticket` (`ProductionID`, `PatronID`, `SeatID`, `Price`, `Status`, `ReservationDeadline`) VALUES ('8', '8', '7', '21.73', 'A', '2025-04-14');
INSERT INTO `Ticket` (`ProductionID`, `PatronID`, `SeatID`, `Price`, `Status`, `ReservationDeadline`) VALUES ('9', '9', '8', '35.23', 'S', '2025-04-11');
INSERT INTO `Ticket` (`ProductionID`, `PatronID`, `SeatID`, `Price`, `Status`, `ReservationDeadline`) VALUES ('10', '10', '9', '34.65', 'A', '2025-03-31');