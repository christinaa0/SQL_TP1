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

create procedure complete_tour (@tour_id int, @party_id int)
as
begin
    set nocount on;


    create table #valid_moves (
        id_player int,
        new_position_col text,
        new_position_row text
    );


    insert into #valid_moves (id_player, new_position_col, new_position_row)
    select pp.id_player, pp.target_position_col, pp.target_position_row
    from players_play pp
    where pp.id_turn = @tour_id;


    delete from #valid_moves
    where exists (
        select 1
        from players_play pp
        where pp.id_turn = @tour_id
        and pp.target_position_col = #valid_moves.new_position_col
        and pp.target_position_row = #valid_moves.new_position_row
        group by pp.target_position_col, pp.target_position_row
        having count(*) > 1
    );


    update pp
    set origin_position_col = vm.new_position_col,
        origin_position_row = vm.new_position_row
    from players_play pp
    join #valid_moves vm on pp.id_player = vm.id_player
    where pp.id_turn = @tour_id;


    drop table #valid_moves;
end;

