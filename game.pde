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
    _ghosts[0]._normalSpeed = _diffSettings.ghostSpeed;  // Mémoriser la vitesse de difficulté
    
    // Pinky (rose)
    _ghosts[1] = new Ghost(_board, 11, ghostBoxY, COLOR_GHOST_PINK, "Pinky", (int)(baseDelay * 0.5));
    _ghosts[1]._speed = _diffSettings.ghostSpeed;
    _ghosts[1]._normalSpeed = _diffSettings.ghostSpeed;  // Mémoriser la vitesse de difficulté
    
    // Inky (bleu)  
    _ghosts[2] = new Ghost(_board, 10, ghostBoxY, COLOR_GHOST_CYAN, "Inky", baseDelay);
    _ghosts[2]._speed = _diffSettings.ghostSpeed;
    _ghosts[2]._normalSpeed = _diffSettings.ghostSpeed;  // Mémoriser la vitesse de difficulté
    
    // Clyde (orange)
    _ghosts[3] = new Ghost(_board, 12, ghostBoxY, COLOR_GHOST_ORANGE, "Clyde", (int)(baseDelay * 1.5));
    _ghosts[3]._speed = _diffSettings.ghostSpeed;
    _ghosts[3]._normalSpeed = _diffSettings.ghostSpeed;  // Mémoriser la vitesse de difficulté
  }
  
  void update() {
    if (_levelComplete || _paused) return;
    
    if (_gameOver) {
      _gameOverTimer++;
      // Vérifier si c'est un high score et si on n'est pas déjà en train d'entrer le nom
      if (_gameOverTimer == 60 && !_enteringName) {
        // Toujours demander le nom (game over ou niveau terminé)
        _enteringName = true;
        _playerName = "";
      }
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
        String bonusType = _bonus.getType();
        int bonusScore = _bonus.collect();
        
        // Si c'est une cerise, donner une vie bonus
        if (bonusType.equals("cherry") && bonusScore > 0) {
          _lives++;
          _cherriesCollected++;
          println("Cerise collectée ! +1 vie");
        } else if (bonusScore > 0) {
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
      _gameOver = true;  // Traiter comme game over pour demander le nom
      _gameOverTimer = 0;
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
      _gameOverTimer = 0;  // Réinitialiser le timer
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
    fill(color(0, 100, 255)); // Bleu vif
    textAlign(CENTER);
    textSize(48); // Plus gros
    // Effet gras : dessiner le texte plusieurs fois avec léger décalage
    text("PAC-MAN", width/2, 50);
    text("PAC-MAN", width/2 + 1, 50);
    text("PAC-MAN", width/2, 50 + 1);
    text("PAC-MAN", width/2 + 1, 50 + 1);
  }
  
  // Affiche les informations de jeu (score, vies, gommes)
  void drawGameInfo() {
    fill(color(0, 150, 255)); // Bleu clair
    textAlign(LEFT);
    textSize(26); // Plus gros
    // Effet gras pour SCORE
    String scoreText = "SCORE: " + _score;
    text(scoreText, BOARD_OFFSET_X, BOARD_OFFSET_Y - 30);
    text(scoreText, BOARD_OFFSET_X + 1, BOARD_OFFSET_Y - 30);
    text(scoreText, BOARD_OFFSET_X, BOARD_OFFSET_Y - 29);
    
    // Afficher les gommes restantes avec effet gras
    int dotsLeft = _totalDots - _dotsEaten;
    String gommesText = "GOMMES: " + dotsLeft;
    text(gommesText, BOARD_OFFSET_X + 450, BOARD_OFFSET_Y - 30);
    text(gommesText, BOARD_OFFSET_X + 451, BOARD_OFFSET_Y - 30);
    text(gommesText, BOARD_OFFSET_X + 450, BOARD_OFFSET_Y - 29);
    
    // Afficher les vies et cerises à droite de la map (style Pac-Man original)
    int rightX = BOARD_OFFSET_X + _board._nbCellsX * CELL_SIZE + 30;
    int startY = BOARD_OFFSET_Y + 400;  // Plus bas pour éviter la légende des trajectoires
    
    // Titre
    fill(255, 255, 0);
    textSize(24);
    text("VIES", rightX + 50, startY);
    
    // Dessiner les vies horizontalement (symboles Pac-Man)
    fill(255, 255, 0);
    for (int i = 0; i < _lives; i++) {
      int x = rightX + i * 40;
      int y = startY + 40;
      // Dessiner un petit Pac-Man
      arc(x + 15, y, 30, 30, radians(30), radians(330));
    }
    
    // Cerises collectées (en dessous des vies)
    fill(255, 255, 0);
    textSize(24);
    text("CERISES", rightX + 30, startY + 100);
    
    // Dessiner les cerises horizontalement
    for (int i = 0; i < _cherriesCollected; i++) {
      int x = rightX + i * 40;
      int y = startY + 140;
      // Dessiner une cerise
      fill(255, 0, 0);
      ellipse(x + 10, y, 20, 20);
      ellipse(x + 25, y + 5, 20, 20);
      stroke(0, 150, 0);
      strokeWeight(2);
      line(x + 17, y - 10, x + 17, y - 2);
      noStroke();
    }
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
    // Si on entre le nom, afficher l'interface de saisie
    if (_enteringName) {
      drawNameEntry();
      return;
    }
    
    // Fond noir
    background(0);
    
    // Attendre un peu avant d'afficher le texte
    if (_gameOverTimer < 30) return;
    
    // Effet de pulsation sur le titre
    float pulseScale = 1 + sin(_gameOverTimer * 0.1) * 0.05;
    
    pushMatrix();
    translate(width/2, 150);
    scale(pulseScale);
    
    // Titre "GAME OVER" avec effet
    fill(255, 50, 50);  // Rouge
    textAlign(CENTER);
    textSize(72);
    text("GAME OVER", 0, 0);
    
    popMatrix();
    
    // Attendre encore un peu pour le reste
    if (_gameOverTimer < 60) return;
    
    // Sous-titre avec score final
    fill(255, 184, 151);
    textSize(24);
    text("Score Final: " + _score, width/2, 210);
    
    // Menu d'options
    String[] options = {"REJOUER", "MENU PRINCIPAL", "QUITTER"};
    int startY = 400;
    int spacing = 80;
    
    for (int i = 0; i < options.length; i++) {
      int y = startY + i * spacing;
      
      // Surbrillance de l'option sélectionnée
      if (i == _gameOverOpt) {
        // Rectangle de sélection
        fill(255, 255, 0, 40);
        rectMode(CENTER);
        rect(width/2, y - 12, 300, 50, 8);
        rectMode(CORNER);
        
        // Texte en jaune avec flèches
        fill(255, 255, 0);
        textSize(40);
        text(">", width/2 - 140, y);
        text("<", width/2 + 140, y);
      } else {
        fill(255, 255, 255);
        textSize(32);
      }
      
      text(options[i], width/2, y);
    }
    
    // Instructions en bas
    if (_gameOverTimer > 90) {
      float alpha = min((_gameOverTimer - 90) * 3, 255);
      fill(150, 150, 150, alpha);
      textSize(18);
      text("↑ ↓ pour naviguer  |  ENTRÉE pour sélectionner", width/2, height - 60);
    }
  }
  
  // Interface pour entrer le nom du joueur
  void drawNameEntry() {
    fill(0, 0, 0, 220);
    rect(0, 0, width, height);
    
    fill(255, 255, 0);
    textAlign(CENTER);
    textSize(48);
    text("NOUVEAU RECORD !", width/2, height/2 - 150);
    
    fill(255);
    textSize(32);
    text("Score: " + _score, width/2, height/2 - 80);
    
    textSize(24);
    text("Entrez votre nom:", width/2, height/2 - 20);
    
    // Cadre pour le nom
    stroke(255, 255, 0);
    strokeWeight(3);
    noFill();
    rect(width/2 - 150, height/2 + 10, 300, 50, 10);
    noStroke();
    
    // Afficher le nom en cours de saisie
    fill(255, 255, 0);
    textSize(32);
    String displayName = _playerName;
    if (frameCount % 30 < 15) {
      displayName += "_";
    }
    text(displayName, width/2, height/2 + 45);
    
    // Instructions
    fill(150);
    textSize(18);
    text("Appuyez sur ENTRÉE pour valider", width/2, height/2 + 120);
    text("(Maximum 15 caractères)", width/2, height/2 + 145);
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
    // Fond noir
    background(0);
    
    // Titre principal
    fill(255, 255, 0);
    textAlign(CENTER);
    textSize(72);
    text("PAUSE", width/2, 150);
    
    // Sous-titre
    fill(255, 184, 151);
    textSize(24);
    text("Jeu en pause", width/2, 200);
    
    // Options du menu pause
    String[] options = {"REPRENDRE", "MENU PRINCIPAL"};
    int startY = 400;
    int spacing = 80;
    
    for (int i = 0; i < options.length; i++) {
      int y = startY + i * spacing;
      
      // Highlight de l'option sélectionnée
      if (i == _pauseMenuOption) {
        // Rectangle de sélection
        fill(255, 255, 0, 40);
        rectMode(CENTER);
        rect(width/2, y - 12, 300, 50, 8);
        rectMode(CORNER);
        
        // Texte en jaune avec flèches
        fill(255, 255, 0);
        textSize(40);
        text(">", width/2 - 140, y);
        text("<", width/2 + 140, y);
      } else {
        fill(255, 255, 255);
        textSize(32);
      }
      
      text(options[i], width/2, y);
    }
    
    // Instructions en bas
    fill(150, 150, 150);
    textSize(18);
    text("↑↓ : Naviguer  |  ENTRÉE : Sélectionner  |  P : Reprendre", width/2, height - 60);
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
    // Si on entre le nom, gérer la saisie
    if (_enteringName) {
      if (k == '\n' || k == '\r') {
        // Valider le nom
        if (_playerName.length() > 0) {
          _highScores.addScore(_playerName, _score);
          _enteringName = false;
        }
      } else if (k == 8 || k == 127) {
        // Backspace
        if (_playerName.length() > 0) {
          _playerName = _playerName.substring(0, _playerName.length() - 1);
        }
      } else if (_playerName.length() < 15 && k >= 32 && k <= 126) {
        // Ajouter le caractère
        _playerName += (char)k;
      }
      return;
    }
    
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
        _cherriesCollected = 0;
        _enteringName = false;
        _playerName = "";
        
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
