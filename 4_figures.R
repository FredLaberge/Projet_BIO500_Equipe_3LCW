library(igraph)
library(knitr)

# Charger les donnees pour construire les figures
load("donnees_pour_figures.Rdata")
load("donnees_pour_tableau.Rdata")

###################################################
#Creation du graphique compose pour comparer nombre de collaborations avant et apres covid-19
###################################################

# Générer le pdf de la figure
pdf("figure_avant_apres_covid.pdf", width=13, height=7)

#Joindre les deux graphiques ensembles
par(mfrow=c(1,2))

#Creer l'histogramme : collaborations avant covid des membres du cours de BIO500 seulement
hist(data_avant_covid$nb_collaborations,
                          main = "Collaborations des membres du cours de BIO500 avant Covid-19",
                          axes = FALSE,
                          xlab = "Nombre de collaborations",
                          xlim = c(0,35),
                          ylab = "Nombre d'étudiants",
                          ylim = c(0,15),
                          col = "dodgerblue4",
                          border = "white"
)
par(las=1)
axis(side=1, at=seq(0,35,5), pos = 0)
axis(side=2, at=seq(0,15,3))
abline(h=c(0,3,6,9,12,15), lty=1, col="black")

#Creer l'histogramme : collaborations apres covid des membres du cours de BIO500 seulement
hist(data_apres_covid$nb_collaborations,
                          main = "Collaborations des membres du cours de BIO500 apres Covid-19",
                          axes = FALSE,
                          xlab = "Nombre de collaborations",
                          xlim = c(0,35),
                          ylab = "Nombre d'étudiants",
                          ylim = c(0,15),
                          col = "dodgerblue4",
                          border = "white"
)
par(las=1)
axis(side=1, at=seq(0,35,5), pos = 0)
axis(side=2, at=seq(0,15,3))
abline(h=c(0,3,6,9,12,15), lty=1, col="black")

# Terminer le fichier de la figure
dev.off()

###################################################
# Création du graphique nombre de collaborations par etudiant par cours
###################################################

#Mettre en ordre les donnees
data_liens_cours <- data_liens_cours[order(data_liens_cours$coll_par_etudiant, decreasing =FALSE),]

# Générer le pdf de la figure
pdf("figure_collaborations_etudiant.pdf")

#Creer le diagramme a bandes
par(mar = c(1,5,5,1))
par(cex.axis = 0.9)
barplot(height=data_liens_cours$coll_par_etudiant,names.arg = data_liens_cours$cours, 
        axes = FALSE,
        horiz=TRUE,
        space=1,
        col = "deeppink",
        cex.names=0.70, 
        las=1,
        border = "white"
)
axis(3)
abline(v=c(0,1,2,3,4,5,6,7), lty=1)

# Terminer le fichier de la figure
dev.off()

###################################################
# Création du tableau du nombre de coequipiers
###################################################
# Créer le tableau
tableau_coequipier <- data.frame(data_coequipier$nb_minimal_coequipier, data_coequipier$nb_moyen_coequipier, data_coequipier$nb_maximal_coequipier)

# Appliquer les noms de lignes et colonnes 
row.names(tableau_coequipier) <- c("Présentiel", "Distance")
colnames(tableau_coequipier) <- c("Minimum", "Moyenne", "Maximum")

# Exporter le tableau pour LateX
tableau_coequipier_latex <- kable(tableau_coequipier, format="latex")
writeLines(tableau_coequipier_latex, con="tableau_coequipier_latex", sep="\n", useBytes=FALSE)

###################################################
# Création de la figure du réseau avec igraph
###################################################
# Déterminer les noms des étudiants du cours BIO500
nom_etudiants_reseau_bio500 <- sort(unique(data_reseau_bio500[, 1]))

# Initialiser la matrice d'ajacence
matrice_adjacence_bio500 <- matrix(0, nrow=length(nom_etudiants_reseau_bio500), ncol=length(nom_etudiants_reseau_bio500))

# Ajouter les noms des étudiants dans la matrice d'adjacence
rownames(matrice_adjacence_bio500) <- nom_etudiants_reseau_bio500
colnames(matrice_adjacence_bio500) <- nom_etudiants_reseau_bio500

# Ajouter les valeurs d'adjacences à la matrice
for(i in 1:nrow(data_reseau_bio500)) {
  matrice_adjacence_bio500[data_reseau_bio500[i,1], data_reseau_bio500[i,2]] <- data_reseau_bio500[i,3]
}

# Création de la figure
graphe_adjacence_bio500 <- simplify(graph.adjacency(matrice_adjacence_bio500))

# Appliquer les couleurs des noeuds selon le nombre de collaborations
degre_adjacence <- apply(matrice_adjacence_bio500, 1, sum) #+ apply(matrice_adjacence_bio500, 2, sum)
rk <- rank(-degre_adjacence)
couleurs <- heat.colors(length(nom_etudiants_reseau_bio500))
V(graphe_adjacence_bio500)$color <- couleurs[rk]

# Générer le pdf de la figure
pdf("figure_reseau_bio500.pdf")
plot(graphe_adjacence_bio500, vertex.label=NA, edge.arrow.mode=0, layout=layout.kamada.kawai(graphe_adjacence_bio500), vertex.size=7)

# Ajouter la légende
legend(x=0.6, y=-0.5, legend=c(rep("",10),max(degre_adjacence),rep("",length(couleurs)-2),min(degre_adjacence)), fill=c(rep(NA,10),couleurs), y.intersp=0.1, border=NA, box.col=NA, title="Nombre de\ncollaborations")

# Terminer le fichier de la figure
dev.off()

###################################################
