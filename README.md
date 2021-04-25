# Projet BIO500 - Equipe 3LCW
Pour l'exécution des fichiers R, il faut les exécuter dans l'ordre, soit:
* 1_creation_BD.R
* 2_injections_BD.R
* 3_requetes_BD.R
* 4_figures.R

Il est à noter que l'exécution du script #3 créera des fichiers stockant les données des requêtes, 
qui seront chargées au début du script #4 pour la création des figures. 
De plus, les figures sont générées en fichiers PDF, qui seront utilisées pour le rapport en LateX.
Le tableau, pour sa part, est directement généré en fichier LateX. Par contre, celui-ci n'est pas utilisé pour
le rapport car nous désirions une mise en forme différente.

Voici les fichiers générés par les scripts:
| Fichier | Description |
| :--- | :--- |
| reseau.db | Contient la base de données |
| donnees_pour_figures.Rdata | Données obtenues des requêtes, utilisées pour générer les figures |
| donnees_pour_tableau.Rdata | Données obtenues des requêtes, utilisées pour générer le tableau |
| figure_reseau_bio500.pdf | Figure 1 |
| figure_collaborations_etudiant.pdf | Figure 2 |
| figure_avant_apres_covid.pdf | Figure 3 |
| tableau_coequipier_latex.tex | Tableau |

Voici les fichiers du rapport final:
| Fichier | Description |
| :--- | :--- |
| code_source_rapport_projet_bio500.tex | Code LateX pour générer le rapport |
| biblio_projet_bio500.bib | Bibliographie LateX pour le rapport |
| Rapport_Projet_BIO500.pdf | Rapport final en version PDF |
