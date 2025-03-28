use werewolfvillage;
go

-- trigger 1 : appeler complete_tour quand un tour est marqué terminé
create trigger tr_on_tour_end
on dbo.turns
after update
as
begin
    if update(end_time)
    begin
        declare @tour_id int;
        declare @party_id int;

        select @tour_id = id_turn, @party_id = id_party
        from inserted
        where end_time is not null;

        if @tour_id is not null and @party_id is not null
        begin
            exec complete_tour @tour_id, @party_id;
        end;
    end;
end;
go

-- trigger 2 : appeler username_to_lower quand un joueur s'inscrit
create trigger tr_on_player_insert
on dbo.players
after insert
as
begin
    exec username_to_lower;
end;
go
