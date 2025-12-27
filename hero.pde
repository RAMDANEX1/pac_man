// ===== CLASSE HERO : PAC-MAN =====
class Hero {
  // Position à l'écran (coordonnées pixel)
  PVector _position;
  PVector _posOffset;        // Offset par rapport au centre de la cellule
  PImage spriteSheet;  // Ajouter cette ligne
  PImage[] sprites;    // Pour stocker les frames d'animation
  // Position sur le plateau (coordonnées grille)
  int _cellX, _cellY;
  
  // Affichage
  float _size;               // Taille de Pac-Man
  float _mouthAngle;         // Angle actuel de la bouche (pour animation)
  float _mouthDirection;     // Direction de l'animation (ouverture/fermeture)
  
  // Déplacement
  PVector _direction;        // Direction actuelle (normalisée)
  PVector _nextDirection;    // Direction demandée par le joueur (buffer)
  boolean _moving;           // Est en mouvement ?
  float _speed;              // Vitesse en pixels par frame
  
  // Référence au plateau pour les collisions
  Board _board;
  
  // Constructeur : initialise Pac-Man à une position donnée
  Hero(Board board, int startCellX, int startCellY) {
    _board = board;
    _cellX = startCellX;
    _cellY = startCellY;
    
    // Position pixel au centre de la cellule de départ
    PVector cellCenter = _board.getCellCenter(_cellX, _cellY);
    _position = cellCenter.copy();
    _posOffset = new PVector(0, 0);
    
    // Initialisation du mouvement
    _direction = new PVector(0, 0);      // Immobile au départ
    _nextDirection = new PVector(0, 0);  // Pas de direction demandée
    _moving = false;
    _speed = PACMAN_SPEED;
    
    // Initialisation de l'apparence
    _size = PACMAN_SIZE;
    _mouthAngle = 0;
    _mouthDirection = 1;  // 1 = ouverture, -1 = fermeture
  }
  
  // Lance un mouvement dans une direction donnée
  void launchMove(PVector dir) {
    // Normaliser la direction (pour avoir un vecteur unitaire)
    if (dir.mag() > 0) {
      _nextDirection = dir.copy().normalize();
    }
  }
  
  // Déplace Pac-Man selon la direction actuelle
  void move(Board board) {
    if (!_moving) return;
    
    // Calculer la nouvelle position potentielle
    PVector nextPos = PVector.add(_position, PVector.mult(_direction, _speed));
    
    // Vérifier si on peut se déplacer (pas de mur)
    if (canMoveTo(nextPos, board)) {
      _position = nextPos;
      
      // Mettre à jour la position de cellule
      updateCellPosition();
    } else {
      // Bloquer contre le mur : aligner sur le centre de la cellule
      PVector cellCenter = board.getCellCenter(_cellX, _cellY);
      
      // Aligner sur le centre de la cellule
      _position = cellCenter.copy();
      
      // Arrêter le mouvement
      _moving = false;
    }
  }
  
  // Vérifie si Pac-Man peut se déplacer à une position donnée
  boolean canMoveTo(PVector pos, Board board) {
    // Calculer les coordonnées de cellule pour cette position
    int cellX = floor((pos.x - board._position.x) / board._cellSize);
    int cellY = floor((pos.y - board._position.y) / board._cellSize);
    
    // Vérifier les limites et les murs
    return !board.isWall(cellX, cellY);
  }
  
  // Met à jour la position de cellule basée sur la position pixel
  void updateCellPosition() {
    _cellX = floor((_position.x - _board._position.x) / _board._cellSize);
    _cellY = floor((_position.y - _board._position.y) / _board._cellSize);
  }
  
  // Essaie de changer de direction (depuis le buffer _nextDirection)
  void tryChangeDirection() {
    if (_nextDirection.mag() == 0) return;  // Pas de nouvelle direction demandée
    
    // Vérifier si on est suffisamment centré sur une cellule
    PVector cellCenter = _board.getCellCenter(_cellX, _cellY);
    float distToCenter = PVector.dist(_position, cellCenter);
    
    // Si on est proche du centre, essayer de changer de direction
    if (distToCenter < _speed * 2.5) {
      // Calculer la position après un mouvement dans la nouvelle direction
      PVector testPos = PVector.add(cellCenter, PVector.mult(_nextDirection, _speed));
      
      if (canMoveTo(testPos, _board)) {
        // Changement possible : aligner sur le centre et changer de direction
        _position = cellCenter.copy();
        _direction = _nextDirection.copy();
        _moving = true;
        _nextDirection.set(0, 0);  // Reset du buffer
      }
    }
  }
  
  // Mise à jour générale de Pac-Man
  void update(Board board) {
    // Essayer de changer de direction si demandé
    tryChangeDirection();
    
    // Déplacer Pac-Man
    move(board);
    
    // Animer la bouche
    animateMouth();
    
    // Note: La vérification des gommes est maintenant gérée dans game.pde
  }
  
  // Animation de la bouche (ouverture/fermeture)
  void animateMouth() {
    if (_moving) {
      _mouthAngle += MOUTH_SPEED * _mouthDirection * 10;
      
      // Inverser la direction d'animation
      if (_mouthAngle >= MOUTH_ANGLE) {
        _mouthAngle = MOUTH_ANGLE;
        _mouthDirection = -1;
      } else if (_mouthAngle <= 0) {
        _mouthAngle = 0;
        _mouthDirection = 1;
      }
    } else {
      // Si immobile, bouche légèrement ouverte
      _mouthAngle = MOUTH_ANGLE * 0.3;
    }
  }
  
  // Affiche Pac-Man
  void drawIt() {
    // Calculer l'angle de rotation selon la direction
    float rotationAngle = 0;
    if (_direction.mag() > 0) {
      rotationAngle = atan2(_direction.y, _direction.x);
    }
    
    pushMatrix();
    translate(_position.x, _position.y);
    rotate(rotationAngle);
    
    // Dessiner Pac-Man comme un "pac" (cercle avec bouche)
    fill(COLOR_PACMAN);
    noStroke();
    
    // Arc de cercle avec ouverture pour la bouche
    arc(0, 0, _size, _size, 
        radians(_mouthAngle), 
        radians(360 - _mouthAngle), 
        PIE);
    
    // Œil de Pac-Man
    fill(0);
    float eyeX = _size * 0.15;
    float eyeY = -_size * 0.15;
    circle(eyeX, eyeY, _size * 0.12);
    
    popMatrix();
  }
  
  // Retourne la position de cellule actuelle
  int getCellX() { return _cellX; }
  int getCellY() { return _cellY; }
  
  // Retourne la direction actuelle
  PVector getDirection() { return _direction.copy(); }
}
