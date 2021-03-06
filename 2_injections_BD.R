library(RSQLite)

# Connection � la base de donn�es
con <- dbConnect(SQLite(), dbname="./reseau.db")

########################################
# Lecture des fichiers CSV
########################################
# On commence par notre �quipe car les noms de colonnes sont les m�me quand dans notre base de donn�es
# �quipe 3LCW
noeuds_3LCW <- read.csv(file="Donnees/Dominique/3LCW_noeuds.csv", header=TRUE, sep=",", fileEncoding="UTF-8-BOM")
cours_3LCW <- read.csv(file="Donnees/Dominique/3LCW_cours.csv", header=TRUE, sep=",", fileEncoding="UTF-8-BOM")
collaborations_3LCW <- read.csv(file="Donnees/Dominique/3LCW_collaborations.csv", header=TRUE, sep=",", fileEncoding="UTF-8-BOM")

# �quipe EGM
noeuds_EquipeEGM <- read.csv(file="Donnees/Dominique/EquipeEGM_noeuds.csv", header=TRUE, sep=",", fileEncoding="UTF-8-BOM")
cours_EquipeEGM <- read.csv(file="Donnees/Dominique/EquipeEGM_cours.csv", header=TRUE, sep=",", fileEncoding="UTF-8-BOM")
collaborations_EquipeEGM <- read.csv(file="Donnees/Dominique/EquipeEGM_collaborations.csv", header=TRUE, sep=",", fileEncoding="UTF-8-BOM")
# Assurer que les noms de colonnes sont les m�mes
names(noeuds_EquipeEGM) <- names(noeuds_3LCW)
names(cours_EquipeEGM) <- names(cours_3LCW)
names(collaborations_EquipeEGM) <- names(collaborations_3LCW)

# �quipe Spikee
noeuds_Spikee <- read.csv(file="Donnees/Dominique/Spikee_noeuds.csv", header=TRUE, sep=";", fileEncoding="UTF-8-BOM")
cours_Spikee <- read.csv(file="Donnees/Dominique/Spikee_cours.csv", header=TRUE, sep=";", fileEncoding="UTF-8-BOM")
collaborations_Spikee <- read.csv(file="Donnees/Dominique/Spikee_collaborations.csv", header=TRUE, sep=";", fileEncoding="UTF-8-BOM")
# Assurer que les noms de colonnes sont les m�mes
names(noeuds_Spikee) <- names(noeuds_3LCW)
names(cours_Spikee) <- names(cours_3LCW)
names(collaborations_Spikee) <- names(collaborations_3LCW)

# �quipe Supernanas
noeuds_Supernanas <- read.csv(file="Donnees/Dominique/Supernanas_noeuds.csv", header=TRUE, sep=";", fileEncoding="UTF-8-BOM")
cours_Supernanas <- read.csv(file="Donnees/Dominique/Supernanas_cours.csv", header=TRUE, sep=";", fileEncoding="UTF-8-BOM")
collaborations_Supernanas <- read.csv(file="Donnees/Dominique/Supernanas_collaborations.csv", header=TRUE, sep=";", fileEncoding="UTF-8-BOM")
# Assurer que les noms de colonnes sont les m�mes
names(noeuds_Supernanas) <- names(noeuds_3LCW)
names(cours_Supernanas) <- names(cours_3LCW)
names(collaborations_Supernanas) <- names(collaborations_3LCW)

# �quipe Teamdefeu2
noeuds_Teamdefeu2 <- read.csv(file="Donnees/Dominique/Teamdefeu2_noeuds.csv", header=TRUE, sep=";", fileEncoding="UTF-8-BOM")
cours_Teamdefeu2 <- read.csv(file="Donnees/Dominique/Teamdefeu2_cours.csv", header=TRUE, sep=";", fileEncoding="UTF-8-BOM")
collaborations_Teamdefeu2 <- read.csv(file="Donnees/Dominique/Teamdefeu2_collaborations.csv", header=TRUE, sep=";", fileEncoding="UTF-8-BOM")
# Assurer que les noms de colonnes sont les m�mes
names(noeuds_Teamdefeu2) <- names(noeuds_3LCW)
names(cours_Teamdefeu2) <- names(cours_3LCW)
names(collaborations_Teamdefeu2) <- names(collaborations_3LCW)

########################################

# Fusionner les tables de toutes les �quipes
bd_noeuds <- do.call("rbind", list(noeuds_3LCW, noeuds_EquipeEGM, noeuds_Spikee, noeuds_Supernanas, noeuds_Teamdefeu2))
bd_cours <- do.call("rbind", list(cours_3LCW, cours_EquipeEGM, cours_Spikee, cours_Supernanas, cours_Teamdefeu2))
bd_collaborations <- do.call("rbind", list(collaborations_3LCW, collaborations_EquipeEGM, collaborations_Spikee, collaborations_Supernanas, collaborations_Teamdefeu2))

# Retirer les espaces blanc au d�but et � la fin des champs pour les 3 tables
for(i in 1:ncol(bd_noeuds)) {
  bd_noeuds[ , i] <- trimws(bd_noeuds[ , i])
}
for(i in 1:ncol(bd_cours)) {
  bd_cours[ , i] <- trimws(bd_cours[ , i])
}
for(i in 1:ncol(bd_collaborations)) {
  bd_collaborations[ , i] <- trimws(bd_collaborations[ , i])
}

# Mettre en ordre les noeuds selon quelques informations pour que la fonction unique
#     conserve les doublons ayant le plus d'informations car ils sont les premiers rencontr�s
bd_noeuds <- bd_noeuds[order(bd_noeuds$annee_debut, bd_noeuds$programme), ]

# Supprimer les doublons
bd_noeuds <- bd_noeuds[row.names(unique(bd_noeuds["nom_prenom"])),]
bd_cours <- bd_cours[row.names(unique(bd_cours["sigle"])),]
bd_collaborations <- unique(bd_collaborations)

# Injections des donn�es dans la BD
dbWriteTable(con, append=TRUE, name="noeuds", value=bd_noeuds, row.names=FALSE)
dbWriteTable(con, append=TRUE, name="cours", value=bd_cours, row.names=FALSE)
dbWriteTable(con, append=TRUE, name="collaborations", value=bd_collaborations, row.names=FALSE)

# D�connection de la base de donn�es
dbDisconnect(con)
