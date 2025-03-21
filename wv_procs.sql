CREATE PROCEDURE SEED_DATA (@NB_PLAYERS INT, @PARTY_ID INT)
AS
BEGIN
    DECLARE @i INT = 1;
    DECLARE @start_time DATETIME;
    DECLARE @end_time DATETIME;

    WHILE @i <= @NB_PLAYERS
    BEGIN

        SET @start_time = DATEADD(MINUTE, (RAND() * 1000), GETDATE());


        SET @end_time = DATEADD(MINUTE, (RAND() * 5) + 5, @start_time); 


        INSERT INTO turns (id_party, start_time, end_time)
        VALUES (@PARTY_ID, @start_time, @end_time);


        SET @i = @i + 1;
    END
END;
