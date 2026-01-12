// classe principale qui gere toute la partie
// c'etait la partie la plus complexe du projet
class Game 
{
  Board board;
  Hero hero;
  Ghost[] ghosts;
  
  String levelName;         // nom niveau actuel
  int score;                // score joueur
  int lives;                // vies restantes
  int totalDots;            // nb total gommes au depart
  int dotsEaten;            // nb gommes mangees
  
  boolean gameOver;         // partie terminee ?
  boolean levelComplete;    // niveau complete ?
  boolean paused;           // jeu en pause ?
  int pauseMenuOption;      // option selectionnee menu pause (0=Reprendre, 1=Menu)
  
  Bonus bonus;              // bonus/fruit
  int ghostCombo;           // nb fantomes manges pendant super gomme
  boolean extraLifeGiven;   // vie bonus donnee une fois  // cadeau de la maison
  
  // highscores
  HighScores highScores;
  boolean enteringName;     // entrain dentrer nom
  String playerName;        // nom joueur
  int cherriesCollected;    // nb cerises mangees
  
  // animation gameover
  int gameOverTimer;        // timer pour animation
  int gameOverOpt;   // option selectionnee (0=Rejouer, 1=Menu, 2=Quitter)
  boolean returnToMenu;     // flag pour retour menu principal
  
  // difficulte
  int difficulty;           // 0=EAsY, 1=MeDIUM, 2=HARD
  DifficultySettings diffSettings;
  
  // constructeur - initialise tout le jeu
  // beaucoup de variables a initialiser ici
  Game(int diff) {
    board = null;
    hero = null;
    ghosts = new Ghost[GHOST_COUNT];
    score = 0;
    difficulty = diff;
    diffSettings = getDifficultySettings(difficulty);
    lives = diffSettings.lives;
    gameOver = false;
    levelComplete = false;
    paused = false;
    pauseMenuOption = 0;
    dotsEaten = 0;
    ghostCombo = 0;
    extraLifeGiven = false;
    gameOverTimer = 0;
    gameOverOpt = 0;
    returnToMenu = false;
    
    highScores = new HighScores();
    enteringName = false;
    playerName = "";
    cherriesCollected = 0;
    
    // charge niveau depuis fichier
    initializeBoard();
    
    // cree pacman a sa pos de depart
    initializeHero();
    
    // cree fantomes
    initializeGhosts();
    
    // cree bonus (apparaittra au centre sous cage)
    if (board != null) {
      bonus = new Bonus(board, 11, 12, "cherry");  // pos sous cage fantomes
    }
    
    // compte les gommes du board
    if (board != null) {
      totalDots = board.countTotalDots();
    }
  }
  
  // init plateau
  void initializeBoard() {
    PVector boardPosition = new PVector(BOARD_OFFSET_X, BOARD_OFFSET_Y);
    
    String levelPath = "levels/level1.txt";
    board = new Board(boardPosition, CELL_SIZE, levelPath);
  }
  
  // init pacman
  void initializeHero() {
    if (board != null) {
      PVector startPos = board.findStartPosition("levels/level1.txt");
      hero = new Hero(board, (int)startPos.x, (int)startPos.y);
    }
  }
  
  void initializeGhosts() {
    if (board == null) return;
    
    int ghostBoxY = 10;
    int baseDelay = diffSettings.releaseDelay;
    
    // initialisation de mr blinky rouge
    ghosts[0] = new Ghost(board, 11, 8, COLOR_GHOST_RED, "Blinky", 0);
    ghosts[0].speed = diffSettings.ghostSpeed;
    ghosts[0].vitesseNormale = diffSettings.ghostSpeed;  // Mémoriser la vitesse de difficulté
    
    // initialisation de mr pinky rose
    ghosts[1] = new Ghost(board, 11, ghostBoxY, COLOR_GHOST_PINK, "Pinky", (int)(baseDelay * 0.5));
    ghosts[1].speed = diffSettings.ghostSpeed;
    ghosts[1].vitesseNormale = diffSettings.ghostSpeed;  // Mémoriser la vitesse de difficulté
    
    // initialisation de mr inky bleu  
    ghosts[2] = new Ghost(board, 10, ghostBoxY, COLOR_GHOST_CYAN, "Inky", baseDelay);
    ghosts[2].speed = diffSettings.ghostSpeed;
    ghosts[2].vitesseNormale = diffSettings.ghostSpeed;  // Mémoriser la vitesse de difficulté
    
    // initialisation de mr clyde orange
    ghosts[3] = new Ghost(board, 12, ghostBoxY, COLOR_GHOST_ORANGE, "Clyde", (int)(baseDelay * 1.5));
    ghosts[3].speed = diffSettings.ghostSpeed;
    ghosts[3].vitesseNormale = diffSettings.ghostSpeed;  // Mémoriser la vitesse de difficulté
  }
  
  // update principal du jeu appellé a chaque frame
  // gere tout : pacman, fantomes, bonus, colisions etc
  void update() {
    if (paused) return;
    
    if (gameOver) {
      gameOverTimer++;
      // toujours demander le nom
      if (gameOverTimer == 60 && !enteringName) {
        enteringName = true;
        playerName = "";
      }
      return;
    }
    
    if (levelComplete) {
      gameOverTimer++;
      // demander le nom après victoire
      if (gameOverTimer == 120 && !enteringName) {
        enteringName = true;
        playerName = "";
      }
      return;
    }
    
    // Si Pac-Man est en train de mourir, attendre la fin de l'animation
    if (hero != null && hero.dying) {
      hero.update(board);  // Continuer l'animation
      
      // Si l'animation est terminée, réinitialiser
      if (hero.deathAnimationComplete()) {
        loseLife();
      }
      return;  // Ne pas mettre à jour le reste du jeu
    }
    
    // Mettre à jour Pac-Man
    if (hero != null && board != null) {
      hero.update(board);
      
      // Vérifier si une gomme a été mangée
      checkDotEaten();
    }
    
    // Mettre à jour les fantômes
    for (int i = 0; i < ghosts.length; i++) {
      if (ghosts[i] != null) {
        ghosts[i].update(hero);
        
        // Vérifier les collisions avec Pac-Man
        checkGhostCollision(ghosts[i]);
      }
    }
    
    // Mettre à jour le bonus
    if (bonus != null) {
      bonus.update(dotsEaten, totalDots);
      
      // Vérifier si Pac-Man touche le bonus
      if (bonus.collidesWith(hero)) {
        String bonusType = bonus.getType();
        int bonusScore = bonus.collect();
        
        // Si c'est une cerise, donner une vie bonus
        if (bonusType.equals("cherry") && bonusScore > 0) {
          lives++;
          cherriesCollected++;
          println("Cerise collectée ! +1 vie");
        } else if (bonusScore > 0) {
          score += bonusScore;
          println("Bonus collecté ! +" + bonusScore + " points");
        }
      }
    }
    
    // Vérifier si le joueur a atteint le seuil pour gagner une vie (selon la difficulté)
    if (score >= diffSettings.extraLifeScore && !extraLifeGiven) {
      lives++;
      extraLifeGiven = true;
      println("Vie bonus gagnée ! Score: " + score);
    }
    
    // Vérifier si le niveau est terminé
    if (dotsEaten >= totalDots) {
      levelComplete = true;
      gameOverTimer = 0;
    }
  }
  
  // regarde si pacman mange une gomme
  // pacman a toujours faim apparemment haha
  void checkDotEaten() {
    TypeCell currentCell = board.getCellType(hero.getCellX(), hero.getCellY());
    
    // verif centre cellule (sinon bug parfois)
    PVector cellCenter = board.getCellCenter(hero.getCellX(), hero.getCellY());
    float distToCenter = PVector.dist(hero.pos, cellCenter);
    
    if (distToCenter < board.taille * 0.3) {
      if (currentCell == TypeCell.DOT) {
        board.setCellType(hero.getCellX(), hero.getCellY(), TypeCell.EMPTY);
        score += SCORE_DOT;
        dotsEaten++;
      } else if (currentCell == TypeCell.SUPER_DOT) {
        board.setCellType(hero.getCellX(), hero.getCellY(), TypeCell.EMPTY);
        score += SCORE_SUPER_DOT;
        dotsEaten++;
        
        // effraye tous fantomes avec duree selon difficulte
        ghostCombo = 0;  // reinit combo
        for (Ghost ghost : ghosts) {
          if (ghost != null) {
            ghost.scare(diffSettings.scaredDuration, 
                       diffSettings.ghostScaredSpeed, 
                       diffSettings.ghostScaredSpeedClyde);
          }
        }
      }
    }
  }
  
  // quand pacman touche un fantome
  // c'est la ou on decide qui mange qui
  void checkGhostCollision(Ghost ghost) {
    if (ghost.collidesWith(hero)) {
      if (ghost.isScared()) {
        // mange fantome
        ghostCombo++;
        int ghostScore = SCORE_GHOST * (int)pow(2, ghostCombo - 1); // 200, 400, 800, 1600
        score += ghostScore;
        println("Fantome mange ! Combo x" + ghostCombo + " = +" + ghostScore + " points");
        
        ghost.eyes = true;
        ghost.peur = false;
        ghost.timerPeur = 0;
      } else if (!hero.dying) {  // seulement si pas deja entrain de mourir
        // declenche animation mort
        ghostCombo = 0;  // reinit combo
        hero.die();
      }
    }
  }
  
  // Perd une vie oh noooo
  void loseLife() {
    lives--;
    
    if (lives <= 0) {
      gameOver = true; // la fin du jeu 
      gameOverTimer = 0;  // Réinitialiser le timer
    } else {
      // Réinitialiser les positions
      resetPositions();
    }
  }
  
  // Réinitialise les positions après une mort de Pac-Man
  void resetPositions() {
    if (hero != null) {
      PVector startPos = board.findStartPosition("levels/level1.txt");
      hero = new Hero(board, (int)startPos.x, (int)startPos.y);
    }
    
    // Réinitialiser les fantômes à leurs positions de départ
    for (Ghost ghost : ghosts) {
      if (ghost != null) {
        ghost.reset();
      }
    }
  }
  
  // Affichage du jeu
  void drawIt() {
    // Si on est en game over, pause ou niveau terminé, ne pas dessiner le jeu normal
    if (gameOver) {
      drawGameOver();
      return;
    }
    
    if (levelComplete) {
      drawLevelComplete();
      return;
    }
    
    if (paused) {
      drawPauseMenu();
      return;
    }
    
    background(COLOR_BG);
    
    // Afficher le titre du jeu (PAC MAN)
    drawHeader();
    
    // Afficher le plateau
    if (board != null) {
      board.drawIt();
    }
    
    // Afficher les fantômes
    for (int i = 0; i < ghosts.length; i++) {
      if (ghosts[i] != null) {
        ghosts[i].drawIt();
      }
    }
    
    // Afficher le bonus
    if (bonus != null) {
      bonus.drawIt();
    }
    
    // Afficher Pac-Man
    if (hero != null) {
      hero.drawIt();
    }
    
    // Afficher le score et les informations
    drawGameInfo();
    
    // DEBUG - Afficher la légende des trajectoires
    if (DEBUG_GHOST_PATH) {
      drawPathLegend();
    }
  }
  
  // titre jeu  (dessination)
  void drawHeader() {
    fill(color(0, 100, 255));
    textAlign(CENTER);
    textSize(48);
    // effet gras
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
    String scoreText = "SCORE: " + score;
    text(scoreText, BOARD_OFFSET_X, BOARD_OFFSET_Y - 30);
    text(scoreText, BOARD_OFFSET_X + 1, BOARD_OFFSET_Y - 30);
    text(scoreText, BOARD_OFFSET_X, BOARD_OFFSET_Y - 29);
    
    // Afficher les gommes restantes avec effet gras
    int dotsLeft = totalDots - dotsEaten;
    String gommesText = "GOMMES: " + dotsLeft;
    text(gommesText, BOARD_OFFSET_X + 450, BOARD_OFFSET_Y - 30);
    text(gommesText, BOARD_OFFSET_X + 451, BOARD_OFFSET_Y - 30);
    text(gommesText, BOARD_OFFSET_X + 450, BOARD_OFFSET_Y - 29);
    
    // Afficher les vies et cerises à droite de la map (style Pac-Man original)
    int rightX = BOARD_OFFSET_X + board.nbX * CELL_SIZE + 30;
    int startY = BOARD_OFFSET_Y + 400;  // Plus bas pour éviter la légende des trajectoires
    
    // Titre
    fill(255, 255, 0);
    textSize(24);
    text("VIES", rightX + 50, startY);
    
    // Dessiner les vies horizontalement (symboles Pac-Man)
    fill(255, 255, 0);
    for (int i = 0; i < lives; i++) {
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
    for (int i = 0; i < cherriesCollected; i++) {
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
    int legendX = BOARD_OFFSET_X + board.nbX * CELL_SIZE + 50;
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
    if (enteringName) {
      drawNameEntry();
      return;
    }
    
    // Fond noir
    background(0);
    
    // Attendre un peu avant d'afficher le texte
    if (gameOverTimer < 30) return;
    
    // Effet de pulsation sur le titre
    float pulseScale = 1 + sin(gameOverTimer * 0.1) * 0.05;
    
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
    if (gameOverTimer < 60) return;
    
    // Sous-titre avec score final
    fill(255, 184, 151);
    textSize(24);
    text("Score Final: " + score, width/2, 210);
    
    // Menu d'options
    String[] options = {"REJOUER", "MENU PRINCIPAL", "QUITTER"};
    int startY = 400;
    int spacing = 80;
    
    for (int i = 0; i < options.length; i++) {
      int y = startY + i * spacing;
      
      // Surbrillance de l'option sélectionnée
      if (i == gameOverOpt) {
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
    if (gameOverTimer > 90) {
      float alpha = min((gameOverTimer - 90) * 3, 255);
      fill(150, 150, 150, alpha);
      textSize(18);
      text("↑ ↓ pour naviguer  |  ENTRÉE pour sélectionner", width/2, height - 60);
    }
  }
  
  // Interface pour entrer le nom du joueur
  void drawNameEntry() {
    // Fond noir complet
    background(0);
    
    fill(255, 255, 0);
    textAlign(CENTER);
    textSize(48);
    text("NOUVEAU RECORD !", width/2, height/2 - 150);
    
    fill(255);
    textSize(32);
    text("Score: " + score, width/2, height/2 - 80);
    
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
    String displayName = playerName;
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
    // Si on entre le nom, afficher l'interface de saisie
    if (enteringName) {
      drawNameEntry();
      return;
    }
    
    // Fond noir
    background(0);
    
    // Attendre un peu avant d'afficher le texte
    if (gameOverTimer < 30) return;
    
    // Effet de pulsation sur le titre
    float pulseScale = 1 + sin(gameOverTimer * 0.1) * 0.05;
    
    pushMatrix();
    translate(width/2, 150);
    scale(pulseScale);
    
    // Titre "NIVEAU TERMINE" avec effet
    fill(0, 255, 0);  // Vert
    textAlign(CENTER);
    textSize(72);
    text("NIVEAU TERMINE!", 0, 0);
    
    popMatrix();
    
    // Attendre encore un peu pour le reste
    if (gameOverTimer < 60) return;
    
    // Félicitations
    fill(255, 255, 0);
    textSize(36);
    text("FELICITATIONS !", width/2, 250);
    
    // Sous-titre avec score final
    fill(255, 184, 151);
    textSize(24);
    text("Score Final: " + score, width/2, 310);
    
    // Message d'attente
    if (gameOverTimer > 90) {
      float alpha = min((gameOverTimer - 90) * 3, 255);
      fill(150, 150, 150, alpha);
      textSize(22);
      text("Preparation de la saisie du nom...", width/2, height/2 + 100);
    }
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
      if (i == pauseMenuOption) {
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
    if (hero == null) return;
    
    // Gérer le menu de game over
    if (gameOver) {
      handleGameOverMenu(k);
      return;
    }
    
    // Gérer le niveau terminé
    if (levelComplete) {
      handleLevelCompleteMenu(k);
      return;
    }
    
    // Gérer le menu pause
    if (paused) {
      handlePauseMenu(k);
      return;
    }
    
    // Touche ECHAP pour mettre en pause
    if (gameOver || levelComplete) return;
    
    // Déplacements avec les flèches ou ZQSD
    if (k == CODED) {
      if (keyCode == UP) {
        hero.launchMove(new PVector(0, -1));
      } else if (keyCode == DOWN) {
        hero.launchMove(new PVector(0, 1));
      } else if (keyCode == LEFT) {
        hero.launchMove(new PVector(-1, 0));
      } else if (keyCode == RIGHT) {
        hero.launchMove(new PVector(1, 0));
      }
    } else {
      // Support ZQSD (clavier AZERTY)
      if (k == 'z' || k == 'Z') {
        hero.launchMove(new PVector(0, -1));
      } else if (k == 's' || k == 'S') {
        hero.launchMove(new PVector(0, 1));
      } else if (k == 'q' || k == 'Q') {
        hero.launchMove(new PVector(-1, 0));
      } else if (k == 'd' || k == 'D') {
        hero.launchMove(new PVector(1, 0));
      }
      // Support WASD (clavier QWERTY)
      else if (k == 'w' || k == 'W') {
        hero.launchMove(new PVector(0, -1));
      } else if (k == 'a' || k == 'A') {
        hero.launchMove(new PVector(-1, 0));
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
        pauseMenuOption--;
        if (pauseMenuOption < 0) {
          pauseMenuOption = 1;
        }
      } else if (keyCode == DOWN) {
        pauseMenuOption++;
        if (pauseMenuOption > 1) {
          pauseMenuOption = 0;
        }
      }
    } else if (k == '\n' || k == '\r') {
      // ENTRÉE pressée
      if (pauseMenuOption == 0) {
        // Reprendre le jeu
        paused = false;
      }
      // Si option 1 (Menu Principal), ce sera géré dans pacman.pde
    }
  }
  
  // Gestion des touches dans le menu de game over
  void handleGameOverMenu(int k) {
    // Si on entre le nom, gérer la saisie
    if (enteringName) {
      if (k == '\n' || k == '\r') {
        // Valider le nom
        if (playerName.length() > 0) {
          highScores.addScore(playerName, score);
          println("Score sauvegardee: " + playerName + " - " + score);
          enteringName = false;
        }
      } else if (k == 8 || k == 127) {
        // Backspace
        if (playerName.length() > 0) {
          playerName = playerName.substring(0, playerName.length() - 1);
        }
      } else if (playerName.length() < 15 && k >= 32 && k <= 126) {
        // Ajouter le caractère
        playerName += (char)k;
      }
      return;
    }
    
    if (k == CODED) {
      if (keyCode == UP) {
        gameOverOpt = (gameOverOpt - 1 + 3) % 3;
      } else if (keyCode == DOWN) {
        gameOverOpt = (gameOverOpt + 1) % 3;
      }
    } else if (k == '\n' || k == '\r') {  // Touche Entrée
      if (gameOverOpt == 0) {
        // Rejouer avec la même difficulté
        score = 0;
        lives = diffSettings.lives;
        gameOver = false;
        gameOverTimer = 0;
        gameOverOpt = 0;
        levelComplete = false;
        dotsEaten = 0;
        ghostCombo = 0;
        extraLifeGiven = false;
        cherriesCollected = 0;
        enteringName = false;
        playerName = "";
        
        initializeBoard();
        initializeHero();
        initializeGhosts();
        
        if (board != null) {
          totalDots = board.countTotalDots();
          bonus = new Bonus(board, 11, 12, "cherry");
        }
      } else if (gameOverOpt == 1) {
        // Retour au menu principal
        returnToMenu = true;
      } else if (gameOverOpt == 2) {
        // Quitter
        exit();
      }
    }
  }
  
  // Gestion des touches dans le niveau terminé
  void handleLevelCompleteMenu(int k) {
    // Si on entre le nom, gérer la saisie
    if (enteringName) {
      if (k == '\n' || k == '\r') {
        // Valider le nom
        if (playerName.length() > 0) {
          highScores.addScore(playerName, score);
          println("Score sauvegarde: " + playerName + " - " + score);
          enteringName = false;
          // Retourner au menu après la saisie
          returnToMenu = true;
        }
      } else if (k == 8 || k == 127) {
        // Backspace
        if (playerName.length() > 0) {
          playerName = playerName.substring(0, playerName.length() - 1);
        }
      } else if (playerName.length() < 15 && k >= 32 && k <= 126) {
        // Ajouter le caractère
        playerName += (char)k;
      }
    }
  }
  
  // Active/désactive la pause
  void togglePause() {
    if (!gameOver && !levelComplete) {
      paused = !paused;
      if (paused) {
        pauseMenuOption = 0; // Réinitialiser à "REPRENDRE"
      }
    }
  }
  
  // Retourne true si on doit retourner au menu principal
  boolean shouldReturnToMenu() {
    return returnToMenu;
  }
}



