/*
Create a reservation on a specific flight
*/
DELIMITER //
DROP PROCEDURE IF EXISTS addReservation;

CREATE PROCEDURE addReservation(IN departure_airport_code VARCHAR(3), IN arrival_airport_code VARCHAR(3), IN year INTEGER, IN week INTEGER,  
IN day VARCHAR(10), IN time TIME, IN number_of_passengers INTEGER, OUT output_reservation_nr INTEGER) 
BEGIN 
    DECLARE flightNumber INTEGER; 
    
   
    SELECT f.Flight_Number INTO flightNumber
    FROM Flight AS f
    JOIN WeeklySchedule AS ws ON f.WS_Schedule_ID = ws.ScheduleID
    JOIN Rout ON ws.R_Rout_Number = Rout.Rout_Number
    JOIN Rout_Year_Dependency AS RY ON Rout.Rout_Number = RY.R_Rout_Number
    WHERE Rout.Arrival_Airport_Code = arrival_airport_code
      AND Rout.Dep_Airport_Code = departure_airport_code
      AND RY.Y_Year_Code = year
      AND ws.D_Week_Day = day
      AND ws.Departure_time = time
      AND f.week_Number = week;
     
    if (flightNumber is not null)
	THEN 
		if (calculateFreeSeats(flightNumber)>=number_of_passengers ) 

		then  

			insert into Reservation(F_Flight_Number) 

			values (flightNumber); 

			set output_reservation_nr=LAST_INSERT_ID() ; 

		else 

			select "There are not enough seats available on the chosen flight"; 

		end if; 

    else  

		select "There exist no flight for the given route, date and time"; 

    end if; 


END//

DELIMITER ;

/*
 Add a passenger to a reservation
*/

DROP PROCEDURE IF EXISTS addPassenger;
DELIMITER // 

CREATE  PROCEDURE addPassenger(IN reservation_nr INTEGER, IN passport_number INTEGER, IN name varchar(30)) 

BEGIN 

	DECLARE reservationNumber INT; 

	DECLARE PASSPORT INTEGER; 

    if ((select Booking.ReservationNumber from Booking where Booking.ReservationNumber=reservation_nr) IS NULL) 

	then 

        set reservationNumber = (select Reservation.ReservationNumber from Reservation where Reservation.ReservationNumber=reservation_nr); 

		if(reservationNumber is not null) 

		then 

			set PASSPORT = (Select Passenger.PassportNumber from Passenger where Passenger.PassportNumber=passport_number); 

			if (PASSPORT is null) 

			then 

				insert into Passenger(name,PassportNumber) 

				values (name,passport_number); 

				Insert into Contact(P_PassportNumber) 

				values (passport_number); 

			end if; 

			insert into Reserved_Passenger(R_ReservationtNumber,P_PassportNumber) 

			values (reservation_nr,passport_number); 

		end if; 

		if (reservationNumber is null) 

		then  

			select "The given reservation number does not exist"; 

		end if; 

	else  

		select "The booking has already been payed and no further passengers can be added"; 

	end if; 

END//
DELIMITER ;




/*
 Add a contact
*/

DROP PROCEDURE IF EXISTS `addContact`; 

DELIMITER //

CREATE PROCEDURE `addContact`(
    IN reservation_nr INTEGER, 
    IN passport_number INTEGER, 
    IN email VARCHAR(30), 
    IN phone BIGINT
) 
BEGIN 
    DECLARE passenger_added INT; 
    DECLARE contact_added INT; 
    DECLARE reserved INT; 

    SET reserved = (
        SELECT COUNT(*) 
        FROM Reservation 
        WHERE ReservationNumber = reservation_nr
    ); 

    IF (reserved > 0) THEN 
        
        SET passenger_added = (
            SELECT COUNT(*) 
            FROM Reserved_Passenger 
            WHERE P_PassportNumber = passport_number 
              AND R_ReservationtNumber = reservation_nr
        ); 

        IF (passenger_added > 0) THEN  
           
            SET contact_added  = (
                SELECT COUNT(*) 
                FROM Contact 
                WHERE P_PassportNumber = passport_number
            ); 

            IF (contact_added  = 0) THEN 
                INSERT INTO Contact (Email, Phone_Number, P_PassportNumber) 
                VALUES (email, phone, passport_number); 
            ELSE 
                
                UPDATE Contact 
                SET Email = email, Phone_Number = phone 
                WHERE P_PassportNumber = passport_number; 
            END IF; 

            
            UPDATE Reservation 
            SET Contact_Passport_Number = passport_number 
            WHERE ReservationNumber = reservation_nr;
            
        ELSE  
            SELECT "The person is not a passenger of the reservation"; 
        END IF; 
    ELSE 
        
        SELECT "The given reservation number does not exist"; 
    END IF; 
END//

DELIMITER ;


/*
 Add a payment
*/


DROP PROCEDURE IF EXISTS addPayment; 
DELIMITER //

CREATE PROCEDURE addPayment(
    IN reservation_nr INTEGER, 
    IN cardholder_name VARCHAR(30), 
    IN credit_card_number BIGINT
)
BEGIN
    DECLARE v_flightNumber INT;
    DECLARE v_price DOUBLE;
    DECLARE v_availableSeats INT;
    DECLARE v_contactExists INT DEFAULT 0;
    DECLARE v_contactEmail VARCHAR(30);
    DECLARE v_creditCardExists INT;


    SELECT F_Flight_Number INTO v_flightNumber
    FROM Reservation
    WHERE ReservationNumber = reservation_nr;
    
    IF v_flightNumber IS NOT NULL THEN

        SET v_availableSeats = calculateFreeSeats(v_flightNumber);
        
        SELECT COUNT(*), Email INTO v_contactExists, v_contactEmail
        FROM Contact
        WHERE P_PassportNumber = (SELECT Contact_Passport_Number FROM Reservation WHERE ReservationNumber = reservation_nr);
        
        IF v_contactExists > 0 THEN

            IF v_availableSeats > 0 THEN

                SET v_price = calculatePrice(v_flightNumber);
                
                SELECT COUNT(*) INTO v_creditCardExists FROM CreditCard WHERE Card_Num = credit_card_number;
                
                IF v_creditCardExists = 0 THEN

                    INSERT INTO CreditCard(Card_Num, Card_Holder) VALUES (credit_card_number, cardholder_name);
                END IF;
                
                INSERT INTO Booking(ReservationNumber, TotalPrice, CreditCard_Num) VALUES (reservation_nr, v_price, credit_card_number);
                
            ELSE
                SELECT "There are not enough seats available on the flight anymore" AS ErrorMessage;
            END IF;
        ELSE
            SELECT "The reservation has no contact yet" AS ErrorMessage;
        END IF;
    ELSE
        SELECT "The given reservation number does not exist" AS ErrorMessage;
    END IF;
END//

DELIMITER ;


