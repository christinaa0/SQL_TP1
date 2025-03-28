use werewolfvillage;
go

-- supprimer les vues existantes pour éviter les conflits
if exists (select * from sys.views where name = 'all_players')
    drop view all_players;
go

if exists (select * from sys.views where name = 'all_players_elapsed_game')
    drop view all_players_elapsed_game;
go

if exists (select * from sys.views where name = 'all_players_elapsed_tour')
    drop view all_players_elapsed_tour;
go

if exists (select * from sys.views where name = 'all_players_stats')
    drop view all_players_stats;
go

-- vue 1 : all_players
create view all_players as
select 
    pl.pseudo,
    count(distinct pip.id_party) as number_of_parties,
    count(pp.id_turn) as number_of_turns,
    min(t.start_time) as first_participation,
    max(pp.end_time) as last_action
from dbo.players pl
left join dbo.players_in_parties pip on pl.id_player = pip.id_player
left join dbo.players_play pp on pl.id_player = pp.id_player
left join dbo.turns t on pp.id_turn = t.id_turn
group by pl.pseudo
having count(distinct pip.id_party) > 0;
go

-- vue 2 : all_players_elapsed_game
create view all_players_elapsed_game as
select 
    pl.pseudo,
    p.title_party,
    count(distinct pip2.id_player) as number_of_participants,
    min(pp.start_time) as first_action,
    max(pp.end_time) as last_action,
    datediff(second, min(pp.start_time), max(pp.end_time)) as seconds_in_game
from dbo.players pl
join dbo.players_in_parties pip on pl.id_player = pip.id_player
join dbo.parties p on pip.id_party = p.id_party
join dbo.players_play pp on pl.id_player = pp.id_player
join dbo.turns t on pp.id_turn = t.id_turn and t.id_party = p.id_party
join dbo.players_in_parties pip2 on p.id_party = pip2.id_party
group by pl.pseudo, p.title_party;
go

-- vue 3 : all_players_elapsed_tour
create view all_players_elapsed_tour as
select 
    pl.pseudo,
    p.title_party,
    t.id_turn as tour_number,
    t.start_time as tour_start_time,
    pp.end_time as decision_time,
    datediff(second, t.start_time, pp.end_time) as seconds_in_tour
from dbo.players pl
join dbo.players_play pp on pl.id_player = pp.id_player
join dbo.turns t on pp.id_turn = t.id_turn
join dbo.parties p on t.id_party = p.id_party;
go

-- vue 4 : all_players_stats
create view all_players_stats as
select 
    pl.pseudo,
    r.description_role as role,
    p.title_party,
    p.id_party, -- inclure id_party pour l'utiliser dans les sous-requêtes
    count(distinct pp.id_turn) as tours_played,
    gs.total_turns as total_tours,
    case 
        when r.description_role = 'loup' and 
             (select count(*) 
              from dbo.players_in_parties pip2 
              join dbo.roles r2 on pip2.id_role = r2.id_role 
              where pip2.id_party = p.id_party 
              and r2.description_role = 'villageois' 
              and pip2.is_alive = 'oui') = 0 
        then 'vainqueur'
        when r.description_role = 'villageois' and 
             (select count(*) 
              from dbo.turns t 
              where t.id_party = p.id_party) >= gs.total_turns and 
             (select count(*) 
              from dbo.players_in_parties pip2 
              join dbo.roles r2 on pip2.id_role = r2.id_role 
              where pip2.id_party = p.id_party 
              and r2.description_role = 'villageois' 
              and pip2.is_alive = 'oui') > 0 
        then 'vainqueur'
        else 'perdant'
    end as winner,
    avg(datediff(second, t.start_time, pp.end_time)) as avg_decision_time
from dbo.players pl
join dbo.players_in_parties pip on pl.id_player = pip.id_player
join dbo.parties p on pip.id_party = p.id_party
join dbo.roles r on pip.id_role = r.id_role
join dbo.game_settings gs on p.id_party = gs.id_party
left join dbo.players_play pp on pl.id_player = pp.id_player
left join dbo.turns t on pp.id_turn = t.id_turn and t.id_party = p.id_party
group by pl.pseudo, r.description_role, p.title_party, p.id_party, gs.total_turns;
go
