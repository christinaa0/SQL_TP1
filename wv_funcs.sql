use werewolfvillage;
go

-- créer une vue pour générer un nombre aléatoire
if exists (select * from sys.views where name = 'vw_random')
    drop view vw_random;
go

create view vw_random
as
select rand() as random_value;
go

-- supprimer les anciennes fonctions si elles existent
if exists (select * from sys.objects where name = 'random_position' and type = 'TF')
    drop function random_position;
go

if exists (select * from sys.objects where name = 'random_role' and type = 'FN')
    drop function random_role;
go

if exists (select * from sys.objects where name = 'get_the_winner' and type = 'TF')
    drop function get_the_winner;
go

-- fonction 1 : random_position
create function random_position
(
    @rows int,
    @columns int,
    @party_id int
)
returns @position table (row int, col int)
as
begin
    declare @row int;
    declare @col int;
    declare @is_unique bit = 0;
    declare @rand_value float;

    -- boucle jusqu'à trouver une position non utilisée
    while @is_unique = 0
    begin
        -- récupérer une valeur aléatoire depuis la vue
        select @rand_value = random_value from vw_random;
        set @row = floor(@rand_value * @rows) + 1;

        -- récupérer une autre valeur aléatoire pour la colonne
        select @rand_value = random_value from vw_random;
        set @col = floor(@rand_value * @columns) + 1;

        -- vérifier si la position est déjà utilisée par un obstacle
        if not exists (
            select 1
            from dbo.obstacles
            where id_party = @party_id
            and position_row = @row
            and position_col = @col
        )
        begin
            set @is_unique = 1;
        end;
    end;

    insert into @position (row, col)
    values (@row, @col);

    return;
end;
go

-- fonction 2 : random_role
create function random_role
(
    @party_id int
)
returns int
as
begin
    declare @loup_count int;
    declare @villageois_count int;
    declare @total_players int;
    declare @role_id int;

    -- compter les loups et villageois actuels
    select @loup_count = count(*)
    from dbo.players_in_parties pip
    join dbo.roles r on pip.id_role = r.id_role
    where pip.id_party = @party_id and r.description_role = 'loup';

    select @villageois_count = count(*)
    from dbo.players_in_parties pip
    join dbo.roles r on pip.id_role = r.id_role
    where pip.id_party = @party_id and r.description_role = 'villageois';

    set @total_players = @loup_count + @villageois_count;

    -- quota : 1 loup pour 3 villageois (par exemple)
    if @loup_count * 3 < @villageois_count
    begin
        -- attribuer le rôle loup
        select @role_id = id_role
        from dbo.roles
        where description_role = 'loup';
    end
    else
    begin
        -- attribuer le rôle villageois
        select @role_id = id_role
        from dbo.roles
        where description_role = 'villageois';
    end;

    return @role_id;
end;
go

-- fonction 3 : get_the_winner
create function get_the_winner
(
    @partyid int
)
returns @winner table (
    player_name nvarchar(50),
    role nvarchar(20),
    party_name nvarchar(100),
    tours_played int,
    total_tours int,
    avg_decision_time int
)
as
begin
    declare @winner_id int;
    declare @winner_role nvarchar(20);

    -- vérifier si les loups ont gagné (tous les villageois sont morts)
    if not exists (
        select 1
        from dbo.players_in_parties pip
        join dbo.roles r on pip.id_role = r.id_role
        where pip.id_party = @partyid
        and r.description_role = 'villageois'
        and pip.is_alive = 'oui'
    )
    begin
        -- les loups ont gagné, choisir un loup vivant
        select top 1 @winner_id = pip.id_player, @winner_role = r.description_role
        from dbo.players_in_parties pip
        join dbo.roles r on pip.id_role = r.id_role
        where pip.id_party = @partyid
        and r.description_role = 'loup'
        and pip.is_alive = 'oui';
    end
    else
    begin
        -- vérifier si les villageois ont gagné (fin des tours et au moins un villageois vivant)
        declare @total_turns int;
        select @total_turns = total_turns
        from dbo.game_settings
        where id_party = @partyid;

        if (select count(*) from dbo.turns where id_party = @partyid) >= @total_turns
        begin
            -- les villageois ont gagné, choisir un villageois vivant
            select top 1 @winner_id = pip.id_player, @winner_role = r.description_role
            from dbo.players_in_parties pip
            join dbo.roles r on pip.id_role = r.id_role
            where pip.id_party = @partyid
            and r.description_role = 'villageois'
            and pip.is_alive = 'oui';
        end;
    end;

    -- insérer les informations du vainqueur, ou une ligne vide si aucun vainqueur
    if @winner_id is not null
    begin
        insert into @winner (player_name, role, party_name, tours_played, total_tours, avg_decision_time)
        select 
            pl.pseudo,
            @winner_role,
            p.title_party,
            count(distinct pp.id_turn) as tours_played,
            gs.total_turns,
            avg(datediff(second, t.start_time, pp.end_time)) as avg_decision_time
        from dbo.players pl
        join dbo.players_in_parties pip on pl.id_player = pip.id_player
        join dbo.parties p on pip.id_party = p.id_party
        join dbo.game_settings gs on p.id_party = gs.id_party
        left join dbo.players_play pp on pl.id_player = pp.id_player
        left join dbo.turns t on pp.id_turn = t.id_turn and t.id_party = p.id_party
        where pl.id_player = @winner_id
        group by pl.pseudo, p.title_party, gs.total_turns;
    end
    else
    begin
        -- aucun vainqueur trouvé, retourner une ligne vide
        insert into @winner (player_name, role, party_name, tours_played, total_tours, avg_decision_time)
        values (null, null, null, 0, 0, 0);
    end;

    return;
end;
go
