
/*-------------------------------------------------
 Fonction 1 : random_position
 Retourne la première paire (line, col) non occupée pour une partie donnée.
 Cette version est déterministe car NEWID() n'est pas utilisé.
--------------------------------------------------*/
CREATE FUNCTION dbo.random_position(
    @partyID INT,
    @lines INT,
    @cols INT
)
RETURNS TABLE
AS
RETURN
(
    WITH PossiblePositions AS (
        SELECT 
            ROW_NUMBER() OVER (ORDER BY l.number, c.number) AS row_idx,
            l.number AS [line], 
            c.number AS [col]
        FROM master..spt_values l
        CROSS JOIN master..spt_values c
        WHERE l.type = 'P' AND c.type = 'P'
          AND l.number BETWEEN 1 AND @lines
          AND c.number BETWEEN 1 AND @cols
    )
    SELECT TOP 1 [line], [col]
    FROM PossiblePositions p
    WHERE NOT EXISTS (
         SELECT 1 
         FROM dbo.OccupiedPositions op
         WHERE op.id_party = @partyID
           AND op.[line] = p.[line]
           AND op.[col] = p.[col]
    );
);
GO

/*-------------------------------------------------
 Fonction 2 : random_role
 Retourne 'loup' ou 'villageois' en fonction de l'ID de la partie.
 La détermination repose sur la parité de @partyID.
--------------------------------------------------*/
CREATE FUNCTION dbo.random_role(@partyID INT)
RETURNS VARCHAR(10)
AS
BEGIN
    RETURN CASE WHEN @partyID % 2 = 0 THEN 'loup' ELSE 'villageois' END;
END;
GO

/*-------------------------------------------------
 Fonction 3 : get_the_winner
 Retourne les détails du gagnant d'une partie sous forme de table.
 Les colonnes texte sont castées en VARCHAR(255) et incluses dans le GROUP BY.
--------------------------------------------------*/
CREATE FUNCTION dbo.get_the_winner(@partyID INT)
RETURNS TABLE
AS
RETURN
(
    SELECT TOP 1
         CAST(p.pseudo AS VARCHAR(255)) AS PlayerName,
         CAST(r.description_role AS VARCHAR(255)) AS Role,
         CAST(pa.title_party AS VARCHAR(255)) AS PartyName,
         (
             SELECT COUNT(*) 
             FROM dbo.players_play pp2
             JOIN dbo.turns t2 ON pp2.id_turn = t2.id_turn
             WHERE pp2.id_player = p.id_player 
               AND t2.id_party = @partyID
         ) AS TurnsPlayed,
         (
             SELECT COUNT(*) 
             FROM dbo.turns t3
             WHERE t3.id_party = @partyID
         ) AS TotalTurns,
         AVG(DATEDIFF(SECOND, pp.start_time, pp.end_time)) AS AverageDecisionTime
    FROM dbo.players p
    JOIN dbo.players_in_parties pip ON p.id_player = pip.id_player
    JOIN dbo.roles r ON pip.id_role = r.id_role
    JOIN dbo.parties pa ON pip.id_party = pa.id_party
    JOIN dbo.players_play pp ON p.id_player = pp.id_player
    WHERE pip.id_party = @partyID
    GROUP BY p.id_player, p.pseudo, r.description_role, pa.title_party
    ORDER BY COUNT(*) DESC;
);
GO
