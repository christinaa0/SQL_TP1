
alter table parties
alter column id_party int not null;

alter table roles
alter column id_role int not null;

alter table players
alter column id_player int not null;

alter table turns
alter column id_turn int not null;

alter table players_play
alter column id_player int not null;

alter table players_play
alter column id_turn int not null;


alter table parties
add primary key (id_party);

alter table roles
add primary key (id_role);

alter table players
add primary key (id_player);

alter table turns
add primary key (id_turn);



alter table players_in_parties
add foreign key (id_party) references parties (id_party);

alter table players_in_parties
add foreign key (id_player) references players (id_player);

alter table players_in_parties
add foreign key (id_role) references roles (id_role);

alter table turns
add foreign key (id_party) references parties (id_party);

alter table players_play
add foreign key (id_player) references players (id_player);

alter table players_play
add foreign key (id_turn) references turns (id_turn);


-- Fausse donnée generer par chatGPT


insert into parties (id_party, title_party)
values (1, 'Party A'),
       (2, 'Party B'),
       (3, 'Party C');


insert into roles (id_role, description_role)
values (1, 'Role 1'),
       (2, 'Role 2'),
       (3, 'Role 3');


insert into players (id_player, pseudo)
values (1, 'Player1'),
       (2, 'Player2'),
       (3, 'Player3'),
       (4, 'Player4'),
       (5, 'Player5'),
       (6, 'Player6'),
       (7, 'Player7'),
       (8, 'Player8'),
       (9, 'Player9'),
       (10, 'Player10');


insert into players_in_parties (id_party, id_player, id_role, is_alive)
values (1, 1, 1, 'yes'),
       (1, 2, 2, 'yes'),
       (1, 3, 3, 'yes'),
       (2, 4, 1, 'yes'),
       (2, 5, 2, 'yes'),
       (2, 6, 3, 'yes'),
       (3, 7, 1, 'yes'),
       (3, 8, 2, 'yes'),
       (3, 9, 3, 'yes'),
       (3, 10, 1, 'yes');


insert into turns (id_turn, id_party, start_time, end_time)
values
(1, 1, '2025-03-21 10:00:00', '2025-03-21 10:30:00'),
(2, 1, '2025-03-21 11:00:00', '2025-03-21 11:30:00'),
(3, 2, '2025-03-21 13:00:00', '2025-03-21 13:30:00'),
(4, 2, '2025-03-21 14:00:00', '2025-03-21 14:30:00'),
(5, 3, '2025-03-21 16:00:00', '2025-03-21 16:30:00');



-- Insérer des données dans la table players_play
insert into players_play (id_player, id_turn, start_time, end_time, action, origin_position_col, origin_position_row, target_position_col, target_position_row)
values (1, 1, '2025-03-21 10:05:00', '2025-03-21 10:10:00', 'MOVE', 'A', '1', 'B', '2'),
       (2, 1, '2025-03-21 10:15:00', '2025-03-21 10:20:00', 'MOVE', 'C', '2', 'D', '3'),
       (3, 2, '2025-03-21 14:05:00', '2025-03-21 14:10:00', 'ATTACK', 'B', '1', 'C', '2'),
       (4, 2, '2025-03-21 14:15:00', '2025-03-21 14:20:00', 'MOVE', 'D', '3', 'E', '4'),
       (5, 3, '2025-03-21 16:05:00', '2025-03-21 16:10:00', 'DEFEND', 'F', '1', 'G', '2'),
       (6, 3, '2025-03-21 16:15:00', '2025-03-21 16:20:00', 'MOVE', 'H', '2', 'I', '3'),
       (7, 4, '2025-03-21 17:05:00', '2025-03-21 17:10:00', 'MOVE', 'J', '1', 'K', '2'),
       (8, 4, '2025-03-21 17:15:00', '2025-03-21 17:20:00', 'ATTACK', 'L', '3', 'M', '4');
