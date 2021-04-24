library(RSQLite)

# Connection à la base de données
con <- dbConnect(SQLite(), dbname="./reseau.db")

########################################
# Première partie: 
# Comparer le nombre de collaborations par etudiant du cours BIO500 avant et après l'arrivée du covid
########################################
# Nombre de collaborations par etudiant du cours BIO500 en 2019 et avant
sql_requete_coll_avant <- "
  SELECT etudiant1, COUNT(etudiant1) AS nb_collaborations, BIO500
  FROM(
    SELECT etudiant1, BIO500, date
    FROM collaborations
    INNER JOIN noeuds ON collaborations.etudiant1 = noeuds.nom_prenom
  )
  WHERE (BIO500 = 1) AND (date LIKE '_1_')
  GROUP BY etudiant1
;"

data_avant_covid <- dbGetQuery(con,sql_requete_coll_avant)
head(data_avant_covid)

# Nombre de collaborations par etudiant du cours BIO500 en 2020 et après
sql_requete_coll_apres <- "
  SELECT etudiant1, COUNT(etudiant1) AS nb_collaborations, BIO500
  FROM(
    SELECT etudiant1, BIO500, date
    FROM collaborations
    INNER JOIN noeuds ON collaborations.etudiant1 = noeuds.nom_prenom
  )
  WHERE (BIO500 = 1) AND (date LIKE '_2_')
  GROUP BY etudiant1
;"

data_apres_covid <- dbGetQuery(con,sql_requete_coll_apres)
head(data_apres_covid)

########################################
# Deuxième partie:
# Nombre de collaborations par etudiant par cours
########################################
# Nombre de collaborations par cours
sql_requete_nb_coll <- "
  SELECT cours, COUNT(cours) AS nb_coll_cours
  FROM collaborations
  GROUP BY cours
;"

nb_coll_par_cours <- dbGetQuery(con,sql_requete_nb_coll)
head(nb_coll_par_cours)

# Nombre d'étudiants par cours
sql_requete_nb_etudiant <- "
  SELECT COUNT(etudiant1) AS nb_etudiants
  FROM (
    SELECT DISTINCT cours, etudiant1
    FROM collaborations
    ORDER BY cours
    )
  GROUP BY cours
;"
nb_etudiant_par_cours <- dbGetQuery(con,sql_requete_nb_etudiant)
head(nb_etudiant_par_cours)

# Jumeler les informations en une table
data_liens_cours <- data.frame(nb_coll_par_cours,nb_etudiant_par_cours)

# Calculer le nombre de collaboration par étudiant pour chaque cours
coll_par_etudiant <- round(data_liens_cours$nb_coll_cours / data_liens_cours$nb_etudiants, digits=0)
data_liens_cours <- data.frame(data_liens_cours$cours,coll_par_etudiant)
colnames(data_liens_cours) <- c("cours", "coll_par_etudiant")

########################################
# Troisième partie: 
# Nombre de coequipier différents selon le contexte du cours
########################################
# Nombre de coequipiers par etudiant en présentiel
sql_requete_coequipier_p <- "
  SELECT  MIN(nb_coequipier) AS nb_minimal_coequipier, 
          ROUND(AVG(nb_coequipier)) AS nb_moyen_coequipier,
          MAX(nb_coequipier) AS nb_maximal_coequipier
  FROM(
    SELECT etudiant1, COUNT(etudiant2) AS nb_coequipier
    FROM (
      SELECT DISTINCT etudiant1, etudiant2
      FROM (
        SELECT etudiant1, etudiant2, distance
        FROM collaborations
        INNER JOIN cours ON collaborations.cours = cours.sigle
        WHERE distance = 0
      )
    ORDER BY etudiant1
    )
  GROUP BY etudiant1
  )
;"
coequipier_p <- dbGetQuery(con,sql_requete_coequipier_p)
head(coequipier_p)

# Nombre de coequipiers différents par etudiant à distance
sql_requete_coequipier_d <- "
  SELECT  MIN(nb_coequipier) AS nb_minimal_coequipier, 
          ROUND(AVG(nb_coequipier)) AS nb_moyen_coequipier,
          MAX(nb_coequipier) AS nb_maximal_coequipier
  FROM(
    SELECT etudiant1, COUNT(etudiant2) AS nb_coequipier
    FROM (
      SELECT DISTINCT etudiant1, etudiant2
      FROM (
        SELECT etudiant1, etudiant2, distance
        FROM collaborations
        INNER JOIN cours ON collaborations.cours = cours.sigle
        WHERE distance = 1
      )
    ORDER BY etudiant1
    )
  GROUP BY etudiant1
  )
;"
coequipier_d <- dbGetQuery(con,sql_requete_coequipier_d)
head(coequipier_d)

# Creation de la table pour le nb de coequipier
data_coequipier_presence <- data.frame(distance=0,coequipier_p)
data_coequipier_distance <- data.frame(distance=1,coequipier_d)
data_coequipier <- rbind(data_coequipier_presence, data_coequipier_distance)

########################################
# Quatrième partie: 
# Données pour la figure du réseau avec igraph
########################################
# Nombre de collaborations par couple d'étudiants dont les 2 étudiants suivent le cours BIO500
sql_requete_reseau_bio500 <- "
  SELECT DISTINCT c.etudiant1, c.etudiant2, 
      (SELECT count(*) FROM collaborations co 
        WHERE co.etudiant1 = c.etudiant1 
        AND co.etudiant2 = c.etudiant2) AS nombre_collaborations
    FROM collaborations AS c, noeuds AS n1, noeuds AS n2
    WHERE c.etudiant1 = n1.nom_prenom
    AND c.etudiant2 = n2.nom_prenom
    AND n1.bio500 = 1
    AND n2.bio500 = 1
;"
data_reseau_bio500 <- dbGetQuery(con,sql_requete_reseau_bio500)
head(data_reseau_bio500)

########################################

# Sauvegarder les informations des requêtes
save(list = c("data_avant_covid", "data_apres_covid", "data_liens_cours", "data_reseau_bio500"), file = "donnees_pour_figures.Rdata")
save("data_coequipier", file="donnees_pour_tableau.Rdata")

# Déconnection de la base de données
dbDisconnect(con)
