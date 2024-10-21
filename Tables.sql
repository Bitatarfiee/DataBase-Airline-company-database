DROP TABLE IF EXISTS Reserved_Passenger;
DROP TABLE IF EXISTS Purchase_For;
DROP TABLE IF EXISTS Booking;
DROP TABLE IF EXISTS CreditCard;
DROP TABLE IF EXISTS Reservation;
DROP TABLE IF EXISTS Contact;
DROP TABLE IF EXISTS Passenger;
DROP TABLE IF EXISTS Flight;
DROP TABLE IF EXISTS Rout_Year_Dependency;
DROP TABLE IF EXISTS WeeklySchedule;
DROP TABLE IF EXISTS Rout;
DROP TABLE IF EXISTS Airport;
DROP TABLE IF EXISTS Day;
DROP TABLE IF EXISTS Year;



CREATE TABLE Year(
    Year_Code int NOT NULL AUTO_INCREMENT,
    Profit_Factor DOUBLE NOT NULL,
    constraint pk_Year primary key (Year_Code)
);

CREATE TABLE Day(
    Week_Day varchar(10) NOT NULL,
    WeekDay_Factor DOUBLE NOT NULL,                    
    Year_Code int NOT NULL AUTO_INCREMENT,
    constraint pk_Day primary key (Week_Day,Year_Code),           
    constraint fk_Year_Day FOREIGN KEY (Year_Code) references Year(Year_Code)
);

CREATE TABLE Airport(
    Airport_Code VARCHAR(3) NOT NULL,
    Airport_Name VARCHAR(30),
    Airport_Country VARCHAR(30),
    constraint pk_Airport primary key (Airport_Code)
);

CREATE TABLE Rout(
    Rout_Number BIGINT NOT NULL AUTO_INCREMENT,
    Dep_Airport_Code VARCHAR(30),
    Arrival_Airport_Code VARCHAR(30),
    #Routyear int,
    constraint pk_Rout primary key (Rout_Number),
    constraint fk_Airport_Rout_Dept FOREIGN KEY (Dep_Airport_Code) references Airport(Airport_Code),
    constraint fk_Airport_Rout_Arrival FOREIGN KEY (Arrival_Airport_Code) references Airport(Airport_Code)
    #constraint fk_Year_Rout_Routyear FOREIGN KEY (Routyear) references Year(Year_code)
);

CREATE TABLE WeeklySchedule(
    ScheduleID int NOT NULL AUTO_INCREMENT,
    Departure_time TIME,
    D_Week_Day varchar(10),
    Year_Code int,
    R_Rout_Number BIGINT ,
    constraint pk_WeeklySchedule primary key (ScheduleID),
    constraint fk_Day_WeeklySchedule_week FOREIGN KEY (D_week_day) references Day(Week_Day),
    constraint fk_Day_WeeklySchedule_Year FOREIGN KEY (Year_Code) references Day(Year_Code),
    constraint fk_Rout_WeeklySchedule FOREIGN KEY (R_Rout_Number) references Rout(Rout_Number)
);

CREATE TABLE Rout_Year_Dependency(
    Y_Year_Code int NOT NULL,
    R_Rout_Number bigint NOT NULL AUTO_INCREMENT,
    Rout_Price double,
    constraint pk_Rout_Year_Dependency primary key (Y_Year_Code, R_Rout_Number),
    constraint fk_Year_Rout_Year_Dependency FOREIGN KEY (Y_Year_Code) references Year(Year_Code),
    constraint fk_Rout_Rout_Year_Dependency FOREIGN KEY (R_Rout_Number) references Rout(Rout_Number)
);


CREATE TABLE Flight(
    Flight_Number int NOT NULL AUTO_INCREMENT,
    WS_Schedule_ID int,
    week_Number int,
    constraint pk_Flight primary key (Flight_Number),
    constraint fk_WeeklySchedule_Flight FOREIGN KEY (WS_Schedule_ID) references WeeklySchedule(ScheduleID)
);

CREATE TABLE Passenger(
    PassportNumber int NOT NULL,
    Name varchar(30),
    constraint pk_Passenger primary key (PassportNumber)
);

CREATE TABLE Contact(
    P_PassportNumber int NOT NULL,
    Email varchar(30),
    Phone_Number bigint,
    constraint pk_Contact primary key (P_PassportNumber),
    constraint fk_Passenger_Contact FOREIGN KEY (P_PassportNumber) references Passenger(PassportNumber)
);


CREATE TABLE Reservation(
    ReservationNumber int NOT NULL AUTO_INCREMENT,
    F_Flight_Number int,
    Contact_Passport_Number int,
    constraint pk_Reservation primary key (ReservationNumber),
    constraint fk_Flight_Reservation FOREIGN KEY (F_Flight_Number) references Flight(Flight_Number),
    constraint fk_Contact_Reservation FOREIGN KEY (Contact_Passport_Number) references Contact(P_PassportNumber)
);


CREATE TABLE CreditCard(
    Card_Num bigint NOT NULL AUTO_INCREMENT,
    Card_Holder varchar(30),
    constraint pk_CreditCard primary key (Card_Num)
);

CREATE TABLE Booking(
    ReservationNumber int NOT NULL AUTO_INCREMENT,
    TotalPrice double,
    CreditCard_Num BIGINT,
    constraint pk_Booking primary key (ReservationNumber),
    constraint fk_Reservation_Booking FOREIGN KEY (ReservationNumber) references Reservation(ReservationNumber),
    constraint fk_CreditCard_Booking FOREIGN KEY (CreditCard_Num) references CreditCard(Card_Num)
);

CREATE TABLE Purchase_For(
    B_ReservationtNumber int NOT NULL AUTO_INCREMENT,
    Ticket_Num BIGINT,
    P_PassportNumber int NOT NULL,
    constraint pk_Purchase_For primary key (B_ReservationtNumber, P_PassportNumber),
    constraint fk_Passenger_Purchase_For FOREIGN KEY (P_PassportNumber) references Passenger(PassportNumber),
    constraint fk_Booking_Purchase_For FOREIGN KEY (B_ReservationtNumber) references Booking(ReservationNumber)
);

CREATE TABLE Reserved_Passenger(
    P_PassportNumber int NOT NULL AUTO_INCREMENT,
    R_ReservationtNumber int NOT NULL,
    constraint pk_Reserved_Passenger primary key (P_PassportNumber, R_ReservationtNumber),
    constraint fk_Passenger_Reserved_Passenger FOREIGN KEY (P_PassportNumber) references Passenger(PassportNumber),
    constraint fk_Reservation_Reserved_Passenger FOREIGN KEY (R_ReservationtNumber) references Reservation(ReservationNumber)
);
