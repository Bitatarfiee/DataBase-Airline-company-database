DROP VIEW IF EXISTS allFlights;

CREATE VIEW allFlights AS
SELECT
    dep_airport.Airport_Name AS departure_city_name,
    arr_airport.Airport_Name AS destination_city_name,
    ws.Departure_time AS departure_time,
    d.Week_Day AS departure_day,
    f.week_Number AS departure_week,
    d.Year_Code AS departure_year,
    calculateFreeSeats(f.Flight_Number) AS nr_of_free_seats,
    calculatePrice(f.Flight_Number) AS current_price_per_seat

FROM
    Flight f
JOIN
    WeeklySchedule ws ON f.WS_Schedule_ID = ws.ScheduleID
JOIN
    Rout r ON ws.R_Rout_Number = r.Rout_Number
JOIN
    Airport dep_airport ON r.Dep_Airport_Code = dep_airport.Airport_Code
JOIN
    Airport arr_airport ON r.Arrival_Airport_Code = arr_airport.Airport_Code
JOIN
    Day d ON ws.D_Week_Day = d.Week_Day AND ws.Year_Code = d.Year_Code
JOIN
    Year y ON d.Year_Code = y.Year_Code
JOIN
    Rout_Year_Dependency ryd ON r.Rout_Number = ryd.R_Rout_Number AND y.Year_Code = ryd.Y_Year_Code;

