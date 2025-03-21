create view all_players as
select 
    players.pseudo as nom_du_joueur,
    count(distinct parties.id_party) as nombre_de_parties_jouees,
    count(turns.id_turn) as nombre_de_tours_joues,
    min(turns.start_time) as date_premiere_participation,
    max(turns.end_time) as date_derniere_action
from 
    players
join 
    players_in_parties on players.id_player = players_in_parties.id_player
join 
    parties on players_in_parties.id_party = parties.id_party
join 
    turns on turns.id_party = parties.id_party
group by 
    players.pseudo
order by 
    nombre_de_parties_jouees desc,
    date_premiere_participation asc,
    date_derniere_action desc,
    nom_du_joueur asc;
create view all_players_elapsed_game as
select 
    players.pseudo as nom_du_joueur,
    parties.title_party as nom_de_la_partie,
    count(players_in_parties.id_player) as nombre_de_participants,
    min(turns.start_time) as date_premiere_action,
    max(turns.end_time) as date_derniere_action,
    timestampdiff(second, min(turns.start_time), max(turns.end_time)) as temps_ecoule_en_secondes
from 
    players
join 
    players_in_parties on players.id_player = players_in_parties.id_player
join 
    parties on players_in_parties.id_party = parties.id_party
join 
    turns on turns.id_party = parties.id_party
group by 
    players.pseudo, parties.title_party;
create view all_players_elapsed_tour as
select 
    players.pseudo as nom_du_joueur,
    parties.title_party as nom_de_la_partie,
    turns.id_turn as numero_du_tour,
    turns.start_time as debut_du_tour,
    players_play.start_time as date_decision,
    timestampdiff(second, turns.start_time, players_play.start_time) as temps_ecoule_pour_le_tour
from 
    players
join 
    players_play on players.id_player = players_play.id_player
join 
    turns on players_play.id_turn = turns.id_turn
join 
    parties on turns.id_party = parties.id_party;
create view all_players_stats as
select 
    players.pseudo as nom_du_joueur,
    roles.description_role as role_du_joueur,
    parties.title_party as nom_de_la_partie,
    count(turns.id_turn) as nombre_de_tours_joues,
    (select count(*) from turns where turns.id_party = parties.id_party) as nombre_total_de_tours,
    parties.title_party as vainqueur_dependant_du_role,
    avg(timestampdiff(second, turns.start_time, players_play.start_time)) as temps_moyen_decision
from 
    players
join 
    players_in_parties on players.id_player = players_in_parties.id_player
join 
    roles on players_in_parties.id_role = roles.id_role
join 
    parties on players_in_parties.id_party = parties.id_party
join 
    turns on turns.id_party = parties.id_party
join 
    players_play on players.id_player = players_play.id_player
group by 
    players.pseudo, roles.description_role, parties.title_party;


