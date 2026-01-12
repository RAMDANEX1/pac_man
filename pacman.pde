// variables globales du jeu
Game game;
Menu menu;
boolean inMenu;

// fonction de demarrage de processing
// appellé une seule fois au lancement
void setup() {
  size(900, 950, P2D);  // taille fenetre
  println("=== DEMARRAGE PAC-MAN ===");
  
  // on commence par le menu
  menu = new Menu();
  inMenu = true;
  
  // le jeu sera cree quand on clique sur jouer sinon ya rien hehe 
  game = null;
  
  frameRate(60);  // 60 fps ca suffit largement ( et c'est plus facile a gerer )(et c'est suffisant pour votre ecran)
  println("=== MENU INITIALISÉ ===");
}

// boucle principale - 60 fois par seconde
// le coeur du jeu qui bat sans arret
void draw() {
  if (inMenu) {
    menu.update();
    menu.drawIt();
  } else {
    if (game != null) {
      // check si le joueur veut revenir au menu
      if (game.shouldReturnToMenu()) {
        inMenu = true;
        menu.reset();
        game = null;
        return;
      }
      
      game.update();
      game.drawIt();
    }
  }
}

// gestion des touches du clavier
void keyPressed() {
  if (inMenu) {
    // verif etat avant
    boolean wasSelectingDifficulty = menu.selectingDifficulty;
    
    menu.handleKey(key);
    
    // si difficulte selectionnee
    if (key == '\n' || key == '\r') {
      if (wasSelectingDifficulty && menu.selectingDifficulty) {
        // Démarrer le jeu avec la difficulté sélectionnée
        int difficulty = menu.selectedDifficulty;
        println("=== DÉMARRAGE DU JEU (Difficulté: " + difficulty + ") ===");
        game = new Game(difficulty);
        inMenu = false;
        println("=== JEU INITIALISÉ ===");
      }
    }
  } else {
    if (game != null) {
      // ESC = pause
      if (key == ESC) {
        game.togglePause();
        key = 0;
      } else if (game.paused && (key == '\n' || key == '\r')) {
        // menu pause ENTREE
        if (game.pauseMenuOption == 1) {
          // Option "MENU PRINCIPAL" sélectionnée
          inMenu = true;
          menu.reset();
          game = null; // Libérer le jeu
          return; // Ne pas appeler handleKey sur null
        }
        // Si option 0 (REPRENDRE), c'est géré dans game.handleKey
      }
      
      game.handleKey(key);
    }
  }
}

void mousePressed() { // pour utilisation future si besoin (on sait jamais)
}

