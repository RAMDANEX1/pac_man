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
  boolean _eyes;             // Mode yeux (retour à la cage après être mangé)
  int _behaviorTimer;        // Timer pour comportements aléatoires
  
  // Référence au plateau
  Board _board;
  
  // DEBUG - Trajectoire
  ArrayList<PVector> _pathPoints;      // Liste des points de la trajectoire
  int _pathUpdateCounter;              // Compteur pour espacer les points
  
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
    _eyes = false;
    _behaviorTimer = 0;
    
    // Initialiser la trajectoire pour le debug
    _pathPoints = new ArrayList<PVector>();
    _pathUpdateCounter = 0;
  }
  
  // Mise à jour du fantôme
  void update(Hero hero) {
    // Mode yeux : retour à la cage
    if (_eyes) {
      returnToHome();
      return;
    }
    
    // Gestion du timer de sortie
    if (!_released) {
      _releaseTimer--;
      if (_releaseTimer <= 0) {
        _released = true;
      }
      // IMPORTANT : Les fantômes restent FIXES dans la cage tant que !_released
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
    
    // IA : choisir une direction (seulement si released)
    chooseDirection(hero);
    move();
    
    // DEBUG - Mettre à jour la trajectoire avec le héros
    updatePath(hero);
  }
  
  // Retour à la cage en mode yeux
  void returnToHome() {
    // Destination : centre de la cage
    int homeX = 11;
    int homeY = 10;
    
    // Si arrivé à la cage, se régénérer
    if (_cellX == homeX && _cellY == homeY) {
      PVector cellCenter = _board.getCellCenter(_cellX, _cellY);
      _position = cellCenter.copy();
      
      // Redevenir vivant (V)
      _eyes = false;
      _scared = false;
      _scaredTimer = 0;
      _released = false;
      _releaseTimer = 180; // Attendre 3 secondes avant de ressortir
      _direction = new PVector(0, -1); // Direction vers le haut pour sortir
      _speed = GHOST_SPEED;
      
      // DEBUG - Effacer la trajectoire lors de la régénération
      _pathPoints.clear();
      return;
    }
    
    // Vitesse plus rapide en mode yeux
    _speed = GHOST_SPEED * 2;
    
    // Utiliser le chemin BFS calculé pour suivre exactement la trajectoire affichée
    // Calculer le chemin avec BFS
    ArrayList<PVector> pathCells = calculatePath(_cellX, _cellY, homeX, homeY);
    
    // Vérifier si on est au centre d'une cellule
    PVector cellCenter = _board.getCellCenter(_cellX, _cellY);
    float distToCenter = PVector.dist(_position, cellCenter);
    
    if (distToCenter < _speed * 1.5) {
      if (pathCells.size() >= 2) {
        // Au centre, prendre la direction vers la prochaine cellule du chemin BFS
        // pathCells[0] = position actuelle, pathCells[1] = prochaine cellule
        PVector nextCell = pathCells.get(1);
        
        // Calculer la direction vers la prochaine cellule
        int dirX = (int)nextCell.x - _cellX;
        int dirY = (int)nextCell.y - _cellY;
        _direction = new PVector(dirX, dirY);
      } else {
        // Si pas de chemin BFS trouvé (bloqué), utiliser approche greedy comme fallback
        ArrayList<PVector> possibleDirs = new ArrayList<PVector>();
        PVector[] directions = {
          new PVector(0, -1),  // Haut
          new PVector(0, 1),   // Bas
          new PVector(-1, 0),  // Gauche
          new PVector(1, 0)    // Droite
        };
        
        for (PVector dir : directions) {
          int nextX = _cellX + (int)dir.x;
          int nextY = _cellY + (int)dir.y;
          
          if (!_board.isWall(nextX, nextY)) {
            possibleDirs.add(dir);
          }
        }
        
        // Choisir la direction qui rapproche le plus de la cage
        if (possibleDirs.size() > 0) {
          PVector bestDir = null;
          float bestDist = Float.MAX_VALUE;
          
          for (PVector dir : possibleDirs) {
            int nextX = _cellX + (int)dir.x;
            int nextY = _cellY + (int)dir.y;
            float d = dist(nextX, nextY, homeX, homeY);
            
            if (d < bestDist) {
              bestDist = d;
              bestDir = dir;
            }
          }
          
          if (bestDir != null) {
            _direction = bestDir.copy();
          }
        }
      }
    }
    
    // Déplacer normalement (avec collisions)
    move();
    
    // DEBUG - Mettre à jour la trajectoire (pas de héros nécessaire pour le mode yeux)
    updatePath(null);
  }
  
  // IA avec comportements spécifiques selon le fantôme
  void chooseDirection(Hero hero) {
    // Si dans la cage, logique spéciale de sortie
    boolean inCage = (_cellY == 10 && _cellX >= 9 && _cellX <= 13);
    boolean aboveCage = (_cellY == 9 && _cellX >= 9 && _cellX <= 13);
    
    if (inCage) {
      // Dans la cage : d'abord aller au centre (x=11), puis monter
      if (_cellX < 11) {
        _direction = new PVector(1, 0);  // Aller à droite vers le centre
      } else if (_cellX > 11) {
        _direction = new PVector(-1, 0);  // Aller à gauche vers le centre
      } else {
        _direction = new PVector(0, -1);  // Au centre, monter
      }
      return;
    }
    
    if (aboveCage) {
      _direction = new PVector(0, -1);  // Au-dessus de la cage, continuer à monter
      return;
    }
    
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
          // Choisir selon le type de fantôme en utilisant le chemin BFS
          PVector targetCell = getTargetCell(hero);
          
          // Calculer le chemin BFS vers la cible
          ArrayList<PVector> pathCells = calculatePath(_cellX, _cellY, (int)targetCell.x, (int)targetCell.y);
          
          // Si on a un chemin avec au moins 2 cellules (position actuelle + prochaine)
          if (pathCells.size() >= 2) {
            // Prendre la direction vers la prochaine cellule du chemin BFS
            PVector nextCell = pathCells.get(1);
            int dirX = (int)nextCell.x - _cellX;
            int dirY = (int)nextCell.y - _cellY;
            _direction = new PVector(dirX, dirY);
          } else {
            // Si pas de chemin, utiliser l'approche greedy comme fallback
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
      // INKY (bleu/cyan) : de temps en temps, part dans la direction opposée
      _behaviorTimer--;
      if (_behaviorTimer <= 0) {
        _behaviorTimer = (int)random(180, 300); // Change tous les 3-5 secondes
      }
      
      if (_behaviorTimer > 240) {
        // Direction opposée de Pac-Man
        int targetX = _cellX - (heroX - _cellX);
        int targetY = _cellY - (heroY - _cellY);
        return new PVector(targetX, targetY);
      } else {
        // Suit Pac-Man normalement
        return new PVector(heroX, heroY);
      }
      
    } else if (_name.equals("Clyde")) {
      // CLYDE (orange) : de temps en temps, change de direction aléatoirement
      _behaviorTimer--;
      if (_behaviorTimer <= 0) {
        _behaviorTimer = (int)random(120, 240); // Change tous les 2-4 secondes
      }
      
      if (_behaviorTimer > 180) {
        // Direction aléatoire
        return new PVector(random(_board._nbCellsX), random(_board._nbCellsY));
      } else {
        // Suit Pac-Man
        return new PVector(heroX, heroY);
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
      
      // Téléportation pour les fantômes aussi
      checkTeleportation();
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
    
    // Vérifier si c'est un mur
    if (_board.isWall(cellX, cellY)) return false;
    
    // Les fantômes released ne peuvent pas rentrer dans la cage (SAUF en mode yeux OU s'ils sont déjà dans la cage)
    if (!_eyes) {
      boolean targetInCage = (cellY == 10 && cellX >= 9 && cellX <= 13);
      boolean currentInCage = (_cellY == 10 && _cellX >= 9 && _cellX <= 13);
      
      // Empêcher entrée dans cage si released et pas dans cage actuellement
      // MAIS permettre le mouvement dans la cage si on y est déjà (pour sortir)
      if (_released && !currentInCage && targetInCage) {
        return false;
      }
    }
    
    return true;
  }
  
  // Met à jour la position de cellule
  void updateCellPosition() {
    _cellX = floor((_position.x - _board._position.x) / _board._cellSize);
    _cellY = floor((_position.y - _board._position.y) / _board._cellSize);
  }
  
  // Téléportation entre les bords de la carte
  void checkTeleportation() {
    // Téléportation horizontale (gauche <-> droite)
    if (_cellX < 0) {
      _cellX = _board._nbCellsX - 1;
      _position.x = _board._position.x + _cellX * _board._cellSize + _board._cellSize / 2;
    } else if (_cellX >= _board._nbCellsX) {
      _cellX = 0;
      _position.x = _board._position.x + _cellX * _board._cellSize + _board._cellSize / 2;
    }
    
    // Téléportation verticale (haut <-> bas) - optionnel
    if (_cellY < 0) {
      _cellY = _board._nbCellsY - 1;
      _position.y = _board._position.y + _cellY * _board._cellSize + _board._cellSize / 2;
    } else if (_cellY >= _board._nbCellsY) {
      _cellY = 0;
      _position.y = _board._position.y + _cellY * _board._cellSize + _board._cellSize / 2;
    }
  }
  
  // Active le mode effrayé (quand Pac-Man mange une super-gomme)
  void scare() {
    // Ne pas effrayer les fantômes en mode yeux ou non-released
    if (_eyes || !_released) return;
    
    _scared = true;
    _scaredTimer = GHOST_SCARED_TIME;
    
    // Clyde (orange) est un peu plus rapide que les autres en mode effrayé
    if (_name.equals("Clyde")) {
      _speed = GHOST_SCARED_SPEED_CLYDE;
    } else {
      _speed = GHOST_SCARED_SPEED;
    }
  }
  
  // Réinitialise le fantôme (quand Pac-Man est mangé OU après être mangé par Pac-Man)
  void reset() {
    // Retourner à la position de départ
    _position = _homePosition.copy();
    _cellX = (int)((_position.x - _board._position.x) / _board._cellSize);
    _cellY = (int)((_position.y - _board._position.y) / _board._cellSize);
    
    // Réinitialiser les états
    _scared = false;
    _scaredTimer = 0;
    _eyes = false;
    _speed = GHOST_SPEED;
    
    // Si c'était Blinky (déjà released au départ), rester released
    // Les autres retournent dans la cage
    if (_releaseTimer == 0 && _name.equals("Blinky")) {
      _released = true;
    } else {
      _released = false;
      // Réinitialiser les timers de sortie
      if (_name.equals("Pinky")) _releaseTimer = 60;
      else if (_name.equals("Inky")) _releaseTimer = 120;
      else if (_name.equals("Clyde")) _releaseTimer = 180;
    }
  }
  
  // Vérifie la collision avec Pac-Man
  boolean collidesWith(Hero hero) {
    if (!_released || _eyes) return false; // Pas de collision si dans la cage ou en mode yeux
    return dist(_position.x, _position.y, hero._position.x, hero._position.y) < (_size + hero._size) * 0.4;
  }
  
  // DEBUG - Met à jour la trajectoire du fantôme (où il VA, pas d'où il vient)
  void updatePath(Hero hero) {
    if (!DEBUG_GHOST_PATH) return;
    
    // Effacer l'ancienne trajectoire
    _pathPoints.clear();
    
    // Si pas released, ne pas afficher de trajectoire
    if (!_released && !_eyes) return;
    
    // Déterminer la cible selon le mode
    PVector targetCell;
    if (_eyes) {
      // Mode yeux : cible = cage
      targetCell = new PVector(11, 10);
    } else {
      // Mode normal : cible déterminée par l'IA
      targetCell = getTargetCell(hero);
      if (targetCell == null) {
        targetCell = new PVector(_cellX, _cellY);
      }
    }
    
    // Calculer le chemin complet avec pathfinding
    ArrayList<PVector> path = calculatePath(_cellX, _cellY, (int)targetCell.x, (int)targetCell.y);
    
    // Convertir les cellules en positions pixels
    for (PVector cell : path) {
      PVector pixelPos = _board.getCellCenter((int)cell.x, (int)cell.y);
      _pathPoints.add(pixelPos);
    }
  }
  
  // Calcule le chemin du point A au point B en utilisant un algorithme de pathfinding simplifié
  ArrayList<PVector> calculatePath(int startX, int startY, int endX, int endY) {
    ArrayList<PVector> path = new ArrayList<PVector>();
    
    // Si hors limites, retourner chemin vide
    if (endX < 0 || endX >= _board._nbCellsX || endY < 0 || endY >= _board._nbCellsY) {
      path.add(new PVector(startX, startY));
      return path;
    }
    
    // Utiliser BFS (Breadth-First Search) pour trouver le chemin
    ArrayList<PVector> queue = new ArrayList<PVector>();
    boolean[][] visited = new boolean[_board._nbCellsX][_board._nbCellsY];
    HashMap<String, PVector> parent = new HashMap<String, PVector>();
    
    queue.add(new PVector(startX, startY));
    visited[startX][startY] = true;
    
    boolean found = false;
    PVector[] directions = {
      new PVector(0, -1),  // Haut
      new PVector(0, 1),   // Bas
      new PVector(-1, 0),  // Gauche
      new PVector(1, 0)    // Droite
    };
    
    // BFS pour trouver le chemin le plus court
    while (queue.size() > 0 && !found) {
      PVector current = queue.remove(0);
      int cx = (int)current.x;
      int cy = (int)current.y;
      
      // Si on a atteint la cible
      if (cx == endX && cy == endY) {
        found = true;
        break;
      }
      
      // Explorer les voisins
      for (PVector dir : directions) {
        int nx = cx + (int)dir.x;
        int ny = cy + (int)dir.y;
        
        // Vérifier si valide et pas visité
        if (nx >= 0 && nx < _board._nbCellsX && 
            ny >= 0 && ny < _board._nbCellsY &&
            !visited[nx][ny] && !_board.isWall(nx, ny)) {
          
          // Gérer la cage : les fantômes normaux ne peuvent pas y entrer SAUF si c'est la destination
          boolean targetInCage = (ny == 10 && nx >= 9 && nx <= 13);
          if (!_eyes && targetInCage) {
            // Les fantômes normaux ne peuvent pas entrer dans la cage
            // SAUF si c'est la destination finale (rare mais possible)
            if (!(nx == endX && ny == endY)) {
              continue;
            }
          }
          
          visited[nx][ny] = true;
          queue.add(new PVector(nx, ny));
          parent.put(nx + "," + ny, current);
        }
      }
      
      // Limiter la recherche pour les performances (augmenté pour les yeux)
      if (queue.size() > 200) break;
    }
    
    // Reconstruire le chemin
    if (found) {
      ArrayList<PVector> reversePath = new ArrayList<PVector>();
      PVector current = new PVector(endX, endY);
      
      while (current != null) {
        reversePath.add(current);
        String key = (int)current.x + "," + (int)current.y;
        current = parent.get(key);
        
        // Éviter boucle infinie
        if (reversePath.size() > 200) break;
      }
      
      // Inverser le chemin
      for (int i = reversePath.size() - 1; i >= 0; i--) {
        path.add(reversePath.get(i));
      }
    } else {
      // Si pas de chemin trouvé, juste ajouter la position actuelle
      path.add(new PVector(startX, startY));
    }
    
    return path;
  }
  
  // DEBUG - Affiche la trajectoire du fantôme
  void drawPath() {
    if (!DEBUG_GHOST_PATH || _pathPoints.size() < 2) return;
    
    pushStyle();
    noFill();
    strokeWeight(3);
    
    // Utiliser la couleur du fantôme avec transparence
    color pathColor;
    if (_scared) {
      pathColor = COLOR_GHOST_SCARED;
    } else if (_eyes) {
      pathColor = color(255, 255, 255);
    } else {
      pathColor = _color;
    }
    
    stroke(red(pathColor), green(pathColor), blue(pathColor), 150);
    
    // Dessiner les lignes entre les points
    for (int i = 0; i < _pathPoints.size() - 1; i++) {
      PVector p1 = _pathPoints.get(i);
      PVector p2 = _pathPoints.get(i + 1);
      line(p1.x, p1.y, p2.x, p2.y);
    }
    
    // Dessiner de petits cercles aux points clés (tous les 3 points)
    fill(red(pathColor), green(pathColor), blue(pathColor), 200);
    noStroke();
    for (int i = 0; i < _pathPoints.size(); i += 3) {
      PVector p = _pathPoints.get(i);
      ellipse(p.x, p.y, 5, 5);
    }
    
    // Dessiner la cible (dernier point) avec un X
    if (_pathPoints.size() > 0) {
      PVector target = _pathPoints.get(_pathPoints.size() - 1);
      stroke(red(pathColor), green(pathColor), blue(pathColor), 255);
      strokeWeight(2);
      float crossSize = 8;
      line(target.x - crossSize, target.y - crossSize, target.x + crossSize, target.y + crossSize);
      line(target.x - crossSize, target.y + crossSize, target.x + crossSize, target.y - crossSize);
      
      // Cercle autour de la cible
      noFill();
      stroke(red(pathColor), green(pathColor), blue(pathColor), 150);
      ellipse(target.x, target.y, crossSize * 3, crossSize * 3);
    }
    
    popStyle();
  }
  
  // Affiche le fantôme
  void drawIt() {
    // DEBUG - Afficher d'abord la trajectoire (sous le fantôme)
    drawPath();
    
    // Toujours afficher le fantôme (même dans la cage)
    pushMatrix();
    translate(_position.x, _position.y);
    
    if (_eyes) {
      // Mode yeux : juste des yeux blancs
      fill(255);
      noStroke();
      
      // Yeux (deux cercles blancs)
      ellipse(-_size * 0.2, 0, _size * 0.35, _size * 0.4);
      ellipse(_size * 0.2, 0, _size * 0.35, _size * 0.4);
      
      // Pupilles bleues
      fill(0, 0, 255);
      ellipse(-_size * 0.2, 0, _size * 0.15, _size * 0.2);
      ellipse(_size * 0.2, 0, _size * 0.15, _size * 0.2);
      
    } else if (_scared) {
      // Fantôme effrayé : bleu avec clignotement vers la fin
      if (_scaredTimer < 100 && frameCount % 20 < 10) {
        fill(255, 255, 255); // Blanc clignotant
      } else {
        fill(COLOR_GHOST_SCARED);
      }
      noStroke();
      
      // Corps arrondi
      arc(0, -_size * 0.15, _size, _size * 0.8, PI, TWO_PI, CHORD);
      rect(-_size/2, -_size * 0.15, _size, _size * 0.5);
      
      // Bas ondulé
      for (int i = 0; i < 4; i++) {
        float x = -_size/2 + i * _size/4;
        arc(x + _size/8, _size * 0.35, _size/4, _size * 0.3, 0, PI, CHORD);
      }
      
      // Yeux effrayés (blancs)
      fill(255);
      ellipse(-_size * 0.2, -_size * 0.1, _size * 0.25, _size * 0.3);
      ellipse(_size * 0.2, -_size * 0.1, _size * 0.25, _size * 0.3);
      
    } else {
      // Fantôme normal avec couleur
      fill(_color);
      noStroke();
      
      // Corps arrondi (demi-cercle en haut)
      arc(0, -_size * 0.15, _size, _size * 0.8, PI, TWO_PI, CHORD);
      rect(-_size/2, -_size * 0.15, _size, _size * 0.5);
      
      // Bas ondulé (4 petites vagues)
      for (int i = 0; i < 4; i++) {
        float x = -_size/2 + i * _size/4;
        arc(x + _size/8, _size * 0.35, _size/4, _size * 0.3, 0, PI, CHORD);
      }
      
      // Yeux blancs
      fill(COLOR_GHOST_EYES);
      ellipse(-_size * 0.2, -_size * 0.1, _size * 0.3, _size * 0.35);
      ellipse(_size * 0.2, -_size * 0.1, _size * 0.3, _size * 0.35);
      
      // Pupilles (regardent vers Pac-Man si disponible)
      fill(0, 0, 200);
      ellipse(-_size * 0.2, -_size * 0.05, _size * 0.12, _size * 0.15);
      ellipse(_size * 0.2, -_size * 0.05, _size * 0.12, _size * 0.15);
    }
    
    popMatrix();
  }
  
  // Getters
  boolean isScared() { return _scared; }
  boolean isReleased() { return _released; }
  int getCellX() { return _cellX; }
  int getCellY() { return _cellY; }
}
