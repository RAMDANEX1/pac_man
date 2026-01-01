Game game;
Menu menu;
boolean inMenu;

void setup() {
  size(900, 950, P2D);
  println("=== DEMARRAGE PAC-MAN ===");
  
  // menu au debut
  menu = new Menu();
  inMenu = true;
  
  // jeu cree apres choix JOUER
  game = null;
  
  frameRate(60);
  println("=== MENU INITIALISÉ ===");
}

void draw() {
  if (inMenu) {
    menu.update();
    menu.drawIt();
  } else {
    if (game != null) {
      // Vérifier si on doit retourner au menu
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

void keyPressed() {
  if (inMenu) {
    // verif etat avant
    boolean wasSelectingDifficulty = menu._selectingDifficulty;
    
    menu.handleKey(key);
    
    // si difficulte selectionnee
    if (key == '\n' || key == '\r') {
      if (wasSelectingDifficulty && menu._selectingDifficulty) {
        // Démarrer le jeu avec la difficulté sélectionnée
        int difficulty = menu._selectedDifficulty;
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
      } else if (game._paused && (key == '\n' || key == '\r')) {
        // menu pause ENTREE
        if (game._pauseMenuOption == 1) {
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

void mousePressed() { // For future use
}
