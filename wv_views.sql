CREATE VIEW ALL_PLAYERS AS
SELECT 
    joueur.nom AS nom_du_joueur,
    COUNT(DISTINCT partie.id) AS nombre_de_parties_jouees,
    COUNT(tour.id) AS nombre_de_tours_joues,
    MIN(tour.date_heure_debut) AS date_premiere_participation,
    MAX(tour.date_heure_fin) AS date_derniere_action
FROM 
    joueur
JOIN 
    participation ON joueur.id = participation.joueur_id
JOIN 
    partie ON participation.partie_id = partie.id
JOIN 
    tour ON tour.partie_id = partie.id
GROUP BY 
    joueur.nom
ORDER BY 
    nombre_de_parties_jouees DESC,
    date_premiere_participation ASC,
    date_derniere_action DESC,
    nom_du_joueur ASC;
CREATE VIEW ALL_PLAYERS_ELAPSED_GAME AS
SELECT 
    joueur.nom AS nom_du_joueur,
    partie.nom AS nom_de_la_partie,
    COUNT(participation.id) AS nombre_de_participants,
    MIN(tour.date_heure_debut) AS date_premiere_action,
    MAX(tour.date_heure_fin) AS date_derniere_action,
    DATEDIFF(SECOND, MIN(tour.date_heure_debut), MAX(tour.date_heure_fin)) AS temps_ecoule_en_secondes
FROM 
    joueur
JOIN 
    participation ON joueur.id = participation.joueur_id
JOIN 
    partie ON participation.partie_id = partie.id
JOIN 
    tour ON tour.partie_id = partie.id
GROUP BY 
    joueur.nom, partie.nom;
