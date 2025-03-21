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
    
