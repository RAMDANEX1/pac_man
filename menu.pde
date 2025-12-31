// ===== CLASSE MENU : ÉCRAN DE DÉMARRAGE ET MENU PRINCIPAL =====
class Menu {
  int _selectedOption;           // Option sélectionnée (0, 1, 2...)
  boolean _animatePacman;        // Animation Pac-Man
  float _pacmanX;                // Position X de l'animation
  int _animationFrame;           // Frame d'animation
  
  // Options du menu
  String[] _menuOptions = {"JOUER", "INSTRUCTIONS", "QUITTER"};
  
  // État des instructions
  boolean _showingInstructions;
  
  // État de sélection de difficulté
  boolean _selectingDifficulty;
  int _selectedDifficulty;       // 0=EASY, 1=MEDIUM, 2=HARD
  String[] _difficultyOptions = {"NIVEAU CHÈVRE", "MOYEN", "DIFFICILE"};
  
  // Constructeur
  Menu() {
    _selectedOption = 0;
    _animatePacman = true;
    _pacmanX = -50;
    _animationFrame = 0;
    _showingInstructions = false;
    _selectingDifficulty = false;
    _selectedDifficulty = 1; // MEDIUM par défaut
  }
  
  // Mise à jour du menu
  void update() {
    // Animation Pac-Man qui traverse l'écran
    if (_animatePacman) {
      _pacmanX += 3;
      _animationFrame++;
      
      // Réinitialiser l'animation
      if (_pacmanX > width + 100) {
        _pacmanX = -50;
      }
    }
  }
  
  // Affichage du menu
  void drawIt() {
    background(0);
    
    if (_showingInstructions) {
      drawInstructions();
    } else if (_selectingDifficulty) {
      drawDifficultySelection();
    } else {
      drawMainMenu();
    }
  }
  
  // Affiche le menu principal
  void drawMainMenu() {
    // Titre principal
    fill(#FFFF00);
    textAlign(CENTER);
    textSize(72);
    text("PAC-MAN", width/2, 150);
    
    // Sous-titre
    fill(#FFB897);
    textSize(24);
    text("Prêt à manger des gommes ?", width/2, 200);
    
    // Animation Pac-Man
    drawAnimatedPacman();
    
    // Options du menu
    int startY = 400;
    int spacing = 80;
    
    for (int i = 0; i < _menuOptions.length; i++) {
      int y = startY + i * spacing;
      
      // Highlight de l'option sélectionnée
      if (i == _selectedOption) {
        fill(#FFFF00);
        textSize(40);
        // Flèche indicatrice
        text("►", width/2 - 150, y);
        text("◄", width/2 + 150, y);
      } else {
        fill(#FFFFFF);
        textSize(32);
      }
      
      text(_menuOptions[i], width/2, y);
    }
    
    // Instructions en bas
    fill(#888888);
    textSize(18);
    text("↑↓ : Naviguer  |  ENTRÉE : Sélectionner", width/2, height - 50);
  }
  
  // Affiche les instructions
  void drawInstructions() {
    // Titre
    fill(#FFFF00);
    textAlign(CENTER);
    textSize(48);
    text("INSTRUCTIONS", width/2, 80);
    
    // Instructions de jeu
    fill(#FFFFFF);
    textSize(24);
    int y = 150;
    int spacing = 40;
    
    text("Contrôles :", width/2, y);
    y += spacing;
    
    textSize(20);
    text("ZQSD ou FLÈCHES : Déplacer Pac-Man", width/2, y);
    y += spacing;
    text("ESC : Pause", width/2, y);
    y += spacing * 1.5;
    
    textSize(24);
    text("Objectif :", width/2, y);
    y += spacing;
    
    textSize(20);
    text("Manger toutes les gommes sans te faire attraper !", width/2, y);
    y += spacing * 1.5;
    
    textSize(24);
    text("Fantômes :", width/2, y);
    y += spacing;
    
    textSize(18);
    fill(#FF0000);
    text("● BLINKY (rouge) : Te poursuit directement", width/2, y);
    y += spacing;
    fill(#FFB8FF);
    text("● PINKY (rose) : Anticipe tes mouvements", width/2, y);
    y += spacing;
    fill(#00FFFF);
    text("● INKY (cyan) : Alterne entre poursuite et patrouille", width/2, y);
    y += spacing;
    fill(#FFB852);
    text("● CLYDE (orange) : Aléatoire et fuit si trop proche", width/2, y);
    y += spacing * 1.5;
    
    fill(#FFFFFF);
    textSize(20);
    text("🔵 Super-gomme : Mange les fantômes pendant quelques secondes !", width/2, y);
    y += spacing;
    text("🍒 Fruits : Bonus de points !", width/2, y);
    
    // Retour
    fill(#888888);
    textSize(18);
    text("Appuyez sur ECHAP pour revenir", width/2, height - 50);
  }
  
  // Affiche l'écran de sélection de difficulté
  void drawDifficultySelection() {
    // Titre
    fill(#FFFF00);
    textAlign(CENTER);
    textSize(56);
    text("CHOISISSEZ LA DIFFICULTÉ", width/2, 120);
    
    // Options de difficulté
    int startY = 300;
    int spacing = 100;
    
    for (int i = 0; i < _difficultyOptions.length; i++) {
      int y = startY + i * spacing;
      
      // Couleur selon la difficulté
      color optionColor;
      if (i == 0) optionColor = #00FF00;      // Vert pour FACILE
      else if (i == 1) optionColor = #FFFF00; // Jaune pour MOYEN
      else optionColor = #FF0000;             // Rouge pour DIFFICILE
      
      // Highlight de l'option sélectionnée
      if (i == _selectedDifficulty) {
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
      
      text(_difficultyOptions[i], width/2, y);
    }
    
    // Description de la difficulté
    fill(#FFFFFF);
    textSize(20);
    int descY = startY + _difficultyOptions.length * spacing + 50;
    
    switch(_selectedDifficulty) {
      case 0: // NIVEAU CHÈVRE
        text("🐐 5 vies | Fantômes très lents | Super-gomme infinie", width/2, descY);
        break;
      case 1: // MOYEN
        text("🟡 3 vies | Fantômes rapides | Durée réduite", width/2, descY);
        break;
      case 2: // DIFFICILE
        text("🔴 2 vies | Fantômes EXTRÊMMEMENT rapides | Mort instantanée", width/2, descY);
        break;
    }
    
    // Instructions
    fill(#888888);
    textSize(18);
    text("↑↓ : Changer  |  ENTRÉE : Commencer  |  ECHAP : Retour", width/2, height - 50);
  }
  
  // Affiche les instructions (ancienne méthode conservée mais renommée)
  void drawInstructionsOld() {
    // Titre
    fill(#FFFF00);
    textAlign(CENTER);
    textSize(48);
    text("INSTRUCTIONS", width/2, 80);
    
    // Instructions de jeu
    textAlign(LEFT);
    fill(#FFFFFF);
    textSize(24);
    int startY = 150;
    int lineHeight = 40;
    
    text("🎮 CONTRÔLES :", 100, startY);
    fill(#FFB897);
    textSize(20);
    text("• Flèches directionnelles ou ZQSD pour se déplacer", 120, startY + lineHeight);
    text("• R pour recommencer après Game Over", 120, startY + lineHeight * 2);
    
    fill(#FFFFFF);
    textSize(24);
    text("🎯 OBJECTIF :", 100, startY + lineHeight * 4);
    fill(#FFB897);
    textSize(20);
    text("• Manger toutes les gommes pour finir le niveau", 120, startY + lineHeight * 5);
    text("• Éviter les fantômes (ils vous tuent !)", 120, startY + lineHeight * 6);
    
    fill(#FFFFFF);
    textSize(24);
    text("👻 FANTÔMES :", 100, startY + lineHeight * 8);
    fill(#FFB897);
    textSize(20);
    text("• 🔴 Blinky : Vous suit directement", 120, startY + lineHeight * 9);
    text("• 🌸 Pinky : Anticipe votre chemin", 120, startY + lineHeight * 10);
    text("• 🔵 Inky : Comportement imprévisible", 120, startY + lineHeight * 11);
    text("• 🟠 Clyde : Alterne entre vous suivre et fuir", 120, startY + lineHeight * 12);
    
    fill(#FFFFFF);
    textSize(24);
    text("⭐ BONUS :", 100, startY + lineHeight * 14);
    fill(#FFB897);
    textSize(20);
    text("• Petites gommes (o) : 10 points", 120, startY + lineHeight * 15);
    text("• Super-gommes (O) : 50 points + fantômes mangeable", 120, startY + lineHeight * 16);
    text("• Fantôme mangé : 200 points", 120, startY + lineHeight * 17);
    
    // Retour
    fill(#FFFF00);
    textAlign(CENTER);
    textSize(22);
    text("Appuyez sur ÉCHAP pour retourner au menu", width/2, height - 50);
  }
  
  // Animation Pac-Man
  void drawAnimatedPacman() {
    pushMatrix();
    translate(_pacmanX, 280);
    
    fill(#FFFF00);
    noStroke();
    
    // Animation de la bouche
    float mouthAngle = 45 * abs(sin(_animationFrame * 0.15));
    
    // Corps de Pac-Man
    arc(0, 0, 60, 60, radians(mouthAngle/2), radians(360 - mouthAngle/2), PIE);
    
    popMatrix();
    
    // Dessiner quelques gommes devant Pac-Man
    for (int i = 0; i < 5; i++) {
      float dotX = _pacmanX + 100 + i * 40;
      if (dotX > 0 && dotX < width) {
        fill(#FFB897);
        ellipse(dotX, 280, 12, 12);
      }
    }
  }
  
  // Gestion des touches
  void handleKey(int k) {
    if (_showingInstructions) {
      // Dans les instructions, ESC pour retourner
      if (k == ESC) {
        _showingInstructions = false;
        key = 0; // Empêcher la fermeture de l'application
      }
    } else if (_selectingDifficulty) {
      // Navigation dans la sélection de difficulté
      if (k == CODED) {
        if (keyCode == UP) {
          _selectedDifficulty--;
          if (_selectedDifficulty < 0) {
            _selectedDifficulty = _difficultyOptions.length - 1;
          }
        } else if (keyCode == DOWN) {
          _selectedDifficulty++;
          if (_selectedDifficulty >= _difficultyOptions.length) {
            _selectedDifficulty = 0;
          }
        }
      } else if (k == ESC) {
        // Retour au menu principal
        _selectingDifficulty = false;
        key = 0;
      }
      // ENTRÉE sera gérée dans pacman.pde
    } else {
      // Dans le menu principal
      if (k == CODED) {
        if (keyCode == UP) {
          _selectedOption--;
          if (_selectedOption < 0) {
            _selectedOption = _menuOptions.length - 1;
          }
        } else if (keyCode == DOWN) {
          _selectedOption++;
          if (_selectedOption >= _menuOptions.length) {
            _selectedOption = 0;
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
    switch(_selectedOption) {
      case 0: // JOUER
        _selectingDifficulty = true;
        break;
      case 1: // INSTRUCTIONS
        _showingInstructions = true;
        break;
      case 2: // QUITTER
        exit();
        break;
    }
  }
  
  // Réinitialise le menu
  void reset() {
    _selectedOption = 0;
    _showingInstructions = false;
    _selectingDifficulty = false;
    _pacmanX = -50;
  }
  
  // Getters
  int getSelectedOption() {
    return _selectedOption;
  }
  
  boolean isShowingInstructions() {
    return _showingInstructions;
  }
  
  boolean isSelectingDifficulty() {
    return _selectingDifficulty;
  }
  
  int getSelectedDifficulty() {
    return _selectedDifficulty;
  }
}
