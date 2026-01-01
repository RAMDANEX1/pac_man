// pacman
class Hero {
  PVector _pos;
  PVector _offset;
  
  // position grille
  int _x, _y;
  
  // Affichage
  float _size;
  float _angle;
  float _angleDir;
  
  // Animation de mort
  boolean _dying;
  int _timer;
  int _duration;
  
  // Déplacement
  PVector _direction;
  PVector _nextDir;
  boolean _bouge;
  float _vitesse;
  
  Board _board;
  
  // Constructeur
  Hero(Board board, int startCellX, int startCellY) {
    _board = board;
    _x = startCellX;
    _y = startCellY;
    
    // Position pixel au centre de la cellule de départ
    PVector cellCenter = _board.getCellCenter(_x, _y);
    _pos = cellCenter.copy();
    _offset = new PVector(0, 0);
    
    _direction = new PVector(0, 0);
    _nextDir = new PVector(0, 0);
    _bouge = false;
    _vitesse = PACMAN_SPEED;
    
    _size = PACMAN_SIZE;
    _angle = 0;
    _angleDir = 1;
    
    _dying = false;
    _timer = 0;
    _duration = 60; // 1 sec
  }
  
  // lancer un mouvement
  void launchMove(PVector dir) {
    // normaliser direction
    if (dir.mag() > 0) {
      _nextDir = dir.copy().normalize();
    }
  }
  
  // deplacement selon direction
  void move(Board board) {
    if (!_bouge) return;
    
    // nouvelle position
    PVector nextPos = PVector.add(_pos, PVector.mult(_direction, _vitesse));
    
    // Vérifier si on peut se déplacer (pas de mur)
    if (canMoveTo(nextPos, board)) {
      _pos = nextPos;
      
      // Mettre à jour la position de cellule
      updateCellPosition();
      
      // Téléportation : si sort d'un côté, réapparaît de l'autre
      checkTeleportation(board);
    } else {
      // Bloquer contre le mur : aligner sur le centre de la cellule
      PVector cellCenter = board.getCellCenter(_x, _y);
      
      // Aligner sur le centre de la cellule
      _pos = cellCenter.copy();
      
      // Arrêter le mouvement
      _bouge = false;
    }
  }
  
  // teleportation bords
  void checkTeleportation(Board board) {
    // horizontal
    if (_x < 0) {
      _x = board._nbX - 1;
      _pos.x = board._pos.x + _x * board._taille + board._taille / 2;
    } else if (_x >= board._nbX) {
      _x = 0;
      _pos.x = board._pos.x + _x * board._taille + board._taille / 2;
    }
    
    // Téléportation verticale (haut <-> bas) - optionnel
    if (_y < 0) {
      _y = board._nbY - 1;
      _pos.y = board._pos.y + _y * board._taille + board._taille / 2;
    } else if (_y >= board._nbY) {
      _y = 0;
      _pos.y = board._pos.y + _y * board._taille + board._taille / 2;
    }
  }
  
  // Vérifie si Pac-Man peut se déplacer à une position donnée
  boolean canMoveTo(PVector pos, Board board) {
    // Calculer les coordonnées de cellule pour cette position
    int cellX = floor((pos.x - board._pos.x) / board._taille);
    int cellY = floor((pos.y - board._pos.y) / board._taille);
    
    // Vérifier les limites et les murs
    return !board.isWall(cellX, cellY);
  }
  
  // Met à jour la position de cellule basée sur la position pixel
  void updateCellPosition() {
    _x = floor((_pos.x - _board._pos.x) / _board._taille);
    _y = floor((_pos.y - _board._pos.y) / _board._taille);
  }
  
  // Essaie de changer de direction (depuis le buffer _nextDir)
  void tryChangeDirection() {
    if (_nextDir.mag() == 0) return;  // Pas de nouvelle direction demandée
    
    // Vérifier si on est suffisamment centré sur une cellule
    PVector cellCenter = _board.getCellCenter(_x, _y);
    float distToCenter = PVector.dist(_pos, cellCenter);
    
    // Si on est proche du centre, essayer de changer de direction
    if (distToCenter < _vitesse * 2.5) {
      // Calculer la position après un mouvement dans la nouvelle direction
      PVector testPos = PVector.add(cellCenter, PVector.mult(_nextDir, _vitesse));
      
      if (canMoveTo(testPos, _board)) {
        // Changement possible : aligner sur le centre et changer de direction
        _pos = cellCenter.copy();
        _direction = _nextDir.copy();
        _bouge = true;
        _nextDir.set(0, 0);  // Reset du buffer
      }
    }
  }
  
  // Mise à jour générale de Pac-Man
  void update(Board board) {
    // Si en train de mourir, jouer l'animation
    if (_dying) {
      _timer++;
      
      // Ouvrir progressivement la bouche jusqu'à 180 degrés
      float progress = (float)_timer / _duration;
      _angle = 180 * progress;  // De 0 à 180 degrés
      
      return;  // Ne pas bouger pendant l'animation de mort
    }
    
    // Essayer de changer de direction si demandé
    tryChangeDirection();
    
    // Déplacer Pac-Man
    move(board);
    
    // Animer la bouche
    animateMouth();
    
    // Note: La vérification des gommes est maintenant gérée dans game.pde
  }
  
  // Déclenche l'animation de mort
  void die() {
    _dying = true;
    _timer = 0;
    _bouge = false;
  }
  
  // Retourne true si l'animation de mort est terminée
  boolean deathAnimationComplete() {
    return _dying && _timer >= _duration;
  }
  
  // Animation de la bouche (ouverture/fermeture)
  void animateMouth() {
    if (_bouge) {
      _angle += MOUTH_SPEED * _angleDir * 10;
      
      // Inverser la direction d'animation
      if (_angle >= MOUTH_ANGLE) {
        _angle = MOUTH_ANGLE;
        _angleDir = -1;
      } else if (_angle <= 0) {
        _angle = 0;
        _angleDir = 1;
      }
    } else {
      // Si immobile, bouche légèrement ouverte
      _angle = MOUTH_ANGLE * 0.3;
    }
  }
  
  // Affiche Pac-Man
  void drawIt() {
    // Si l'animation de mort est terminée, ne pas dessiner
    if (_dying && _timer >= _duration) {
      return;
    }
    
    // Calculer l'angle de rotation selon la direction
    float rotationAngle = 0;
    if (_direction.mag() > 0 && !_dying) {
      rotationAngle = atan2(_direction.y, _direction.x);
    }
    
    pushMatrix();
    translate(_pos.x, _pos.y);
    rotate(rotationAngle);
    
    // Calculer l'opacité pendant la mort (disparition progressive)
    float alpha = 255;
    if (_dying) {
      float progress = (float)_timer / _duration;
      alpha = 255 * (1 - progress);  // Disparaît progressivement
    }
    
    // Dessiner Pac-Man comme un "pac" (cercle avec bouche)
    fill(COLOR_PACMAN, alpha);
    noStroke();
    
    // Arc de cercle avec ouverture pour la bouche
    arc(0, 0, _size, _size, 
        radians(_angle), 
        radians(360 - _angle), 
        PIE);
    
    // Œil de Pac-Man (sauf pendant la mort)
    if (!_dying) {
      fill(0);
      float eyeX = _size * 0.15;
      float eyeY = -_size * 0.15;
      circle(eyeX, eyeY, _size * 0.12);
    }
    
    popMatrix();
  }
  
  // Retourne la position de cellule actuelle
  int getCellX() { return _x; }
  int getCellY() { return _y; }
  
  // Retourne la direction actuelle
  PVector getDirection() { return _direction.copy(); }
}

