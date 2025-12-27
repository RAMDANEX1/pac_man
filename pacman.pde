Game game;

void setup() { // Initialisation du jeu
  size(900, 950, P2D);
  println("=== DÉMARRAGE DU JEU PAC-MAN ===");
  game = new Game();
  frameRate(60);
  println("=== JEU INITIALISÉ ===");
}

void draw() {
  game.update();
  game.drawIt();
}

void keyPressed() {
  game.handleKey(key); // Pass the pressed key to the game handler
}

void mousePressed() { // For future use
}
