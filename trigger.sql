/*
 trigger that issues unique unguessable ticket-numbers for each passenger on a reservation once it is paid
*/

DELIMITER //

CREATE TRIGGER issue_ticket_number
AFTER INSERT ON Booking
FOR EACH ROW
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE passengerID INT;
    DECLARE cur CURSOR FOR SELECT P_PassportNumber FROM Purchase_For WHERE B_ReservationtNumber = NEW.ReservationNumber;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO passengerID;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        UPDATE Purchase_For
        SET Ticket_Num = FLOOR(10000000 + (RAND() * 89999999)) 
        WHERE P_PassportNumber = passengerID AND B_ReservationtNumber = NEW.ReservationNumber;
    END LOOP;

    CLOSE cur;
END//

DELIMITER ;
