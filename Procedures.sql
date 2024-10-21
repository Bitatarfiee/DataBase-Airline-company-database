
DROP PROCEDURE IF EXISTS addYear;
delimiter //
CREATE PROCEDURE addYear(IN p_Year INT, IN p_Profit_Factor DOUBLE)
BEGIN
INSERT INTO Year(Year_Code, Profit_Factor) VALUES (p_Year, p_Profit_Factor);
END;
//
delimiter ;



DROP PROCEDURE IF EXISTS addDay;
delimiter //
CREATE PROCEDURE addDay(IN p_Year INT,IN p_Day Varchar(10),IN p_Factor DOUBLE)
BEGIN
INSERT INTO Day(Year_Code,Week_Day ,WeekDay_Factor) VALUES (p_Year, p_Day,p_Factor);
END;
//
delimiter ;


/*
 Insert a destination: Procedure call: addDestination(airport_code, name,country);
*/
DROP PROCEDURE IF EXISTS addDestination;
delimiter //
CREATE PROCEDURE addDestination(In p_airport_code VARCHAR(3) ,In p_name VARCHAR(30),In p_country VARCHAR(30))
BEGIN
INSERT INTO Airport(Airport_Code,Airport_Name ,Airport_Country) VALUES (p_airport_code,p_name, p_country);
END;
//
delimiter ;


/*
 Insert a route: Procedure call: addRoute(departure_airport_code,arrival_airport_code, year, routeprice);
*/
DROP PROCEDURE IF EXISTS addRoute;
delimiter //
CREATE PROCEDURE addRoute(In p_departure_airport_code VARCHAR(3),IN p_arrival_airport_code VARCHAR(3),In  p_year int,IN p_routeprice bigint)
BEGIN
INSERT INTO Rout(Dep_Airport_Code,Arrival_Airport_Code)VALUES (p_departure_airport_code,p_arrival_airport_code);
INSERT INTO Rout_Year_Dependency(Y_Year_Code,Rout_Price) VALUES (p_year,p_routeprice);
END;
//
delimiter ;



/*
Insert a weekly flight: Procedure call: addFlight
*/
DROP PROCEDURE IF EXISTS addFlight;
delimiter //
CREATE PROCEDURE addFlight(In p_departure_airport_code VARCHAR(3),
In p_arrival_airport_code VARCHAR(3),In p_year int,In p_day varchar(10),In p_departure_time TIME)
BEGIN
DECLARE schedule_id INT;
DECLARE week_number INT;
DECLARE ROUT_NUM BIGINT;
SELECT R.Rout_Number INTO ROUT_NUM
    FROM Rout R
    JOIN Rout_Year_Dependency C ON R.Rout_Number = C.R_Rout_Number
    WHERE R.Dep_Airport_Code = p_departure_airport_code
        AND R.Arrival_Airport_Code = p_arrival_airport_code
        AND C.Y_Year_Code = p_year
   ;

INSERT INTO WeeklySchedule(D_Week_Day, Year_Code, Departure_time, R_Rout_Number) 
VALUES (p_day, p_year, p_departure_time, ROUT_NUM); 
SET schedule_id = LAST_INSERT_ID();

SET week_number = 1;
#SET schedule_id = LAST_INSERT_ID();
WHILE week_number <= 52 DO
	INSERT INTO Flight(WS_Schedule_ID, week_Number) VALUES (schedule_id, week_number);
	SET week_number = week_number + 1;
END WHILE;
END;
//
delimiter ;

