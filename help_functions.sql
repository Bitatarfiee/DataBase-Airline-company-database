/*
Q4a: Help-function: Calculate the number of available seats for a certain flight
*/

DROP function IF EXISTS `calculateFreeSeats`; 
DELIMITER // 

CREATE  FUNCTION `calculateFreeSeats`(flightnumber INTEGER) RETURNS int 

BEGIN 

	declare calculateFreeSeats INTEGER; 

    SET calculateFreeSeats = (SELECT 40-count(Reserved_Passenger.R_ReservationtNumber) from Reserved_Passenger where Reserved_Passenger.R_ReservationtNumber in (select Booking.ReservationNumber from Booking where Booking.ReservationNumber IN (SELECT Reservation.ReservationNumber FROM Reservation WHERE Reservation.F_Flight_Number = flightnumber))); 

RETURN (calculateFreeSeats ); 

END//


DELIMITER ; 


DROP FUNCTION IF EXISTS calculatePrice;
DELIMITER //

CREATE FUNCTION calculatePrice(flightNumber INT) RETURNS DOUBLE
BEGIN
    DECLARE basePrice DOUBLE;
    DECLARE weekdayFactor DOUBLE ; 
    DECLARE numberOfBookedPassengers INT;
    DECLARE profitFactor DOUBLE; 
    DECLARE totalPrice double;
    DECLARE routNumber BIGINT;
    DECLARE routPrice DOUBLE;
    DECLARE scheduleID INT;
    DECLARE yearCode INT;
    DECLARE weekDay VARCHAR(30);


    -- Step 1: Get the rout number associated with the flight
    SELECT WS.R_Rout_Number INTO routNumber
    FROM Flight F
    JOIN WeeklySchedule WS ON F.WS_Schedule_ID = WS.ScheduleID
    WHERE F.Flight_Number = flightNumber;
    
    -- Step 2: Get the root price using the rout number
    SELECT RYD.Rout_Price INTO routPrice
    FROM Rout_Year_Dependency RYD
    WHERE RYD.R_Rout_Number = routNumber;
    
    
      -- Step 1: Get the weekday associated with the flight
    SELECT WS.D_Week_Day INTO weekDay
    FROM Flight F
    JOIN WeeklySchedule WS ON F.WS_Schedule_ID = WS.ScheduleID
    WHERE F.Flight_Number = flightNumber;
    
    -- Step 2: Get the weekday factor using the week day
    SELECT WeekDay_Factor INTO weekdayFactor
    FROM Day D
    WHERE D.Week_Day = weekDay;
    
    
    
    -- Step 3: Get the ScheduleID and Year_Code from the WeeklySchedule table using the flight number
    SELECT WS.ScheduleID, WS.Year_Code INTO scheduleID, yearCode
    FROM Flight F
    JOIN WeeklySchedule WS ON F.WS_Schedule_ID = WS.ScheduleID
    WHERE F.Flight_Number = flightNumber;
    
    SELECT Y.Profit_Factor INTO profitFactor
    FROM Year Y
    WHERE Y.Year_Code = yearCode;


    SET numberOfBookedPassengers = 40 - calculateFreeSeats(flightNumber);


    SET totalPrice = routPrice * weekdayFactor * (((numberOfBookedPassengers)+1)/40) * profitFactor;
    
     if (round(totalPrice) >= totalPrice) 

    then 

		SET totalPrice = round(totalPrice); 

	end if; 
    
    
    RETURN totalPrice;
END//
DELIMITER ;





