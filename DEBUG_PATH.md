# 🎮 Debug des Trajectoires des Fantômes

## 📋 Description
Ce système de debug permet de visualiser en temps réel **le chemin complet** que chaque fantôme va suivre pour atteindre sa cible.

## 🎯 Fonctionnalités

### Visualisation des Trajectoires Complètes
- Chaque fantôme affiche une **trajectoire complète** calculée avec pathfinding (BFS)
- La trajectoire montre le **chemin optimal** de sa position actuelle vers sa cible
- Un **marqueur X** indique la cible finale que le fantôme cherche à atteindre
- Les couleurs correspondent aux fantômes :
  - 🔴 **Rouge** : Blinky (cible = position de Pac-Man)
  - 🌸 **Rose** : Pinky (cible = 4 cases devant Pac-Man)
  - 🔵 **Cyan** : Inky (cible = alterne entre suivre et s'éloigner de Pac-Man)
  - 🟠 **Orange** : Clyde (cible = alterne entre suivre Pac-Man et position aléatoire)

### Algorithme de Pathfinding
- Utilise **BFS (Breadth-First Search)** pour calculer le chemin le plus court
- Respecte tous les murs et obstacles
- Recalculé à chaque frame pour s'adapter aux mouvements de Pac-Man
- Les fantômes normaux ne peuvent pas entrer dans la cage
- Les yeux (mode fantôme mangé) peuvent rentrer dans la cage

### États des Fantômes
- **Mode Normal** : Trace avec la couleur du fantôme vers sa cible
- **Mode Effrayé** : Trace bleue vers des cibles aléatoires (fuite)
- **Mode Yeux** : Trace blanche vers la cage (retour après avoir été mangé)

### Indicateurs Visuels
- **Ligne colorée** : Le chemin complet à suivre
- **Points** : Positions clés le long du chemin (tous les 3 points)
- **X avec cercle** : La cible finale que le fantôme cherche à atteindre

## ⚙️ Configuration

### Dans `constants.pde`
```java
final boolean DEBUG_GHOST_PATH = true;    // Activer/désactiver les trajectoires
final int PATH_MAX_POINTS = 100;          // Nombre de points max (historique)
final int PATH_UPDATE_IN(Non utilisé avec le nouveau système BFS)
- **PATH_UPDATE_INTERVAL** : (Non utilisé avec le nouveau système BFS)

**Note** : Le pathfinding calcule automatiquement tous les points nécessaires.

### Paramètres
- **DEBUG_GHOST_PATH** : `true` pour afficher les trajectoires, `false` pour les cacher
- **PATH_MAX_POINTS** : Nombre maximum de points dans l'historique (plus = trajectoire plus longue)
- **PATH_UPDATE_INTERVAL** : Intervalle entre chaque point (3 = un point toutes les 3 frames)

## 🎨 Affichage

### Légende
Une légende s'affiche à droite du plateau montrant :
- Les noms des fan sur le système

### Trajectoires
- Les lignes relient les cellules du chemin calculé
- Les petits cercles (tous les 3 points) montrent les étapes intermédiaires
- Un **X entouré d'un cercle** marque la cible finale
- Les trajectoires sont semi-transparentes pour ne pas gêner le jeu
- Recalculées en temps réel à chaque frame
- Les petits cercles marquent les positions enregistrées
- Les trajectoires sont semi-transparentes pour ne pas gêner le jeu

## 🐛 Utilisation pour le Debug
avant la cible
2. **Mauvais pathfinding** : La trajectoire fait des détours inutiles au lieu du chemin le plus court
3. **Cible incorrecte** : Le X n'est pas là où il devrait être selon la personnalité du fantôme
4. **Comportement erratique** : La trajectoire change constamment de cible
5. **Mode cage** : Vérifier que les fantômes ne peuvent pas cibler l'intérieur de la cage

### Points de Vérification
- ✅ Les fantômes suivent-ils le chemin affiché ?
- ✅ Les trajectoires respectent-elles les murs (pas de lignes à travers les murs) ?
- ✅ La cible (X) correspond-elle à la stratégie du fantôme ?
  - Blinky : X sur Pac-Man
  - Pinky : X 4 cases devant Pac-Man
  - Inky : X qui alterne
  - Clyde : X qui varie
- ✅ Les yeux retournent-ils directement à la cage (X sur la cage)
- ✅ Les fantômes se téléportent-ils correctement sur les bords ?
- ✅ Le retour que chaque fantôme suit bien son chemin** :
   - Le fantôme doit suivre la ligne colorée
   - Si le fantôme ne suit PAS le chemin affiché, il y a un bug dans l'IA
   - Si le chemin traverse les murs, il y a un bug dans le pathfinding
4. **Observer la cible (X)** :
   - Elle doit correspondre à la personnalité du fantôme
   - Elle doit se déplacer avec Pac-Man pour Blinky
   - Elle doit être devant Pac-Man pour Pinky

### Différence entre Chemin Planifié et Chemin Suivi
- **Chemin planifié** (ligne) : Ce que le fantôme VEUT faire
- **Chemin suivi** (mouvement réel) : Ce que le fantôme FAIT réellement
- S'ils ne correspondent pas → bug dans l'IA ou le mouvement

### Ajuster les Paramètres
- **Trajectoire absente ?** → Vérifier `DEBUG_GHOST_PATH = true`
- **Performances lentes ?** → Le BFS est limité à 100 nœuds explorés
- **Chemin incomplet ?** → Lepour stocker le chemin calculé
   - Méthode `updatePath(Hero)` pour calculer le chemin avec BFS
   - Méthode `calculatePath(startX, startY, endX, endY)` pour le pathfinding BFS
   - Méthode `drawPath()` pour afficher les trajectoires avec indicateurs visuels
3. **game.pde** :
   - Méthode `drawPathLegend()` pour afficher la légende

### Algorithme BFS BFS est optimisé et limité à 100 cellules explorées maximum
- **Isolé** : Peut être désactivé en changeant `DEBUG_GHOST_PATH = false`
- **Temps réel** : Recalculé chaque frame pour refléter les changements de position
2. Explore toutes les directions possibles (haut, bas, gauche, droite)
3. Évite les murs et les cellules déjà visitées
4. Continue jusqu'à atteindre la cible ou explorer 100 cellules (limite)
5. Reconstruit le chemin de la cible vers le départ
6. Inverse le chemin pour obtenir départ → cibl
- **Trajectoire trop courte ?** → Augmenter `PATH_MAX_POINTS`
- **Trajectoire trop dense ?** → Augmenter `PATH_UPDATE_INTERVAL`
- **Performance lente ?** → Diminuer `PATH_MAX_POINTS`

## 🔧 Code Modifié
Implémenter A* pour un pathfinding encore plus intelligent
- [ ] Afficher le coût du chemin (nombre d'étapes)
- [ ] Colorer différemment les sections de trajectoire selon la distance à la cible
- [ ] Ajouter des flèches directionnelles le long du chemin
- [ ] Montrer les chemins alternatifs en pointillés

---

**Note** : Ce système montre le chemin PLANIFIÉ par l'IA. Si le fantôme ne suit pas ce chemin, cela indique un bug dans la logique de mouvement
3. **game.pde** :
   - Méthode `drawPathLegend()` pour afficher la légende

### Impact sur les Performances
- **Minimal** : Le système n'affecte pas le gameplay
- **Isolé** : Peut être désactivé en changeant `DEBUG_GHOST_PATH = false`
- **Optimisé** : Limite le nombre de points pour éviter les ralentissements

## 🚀 Prochaines Étapes

### Améliorations Possibles
- [ ] Ajouter un bouton pour activer/désactiver en jeu
- [ ] Afficher la cellule cible de chaque fantôme
- [ ] Colorer différemment les sections de trajectoire (normal/effrayé/yeux)
- [ ] Ajouter des statistiques (distance parcourue, nombre de changements de direction)

---

**Note** : Ce système est conçu pour le debug uniquement et peut être complètement désactivé sans affecter le jeu.
