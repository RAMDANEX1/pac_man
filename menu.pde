// menu principal du jeu
// avec des animations pour rendre ca plus vivant
class Menu {
  int selectedOption;
  boolean animatePacman;
  float pacmanX;
  int animationFrame;
  
  // Options du menu
  String[] menuOptions = {"JOUER", "INSTRUCTIONS", "SCORES", "QUITTER"};
  
  // État des instructions
  boolean showingInstructions;
  boolean showingScores;
  HighScores highScores;
  
  // État de sélection de difficulté
  boolean selectingDifficulty;
  int selectedDifficulty;       // 0=EASY, 1=MEDIUM, 2=HARD
  String[] difficultyOptions = {"NIVEAU CHÈVRE", "MOYEN", "DIFFICILE"};
  
  // Constructeur
  Menu() {
    selectedOption = 0;
    animatePacman = true;
    pacmanX = -50;
    animationFrame = 0;
    showingInstructions = false;
    showingScores = false;
    selectingDifficulty = false;
    selectedDifficulty = 1; // MEDIUM par défaut
    highScores = new HighScores();
  }
  
  // anime le pacman qui bouge en fond
  // il a pas le droit de se reposer meme dans le menu
  void update() {
    // animation pacman
    if (animatePacman) {
      pacmanX += 3;
      animationFrame++;
      
      // Réinitialiser l'animation
      if (pacmanX > width + 100) {
        pacmanX = -50;
      }
    }
  }
  
  // Affichage du menu
  void drawIt() {
    background(0);
    
    if (showingInstructions) {
      drawInstructions();
    } else if (showingScores) {
      highScores.display();
    } else if (selectingDifficulty) {
      drawDifficultySelection();
    } else {
      drawMainMenu();
    }
  }
  
  // menu principal
  void drawMainMenu() {
    // titre
    fill(255, 255, 0);
    textAlign(CENTER);
    textSize(72);
    text("PAC-MAN", width/2, 150);
    
    // Sous-titre
    fill(255, 184, 151);
    textSize(24);
    text("Prêt à manger des gommes ?", width/2, 200);
    
    // Animation Pac-Man
    drawAnimatedPacman();
    
    // Options du menu
    int startY = 400;
    int spacing = 80;
    
    for (int i = 0; i < menuOptions.length; i++) {
      int y = startY + i * spacing;
      
      // Highlight de l'option sélectionnée
      if (i == selectedOption) {
        // Petit rectangle simple
        fill(255, 255, 0, 40);
        rectMode(CENTER);
        rect(width/2, y - 12, 300, 50, 8);
        rectMode(CORNER);
        
        fill(255, 255, 0);
        textSize(40);
        // Flèches indicatrices
        text(">", width/2 - 140, y);
        text("<", width/2 + 140, y);
      } else {
        fill(255, 255, 255);
        textSize(32);
      }
      
      text(menuOptions[i], width/2, y);
    }
    
    // Instructions en bas
    fill(136, 136, 136);
    textSize(18);
    text("↑↓ : Naviguer  |  ENTRÉE : Sélectionner", width/2, height - 50);
  }
  
  // affiche l'ecran d'aide
  // pour ceux qui n'ont jamais joue a pacman (ca existe ?)
  void drawInstructions() {
    // Titre
    fill(255, 255, 0);
    textAlign(CENTER);
    textSize(48);
    text("INSTRUCTIONS", width/2, 80);
    
    // Ligne simple
    stroke(255, 255, 0);
    strokeWeight(2);
    line(width/2 - 120, 95, width/2 + 120, 95);
    noStroke();
    
    int y = 150;
    int spacing = 35;
    
    // Section Controles
    fill(255, 255, 0);
    textSize(26);
    text("CONTROLES", width/2, y);
    y += spacing;
    
    fill(255, 255, 255);
    textSize(20);
    text("Fleches ou Z Q S D : Deplacer Pac-Man", width/2, y);
    y += spacing;
    text("ESC : Pause", width/2, y);
    y += spacing * 1.8;
    
    // Section Objectif
    fill(0, 255, 0);
    textSize(26);
    text("OBJECTIF", width/2, y);
    y += spacing;
    
    fill(255, 255, 255);
    textSize(20);
    text("Manger toutes les gommes sans te faire attraper !", width/2, y);
    y += spacing * 1.8;
    
    // Section Fantomes
    fill(255, 102, 102);
    textSize(26);
    text("FANTOMES", width/2, y);
    y += spacing;
    
    textSize(19);
    fill(255, 0, 0);
    text("BLINKY (rouge) : Te poursuit directement", width/2, y);
    y += spacing;
    fill(255, 184, 255);
    text("PINKY (rose) : Anticipe tes mouvements", width/2, y);
    y += spacing;
    fill(0, 255, 255);
    text("INKY (cyan) : Alterne entre poursuite et patrouille", width/2, y);
    y += spacing;
    fill(255, 184, 82);
    text("CLYDE (orange) : Aleatoire et fuit si trop proche", width/2, y);
    y += spacing * 1.8;
    
    // Section Bonus
    fill(255, 255, 0);
    textSize(26);
    text("BONUS", width/2, y);
    y += spacing;
    
    fill(255, 255, 255);
    textSize(19);
    text("Super-gomme : Mange les fantomes pendant quelques secondes !", width/2, y);
    y += spacing;
    text("Fruits : Bonus de points et vies !", width/2, y);
    
    // Instructions de retour
    fill(136, 136, 136);
    textSize(18);
    text("Appuyez sur ECHAP pour revenir", width/2, height - 50);
  }
  
  // Affiche l'écran de sélection de difficulté
  void drawDifficultySelection() {
    // Titre
    fill(255, 255, 0);
    textAlign(CENTER);
    textSize(56);
    text("CHOISISSEZ LA DIFFICULTÉ", width/2, 120);
    
    // Options de difficulté
    int startY = 300;
    int spacing = 100;
    
    for (int i = 0; i < difficultyOptions.length; i++) {
      int y = startY + i * spacing;
      
      // Couleur selon la difficulté
      color optionColor;
      if (i == 0) optionColor = color(0, 255, 0);      // Vert pour FACILE
      else if (i == 1) optionColor = color(255, 255, 0); // Jaune pour MOYEN
      else optionColor = color(255, 0, 0);             // Rouge pour DIFFICILE
      
      // Highlight de l'option sélectionnée
      if (i == selectedDifficulty) {
        // Rectangle de sélection
        float pulseSize = sin(frameCount * 0.1) * 10;
        fill(optionColor, 50);
        rectMode(CENTER);
        rect(width/2, y - 10, 400 + pulseSize, 70, 10);
        rectMode(CORNER);
        
        fill(optionColor);
        textSize(48);
        // Flèches
        text("▶", width/2 - 220, y);
        text("◀", width/2 + 220, y);
      } else {
        fill(optionColor, 150);
        textSize(36);
      }
      
      text(difficultyOptions[i], width/2, y);
    }
    
    // Description de la difficulté
    fill(255, 255, 255);
    textSize(20);
    int descY = startY + difficultyOptions.length * spacing + 50;
    
    switch(selectedDifficulty) {
      case 0: // NIVEAU CHÈVRE
        text(" 5 vies | Fantômes très lents | Super-gomme infinie", width/2, descY);
        break;
      case 1: // MOYEN
        text(" 3 vies | Fantômes rapides | Durée réduite", width/2, descY);
        break;
      case 2: // DIFFICILE
        text(" 2 vies | Fantômes EXTRÊMMEMENT rapides | Mort instantanée", width/2, descY);
        break;
    }
    
    // Instructions
    fill(136, 136, 136);
    textSize(18);
    text("↑↓ : Changer  |  ENTRÉE : Commencer  |  ECHAP : Retour", width/2, height - 50);
  }
  
  // Affiche les instructions (ancienne méthode conservée mais renommée)
  void drawInstructionsOld() {
    // Titre
    fill(255, 255, 0);
    textAlign(CENTER);
    textSize(48);
    text("INSTRUCTIONS", width/2, 80);
    
    // Instructions de jeu
    textAlign(LEFT);
    fill(255, 255, 255);
    textSize(24);
    int startY = 150;
    int lineHeight = 40;
    
    text("CONTROLES :", 100, startY);
    fill(255, 184, 151);
    textSize(20);
    text("Fleches directionnelles ou ZQSD pour se deplacer", 120, startY + lineHeight);
    text("• R pour recommencer après Game Over", 120, startY + lineHeight * 2);
    
    fill(255, 255, 255);
    textSize(24);
    text("OBJECTIF :", 100, startY + lineHeight * 4);
    fill(255, 184, 151);
    textSize(20);
    text("Manger toutes les gommes pour finir le niveau", 120, startY + lineHeight * 5);
    text("Eviter les fantomes (ils vous tuent !)", 120, startY + lineHeight * 6);
    
    fill(255, 255, 255);
    textSize(24);
    text("FANTOMES :", 100, startY + lineHeight * 8);
    fill(255, 184, 151);
    textSize(20);
    text("Blinky : Vous suit directement", 120, startY + lineHeight * 9);
    text("Pinky : Anticipe votre chemin", 120, startY + lineHeight * 10);
    text("Inky : Comportement imprevisible", 120, startY + lineHeight * 11);
    text("Clyde : Alterne entre vous suivre et fuir", 120, startY + lineHeight * 12);
    
    fill(255, 255, 255);
    textSize(24);
    text("BONUS :", 100, startY + lineHeight * 14);
    fill(255, 184, 151);
    textSize(20);
    text("Petites gommes (o) : 10 points", 120, startY + lineHeight * 15);
    text("Super-gommes (O) : 50 points + fantomes mangeables", 120, startY + lineHeight * 16);
    text("Fantome mange : 200 points", 120, startY + lineHeight * 17);
    
    // Retour
    fill(255, 255, 0);
    textAlign(CENTER);
    textSize(22);
    text("Appuyez sur ÉCHAP pour retourner au menu", width/2, height - 50);
  }
  
  // Animation Pac-Man
  void drawAnimatedPacman() {
    // Pac-Man fixe au centre
    pushMatrix();
    translate(width/2, 280);
    
    fill(255, 255, 0);
    noStroke();
    
    // Pac-Man avec bouche fixe
    float mouthAngle = 45;
    
    // Corps de Pac-Man
    arc(0, 0, 60, 60, radians(mouthAngle/2), radians(360 - mouthAngle/2), PIE);
    
    popMatrix();
    
    // Dessiner les 4 fantômes autour de Pac-Man
    drawMenuGhost(width/2 - 200, 280, color(255, 0, 0));      // Blinky (rouge) à gauche
    drawMenuGhost(width/2 - 100, 280, color(255, 184, 255));  // Pinky (rose)
    drawMenuGhost(width/2 + 100, 280, color(0, 255, 255));    // Inky (cyan)
    drawMenuGhost(width/2 + 200, 280, color(255, 184, 82));   // Clyde (orange) à droite
    
    // Dessiner quelques gommes entre les fantômes
    fill(255, 184, 151);
    ellipse(width/2 - 150, 280, 10, 10);
    ellipse(width/2 - 50, 280, 10, 10);
    ellipse(width/2 + 50, 280, 10, 10);
    ellipse(width/2 + 150, 280, 10, 10);
  }
  
  // Dessine un fantôme pour le menu
  void drawMenuGhost(float x, float y, color ghostColor) {
    pushMatrix();
    translate(x, y);
    
    float size = 50;
    fill(ghostColor);
    noStroke();
    
    // Corps arrondi
    arc(0, -size * 0.15, size, size * 0.8, PI, TWO_PI, CHORD);
    rect(-size/2, -size * 0.15, size, size * 0.5);
    
    // Bas ondulé
    for (int i = 0; i < 4; i++) {
      float xPos = -size/2 + i * size/4;
      arc(xPos + size/8, size * 0.35, size/4, size * 0.3, 0, PI, CHORD);
    }
    
    // Yeux blancs
    fill(255);
    ellipse(-size * 0.2, -size * 0.1, size * 0.3, size * 0.35);
    ellipse(size * 0.2, -size * 0.1, size * 0.3, size * 0.35);
    
    // Pupilles
    fill(0, 0, 200);
    ellipse(-size * 0.2, -size * 0.05, size * 0.12, size * 0.15);
    ellipse(size * 0.2, -size * 0.05, size * 0.12, size * 0.15);
    
    popMatrix();
  }
  
  // Gestion des touches
  void handleKey(int k) {
    if (showingInstructions) {
      // Dans les instructions, ESC pour retourner
      if (k == ESC) {
        showingInstructions = false;
        key = 0; // Empêcher la fermeture de l'application
      }
    } else if (showingScores) {
      // Dans les scores, ESC pour retourner
      if (k == ESC) {
        showingScores = false;
        key = 0;
      }
    } else if (selectingDifficulty) {
      // Navigation dans la sélection de difficulté
      if (k == CODED) {
        if (keyCode == UP) {
          selectedDifficulty--;
          if (selectedDifficulty < 0) {
            selectedDifficulty = difficultyOptions.length - 1;
          }
        } else if (keyCode == DOWN) {
          selectedDifficulty++;
          if (selectedDifficulty >= difficultyOptions.length) {
            selectedDifficulty = 0;
          }
        }
      } else if (k == ESC) {
        // Retour au menu principal
        selectingDifficulty = false;
        key = 0;
      }
      // ENTRÉE sera gérée dans pacman.pde
    } else {
      // Dans le menu principal
      if (k == CODED) {
        if (keyCode == UP) {
          selectedOption--;
          if (selectedOption < 0) {
            selectedOption = menuOptions.length - 1;
          }
        } else if (keyCode == DOWN) {
          selectedOption++;
          if (selectedOption >= menuOptions.length) {
            selectedOption = 0;
          }
        }
      } else if (k == '\n' || k == '\r') {
        // ENTRÉE pressée
        executeOption();
      }
    }
  }
  
  // Exécute l'option sélectionnée
  void executeOption() {
    switch(selectedOption) {
      case 0: // JOUER
        selectingDifficulty = true;
        break;
      case 1: // INSTRUCTIONS
        showingInstructions = true;
        break;
      case 2: // SCORES
        showingScores = true;
        break;
      case 3: // QUITTER
        exit();
        break;
    }
  }
  
  // Réinitialise le menu
  void reset() {
    selectedOption = 0;
    showingInstructions = false;
    showingScores = false;
    selectingDifficulty = false;
    pacmanX = -50;
  }
  
  // Getters
  int getSelectedOption() {
    return selectedOption;
  }
  
  boolean isShowingInstructions() {
    return showingInstructions;
  }
}

