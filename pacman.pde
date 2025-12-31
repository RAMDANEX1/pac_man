Game game;
Menu menu;
boolean inMenu;

void setup() { // Initialisation du jeu
  size(900, 950, P2D);
  println("=== DÉMARRAGE DU JEU PAC-MAN ===");
  
  // Créer le menu d'abord
  menu = new Menu();
  inMenu = true;
  
  // Le jeu sera créé quand l'utilisateur choisit "JOUER"
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
    menu.handleKey(key);
    
    // Si l'utilisateur a sélectionné "JOUER"
    if (key == '\n' || key == '\r') {
      if (menu.getSelectedOption() == 0 && !menu.isShowingInstructions()) {
        // Démarrer le jeu
        println("=== DÉMARRAGE DU JEU ===");
        game = new Game();
        inMenu = false;
        println("=== JEU INITIALISÉ ===");
      }
    }
  } else {
    if (game != null) {
      // Touche ESC pour mettre en pause
      if (key == ESC) {
        game.togglePause();
        key = 0; // Empêcher la fermeture de l'application
      } else if (game.isPaused() && (key == '\n' || key == '\r')) {
        // Dans le menu pause, ENTRÉE est pressée
        if (game.getPauseMenuOption() == 1) {
          // Option "MENU PRINCIPAL" sélectionnée
          inMenu = true;
          menu.reset();
          game = null; // Libérer le jeu
        }
        // Si option 0 (REPRENDRE), c'est géré dans game.handleKey
      }
      
      game.handleKey(key);
    }
  }
}

void mousePressed() { // For future use
}
