// Classe Game - gère la partie
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
  boolean _paused;           // Jeu en pause ?
  int _pauseMenuOption;      // Option sélectionnée dans le menu pause (0=Reprendre, 1=Menu)
  
  Bonus _bonus;              // Bonus/fruit
  int _ghostCombo;           // Nombre de fantômes mangés pendant la super-gomme
  boolean _extraLifeGiven;   // Vie bonus à 10 000 points donnée
  
  // High Scores
  HighScores _highScores;
  boolean _enteringName;     // En train d'entrer le nom
  String _playerName;        // Nom du joueur
  int _cherriesCollected;    // Nombre de cerises mangées
  
  // Animation Game Over
  int _gameOverTimer;        // Timer pour l'animation
  int _gameOverOpt;   // Option sélectionnée (0=Rejouer, 1=Menu, 2=Quitter)
  boolean _returnToMenu;     // Flag pour retourner au menu principal
  
  // Difficulté
  int _difficulty;           // 0=EASY, 1=MEDIUM, 2=HARD
  DifficultySettings _diffSettings;
  
  // Constructeur : initialise le jeu
  Game(int difficulty) {
    _board = null;
    _hero = null;
    _ghosts = new Ghost[GHOST_COUNT];
    _score = 0;
    _difficulty = difficulty;
    _diffSettings = getDifficultySettings(difficulty);
    _lives = _diffSettings.lives;
    _gameOver = false;
    _levelComplete = false;
    _paused = false;
    _pauseMenuOption = 0;
    _dotsEaten = 0;
    _ghostCombo = 0;
    _extraLifeGiven = false;
    _gameOverTimer = 0;
    _gameOverOpt = 0;
    _returnToMenu = false;
    
    _highScores = new HighScores();
    _enteringName = false;
    _playerName = "";
    _cherriesCollected = 0;
    
    // Charger le niveau depuis le fichier
    initializeBoard();
    
    // Créer Pac-Man à sa position de départ
    initializeHero();
    
    // Créer les fantômes
    initializeGhosts();
    
    // Créer le bonus (apparaitra au centre sous la cage)
    if (_board != null) {
      _bonus = new Bonus(_board, 11, 12, "cherry");  // Position sous la cage des fantômes
    }
    
    // Compter les gommes
    if (_board != null) {
      _totalDots = _board.countTotalDots();
    }
  }
  
  // Initialise le plateau
  void initializeBoard() {
    PVector boardPosition = new PVector(BOARD_OFFSET_X, BOARD_OFFSET_Y);
    
    String levelPath = "levels/level1.txt";
    _board = new Board(boardPosition, CELL_SIZE, levelPath);
  }
  
  // Initialise Pac-Man
  void initializeHero() {
    if (_board != null) {
      PVector startPos = _board.findStartPosition("levels/level1.txt");
      _hero = new Hero(_board, (int)startPos.x, (int)startPos.y);
    }
  }
  
  void initializeGhosts() {
    if (_board == null) return;
    
    int ghostBoxY = 10;
    int baseDelay = _diffSettings.releaseDelay;
    
    // Blinky (rouge)
    _ghosts[0] = new Ghost(_board, 11, 8, COLOR_GHOST_RED, "Blinky", 0);
    _ghosts[0]._speed = _diffSettings.ghostSpeed;
    
    // Pinky (rose)
    _ghosts[1] = new Ghost(_board, 11, ghostBoxY, COLOR_GHOST_PINK, "Pinky", (int)(baseDelay * 0.5));
    _ghosts[1]._speed = _diffSettings.ghostSpeed;
    
    // Inky (bleu)  
    _ghosts[2] = new Ghost(_board, 10, ghostBoxY, COLOR_GHOST_CYAN, "Inky", baseDelay);
    _ghosts[2]._speed = _diffSettings.ghostSpeed;
    
    // Clyde (orange)
    _ghosts[3] = new Ghost(_board, 12, ghostBoxY, COLOR_GHOST_ORANGE, "Clyde", (int)(baseDelay * 1.5));
    _ghosts[3]._speed = _diffSettings.ghostSpeed;
  }
  
  void update() {
    if (_levelComplete || _paused) return;
    
    if (_gameOver) {
      _gameOverTimer++;
      return;
    }
    
    // Si Pac-Man est en train de mourir, attendre la fin de l'animation
    if (_hero != null && _hero._dying) {
      _hero.update(_board);  // Continuer l'animation
      
      // Si l'animation est terminée, réinitialiser
      if (_hero.deathAnimationComplete()) {
        loseLife();
      }
      return;  // Ne pas mettre à jour le reste du jeu
    }
    
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
    
    // Mettre à jour le bonus
    if (_bonus != null) {
      _bonus.update(_dotsEaten, _totalDots);
      
      // Vérifier si Pac-Man touche le bonus
      if (_bonus.collidesWith(_hero)) {
        int bonusScore = _bonus.collect();
        if (bonusScore > 0) {
          _score += bonusScore;
          println("Bonus collecté ! +" + bonusScore + " points");
        }
      }
    }
    
    // Vérifier si le joueur a atteint le seuil pour gagner une vie (selon la difficulté)
    if (_score >= _diffSettings.extraLifeScore && !_extraLifeGiven) {
      _lives++;
      _extraLifeGiven = true;
      println("Vie bonus gagnée ! Score: " + _score);
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
        
        // Effrayer tous les fantômes avec la durée selon la difficulté
        _ghostCombo = 0;  // Réinitialiser le combo
        for (Ghost ghost : _ghosts) {
          if (ghost != null) {
            ghost.scare(_diffSettings.scaredDuration, 
                       _diffSettings.ghostScaredSpeed, 
                       _diffSettings.ghostScaredSpeedClyde);
          }
        }
      }
    }
  }
  
  // Vérifie la collision avec un fantôme
  void checkGhostCollision(Ghost ghost) {
    if (ghost.collidesWith(_hero)) {
      if (ghost.isScared()) {
        // Pac-Man mange le fantôme effrayé -> transformer en yeux
        _ghostCombo++;
        int ghostScore = SCORE_GHOST * (int)pow(2, _ghostCombo - 1); // 200, 400, 800, 1600
        _score += ghostScore;
        println("Fantôme mangé ! Combo x" + _ghostCombo + " = +" + ghostScore + " points");
        
        ghost._eyes = true;
        ghost._scared = false;
        ghost._scaredTimer = 0;
      } else if (!_hero._dying) {  // Seulement si pas déjà en train de mourir
        // Déclencher l'animation de mort
        _ghostCombo = 0;  // Réinitialiser le combo
        _hero.die();
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
  
  // Réinitialise les positions après une mort de Pac-Man
  void resetPositions() {
    if (_hero != null) {
      PVector startPos = _board.findStartPosition("levels/level1.txt");
      _hero = new Hero(_board, (int)startPos.x, (int)startPos.y);
    }
    
    // Réinitialiser les fantômes à leurs positions de départ
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
        _ghosts[i].drawIt();
      }
    }
    
    // Afficher le bonus
    if (_bonus != null) {
      _bonus.drawIt();
    }
    
    // Afficher Pac-Man
    if (_hero != null) {
      _hero.drawIt();
    }
    
    // Afficher le score et les informations
    drawGameInfo();
    
    // DEBUG - Afficher la légende des trajectoires
    if (DEBUG_GHOST_PATH) {
      drawPathLegend();
    }
    
    // Afficher les messages de fin
    if (_gameOver) {
      drawGameOver();
    } else if (_levelComplete) {
      drawLevelComplete();
    } else if (_paused) {
      drawPauseMenu();
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
  
  // DEBUG - Affiche la légende des trajectoires des fantômes
  void drawPathLegend() {
    int legendX = BOARD_OFFSET_X + _board._nbCellsX * CELL_SIZE + 50;
    int legendY = BOARD_OFFSET_Y + 50;
    
    fill(COLOR_TEXT);
    textAlign(LEFT);
    textSize(18);
    text("TRAJECTOIRES:", legendX, legendY);
    
    // Légende pour chaque fantôme
    String[] names = {"Blinky", "Pinky", "Inky", "Clyde"};
    color[] colors = {COLOR_GHOST_RED, COLOR_GHOST_PINK, COLOR_GHOST_CYAN, COLOR_GHOST_ORANGE};
    
    for (int i = 0; i < names.length; i++) {
      int y = legendY + 30 + i * 40;
      
      // Dessiner une ligne de démonstration
      stroke(colors[i]);
      strokeWeight(3);
      line(legendX, y, legendX + 30, y);
      
      // Nom du fantôme
      noStroke();
      fill(colors[i]);
      text(names[i], legendX + 40, y + 5);
    }
    
    // Instructions
    fill(COLOR_TEXT);
    textSize(14);
    text("Les lignes montrent", legendX, legendY + 200);
    text("le chemin parcouru", legendX, legendY + 220);
    text("par chaque fantôme.", legendX, legendY + 240);
  }
  
  // Affiche "GAME OVER" avec animation
  void drawGameOver() {
    // Overlay semi-transparent qui s'assombrit progressivement
    float overlayAlpha = min(_gameOverTimer * 2, 200);
    fill(0, 0, 0, overlayAlpha);
    rect(0, 0, width, height);
    
    // Attendre un peu avant d'afficher le texte
    if (_gameOverTimer < 30) return;
    
    // Effet de pulsation sur le titre
    float pulseScale = 1 + sin(_gameOverTimer * 0.1) * 0.05;
    
    pushMatrix();
    translate(width/2, height/2 - 120);
    scale(pulseScale);
    
    // Titre "GAME OVER" avec effet
    fill(255, 50, 50);  // Rouge
    textAlign(CENTER);
    textSize(64);
    text("GAME OVER", 0, 0);
    
    popMatrix();
    
    // Attendre encore un peu pour le reste
    if (_gameOverTimer < 60) return;
    
    // Score final
    fill(COLOR_TEXT);
    textSize(32);
    text("Score Final: " + _score, width/2, height/2 - 20);
    
    // Séparateur
    stroke(255, 255, 255, 100);
    strokeWeight(2);
    line(width/2 - 200, height/2 + 20, width/2 + 200, height/2 + 20);
    noStroke();
    
    // Menu d'options
    String[] options = {"REJOUER", "MENU PRINCIPAL", "QUITTER"};
    
    for (int i = 0; i < options.length; i++) {
      float yPos = height/2 + 80 + i * 60;
      
      // Surbrillance de l'option sélectionnée
      if (i == _gameOverOpt) {
        // Rectangle de sélection avec animation
        float pulseSize = sin(_gameOverTimer * 0.15) * 5;
        fill(255, 255, 0, 100);
        rectMode(CENTER);
        rect(width/2, yPos, 280 + pulseSize, 50, 10);
        rectMode(CORNER);
        
        // Texte en jaune
        fill(255, 255, 0);
        textSize(32);
      } else {
        // Texte en blanc
        fill(200);
        textSize(28);
      }
      
      text(options[i], width/2, yPos + 5);
    }
    
    // Instructions en bas
    if (_gameOverTimer > 90) {
      float alpha = min((_gameOverTimer - 90) * 3, 255);
      fill(150, 150, 150, alpha);
      textSize(18);
      text("↑ ↓ pour naviguer  |  ENTRÉE pour sélectionner", width/2, height - 60);
    }
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
  
  // Affiche le menu pause
  void drawPauseMenu() {
    // Overlay semi-transparent
    fill(0, 0, 0, 180);
    rect(0, 0, width, height);
    
    // Titre
    fill(COLOR_TEXT);
    textAlign(CENTER);
    textSize(56);
    text("PAUSE", width/2, height/2 - 100);
    
    // Options du menu pause
    String[] options = {"REPRENDRE", "MENU PRINCIPAL"};
    int startY = height/2;
    int spacing = 80;
    
    for (int i = 0; i < options.length; i++) {
      int y = startY + i * spacing;
      
      // Highlight de l'option sélectionnée
      if (i == _pauseMenuOption) {
        fill(#FFFF00);
        textSize(40);
        // Flèches indicatrices
        text("►", width/2 - 180, y);
        text("◄", width/2 + 180, y);
      } else {
        fill(#FFFFFF);
        textSize(32);
      }
      
      text(options[i], width/2, y);
    }
    
    // Instructions en bas
    fill(#888888);
    textSize(18);
    text("↑↓ : Naviguer  |  ENTRÉE : Sélectionner", width/2, height - 50);
  }
  
  // Gestion des touches clavier
  void handleKey(int k) {
    if (_hero == null) return;
    
    // Gérer le menu de game over
    if (_gameOver) {
      handleGameOverMenu(k);
      return;
    }
    
    // Gérer le menu pause
    if (_paused) {
      handlePauseMenu(k);
      return;
    }
    
    // Touche ECHAP pour mettre en pause
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
  
  // Gestion des touches dans le menu pause
  void handlePauseMenu(int k) {
    if (k == CODED) {
      if (keyCode == UP) {
        _pauseMenuOption--;
        if (_pauseMenuOption < 0) {
          _pauseMenuOption = 1;
        }
      } else if (keyCode == DOWN) {
        _pauseMenuOption++;
        if (_pauseMenuOption > 1) {
          _pauseMenuOption = 0;
        }
      }
    } else if (k == '\n' || k == '\r') {
      // ENTRÉE pressée
      if (_pauseMenuOption == 0) {
        // Reprendre le jeu
        _paused = false;
      }
      // Si option 1 (Menu Principal), ce sera géré dans pacman.pde
    }
  }
  
  // Gestion des touches dans le menu de game over
  void handleGameOverMenu(int k) {
    if (k == CODED) {
      if (keyCode == UP) {
        _gameOverOpt = (_gameOverOpt - 1 + 3) % 3;
      } else if (keyCode == DOWN) {
        _gameOverOpt = (_gameOverOpt + 1) % 3;
      }
    } else if (k == '\n' || k == '\r') {  // Touche Entrée
      if (_gameOverOpt == 0) {
        // Rejouer avec la même difficulté
        _score = 0;
        _lives = _diffSettings.lives;
        _gameOver = false;
        _gameOverTimer = 0;
        _gameOverOpt = 0;
        _levelComplete = false;
        _dotsEaten = 0;
        _ghostCombo = 0;
        _extraLifeGiven = false;
        
        initializeBoard();
        initializeHero();
        initializeGhosts();
        
        if (_board != null) {
          _totalDots = _board.countTotalDots();
          _bonus = new Bonus(_board, 11, 12, "cherry");
        }
      } else if (_gameOverOpt == 1) {
        // Retour au menu principal
        _returnToMenu = true;
      } else if (_gameOverOpt == 2) {
        // Quitter
        exit();
      }
    }
  }
  
  // Active/désactive la pause
  void togglePause() {
    if (!_gameOver && !_levelComplete) {
      _paused = !_paused;
      if (_paused) {
        _pauseMenuOption = 0; // Réinitialiser à "REPRENDRE"
      }
    }
  }
  
  // Retourne true si on doit retourner au menu principal
  boolean shouldReturnToMenu() {
    return _returnToMenu;
  }
}
