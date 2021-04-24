library(RSQLite)

# Connection à la base de données
con <- dbConnect(SQLite(), dbname="./reseau.db")

# Supprimer les tables si elles existent
dbSendQuery(con, "DROP TABLE IF EXISTS collaborations;")
dbSendQuery(con, "DROP TABLE IF EXISTS cours;")
dbSendQuery(con, "DROP TABLE IF EXISTS noeuds;")

# Création de la table noeuds
create_table_noeuds <- "CREATE TABLE noeuds (
  nom_prenom VARCHAR(100) NOT NULL,
  annee_debut INTEGER,
  session_debut CHAR(1),
  programme VARCHAR(50),
  coop BOOL,
  bio500 BOOL,
  PRIMARY KEY (nom_prenom)
);"
dbSendQuery(con, create_table_noeuds)

# Création de la table cours
create_table_cours <- "CREATE TABLE cours (
  sigle CHAR(6) NOT NULL,
  credits INTEGER,
  obligatoire BOOL,
  laboratoire BOOL,
  distance BOOL,
  groupes BOOL,
  libre BOOL,
  PRIMARY KEY (sigle)
);"
dbSendQuery(con, create_table_cours)

# Création de la table collaborations
create_table_collaborations <- "CREATE TABLE collaborations (
  etudiant1 VARCHAR(100) NOT NULL,
  etudiant2 VARCHAR(100) NOT NULL,
  cours CHAR(6) NOT NULL,
  date CHAR(3) NOT NULL,
  PRIMARY KEY (etudiant1, etudiant2, cours, date),
  FOREIGN KEY (etudiant1) REFERENCES noeuds(nom_prenom),
  FOREIGN KEY (etudiant2) REFERENCES noeuds(nom_prenom),
  FOREIGN KEY (cours) REFERENCES cours(sigle)
);"
dbSendQuery(con, create_table_collaborations)

# Liste des tables
dbListTables(con)

# Déconnection de la base de données
dbDisconnect(con)
