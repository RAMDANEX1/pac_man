# 🎮 Menu Pac-Man

## 📋 Description
Système de menu complet avec écran de démarrage, navigation et instructions.

## ✨ Fonctionnalités

### Écran Principal
- **Titre animé** "PAC-MAN" en jaune
- **Animation Pac-Man** : Pac-Man traverse l'écran en mangeant des gommes
- **3 Options** :
  1. 🎮 **JOUER** : Lance le jeu
  2. 📖 **INSTRUCTIONS** : Affiche les règles
  3. 🚪 **QUITTER** : Ferme l'application

### Navigation
- **↑↓** ou **Flèches Haut/Bas** : Naviguer entre les options
- **ENTRÉE** : Sélectionner une option
- **ESC** : Retourner au menu depuis le jeu ou les instructions

### Écran Instructions
Affiche :
- 🎮 **Contrôles** : Comment jouer (ZQSD ou flèches)
- 🎯 **Objectif** : But du jeu
- 👻 **Fantômes** : Comportement de chaque fantôme
  - 🔴 Blinky : Suit directement
  - 🌸 Pinky : Anticipe
  - 🔵 Inky : Imprévisible
  - 🟠 Clyde : Alterne
- ⭐ **Système de points** : Scores des gommes et fantômes

## 🎨 Design

### Couleurs
- **Jaune** (#FFFF00) : Titre et sélection
- **Blanc** (#FFFFFF) : Options non sélectionnées
- **Orange** (#FFB897) : Détails et gommes
- **Gris** (#888888) : Aide en bas d'écran

### Animation
- Pac-Man animé qui traverse l'écran de gauche à droite
- Bouche qui s'ouvre et se ferme
- Gommes devant Pac-Man qui donnent l'impression qu'il les mange

### Indicateurs Visuels
- **►** et **◄** : Encadrent l'option sélectionnée
- Taille de texte augmentée pour l'option active
- Mise en évidence par la couleur

## 🔧 Fonctionnement Technique

### Fichiers Modifiés
1. **menu.pde** : Classe Menu complète
2. **pacman.pde** : Intégration du menu dans la boucle principale

### Variables d'État
```java
boolean inMenu;        // true = dans le menu, false = dans le jeu
Menu menu;             // Instance du menu
Game game;             // Instance du jeu (null si pas encore démarré)
```

### Flux du Programme
1. **Démarrage** → Menu principal
2. **Navigation** → Sélection avec ↑↓
3. **Sélection JOUER** → Création du jeu, passage à inMenu=false
4. **Dans le jeu** → ESC retourne au menu
5. **Sélection INSTRUCTIONS** → Affiche les règles
6. **Depuis instructions** → ESC retourne au menu
7. **Sélection QUITTER** → Ferme l'application

## 🎮 Utilisation

### Au Démarrage
1. Le jeu s'ouvre sur le menu principal
2. Utiliser ↑↓ pour naviguer
3. Appuyer sur ENTRÉE pour sélectionner

### Pour Jouer
1. Sélectionner "JOUER"
2. Appuyer sur ENTRÉE
3. Le jeu démarre immédiatement

### Retour au Menu
- Pendant le jeu, appuyer sur **ESC**
- Le menu se réinitialise à l'option "JOUER"

### Consultation des Instructions
1. Sélectionner "INSTRUCTIONS"
2. Lire les règles
3. Appuyer sur **ESC** pour retourner

## 🚀 Améliorations Possibles

- [ ] Ajouter un tableau des meilleurs scores
- [ ] Sélection de niveau de difficulté
- [ ] Effets sonores pour la navigation
- [ ] Animation de transition entre menu et jeu
- [ ] Sauvegarde des préférences
- [ ] Mode 2 joueurs
- [ ] Personnalisation des couleurs

## 📊 Code Structure

### Classe Menu
```java
class Menu {
  int _selectedOption;           // Option actuelle (0-2)
  boolean _animatePacman;        // Animation active
  float _pacmanX;                // Position Pac-Man
  String[] _menuOptions;         // Liste des options
  boolean _showingInstructions;  // Mode instructions
  
  void update();                 // Mise à jour animation
  void drawIt();                 // Affichage
  void handleKey(int k);         // Gestion clavier
  void executeOption();          // Exécution option
  void reset();                  // Réinitialisation
}
```

### Intégration dans pacman.pde
```java
void draw() {
  if (inMenu) {
    menu.update();
    menu.drawIt();
  } else {
    game.update();
    game.drawIt();
  }
}
```

---

**Créé le** : 31 décembre 2025  
**État** : ✅ Fonctionnel et testé  
**Version** : 1.0
