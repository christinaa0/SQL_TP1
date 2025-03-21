create function random_position(@partyid int)
returns table
as
return (
    select top 1 
        char(65 + abs(checksum(newid())) % 10) as col,
        cast(1 + abs(checksum(newid())) % 10 as varchar) as row
    from players_play p
    where not exists (
        select 1 from players_play where id_party = @partyid 
        and origin_position_col = col and origin_position_row = row
    )
);

go

create function random_role(@partyid int)
returns varchar(10)
as
begin
    declare @nb_players int, @nb_wolves int, @nb_villagers int, @role varchar(10)
    select @nb_players = count(*) from players_in_parties where id_party = @partyid
    select @nb_wolves = (@nb_players * 20) / 100, @nb_villagers = @nb_players - @nb_wolves
    if (select count(*) from players_in_parties where id_party = @partyid and id_role = 1) < @nb_wolves
        set @role = 'loup'
    else
        set @role = 'villageois'
    return @role
end

go

create function get_the_winner(@partyid int)
returns table
as
return (
    select top 1 p.pseudo, r.description_role, pa.title_party,
        count(distinct pl.id_turn) as nb_tours_joues,
        (select count(distinct id_turn) from turns where id_party = @partyid) as nb_tours_total,
        avg(datediff(second, pl.start_time, pl.end_time)) as temps_moyen_decision
    from players p
    join players_in_parties pip on p.id_player = pip.id_player
    join roles r on pip.id_role = r.id_role
    join parties pa on pip.id_party = pa.id_party
    join players_play pl on p.id_player = pl.id_player
    where pip.id_party = @partyid and pip.is_alive = 'yes'
    group by p.pseudo, r.description_role, pa.title_party
    order by nb_tours_joues desc
);

go
