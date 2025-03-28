use werewolfvillage;
go

-- supprimer les anciennes procédures si elles existent
if exists (select * from sys.procedures where name = 'sp_start_game')
    drop procedure sp_start_game;
go

if exists (select * from sys.procedures where name = 'sp_add_player_to_game')
    drop procedure sp_add_player_to_game;
go

if exists (select * from sys.procedures where name = 'sp_perform_action')
    drop procedure sp_perform_action;
go

if exists (select * from sys.procedures where name = 'sp_kill_player')
    drop procedure sp_kill_player;
go

if exists (select * from sys.procedures where name = 'seed_data')
    drop procedure seed_data;
go

if exists (select * from sys.procedures where name = 'complete_tour')
    drop procedure complete_tour;
go

if exists (select * from sys.procedures where name = 'username_to_lower')
    drop procedure username_to_lower;
go

-- procédure 1 : seed_data
create procedure seed_data
    @nb_milligrams int,
    @party_id int
as
begin
    declare @total_turns int;
    declare @current_turn int = 1;

    -- récupérer le nombre total de tours pour la partie
    select @total_turns = total_turns
    from dbo.game_settings
    where id_party = @party_id;

    -- insérer les tours
    while @current_turn <= @total_turns
    begin
        insert into dbo.turns (id_turn, id_party, start_time, end_time)
        values (@current_turn, @party_id, dateadd(millisecond, @nb_milligrams * (@current_turn - 1), getdate()), dateadd(millisecond, @nb_milligrams * @current_turn, getdate()));
        set @current_turn = @current_turn + 1;
    end;
end;
go

-- procédure 2 : complete_tour
create procedure complete_tour
    @tour_id int,
    @party_id int
as
begin
    -- table temporaire pour stocker les positions finales
    declare @final_positions table (
        id_player int,
        position_row int,
        position_col int
    );

    -- récupérer les demandes de déplacement pour ce tour
    insert into @final_positions (id_player, position_row, position_col)
    select 
        pp.id_player,
        cast(pp.target_position_row as int),
        cast(pp.target_position_col as int)
    from dbo.players_play pp
    where pp.id_turn = @tour_id;

    -- vérifier les collisions avec les obstacles
    delete fp
    from @final_positions fp
    where exists (
        select 1
        from dbo.obstacles o
        where o.id_party = @party_id
        and o.position_row = fp.position_row
        and o.position_col = fp.position_col
    );

    -- vérifier les éliminations (villageois sur la même case qu'un loup)
    update dbo.players_in_parties
    set is_alive = 'non'
    where id_party = @party_id
    and id_player in (
        select pip.id_player
        from @final_positions fp_v
        join dbo.players_in_parties pip on fp_v.id_player = pip.id_player
        join dbo.roles r on pip.id_role = r.id_role
        where r.description_role = 'villageois'
        and exists (
            select 1
            from @final_positions fp_l
            join dbo.players_in_parties pip_l on fp_l.id_player = pip_l.id_player
            join dbo.roles r_l on pip_l.id_role = r_l.id_role
            where r_l.description_role = 'loup'
            and fp_l.position_row = fp_v.position_row
            and fp_l.position_col = fp_v.position_col
            and pip_l.id_party = @party_id
        )
    );
end;
go

-- procédure 3 : username_to_lower
create procedure username_to_lower
as
begin
    update dbo.players
    set pseudo = lower(pseudo);
end;
go
