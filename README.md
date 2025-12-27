# 🎮 PAC-MAN - Projet Universitaire Processing

## 📋 Description
Recréation complète du jeu Pac-Man en Processing, développé dans le cadre d'un projet universitaire.
Code 100% original, pensé et développé étape par étape.

## ✅ Fonctionnalités Implémentées

### ✨ Étape 1 : Plateau de jeu
- Classe Board avec système de grille 2D
- Affichage des murs, gommes et super-gommes
- Animation pulsante des super-gommes

### ✨ Étape 2 : Pac-Man
- Déplacement fluide pixel par pixel
- Système de buffer de direction (anticipation des virages)
- Animation de la bouche (ouverture/fermeture)
- Rotation automatique selon la direction
- Détection de collisions avec les murs
- Contrôles multiples : Flèches + ZQSD (AZERTY) + WASD (QWERTY)

### ✨ Étape 3 : Système de score
- Score fonctionnel : 10 pts/gomme, 50 pts/super-gomme
- Compteur de gommes mangées / total
- Système de vies (3 au départ)
- Détection de fin de niveau (toutes gommes mangées)
- Game Over et écran de victoire

### ✨ Étape 4 : Chargement de niveaux
- Lecture de fichiers .txt depuis `levels/`
- Format : `x` (mur), `o` (gomme), `O` (super-gomme), `V` (vide), `P` (Pac-Man)
- Détection automatique de la position de départ
- Dimensions dynamiques du plateau

### ✨ Étape 5 : Fantômes avec IA
- 4 fantômes : Blinky (rouge), Pinky (rose), Inky (cyan), Clyde (orange)
- Sortie progressive (délais différents)
- IA avec poursuites et mouvements aléatoires
- Mode "effrayé" après super-gomme (bleus + lents)
- Collision Pac-Man/Fantômes : perte de vie ou capture
- 200 points par fantôme mangé

## 🎮 Contrôles

| Touche | Action |
|--------|--------|
| ⬆️⬇️⬅️➡️ | Déplacer Pac-Man (Flèches) |
| Z Q S D | Déplacer Pac-Man (AZERTY) |
| W A S D | Déplacer Pac-Man (QWERTY) |
| R | Recommencer après Game Over |

## 📁 Architecture du Projet

```
pac_man/
├── pacman.pde          # Fichier principal (setup/draw)
├── constants.pde       # Constantes globales
├── board.pde           # Classe Board (plateau)
├── hero.pde            # Classe Hero (Pac-Man)
├── ghost.pde           # Classe Ghost (fantômes)
├── game.pde            # Gestionnaire principal
├── menu.pde            # Menu pause (à implémenter)
├── data/               # Images et ressources
└── levels/             # Fichiers de niveaux
    └── level1.txt      # Niveau 1
```

## 🎨 Points Originaux

✅ **Labyrinthe personnalisé** : Format texte flexible  
✅ **IA fantômes** : Mélange de poursuite (70%) et aléatoire (30%)  
✅ **Animations fluides** : Bouche, super-gommes pulsantes  
✅ **Système de buffer** : Direction anticipée aux intersections  
✅ **Code modulaire** : Classes séparées, commentées, testables  

## 🚀 Prochaines Étapes Optionnelles

- [ ] Menu pause (recommencer, sauvegarder, charger, scores, quitter)
- [ ] Système de sauvegarde/chargement de parties
- [ ] Meilleurs scores persistants
- [ ] Niveaux multiples
- [ ] Sons et musique
- [ ] Animations plus avancées
- [ ] Power-ups supplémentaires
- [ ] IA fantômes améliorée

## 🛠️ Technologies

- **Processing 4.x**
- **Langage** : Processing (Java simplifié)

## 📝 Notes de Développement

Ce projet a été développé de manière **100% originale**, sans copier de code existant.
Chaque étape a été pensée, documentée et testée individuellement.

---

**Développé avec 💛 pour le projet universitaire Pac-Man**
