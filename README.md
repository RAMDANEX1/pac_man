# PAC-MAN - Projet Processing

## Description du projet
Recréation complete du jeu Pac-Man en utilisant Processing dans le cadre d'un projet universitaire.
Le code a ete developpe entierement de zero, avec une approche progressive et modulaire.

## Fonctionnalités implementees

### Plateau de jeu
Le plateau est represente par une grille 2D avec la classe Board. J'ai implemente :
- Systeme de grille avec enum TypeCell (EMPTY, WALL, DOT, SUPER_DOT)
- Affichage graphique des murs (rectangles bleus)
- Rendu des gommes normales (petits cercles blancs - 10 points)
- Rendu des super-gommes avec animation pulsante (gros cercles - 50 points)
- Chargement dynamique depuis fichiers texte dans le dossier levels/

La classe Board gere toute la logique du plateau : detection de collisions, verification des murs, 
comptage des gommes restantes, etc. Le fichier level1.txt definit la structure avec des caracteres 
simples (x=mur, o=gomme, O=super-gomme, P=position depart pacman).

### Personnage Pac-Man (classe Hero)
Implementation complete du personnage jouable :
- Deplacement fluide pixel par pixel (pas seulement case par case)
- Systeme de buffer de direction pour anticiper les virages aux intersections
- Animation de la bouche qui s'ouvre et se ferme pendant le deplacement
- Rotation automatique selon la direction de deplacement (haut/bas/gauche/droite)
- Detection precise des collisions avec les murs
- Teleportation sur les bords (sort d'un cote, reapparait de l'autre)
- Animation de mort progressive quand touche par un fantome
- Support de plusieurs schemas de controle : fleches directionnelles, ZQSD (AZERTY), WASD (QWERTY)

Le systeme de buffer permet de presser une touche avant d'arriver a une intersection et Pac-Man 
tournera automatiquement des qu'il pourra, ce qui rend le jeu plus fluide.

### Systeme de score et vies
Gestion complete du score et de l'etat de la partie :
- Score qui augmente : 10 pts par gomme normale, 50 pts par super-gomme
- Combo de fantomes : 200, 400, 800, 1600 points (double a chaque fois)
- Affichage en temps reel du score, vies restantes, gommes mangees/total
- Systeme de vies (nombre depend de la difficulte choisie)
- Detection automatique de fin de niveau (quand toutes les gommes sont mangees)
- Ecran Game Over avec possibilite de rejouer
- Systeme de high scores persistent (top 5 sauvegarde dans fichier)
- Vie bonus automatique a 10000 points
- Bonus fruits qui apparaissent a intervalles reguliers (cerises, fraises, oranges, etc.)

Le score est affiche en permanence a droite du plateau avec les informations importantes.

### Intelligence Artificielle des fantomes
Implementation de 4 fantomes avec comportements uniques :

**Blinky (rouge)** : Le chasseur agressif
- Sort immediatement de la cage au debut
- Poursuit directement Pac-Man en utilisant l'algorithme de pathfinding
- Vitesse normale, le plus predictible

**Pinky (rose)** : L'embusqueur
- Sort avec un petit delai
- Essaye d'anticiper les mouvements de Pac-Man
- Cible une position en avance sur la direction de Pac-Man
- Strategie d'interception

**Inky (cyan)** : L'imprevisible  
- Sort avec un delai moyen
- Alterne entre poursuite active et patrouille aleatoire
- Utilise un timer pour changer de comportement
- Parfois fuit, parfois attaque

**Clyde (orange)** : Le peureux
- Sort en dernier
- Devient peureux quand trop proche de Pac-Man
- Fuit si distance < 8 cases, sinon poursuit
- Comportement aleatoire par moments

Tous les fantomes utilisent un algorithme de pathfinding (parcours en largeur) pour trouver 
le chemin optimal vers leur cible. En mode "effraye" (apres une super-gomme), ils deviennent 
bleus, ralentissent, et peuvent etre manges par Pac-Man. Quand manges, ils retournent a la 
cage en mode "yeux" (rapides) puis se regenerent.

### Systeme de difficulte
3 niveaux de difficulte implementes :

**FACILE** :
- 5 vies de depart
- Fantomes lents (vitesse 1.2)
- Mode peur long (10 secondes)
- Delai de sortie des fantomes : 3 secondes

**MOYEN** :
- 3 vies de depart  
- Vitesse normale fantomes (1.8)
- Mode peur moyen (7 secondes)
- Delai sortie : 2 secondes

**DIFFICILE** :
- 2 vies seulement
- Fantomes rapides (2.2)
- Mode peur court (5 secondes)
- Sortent rapidement (1 seconde)

Le joueur choisit la difficulte dans le menu principal avant de commencer.

### Interface et menus
Systeme complet de menus :
- Menu principal avec selection difficulte (FACILE/MOYEN/DIFFICILE)
- Ecran d'instructions detaillees (controles, objectifs, fantomes, bonus)
- Menu pause accessible avec ECHAP (reprendre ou retour menu)
- Ecran game over avec saisie du nom pour high scores
- Affichage des top 5 meilleurs scores
- Animations visuelles (Pac-Man et fantomes animes dans le menu)

Le joueur choisit la difficulte dans le menu principal avant de commencer.

### Interface et menus
Systeme complet de menus :
- Menu principal avec selection difficulte (FACILE/MOYEN/DIFFICILE)
- Ecran d'instructions detaillees (controles, objectifs, fantomes, bonus)
- Menu pause accessible avec ECHAP (reprendre ou retour menu)
- Ecran game over avec saisie du nom pour high scores
- Affichage des top 5 meilleurs scores
- Animations visuelles (Pac-Man et fantomes animes dans le menu)

## Controles du jeu

Le jeu supporte plusieurs schemas de controle pour s'adapter a differents claviers :

| Touche | Action |
|--------|--------|
| Fleches directionnelles | Deplacer Pac-Man (haut/bas/gauche/droite) |
| Z Q S D | Deplacer Pac-Man (disposition AZERTY) |
| W A S D | Deplacer Pac-Man (disposition QWERTY) |
| ECHAP | Mettre en pause / Menu pause |
| R | Rejouer apres Game Over |
| ENTREE | Valider dans les menus |
| ESPACE | Valider saisie nom (high scores) |

## Architecture technique du code

Le projet est organise en modules separes pour faciliter la maintenance :

```
pac_man/
├── pacman.pde          # Fichier principal - setup() et draw()
├── constants.pde       # Constantes globales (tailles, couleurs, vitesses)
├── board.pde           # Classe Board - gestion du plateau et niveau
├── hero.pde            # Classe Hero - Pac-Man (deplacement, animation)
├── ghost.pde           # Classe Ghost - fantomes (IA, pathfinding)
├── game.pde            # Classe Game - logique principale du jeu
├── menu.pde            # Classe Menu - interface menus
├── bonus.pde           # Classe Bonus - gestion fruits bonus
├── highscores.pde      # Classe HighScores - sauvegarde scores
├── data/               # Dossier ressources (images, sons)
│   └── scores.txt      # Fichier sauvegarde high scores
└── levels/             # Dossier niveaux
    └── level1.txt      # Fichier niveau 1 (format texte)
```

### Description des classes principales

**Board (board.pde)** :
- Gere la grille 2D du plateau de jeu
- Charge les niveaux depuis fichiers texte
- Methodes : isWall(), getCellType(), setCellType(), getCellCenter()
- Rendu graphique des murs, gommes et super-gommes

**Hero (hero.pde)** :
- Represente Pac-Man
- Variables : position (_pos), direction, vitesse (_vitesse), etat mort (_dying)
- Methodes : move(), tryChangeDirection(), animateMouth(), die()
- Gere le buffer de direction pour anticipation des virages

**Ghost (ghost.pde)** :
- Represente un fantome avec son comportement unique
- Variables : position, vitesse, mode peur (_peur), timer sortie (_timerSortie)
- Methodes : update(), chooseDirection(), trouverChemin() (pathfinding)
- Algorithme de parcours en largeur (BFS) pour trouver chemin optimal

**Game (game.pde)** :
- Gestionnaire principal de la partie en cours
- Coordonne Board, Hero, Ghosts, Bonus
- Gere score, vies, collisions, game over
- Methodes : update(), checkDotEaten(), checkGhostCollision()

**Menu (menu.pde)** :
- Gere tous les ecrans de menu
- Menu principal, instructions, pause, game over
- Navigation avec touches clavier

**Bonus (bonus.pde)** :
- Gere l'apparition des fruits bonus
- Differents types : cerise (100), fraise (300), orange (500), pomme (700), melon (1000), diamant (3000)
- Apparaissent selon progression (nombre gommes mangees)

**HighScores (highscores.pde)** :
- Sauvegarde et charge les meilleurs scores
- Format fichier : "nom,score,difficulte" par ligne
- Top 5 avec filtrage par difficulte

## Details techniques interessants

### Algorithme de pathfinding (BFS)
Les fantomes utilisent un parcours en largeur pour trouver le chemin le plus court vers Pac-Man :
1. File de positions a explorer (queue)
2. Tableau des cellules visitees
3. Reconstruction du chemin depuis la cible
4. Evite les murs et les boucles infinies

Complexite : O(n*m) ou n et m sont les dimensions de la grille.
Avantage : trouve toujours le chemin optimal s'il existe.

### Systeme de buffer de direction
Quand le joueur appuie sur une touche, la direction est stockee dans _nextDir.
A chaque frame, le code verifie si Pac-Man est assez centre sur une cellule et si le 
changement de direction est possible (pas de mur). Si oui, il change de direction 
immediatement. Cela permet de "preparer" un virage avant d'arriver a l'intersection.

### Gestion des collisions
Deux systemes de collision :
1. **Murs** : Verification basee sur la position pixel future avant deplacement
2. **Fantomes** : Distance euclidienne entre centres (< taille minimale)

### Animation et fluidite
- Deplacement pixel par pixel (pas de saut case par case)
- Interpolation pour mouvements fluides
- Animation bouche avec variable _angle qui oscille
- Super-gommes pulsantes avec fonction sin(frameCount)

## Format du fichier niveau

Le fichier level1.txt utilise un format simple :

```
# Niveau 1 - Labyrinthe classique
xxxxxxxxxxxxxxxxxxxxxxx
xoooooooooxooooooooooox
xoxxxoxxxxxoxxxxoxxxxxo
xOxxxoxxxxxoxxxxoxxxxxO
xoxxxoxxxxxoxxxxoxxxxxo
xooooooooooooooooooooox
xoxxxoxoxxxxxxxxoxoxxxo
xoxxxoxoxxxxxxxxoxoxxxo
xoooooxooooxoooooxoooox
xxxxxoxxxxxVxxxxoxxxxxo
xxxxxoxxxxxVxxxxoxxxxxo
VVVVVoVVVVVVVVVVoVVVVVV
xxxxxoxxxxxVxxxxoxxxxxo
xxxxxoxxxxxVxxxxoxxxxxo
xoooooxooooPoooooxoooox
xoxxxoxxxxxoxxxxoxoxxxo
xOoooxoooooooooooxooooO
xxxoxxxxxxxoxxxxxxoxoxxx
xoooooooooxooooooooooox
xxxxxxxxxxxxxxxxxxxxxxx
```

Legende :
- `x` = mur
- `o` = gomme normale (10 points)
- `O` = super-gomme (50 points)
- `V` = case vide (zone cage fantomes)
- `P` = position depart Pac-Man
- espace = case vide

## Defis rencontres et solutions

**Defi 1 : Pathfinding des fantomes**
Probleme : Comment faire suivre intelligemment Pac-Man par les fantomes ?
Solution : Implementation algorithme BFS (parcours en largeur) qui trouve le chemin optimal.
Amelioration : Ajout de comportements varies par fantome pour gameplay interessant.

**Defi 2 : Fluidite des mouvements**
Probleme : Deplacement case par case trop rigide et peu fluide.
Solution : Deplacement pixel par pixel avec detection collision anticipee.
Buffer de direction pour anticiper les virages.

**Defi 3 : Synchronisation vitesses**
Probleme : Vitesses differentes entre Pac-Man et fantomes difficiles a equilibrer.
Solution : Systeme de constantes ajustables + 3 niveaux de difficulte.
Tests multiples pour trouver bon equilibre.

**Defi 4 : Gestion etats fantomes**
Probleme : Fantomes ont plusieurs etats (normal, peur, yeux) a gerer simultanement.
Solution : Variables d'etat booleen (_peur, _eyes) + timers.
Machine a etats simplifiee dans update().

**Defi 5 : Sauvegarde high scores**
Probleme : Persistance des scores entre sessions.
Solution : Fichier texte data/scores.txt avec format simple.
Lecture/ecriture avec loadStrings() et saveStrings().

## Statistiques du projet

- Lignes de code : ~2500 lignes
- Nombre de classes : 7 (Board, Hero, Ghost, Game, Menu, Bonus, HighScores)
- Temps de developpement : plusieurs semaines
- Fichiers .pde : 9 fichiers
- Tests effectues : nombreux pour equilibrage gameplay

## Points forts du projet

✓ Code bien structure et module (separation des responsabilites)
✓ Commentaires detailles pour comprehension
✓ Systeme de difficulte ajustable
✓ IA fantomes variee et interessante
✓ Interface complete (menus, pause, game over)
✓ Sauvegarde high scores persistante
✓ Animations fluides et agrables visuellement
✓ Support plusieurs schemas clavier
✓ Chargement niveaux depuis fichiers externes

## Ameliorations possibles futures

Idees pour etendre le projet :
- [ ] Niveaux multiples avec progression
- [ ] Sons et musique (effets manger gomme, mort, etc.)
- [ ] Power-ups additionnels (vitesse, invisibilite, etc.)
- [ ] Mode deux joueurs cooperatif ou competitif
- [ ] Editeur de niveaux integre
- [ ] Plus d'animations (fantomes plus expressifs)
- [ ] Particules visuelles (explosions, trainee, etc.)
- [ ] Statistiques detaillees (temps partie, taux reussite, etc.)
- [ ] Achievements/trophees
- [ ] Mode histoire avec cinematiques

## Technologies utilisees

**Processing 4.x** - Environnement de developpement
- Langage base sur Java simplifie
- IDE integre avec debogueur
- Fonctions graphiques facilitees
- Gestion evenements clavier/souris

**Structures de donnees** :
- ArrayList pour chemins pathfinding
- Tableaux 2D pour grille plateau
- Enums pour types cellules
- Classes objets pour encapsulation

## Notes de developpement

Ce projet a ete developpe de maniere progressive en suivant une methodologie incrementale :
1. Creation plateau basique
2. Ajout Pac-Man avec controles
3. Implementation systeme score/vies  
4. Ajout fantomes avec IA simple
5. Amelioration IA avec pathfinding
6. Ajout menus et interface
7. Implementation bonus et high scores
8. Tests et equilibrage final

Chaque etape a ete testee individuellement avant de passer a la suivante.
Le code a ete refactorise plusieurs fois pour ameliorer la lisibilite et la maintenabilite.

Toutes les fonctionnalites ont ete implementees de zero sans copie de code existant.
La logique du jeu, les algorithmes et l'interface ont ete concus et realises par moi meme.

---

**Projet realise dans le cadre du cours de programmation orientee objet**
