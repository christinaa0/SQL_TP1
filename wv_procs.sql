CREATE PROCEDURE SEED_DATA (@NB_PLAYERS INT, @PARTY_ID INT)
AS
BEGIN
    DECLARE @i INT = 1;
    DECLARE @start_time DATETIME;
    DECLARE @end_time DATETIME;

    WHILE @i <= @NB_PLAYERS
    BEGIN
        -- Générer un start_time aléatoire
        SET @start_time = DATEADD(MINUTE, (RAND() * 1000), GETDATE());

        -- Générer un end_time à partir du start_time avec une durée supplémentaire (ex: 5 à 10 minutes)
        SET @end_time = DATEADD(MINUTE, (RAND() * 5) + 5, @start_time);  -- 5 à 10 minutes plus tard

        -- Insérer un nouveau tour de jeu dans la table turns
        INSERT INTO turns (id_party, start_time, end_time)
        VALUES (@PARTY_ID, @start_time, @end_time);

        -- Passer à l'itération suivante
        SET @i = @i + 1;
    END
END;
