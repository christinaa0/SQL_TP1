use werewolfvillage;
go

-- rendre les colonnes des clés primaires not null
alter table dbo.parties
alter column id_party int not null;

alter table dbo.roles
alter column id_role int not null;

alter table dbo.players
alter column id_player int not null;

alter table dbo.players_in_parties
alter column id_party int not null;

alter table dbo.players_in_parties
alter column id_player int not null;

alter table dbo.turns
alter column id_turn int not null;

alter table dbo.players_play
alter column id_player int not null;

alter table dbo.players_play
alter column id_turn int not null;

-- ajout des clés primaires
alter table dbo.parties
add constraint pk_parties primary key (id_party);

alter table dbo.roles
add constraint pk_roles primary key (id_role);

alter table dbo.players
add constraint pk_players primary key (id_player);

alter table dbo.players_in_parties
add constraint pk_players_in_parties primary key (id_party, id_player);

alter table dbo.turns
add constraint pk_turns primary key (id_turn);

alter table dbo.players_play
add constraint pk_players_play primary key (id_player, id_turn);

-- ajout des clés étrangères
alter table dbo.players_in_parties
add constraint fk_players_in_parties_party foreign key (id_party) references dbo.parties(id_party),
    constraint fk_players_in_parties_player foreign key (id_player) references dbo.players(id_player),
    constraint fk_players_in_parties_role foreign key (id_role) references dbo.roles(id_role);

alter table dbo.turns
add constraint fk_turns_party foreign key (id_party) references dbo.parties(id_party);

alter table dbo.players_play
add constraint fk_players_play_player foreign key (id_player) references dbo.players(id_player),
    constraint fk_players_play_turn foreign key (id_turn) references dbo.turns(id_turn);

-- ajout de contraintes d'unicité et de validation
alter table dbo.players
add constraint uk_players_pseudo unique (pseudo);

alter table dbo.players_in_parties
add constraint chk_is_alive check (is_alive in ('oui', 'non'));

-- optimisation des types de données
alter table dbo.players
alter column pseudo nvarchar(50);

alter table dbo.roles
alter column description_role nvarchar(20);

alter table dbo.parties
alter column title_party nvarchar(100);

-- ajout d'une table pour les paramètres de la partie (lignes, colonnes, etc.)
create table dbo.game_settings (
    id_party int primary key,
    rows int not null check (rows > 0),
    columns int not null check (columns > 0),
    max_turn_time int not null check (max_turn_time > 0),
    total_turns int not null check (total_turns > 0),
    obstacle_count int not null check (obstacle_count >= 0),
    foreign key (id_party) references dbo.parties(id_party)
);

-- ajout d'une table pour les obstacles
create table dbo.obstacles (
    id_obstacle int primary key identity(1,1),
    id_party int,
    position_row int not null,
    position_col int not null,
    foreign key (id_party) references dbo.parties(id_party)
);

-- ajout d'index pour optimiser les requêtes
create index idx_players_in_parties_id_party on dbo.players_in_parties(id_party);
create index idx_turns_id_party on dbo.turns(id_party);
create index idx_players_play_id_turn on dbo.players_play(id_turn);
