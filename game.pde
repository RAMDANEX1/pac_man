// ===== CLASSE GAME : GESTIONNAIRE PRINCIPAL DU JEU =====
class Game 
{
  Board _board;              // Le plateau de jeu
  Hero _hero;                // Pac-Man
  Ghost[] _ghosts;           // Tableau de fantômes
  
  String _levelName;         // Nom du niveau actuel
  int _score;                // Score du joueur
  int _lives;                // Vies restantes
  int _totalDots;            // Nombre total de gommes au départ
  int _dotsEaten;            // Nombre de gommes mangées
  
  boolean _gameOver;         // Partie terminée ?
  boolean _levelComplete;    // Niveau complété ?
  
  // Constructeur : initialise le jeu
  Game() {
    _board = null;
    _hero = null;
    _ghosts = new Ghost[GHOST_COUNT];
    _score = 0;
    _lives = INITIAL_LIVES;
    _gameOver = false;
    _levelComplete = false;
    _dotsEaten = 0;
    
    // Charger le niveau depuis le fichier
    initializeBoard();
    
    // Créer Pac-Man à sa position de départ
    initializeHero();
    
    // Créer les fantômes
    initializeGhosts();
    
    // Compter les gommes
    if (_board != null) {
      _totalDots = _board.countTotalDots();
    }
  }
  
  // Initialise le plateau de jeu depuis un fichier
  void initializeBoard() {
    PVector boardPosition = new PVector(BOARD_OFFSET_X, BOARD_OFFSET_Y);
    
    // Essayer de charger depuis le fichier
    String levelPath = "levels/level1.txt";
    _board = new Board(boardPosition, CELL_SIZE, levelPath);
    
    // Ajuster la taille de la fenêtre si nécessaire (optionnel)
    // surface.setSize(_board._nbCellsX * CELL_SIZE + 100, _board._nbCellsY * CELL_SIZE + 150);
  }
  
  // Initialise Pac-Man
  void initializeHero() {
    if (_board != null) {
      // Trouver la position 'P' dans le fichier
      PVector startPos = _board.findStartPosition("levels/level1.txt");
      _hero = new Hero(_board, (int)startPos.x, (int)startPos.y);
    }
  }
  
  // Initialise les 4 fantômes avec des positions et délais différents
  void initializeGhosts() {
    if (_board == null) return;
    
    // La boîte des fantômes est sur la ligne avec beaucoup de V (ligne 11 du fichier = y=10)
    // Ligne: VVVVVVVVxVVVVVxVVVVVVVV
    // Les positions V centrales sont x=9, 10, 11, 12, 13
    int ghostBoxY = 10;  // Ligne avec les V
    
    // Tous les fantômes commencent dans la boîte centrale
    // Blinky (rouge) - au centre, sort immédiatement
    _ghosts[0] = new Ghost(_board, 11, ghostBoxY, COLOR_GHOST_RED, "Blinky", 0);
    
    // Pinky (rose) - à gauche du centre, sort après 2 secondes
    _ghosts[1] = new Ghost(_board, 10, ghostBoxY, COLOR_GHOST_PINK, "Pinky", GHOST_RELEASE_DELAY);
    
    // Inky (cyan) - à droite du centre, sort après 4 secondes
    _ghosts[2] = new Ghost(_board, 12, ghostBoxY, COLOR_GHOST_CYAN, "Inky", GHOST_RELEASE_DELAY * 2);
    
    // Clyde (orange) - plus à gauche, sort après 6 secondes
    _ghosts[3] = new Ghost(_board, 9, ghostBoxY, COLOR_GHOST_ORANGE, "Clyde", GHOST_RELEASE_DELAY * 3);
  }
  
  // Mise à jour du jeu (appelée à chaque frame)
  void update() {
    if (_gameOver || _levelComplete) return;
    
    // Mettre à jour Pac-Man
    if (_hero != null && _board != null) {
      _hero.update(_board);
      
      // Vérifier si une gomme a été mangée
      checkDotEaten();
    }
    
    // Mettre à jour les fantômes
    for (int i = 0; i < _ghosts.length; i++) {
      if (_ghosts[i] != null) {
        _ghosts[i].update(_hero);
        
        // Vérifier les collisions avec Pac-Man
        checkGhostCollision(_ghosts[i]);
      }
    }
    
    // Vérifier si le niveau est terminé
    if (_dotsEaten >= _totalDots) {
      _levelComplete = true;
    }
  }
  
  // Vérifie si Pac-Man a mangé une gomme et met à jour le score
  void checkDotEaten() {
    TypeCell currentCell = _board.getCellType(_hero.getCellX(), _hero.getCellY());
    
    // Vérifier si on est centré sur la cellule
    PVector cellCenter = _board.getCellCenter(_hero.getCellX(), _hero.getCellY());
    float distToCenter = PVector.dist(_hero._position, cellCenter);
    
    if (distToCenter < _board._cellSize * 0.3) {
      if (currentCell == TypeCell.DOT) {
        _board.setCellType(_hero.getCellX(), _hero.getCellY(), TypeCell.EMPTY);
        _score += SCORE_DOT;
        _dotsEaten++;
      } else if (currentCell == TypeCell.SUPER_DOT) {
        _board.setCellType(_hero.getCellX(), _hero.getCellY(), TypeCell.EMPTY);
        _score += SCORE_SUPER_DOT;
        _dotsEaten++;
        
        // Effrayer tous les fantômes
        for (Ghost ghost : _ghosts) {
          if (ghost != null) {
            ghost.scare();
          }
        }
      }
    }
  }
  
  // Vérifie la collision avec un fantôme
  void checkGhostCollision(Ghost ghost) {
    if (ghost.collidesWith(_hero)) {
      if (ghost.isScared()) {
        // Manger le fantôme
        _score += SCORE_GHOST;
        ghost.reset();
      } else {
        // Perdre une vie
        loseLife();
      }
    }
  }
  
  // Perd une vie
  void loseLife() {
    _lives--;
    
    if (_lives <= 0) {
      _gameOver = true;
    } else {
      // Réinitialiser les positions
      resetPositions();
    }
  }
  
  // Réinitialise les positions après une mort
  void resetPositions() {
    if (_hero != null) {
      PVector startPos = _board.findStartPosition("levels/level1.txt");
      _hero = new Hero(_board, (int)startPos.x, (int)startPos.y);
    }
    
    for (Ghost ghost : _ghosts) {
      if (ghost != null) {
        ghost.reset();
      }
    }
  }
  
  // Affichage du jeu
  void drawIt() {
    background(COLOR_BG);
    
    // Afficher le titre du jeu
    drawHeader();
    
    // Afficher le plateau
    if (_board != null) {
      _board.drawIt();
    }
    
    // Afficher les fantômes
    for (int i = 0; i < _ghosts.length; i++) {
      if (_ghosts[i] != null) {
        _ghosts[i].drawIt(i);
      }
    }
    
    // Afficher Pac-Man
    if (_hero != null) {
      _hero.drawIt();
    }
    
    // Afficher le score et les informations
    drawGameInfo();
    
    // Afficher les messages de fin
    if (_gameOver) {
      drawGameOver();
    } else if (_levelComplete) {
      drawLevelComplete();
    }
  }
  
  // Affiche l'en-tête du jeu
  void drawHeader() {
    fill(COLOR_TEXT);
    textAlign(CENTER);
    textSize(32);
    text("PAC-MAN", width/2, 50);
  }
  
  // Affiche les informations de jeu (score, vies, gommes)
  void drawGameInfo() {
    fill(COLOR_TEXT);
    textAlign(LEFT);
    textSize(20);
    text("SCORE: " + _score, BOARD_OFFSET_X, BOARD_OFFSET_Y - 30);
    
    // Afficher les vies
    text("VIES: " + _lives, BOARD_OFFSET_X + 250, BOARD_OFFSET_Y - 30);
    
    // Afficher les gommes restantes
    int dotsLeft = _totalDots - _dotsEaten;
    text("GOMMES: " + dotsLeft, BOARD_OFFSET_X + 450, BOARD_OFFSET_Y - 30);
  }
  
  // Affiche "GAME OVER"
  void drawGameOver() {
    fill(COLOR_TEXT);
    textAlign(CENTER);
    textSize(48);
    text("GAME OVER", width/2, height/2);
    textSize(24);
    text("Score: " + _score, width/2, height/2 + 50);
    text("Appuyez sur R pour recommencer", width/2, height/2 + 90);
  }
  
  // Affiche "NIVEAU TERMINE"
  void drawLevelComplete() {
    fill(COLOR_TEXT);
    textAlign(CENTER);
    textSize(48);
    text("NIVEAU TERMINE!", width/2, height/2);
    textSize(24);
    text("Score: " + _score, width/2, height/2 + 50);
    text("Appuyez sur R pour recommencer", width/2, height/2 + 90);
  }
  
  // Gestion des touches clavier
  void handleKey(int k) {
    if (_hero == null) return;
    
    // Recommencer si Game Over ou Level Complete
    if ((_gameOver || _levelComplete) && (k == 'r' || k == 'R')) {
      // Réinitialiser le jeu
      _score = 0;
      _lives = INITIAL_LIVES;
      _gameOver = false;
      _levelComplete = false;
      _dotsEaten = 0;
      
      initializeBoard();
      initializeHero();
      initializeGhosts();
      
      if (_board != null) {
        _totalDots = _board.countTotalDots();
      }
      return;
    }
    
    if (_gameOver || _levelComplete) return;
    
    // Déplacements avec les flèches ou ZQSD
    if (k == CODED) {
      if (keyCode == UP) {
        _hero.launchMove(new PVector(0, -1));
      } else if (keyCode == DOWN) {
        _hero.launchMove(new PVector(0, 1));
      } else if (keyCode == LEFT) {
        _hero.launchMove(new PVector(-1, 0));
      } else if (keyCode == RIGHT) {
        _hero.launchMove(new PVector(1, 0));
      }
    } else {
      // Support ZQSD (clavier AZERTY)
      if (k == 'z' || k == 'Z') {
        _hero.launchMove(new PVector(0, -1));
      } else if (k == 's' || k == 'S') {
        _hero.launchMove(new PVector(0, 1));
      } else if (k == 'q' || k == 'Q') {
        _hero.launchMove(new PVector(-1, 0));
      } else if (k == 'd' || k == 'D') {
        _hero.launchMove(new PVector(1, 0));
      }
      // Support WASD (clavier QWERTY)
      else if (k == 'w' || k == 'W') {
        _hero.launchMove(new PVector(0, -1));
      } else if (k == 'a' || k == 'A') {
        _hero.launchMove(new PVector(-1, 0));
      }
      // Touche pour activer/désactiver le debug (appuie sur 'X')
      else if (k == 'x' || k == 'X') {
        // Toggle debug mode
        println("Pour activer le mode debug, change DEBUG_SPRITES = true dans constants.pde");
      }
    }
  }
}
