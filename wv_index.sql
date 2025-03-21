
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
