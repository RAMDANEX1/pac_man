// ===== CLASSE GHOST : FANTÔME =====
class Ghost {
  // Position à l'écran (coordonnées pixel)
  PVector _position;
  
  // Position sur le plateau (coordonnées grille)
  int _cellX, _cellY;
  
  // Affichage
  float _size;
  color _color;              // Couleur normale du fantôme
  String _name;              // Nom du fantôme
  
  // Déplacement
  PVector _direction;
  float _speed;
  boolean _moving;
  
  // États du fantôme
  boolean _scared;           // Effrayé (après super-gomme)
  int _scaredTimer;          // Temps restant en mode effrayé
  boolean _released;         // Sorti de la zone de départ
  int _releaseTimer;         // Temps avant la sortie
  PVector _homePosition;     // Position de départ
  
  // Référence au plateau
  Board _board;
  
  // Constructeur
  Ghost(Board board, int startCellX, int startCellY, color ghostColor, String name, int releaseDelay) {
    _board = board;
    _cellX = startCellX;
    _cellY = startCellY;
    _color = ghostColor;
    _name = name;
    _size = GHOST_SIZE;
    
    // Position pixel au centre de la cellule
    PVector cellCenter = _board.getCellCenter(_cellX, _cellY);
    _position = cellCenter.copy();
    _homePosition = _position.copy();
    
    // Initialisation du mouvement - direction aléatoire gauche ou droite
    float dirX = random(1) > 0.5 ? 1 : -1;
    _direction = new PVector(dirX, 0);
    _speed = GHOST_SPEED;
    _moving = true;  // Commencer en mouvement
    
    // États initiaux
    _scared = false;
    _scaredTimer = 0;
    _released = (releaseDelay == 0);
    _releaseTimer = releaseDelay;
  }
  
  // Mise à jour du fantôme
  void update(Hero hero) {
    // Gestion du timer de sortie
    if (!_released) {
      _releaseTimer--;
      if (_releaseTimer <= 0) {
        _released = true;
      }
      // Les fantômes non-releasés bougent horizontalement dans leur boîte
      moveInBox();
      return;
    }
    
    // Gestion du mode effrayé
    if (_scared) {
      _scaredTimer--;
      if (_scaredTimer <= 0) {
        _scared = false;
        _speed = GHOST_SPEED;
      }
    }
    
    // IA : choisir une direction
    chooseDirection(hero);
    move();
  }
  
  // Mouvement dans la boîte (avant d'être released)
  void moveInBox() {
    // Mouvement très simple : gauche-droite lentement
    float moveSpeed = 0.3;
    
    // Calculer la prochaine position
    PVector nextPos = PVector.add(_position, PVector.mult(new PVector(_direction.x, 0), moveSpeed));
    
    // Vérifier si on peut bouger
    int nextCellX = floor((nextPos.x - _board._position.x) / _board._cellSize);
    int nextCellY = floor((nextPos.y - _board._position.y) / _board._cellSize);
    
    if (!_board.isWall(nextCellX, nextCellY)) {
      // On peut bouger
      _position = nextPos;
      updateCellPosition();
    } else {
      // On touche un mur, inverser la direction
      _direction.x *= -1;
      // Recentrer sur la cellule
      PVector cellCenter = _board.getCellCenter(_cellX, _cellY);
      _position.x = cellCenter.x;
    }
  }
  
  // IA avec comportements spécifiques selon le fantôme
  void chooseDirection(Hero hero) {
    // Vérifier si on est au centre d'une cellule
    PVector cellCenter = _board.getCellCenter(_cellX, _cellY);
    float distToCenter = PVector.dist(_position, cellCenter);
    
    if (distToCenter < _speed * 1.5) {
      // On est au centre, on peut changer de direction
      
      ArrayList<PVector> possibleDirs = new ArrayList<PVector>();
      PVector[] directions = {
        new PVector(0, -1),  // Haut
        new PVector(0, 1),   // Bas
        new PVector(-1, 0),  // Gauche
        new PVector(1, 0)    // Droite
      };
      
      // Trouver les directions possibles (pas de mur)
      for (PVector dir : directions) {
        // Éviter le demi-tour sauf si c'est la seule option
        if (possibleDirs.size() > 0 && PVector.dot(dir, _direction) < -0.5) continue;
        
        int nextX = _cellX + (int)dir.x;
        int nextY = _cellY + (int)dir.y;
        
        if (!_board.isWall(nextX, nextY)) {
          possibleDirs.add(dir);
        }
      }
      
      // Si aucune direction trouvée, autoriser le demi-tour
      if (possibleDirs.size() == 0) {
        for (PVector dir : directions) {
          int nextX = _cellX + (int)dir.x;
          int nextY = _cellY + (int)dir.y;
          
          if (!_board.isWall(nextX, nextY)) {
            possibleDirs.add(dir);
          }
        }
      }
      
      if (possibleDirs.size() > 0) {
        if (_scared) {
          // Mode effrayé : choisir aléatoirement
          _direction = possibleDirs.get((int)random(possibleDirs.size())).copy();
        } else {
          // Choisir selon le type de fantôme
          PVector targetCell = getTargetCell(hero);
          
          // Trouver la direction qui rapproche le plus de la cible
          PVector bestDir = null;
          float bestDist = Float.MAX_VALUE;
          
          for (PVector dir : possibleDirs) {
            int nextX = _cellX + (int)dir.x;
            int nextY = _cellY + (int)dir.y;
            float dist = dist(nextX, nextY, targetCell.x, targetCell.y);
            
            if (dist < bestDist) {
              bestDist = dist;
              bestDir = dir;
            }
          }
          
          if (bestDir != null) {
            _direction = bestDir.copy();
          }
        }
      }
    }
  }
  
  // Détermine la cellule cible selon le type de fantôme
  PVector getTargetCell(Hero hero) {
    if (hero == null) {
      return new PVector(_cellX, _cellY);
    }
    
    int heroX = hero.getCellX();
    int heroY = hero.getCellY();
    
    // Comportements spécifiques selon le nom
    if (_name.equals("Blinky")) {
      // BLINKY (rouge) : suit directement Pac-Man
      return new PVector(heroX, heroY);
      
    } else if (_name.equals("Pinky")) {
      // PINKY (rose) : vise 4 cases devant Pac-Man
      PVector heroDir = hero.getDirection();
      int targetX = heroX + (int)(heroDir.x * 4);
      int targetY = heroY + (int)(heroDir.y * 4);
      return new PVector(targetX, targetY);
      
    } else if (_name.equals("Inky")) {
      // INKY (cyan) : comportement basé sur Blinky et Pac-Man
      // Vise 2 cases devant Pac-Man, puis double la distance depuis Blinky
      PVector heroDir = hero.getDirection();
      int intermediateX = heroX + (int)(heroDir.x * 2);
      int intermediateY = heroY + (int)(heroDir.y * 2);
      
      // Trouver Blinky (supposons qu'il est à index 0)
      int targetX = intermediateX * 2 - _cellX;
      int targetY = intermediateY * 2 - _cellY;
      return new PVector(targetX, targetY);
      
    } else if (_name.equals("Clyde")) {
      // CLYDE (orange) : suit Pac-Man quand loin, fuit quand proche
      float distToHero = dist(_cellX, _cellY, heroX, heroY);
      
      if (distToHero > 8) {
        // Loin : suit Pac-Man
        return new PVector(heroX, heroY);
      } else {
        // Proche : retourne au coin inférieur gauche
        return new PVector(0, _board._nbCellsY - 1);
      }
    }
    
    // Par défaut : suivre Pac-Man
    return new PVector(heroX, heroY);
  }
  
  // Déplace le fantôme
  void move() {
    PVector nextPos = PVector.add(_position, PVector.mult(_direction, _speed));
    
    if (canMoveTo(nextPos)) {
      _position = nextPos;
      updateCellPosition();
    } else {
      // Si bloqué, aligner sur le centre de la cellule et forcer un nouveau choix
      PVector cellCenter = _board.getCellCenter(_cellX, _cellY);
      _position = cellCenter.copy();
      
      // Chercher une direction valide immédiatement
      PVector[] directions = {
        new PVector(0, -1), new PVector(0, 1), 
        new PVector(-1, 0), new PVector(1, 0)
      };
      
      for (PVector dir : directions) {
        int nextX = _cellX + (int)dir.x;
        int nextY = _cellY + (int)dir.y;
        if (!_board.isWall(nextX, nextY)) {
          _direction = dir.copy();
          break;
        }
      }
    }
  }
  
  // Vérifie si le fantôme peut se déplacer à une position
  boolean canMoveTo(PVector pos) {
    int cellX = floor((pos.x - _board._position.x) / _board._cellSize);
    int cellY = floor((pos.y - _board._position.y) / _board._cellSize);
    return !_board.isWall(cellX, cellY);
  }
  
  // Met à jour la position de cellule
  void updateCellPosition() {
    _cellX = floor((_position.x - _board._position.x) / _board._cellSize);
    _cellY = floor((_position.y - _board._position.y) / _board._cellSize);
  }
  
  // Active le mode effrayé
  void scare() {
    _scared = true;
    _scaredTimer = GHOST_SCARED_TIME;
    _speed = GHOST_SCARED_SPEED;
  }
  
  // Réinitialise le fantôme (après être mangé)
  void reset() {
    _position = _homePosition.copy();
    _cellX = floor((_position.x - _board._position.x) / _board._cellSize);
    _cellY = floor((_position.y - _board._position.y) / _board._cellSize);
    _scared = false;
    _scaredTimer = 0;
    _speed = GHOST_SPEED;
    _direction = new PVector(0, -1);
  }
  
  // Vérifie la collision avec Pac-Man
  boolean collidesWith(Hero hero) {
    if (!_released) return false;
    return dist(_position.x, _position.y, hero._position.x, hero._position.y) < (_size + hero._size) * 0.4;
  }
  
  // Affiche le fantôme
  void drawIt(int ghostIndex) {
    if (!_released && _releaseTimer > 60) return; // Ne pas afficher au début
    pushMatrix();
    translate(_position.x, _position.y);
    
    // Couleur selon l'état
    if (_scared) {
      // Fantôme effrayé : bleu avec clignotement vers la fin
      if (_scaredTimer < 100 && frameCount % 20 < 10) {
        fill(255, 255, 255); // Blanc clignotant
      } else {
        fill(COLOR_GHOST_SCARED);
      }
    } else {
      fill(_color);
    }
    
    noStroke();
    
    // Corps du fantôme (demi-cercle + rectangle)
    arc(0, 0, _size, _size, PI, TWO_PI, CHORD);
    rect(-_size/2, 0, _size, _size/2);
    
    // Bas ondulé (3 triangles)
    float waveSize = _size / 6;
    for (int i = 0; i < 3; i++) {
      float x1 = -_size/2 + i * (_size/3);
      float x2 = x1 + _size/3;
      float x3 = x1 + _size/6;
      float y1 = _size/2;
      float y2 = y1 + waveSize;
      
      triangle(x1, y1, x2, y1, x3, y2);
    }
    
    // Yeux
    fill(COLOR_GHOST_EYES);
    float eyeSize = _size * 0.25;
    float eyeOffset = _size * 0.15;
    
    if (!_scared) {
      // Yeux normaux
      circle(-eyeOffset, -_size * 0.1, eyeSize);
      circle(eyeOffset, -_size * 0.1, eyeSize);
      
      // Pupilles
      fill(0, 0, 200);
      circle(-eyeOffset, -_size * 0.1, eyeSize * 0.5);
      circle(eyeOffset, -_size * 0.1, eyeSize * 0.5);
    } else {
      // Yeux effrayés (petits)
      circle(-eyeOffset, -_size * 0.1, eyeSize * 0.6);
      circle(eyeOffset, -_size * 0.1, eyeSize * 0.6);
    }
    
    popMatrix();
  }
  
  // Getters
  boolean isScared() { return _scared; }
  boolean isReleased() { return _released; }
  int getCellX() { return _cellX; }
  int getCellY() { return _cellY; }
}
