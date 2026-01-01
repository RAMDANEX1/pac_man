// types cellules
enum TypeCell 
{
  EMPTY,
  WALL,
  DOT,
  SUPER_DOT
}

// plateau de jeu
class Board 
{
  TypeCell[][] _grille;
  PVector _pos;
  int _nbX;
  int _nbY;
  int _taille;
  
  // constructeur
  Board(PVector position, int nbCellsX, int nbCellsY, int cellSize) {
    _pos = position;
    _nbX = nbCellsX;
    _nbY = nbCellsY;
    _taille = cellSize;
    _grille = new TypeCell[nbCellsY][nbCellsX];
    
    // init niveau demo
    initializeHardcodedLevel();
  }
  
  // Constructeur alternatif : charge depuis un fichier
  Board(PVector position, int cellSize, String filename) {
    _pos = position;
    _taille = cellSize;
    
    // Charger le niveau depuis le fichier
    loadFromFile(filename);
  }
  
  // charge niveau depuis fichier
  void loadFromFile(String filename) {
    String[] lines = loadStrings(filename);
    
    if (lines == null || lines.length == 0) {
      println("ERREUR : fichier introuvable " + filename);
      initializeHardcodedLevel();
      return;
    }
    
    // Ignorer la première ligne (commentaire)
    int startLine = 0;
    if (lines[0].contains("Niveau") || lines[0].contains("Level")) {
      startLine = 1;
    }
    
    // Calculer les dimensions du plateau
    _nbY = lines.length - startLine;
    _nbX = lines[startLine].length();
    
    // Allouer le tableau
    _grille = new TypeCell[_nbY][_nbX];
    
    // Lire chaque ligne et créer le plateau
    for (int y = 0; y < _nbY; y++) {
      String line = lines[y + startLine];
      for (int x = 0; x < min(line.length(), _nbX); x++) {
        char c = line.charAt(x);
        
        switch(c) {
          case 'x': // Mur
            _grille[y][x] = TypeCell.WALL;
            break;
          case 'o': // Gomme normale
            _grille[y][x] = TypeCell.DOT;
            break;
          case 'O': // Super-gomme
            _grille[y][x] = TypeCell.SUPER_DOT;
            break;
          case 'V': // Case EMPTY (zone fantômes)
          case 'P': // Position Pac-Man (devient EMPTY)
          case ' ': // Espace EMPTY
            _grille[y][x] = TypeCell.EMPTY;
            break;
          default:
            _grille[y][x] = TypeCell.EMPTY;
            break;
        }
      }
    }
    
    println("Niveau chargé : " + filename + " (" + _nbX + "x" + _nbY + ")");
  }
  
  // trouve position depart pacman
  PVector findStartPosition(String filename) {
    String[] lines = loadStrings(filename);
    
    if (lines == null) return new PVector(9, 10);
    
    int startLine = (lines[0].contains("Niveau") || lines[0].contains("Level")) ? 1 : 0;
    
    for (int y = 0; y < lines.length - startLine; y++) {
      String line = lines[y + startLine];
      for (int x = 0; x < line.length(); x++) {
        if (line.charAt(x) == 'P') {
          return new PVector(x, y);
        }
      }
    }
    
    return new PVector(9, 10); // Position par défaut si 'P' non trouvé
  }
  
  // compte gommes totales
  int countTotalDots() {
    int count = 0;
    for (int y = 0; y < _nbY; y++) {
      for (int x = 0; x < _nbX; x++) {
        if (_grille[y][x] == TypeCell.DOT || _grille[y][x] == TypeCell.SUPER_DOT) {
          count++;
        }
      }
    }
    return count;
  }
  
  // Initialise un niveau basique codé en dur
  void initializeHardcodedLevel() {
    // Créer un labyrinthe simple et original
    // W = mur, E = EMPTY, D = gomme, S = super-gomme
    
    // Remplir tout d'abord avec des murs
    for (int y = 0; y < _nbY; y++) {
      for (int x = 0; x < _nbX; x++) {
        _grille[y][x] = TypeCell.WALL;
      }
    }
    
    // Créer un labyrinthe original en forme de croix avec des chemins
    // Zone centrale horizontale
    for (int x = 3; x < 16; x++) {
      for (int y = 9; y < 12; y++) {
        _grille[y][x] = TypeCell.DOT;
      }
    }
    
    // Zone centrale verticale
    for (int y = 3; y < 18; y++) {
      for (int x = 8; x < 11; x++) {
        _grille[y][x] = TypeCell.DOT;
      }
    }
    
    // Coins avec chemins
    // Haut-gauche
    for (int x = 1; x < 6; x++) {
      for (int y = 1; y < 4; y++) {
        _grille[y][x] = TypeCell.DOT;
      }
    }
    
    // Haut-droite
    for (int x = 13; x < 18; x++) {
      for (int y = 1; y < 4; y++) {
        _grille[y][x] = TypeCell.DOT;
      }
    }
    
    // Bas-gauche
    for (int x = 1; x < 6; x++) {
      for (int y = 17; y < 20; y++) {
        _grille[y][x] = TypeCell.DOT;
      }
    }
    
    // Bas-droite
    for (int x = 13; x < 18; x++) {
      for (int y = 17; y < 20; y++) {
        _grille[y][x] = TypeCell.DOT;
      }
    }
    
    // Connexions verticales vers les coins
    for (int y = 4; y < 9; y++) {
      _grille[y][3] = TypeCell.DOT;
      _grille[y][15] = TypeCell.DOT;
    }
    
    for (int y = 12; y < 17; y++) {
      _grille[y][3] = TypeCell.DOT;
      _grille[y][15] = TypeCell.DOT;
    }
    
    // Placer 4 super-gommes aux quatre coins
    _grille[1][1] = TypeCell.SUPER_DOT;
    _grille[1][17] = TypeCell.SUPER_DOT;
    _grille[19][1] = TypeCell.SUPER_DOT;
    _grille[19][17] = TypeCell.SUPER_DOT;
    
    // Ajouter quelques zones EMPTYs pour la variété
    _grille[10][9] = TypeCell.EMPTY;  // Centre
  }
  
  // centre cellule en pixels
  PVector getCellCenter(int x, int y) {
    float centerX = _pos.x + x * _taille + _taille / 2.0;
    float centerY = _pos.y + y * _taille + _taille / 2.0;
    return new PVector(centerX, centerY);
  }
  
  // Dessine le plateau complet
  void drawIt() {
    // Parcourir toutes les cellules et les dessiner
    for (int y = 0; y < _nbY; y++) {
      for (int x = 0; x < _nbX; x++) {
        drawCell(x, y, _grille[y][x]);
      }
    }
  }
  
  // Dessine une cellule individuelle selon son type
  void drawCell(int x, int y, TypeCell type) {
    float posX = _pos.x + x * _taille;
    float posY = _pos.y + y * _taille;
    
    switch(type) {
      case WALL:
        // Mur : style Pac-Man classique - ligne bleue simple
        fill(COLOR_WALL);
        noStroke();
        rect(posX, posY, _taille, _taille);
        break;
        
      case DOT:
        // Gomme : petit cercle beige sur fond noir
        fill(COLOR_EMPTY);
        noStroke();
        rect(posX, posY, _taille, _taille);
        fill(COLOR_DOT);
        circle(posX + _taille/2, posY + _taille/2, _taille * 0.2);
        break;
        
      case SUPER_DOT:
        // Super-gomme : cercle orange plus gros, légèrement pulsant
        fill(COLOR_EMPTY);
        noStroke();
        rect(posX, posY, _taille, _taille);
        fill(COLOR_SUPER_DOT);
        float pulseSize = _taille * 0.4 + sin(frameCount * 0.1) * 2;
        circle(posX + _taille/2, posY + _taille/2, pulseSize);
        break;
        
      case EMPTY:
        // Case EMPTY : juste le fond noir
        fill(COLOR_EMPTY);
        noStroke();
        rect(posX, posY, _taille, _taille);
        break;
    }
  }
  
  // Vérifie si une cellule est un mur
  boolean isWall(int x, int y) {
    if (x < 0 || x >= _nbX || y < 0 || y >= _nbY) {
      return true;  // Hors limites = mur
    }
    return _grille[y][x] == TypeCell.WALL;
  }
  
  // Retourne le type d'une cellule
  TypeCell getCellType(int x, int y) {
    if (x < 0 || x >= _nbX || y < 0 || y >= _nbY) {
      return TypeCell.WALL;
    }
    return _grille[y][x];
  }
  
  // Modifie le type d'une cellule (utile pour manger les gommes)
  void setCellType(int x, int y, TypeCell newType) {
    if (x >= 0 && x < _nbX && y >= 0 && y < _nbY) {
      _grille[y][x] = newType;
    }
  }
}


