// Types de cellules
enum TypeCell 
{
  EMPTY,
  WALL,
  DOT,
  SUPER_DOT
}

// Classe Board (plateau de jeu)
class Board 
{
  TypeCell[][] _cells;
  PVector _position;
  int _nbCellsX;
  int _nbCellsY;
  int _cellSize;
  
  // Constructeur
  Board(PVector position, int nbCellsX, int nbCellsY, int cellSize) {
    _position = position;
    _nbCellsX = nbCellsX;
    _nbCellsY = nbCellsY;
    _cellSize = cellSize;
    _cells = new TypeCell[nbCellsY][nbCellsX];
    
    // Initialisation du plateau en dur (niveau de démonstration)
    initializeHardcodedLevel();
  }
  
  // Constructeur alternatif : charge depuis un fichier
  Board(PVector position, int cellSize, String filename) {
    _position = position;
    _cellSize = cellSize;
    
    // Charger le niveau depuis le fichier
    loadFromFile(filename);
  }
  
  // Charge un niveau depuis un fichier .txt
  void loadFromFile(String filename) {
    String[] lines = loadStrings(filename);
    
    if (lines == null || lines.length == 0) {
      println("ERREUR : Impossible de charger " + filename);
      initializeHardcodedLevel();
      return;
    }
    
    // Ignorer la première ligne (commentaire)
    int startLine = 0;
    if (lines[0].contains("Niveau") || lines[0].contains("Level")) {
      startLine = 1;
    }
    
    // Calculer les dimensions du plateau
    _nbCellsY = lines.length - startLine;
    _nbCellsX = lines[startLine].length();
    
    // Allouer le tableau
    _cells = new TypeCell[_nbCellsY][_nbCellsX];
    
    // Lire chaque ligne et créer le plateau
    for (int y = 0; y < _nbCellsY; y++) {
      String line = lines[y + startLine];
      for (int x = 0; x < min(line.length(), _nbCellsX); x++) {
        char c = line.charAt(x);
        
        switch(c) {
          case 'x': // Mur
            _cells[y][x] = TypeCell.WALL;
            break;
          case 'o': // Gomme normale
            _cells[y][x] = TypeCell.DOT;
            break;
          case 'O': // Super-gomme
            _cells[y][x] = TypeCell.SUPER_DOT;
            break;
          case 'V': // Case EMPTY (zone fantômes)
          case 'P': // Position Pac-Man (devient EMPTY)
          case ' ': // Espace EMPTY
            _cells[y][x] = TypeCell.EMPTY;
            break;
          default:
            _cells[y][x] = TypeCell.EMPTY;
            break;
        }
      }
    }
    
    println("Niveau chargé : " + filename + " (" + _nbCellsX + "x" + _nbCellsY + ")");
  }
  
  // Trouve la position de départ de Pac-Man dans le fichier
  PVector findStartPosition(String filename) {
    String[] lines = loadStrings(filename);
    
    if (lines == null) return new PVector(9, 10); // Position par défaut
    
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
  
  // Compte le nombre total de gommes (normales + super)
  int countTotalDots() {
    int count = 0;
    for (int y = 0; y < _nbCellsY; y++) {
      for (int x = 0; x < _nbCellsX; x++) {
        if (_cells[y][x] == TypeCell.DOT || _cells[y][x] == TypeCell.SUPER_DOT) {
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
    for (int y = 0; y < _nbCellsY; y++) {
      for (int x = 0; x < _nbCellsX; x++) {
        _cells[y][x] = TypeCell.WALL;
      }
    }
    
    // Créer un labyrinthe original en forme de croix avec des chemins
    // Zone centrale horizontale
    for (int x = 3; x < 16; x++) {
      for (int y = 9; y < 12; y++) {
        _cells[y][x] = TypeCell.DOT;
      }
    }
    
    // Zone centrale verticale
    for (int y = 3; y < 18; y++) {
      for (int x = 8; x < 11; x++) {
        _cells[y][x] = TypeCell.DOT;
      }
    }
    
    // Coins avec chemins
    // Haut-gauche
    for (int x = 1; x < 6; x++) {
      for (int y = 1; y < 4; y++) {
        _cells[y][x] = TypeCell.DOT;
      }
    }
    
    // Haut-droite
    for (int x = 13; x < 18; x++) {
      for (int y = 1; y < 4; y++) {
        _cells[y][x] = TypeCell.DOT;
      }
    }
    
    // Bas-gauche
    for (int x = 1; x < 6; x++) {
      for (int y = 17; y < 20; y++) {
        _cells[y][x] = TypeCell.DOT;
      }
    }
    
    // Bas-droite
    for (int x = 13; x < 18; x++) {
      for (int y = 17; y < 20; y++) {
        _cells[y][x] = TypeCell.DOT;
      }
    }
    
    // Connexions verticales vers les coins
    for (int y = 4; y < 9; y++) {
      _cells[y][3] = TypeCell.DOT;
      _cells[y][15] = TypeCell.DOT;
    }
    
    for (int y = 12; y < 17; y++) {
      _cells[y][3] = TypeCell.DOT;
      _cells[y][15] = TypeCell.DOT;
    }
    
    // Placer 4 super-gommes aux quatre coins
    _cells[1][1] = TypeCell.SUPER_DOT;
    _cells[1][17] = TypeCell.SUPER_DOT;
    _cells[19][1] = TypeCell.SUPER_DOT;
    _cells[19][17] = TypeCell.SUPER_DOT;
    
    // Ajouter quelques zones EMPTYs pour la variété
    _cells[10][9] = TypeCell.EMPTY;  // Centre
  }
  
  // Retourne le centre d'une cellule en coordonnées écran
  PVector getCellCenter(int x, int y) {
    float centerX = _position.x + x * _cellSize + _cellSize / 2.0;
    float centerY = _position.y + y * _cellSize + _cellSize / 2.0;
    return new PVector(centerX, centerY);
  }
  
  // Dessine le plateau complet
  void drawIt() {
    // Parcourir toutes les cellules et les dessiner
    for (int y = 0; y < _nbCellsY; y++) {
      for (int x = 0; x < _nbCellsX; x++) {
        drawCell(x, y, _cells[y][x]);
      }
    }
  }
  
  // Dessine une cellule individuelle selon son type
  void drawCell(int x, int y, TypeCell type) {
    float posX = _position.x + x * _cellSize;
    float posY = _position.y + y * _cellSize;
    
    switch(type) {
      case WALL:
        // Mur : style Pac-Man classique - ligne bleue simple
        fill(COLOR_WALL);
        noStroke();
        rect(posX, posY, _cellSize, _cellSize);
        break;
        
      case DOT:
        // Gomme : petit cercle beige sur fond noir
        fill(COLOR_EMPTY);
        noStroke();
        rect(posX, posY, _cellSize, _cellSize);
        fill(COLOR_DOT);
        circle(posX + _cellSize/2, posY + _cellSize/2, _cellSize * 0.2);
        break;
        
      case SUPER_DOT:
        // Super-gomme : cercle orange plus gros, légèrement pulsant
        fill(COLOR_EMPTY);
        noStroke();
        rect(posX, posY, _cellSize, _cellSize);
        fill(COLOR_SUPER_DOT);
        float pulseSize = _cellSize * 0.4 + sin(frameCount * 0.1) * 2;
        circle(posX + _cellSize/2, posY + _cellSize/2, pulseSize);
        break;
        
      case EMPTY:
        // Case EMPTY : juste le fond noir
        fill(COLOR_EMPTY);
        noStroke();
        rect(posX, posY, _cellSize, _cellSize);
        break;
    }
  }
  
  // Vérifie si une cellule est un mur
  boolean isWall(int x, int y) {
    if (x < 0 || x >= _nbCellsX || y < 0 || y >= _nbCellsY) {
      return true;  // Hors limites = mur
    }
    return _cells[y][x] == TypeCell.WALL;
  }
  
  // Retourne le type d'une cellule
  TypeCell getCellType(int x, int y) {
    if (x < 0 || x >= _nbCellsX || y < 0 || y >= _nbCellsY) {
      return TypeCell.WALL;
    }
    return _cells[y][x];
  }
  
  // Modifie le type d'une cellule (utile pour manger les gommes)
  void setCellType(int x, int y, TypeCell newType) {
    if (x >= 0 && x < _nbCellsX && y >= 0 && y < _nbCellsY) {
      _cells[y][x] = newType;
    }
  }
}
