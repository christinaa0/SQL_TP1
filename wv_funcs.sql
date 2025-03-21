Delimiter$$
create function Random position(nrows_INT, ncol_INT)returns VACHAR(20)
begin
     declare pos_x int;
     declare pos_y int;
     declare position vachar(20);


     set pos_x=floor(rand()*nb_lignes) + 1;
      set pos_x=floor(rand()*colonnes) + 1;
     set position=concat(pos_x,',', pos_y);
     return position;

    end $$;

create function random_role()
returns varchar(10)
begin
    declare role varchar(10);
    
    if (select count(*) from joueurs where role = 'loup') < (select total_loups from parametres) then
        set role = 'loup';
    else
        set role = 'villageois';
    end if;

    return role;
end $$

create function get_the_winner(partyid int)
returns table
begin
    return ( 
        select 
            j.nom as nom_du_joueur,
            j.role,
            p.nom as nom_de_la_partie,
            (select count(*) from tours where joueur_id = j.id) as nb_tours_joues,
            (select count(*) from tours where partie_id = partyid) as nb_total_tours,
            avg(t.temps_decision) as temps_moyen_decision
        from joueurs j
        join parties p on j.partie_id = p.id
        join tours t on j.id = t.joueur_id
        where j.partie_id = partyid
        group by j.id
        order by nb_tours_joues desc
        limit 1
    );
end $$

delimiter ;
