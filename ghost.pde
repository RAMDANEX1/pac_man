// Classe Ghost
class Ghost {
  PVector _pos;
  
  int _x, _y;
  
  // Affichage
  float _size;
  color _color;
  String _name;
  
  // Déplacement
  PVector _direction;
  float _speed;
  float _vitesseNormale;  // Vitesse normale (vitesse de difficulté)
  boolean _bouge;
  
  boolean _peur;
  int _timerPeur;
  boolean _released;
  int _timerSortie;
  PVector _maison;
  boolean _eyes;
  int _timerBehav;
  
  Board _board;
  
  // DEBUG
  ArrayList<PVector> _chemin;
  int _compteurChemin;
  
  // Constructeur
  Ghost(Board board, int startCellX, int startCellY, color ghostColor, String name, int releaseDelay) {
    _board = board;
    _x = startCellX;
    _y = startCellY;
    _color = ghostColor;
    _name = name;
    _size = GHOST_SIZE;
    
    // Position pixel au centre de la cellule
    PVector cellCenter = _board.getCellCenter(_x, _y);
    _pos = cellCenter.copy();
    _maison = _pos.copy();
    
    // Initialisation du mouvement - direction aléatoire gauche ou droite
    float dirX = random(1) > 0.5 ? 1 : -1;
    _direction = new PVector(dirX, 0);
    _speed = GHOST_SPEED;
    _vitesseNormale = GHOST_SPEED;  // Mémoriser la vitesse normale
    _bouge = true;  // Commencer en mouvement
    
    // États initiaux
    _peur = false;
    _timerPeur = 0;
    _released = (releaseDelay == 0);
    _timerSortie = releaseDelay;
    _eyes = false;
    _timerBehav = 0;
    
    // Initialiser la trajectoire pour le debug
    _chemin = new ArrayList<PVector>();
    _compteurChemin = 0;
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
      _timerSortie--;
      if (_timerSortie <= 0) {
        _released = true;
      }
      // IMPORTANT : Les fantômes restent FIXES dans la cage tant que !_released
      return;
    }
    
    // Gestion du mode effrayé
    if (_peur) {
      _timerPeur--;
      if (_timerPeur <= 0) {
        _peur = false;
        // Restaurer la vitesse normale (vitesse de difficulté)
        _speed = _vitesseNormale;
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
    if (_x == homeX && _y == homeY) {
      PVector cellCenter = _board.getCellCenter(_x, _y);
      _pos = cellCenter.copy();
      
      // Redevenir vivant (V)
      _eyes = false;
      _peur = false;
      _timerPeur = 0;
      _released = false;
      _timerSortie = 180; // Attendre 3 secondes avant de ressortir
      _direction = new PVector(0, -1); // Direction vers le haut pour sortir
      _speed = _vitesseNormale;  // Restaurer la vitesse normale (vitesse de difficulté)
      
      // DEBUG - Effacer la trajectoire lors de la régénération
      _chemin.clear();
      return;
    }
    
    // vitesse rapide mode yeux
    _speed = GHOST_SPEED * 2;
    
    // calculer chemin vers maison
    ArrayList<PVector> pathCells = trouverChemin(_x, _y, homeX, homeY);
    
    // Vérifier si on est au centre d'une cellule
    PVector cellCenter = _board.getCellCenter(_x, _y);
    float distToCenter = PVector.dist(_pos, cellCenter);
    
    if (distToCenter < _speed * 1.5) {
      if (pathCells.size() >= 2) {
        // Au centre, prendre la direction vers la prochaine cellule du chemin BFS
        // pathCells[0] = position actuelle, pathCells[1] = prochaine cellule
        PVector nextCell = pathCells.get(1);
        
        // Calculer la direction vers la prochaine cellule
        int dirX = (int)nextCell.x - _x;
        int dirY = (int)nextCell.y - _y;
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
          int nextX = _x + (int)dir.x;
          int nextY = _y + (int)dir.y;
          
          if (!_board.isWall(nextX, nextY)) {
            possibleDirs.add(dir);
          }
        }
        
        // Choisir la direction qui rapproche le plus de la cage
        if (possibleDirs.size() > 0) {
          PVector bestDir = null;
          float bestDist = Float.MAX_VALUE;
          
          for (PVector dir : possibleDirs) {
            int nextX = _x + (int)dir.x;
            int nextY = _y + (int)dir.y;
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
  
  // choix direction selon comportement
  void chooseDirection(Hero hero) {
    // sortie de la cage
    boolean inCage = (_y == 10 && _x >= 9 && _x <= 13);
    boolean aboveCage = (_y == 9 && _x >= 9 && _x <= 13);
    
    if (inCage) {
      // Dans la cage : d'abord aller au centre (x=11), puis monter
      if (_x < 11) {
        _direction = new PVector(1, 0);  // Aller à droite vers le centre
      } else if (_x > 11) {
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
    PVector cellCenter = _board.getCellCenter(_x, _y);
    float distToCenter = PVector.dist(_pos, cellCenter);
    
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
        
        int nextX = _x + (int)dir.x;
        int nextY = _y + (int)dir.y;
        
        if (!_board.isWall(nextX, nextY)) {
          possibleDirs.add(dir);
        }
      }
      
      // Si aucune direction trouvée, autoriser le demi-tour
      if (possibleDirs.size() == 0) {
        for (PVector dir : directions) {
          int nextX = _x + (int)dir.x;
          int nextY = _y + (int)dir.y;
          
          if (!_board.isWall(nextX, nextY)) {
            possibleDirs.add(dir);
          }
        }
      }
      
      if (possibleDirs.size() > 0) {
        if (_peur) {
          // Mode effrayé : choisir aléatoirement
          _direction = possibleDirs.get((int)random(possibleDirs.size())).copy();
        } else {
          // choisir selon type fantome
          PVector targetCell = getTargetCell(hero);
          
          // calculer chemin vers cible
          ArrayList<PVector> pathCells = trouverChemin(_x, _y, (int)targetCell.x, (int)targetCell.y);
          
          // Si on a un chemin avec au moins 2 cellules (position actuelle + prochaine)
          if (pathCells.size() >= 2) {
            // Prendre la direction vers la prochaine cellule du chemin BFS
            PVector nextCell = pathCells.get(1);
            int dirX = (int)nextCell.x - _x;
            int dirY = (int)nextCell.y - _y;
            _direction = new PVector(dirX, dirY);
          } else {
            // Si pas de chemin, utiliser l'approche greedy comme fallback
            PVector bestDir = null;
            float bestDist = Float.MAX_VALUE;
            
            for (PVector dir : possibleDirs) {
              int nextX = _x + (int)dir.x;
              int nextY = _y + (int)dir.y;
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
  
  // cible selon type de fantome
  PVector getTargetCell(Hero hero) {
    if (hero == null) {
      return new PVector(_x, _y);
    }
    
    int heroX = hero.getCellX();
    int heroY = hero.getCellY();
    
    // comportements differents
    if (_name.equals("Blinky")) {
      // suit pacman directement
      return new PVector(heroX, heroY);
      
    } else if (_name.equals("Pinky")) {
      // anticipe mouvement
      PVector heroDir = hero.getDirection();
      int targetX = heroX + (int)(heroDir.x * 4);
      int targetY = heroY + (int)(heroDir.y * 4);
      return new PVector(targetX, targetY);
      
    } else if (_name.equals("Inky")) {
      // parfois part en direction opposee
      _timerBehav--;
      if (_timerBehav <= 0) {
        _timerBehav = (int)random(180, 300);
      }
      
      if (_timerBehav > 240) {
        // direction inverse
        int targetX = _x - (heroX - _x);
        int targetY = _y - (heroY - _y);
        return new PVector(targetX, targetY);
      } else {
        // Suit Pac-Man normalement
        return new PVector(heroX, heroY);
      }
      
    } else if (_name.equals("Clyde")) {
      // fuit quand trop proche
      float distToPacman = dist(_x, _y, heroX, heroY);
      
      if (distToPacman < 3) {
        // fuite
        int targetX = _x - (heroX - _x);
        int targetY = _y - (heroY - _y);
        return new PVector(targetX, targetY);
      } else {
        // Pas trop proche : comportement aléatoire/poursuite
        _timerBehav--;
        if (_timerBehav <= 0) {
          _timerBehav = (int)random(120, 240);
        }
        
        if (_timerBehav > 180) {
          // Direction aléatoire
          return new PVector(random(_board._nbX), random(_board._nbY));
        } else {
          // Suit Pac-Man
          return new PVector(heroX, heroY);
        }
      }
    }
    
    // Par défaut : suivre Pac-Man
    return new PVector(heroX, heroY);
  }
  
  // Déplace le fantôme
  void move() {
    PVector nextPos = PVector.add(_pos, PVector.mult(_direction, _speed));
    
    if (canMoveTo(nextPos)) {
      _pos = nextPos;
      updateCellPosition();
      
      // Téléportation pour les fantômes aussi
      checkTeleportation();
    } else {
      // Si bloqué, aligner sur le centre de la cellule et forcer un nouveau choix
      PVector cellCenter = _board.getCellCenter(_x, _y);
      _pos = cellCenter.copy();
      
      // Chercher une direction valide immédiatement
      PVector[] directions = {
        new PVector(0, -1), new PVector(0, 1), 
        new PVector(-1, 0), new PVector(1, 0)
      };
      
      for (PVector dir : directions) {
        int nextX = _x + (int)dir.x;
        int nextY = _y + (int)dir.y;
        if (!_board.isWall(nextX, nextY)) {
          _direction = dir.copy();
          break;
        }
      }
    }
  }
  
  // Vérifie si le fantôme peut se déplacer à une position
  boolean canMoveTo(PVector pos) {
    int cellX = floor((pos.x - _board._pos.x) / _board._taille);
    int cellY = floor((pos.y - _board._pos.y) / _board._taille);
    
    // Vérifier si c'est un mur
    if (_board.isWall(cellX, cellY)) return false;
    
    // Les fantômes released ne peuvent pas rentrer dans la cage (SAUF en mode yeux OU s'ils sont déjà dans la cage)
    if (!_eyes) {
      boolean targetInCage = (cellY == 10 && cellX >= 9 && cellX <= 13);
      boolean currentInCage = (_y == 10 && _x >= 9 && _x <= 13);
      
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
    _x = floor((_pos.x - _board._pos.x) / _board._taille);
    _y = floor((_pos.y - _board._pos.y) / _board._taille);
  }
  
  // Téléportation entre les bords de la carte
  void checkTeleportation() {
    // Téléportation horizontale (gauche <-> droite)
    if (_x < 0) {
      _x = _board._nbX - 1;
      _pos.x = _board._pos.x + _x * _board._taille + _board._taille / 2;
    } else if (_x >= _board._nbX) {
      _x = 0;
      _pos.x = _board._pos.x + _x * _board._taille + _board._taille / 2;
    }
    
    // Téléportation verticale (haut <-> bas) - optionnel
    if (_y < 0) {
      _y = _board._nbY - 1;
      _pos.y = _board._pos.y + _y * _board._taille + _board._taille / 2;
    } else if (_y >= _board._nbY) {
      _y = 0;
      _pos.y = _board._pos.y + _y * _board._taille + _board._taille / 2;
    }
  }
  
  // Active le mode effrayé (quand Pac-Man mange une super-gomme)
  void scare(int duration, float scaredSpeed, float scaredSpeedClyde) {
    // Ne pas effrayer les fantômes en mode yeux ou non-released
    if (_eyes || !_released) return;
    
    _peur = true;
    _timerPeur = duration;
    
    // Clyde (orange) est un peu plus rapide que les autres en mode effrayé
    if (_name.equals("Clyde")) {
      _speed = scaredSpeedClyde;
    } else {
      _speed = scaredSpeed;
    }
  }
  
  // Réinitialise le fantôme (quand Pac-Man est mangé OU après être mangé par Pac-Man)
  void reset() {
    // Retourner à la position de départ
    _pos = _maison.copy();
    _x = (int)((_pos.x - _board._pos.x) / _board._taille);
    _y = (int)((_pos.y - _board._pos.y) / _board._taille);
    
    // Réinitialiser les états
    _peur = false;
    _timerPeur = 0;
    _eyes = false;
    // NE PAS réinitialiser _speed ici pour garder la vitesse de difficulté
    
    // Si c'était Blinky (déjà released au départ), rester released
    // Les autres retournent dans la cage
    if (_timerSortie == 0 && _name.equals("Blinky")) {
      _released = true;
    } else {
      _released = false;
      // Réinitialiser les timers de sortie
      if (_name.equals("Pinky")) _timerSortie = 60;
      else if (_name.equals("Inky")) _timerSortie = 120;
      else if (_name.equals("Clyde")) _timerSortie = 180;
    }
  }
  
  // Vérifie la collision avec Pac-Man
  boolean collidesWith(Hero hero) {
    if (!_released || _eyes) return false; // Pas de collision si dans la cage ou en mode yeux
    return dist(_pos.x, _pos.y, hero._pos.x, hero._pos.y) < (_size + hero._size) * 0.4;
  }
  
  // DEBUG - Met à jour la trajectoire du fantôme (où il VA, pas d'où il vient)
  void updatePath(Hero hero) {
    if (!DEBUG_GHOST_PATH) return;
    
    // Effacer l'ancienne trajectoire
    _chemin.clear();
    
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
        targetCell = new PVector(_x, _y);
      }
    }
    
    // calculer chemin complet
    ArrayList<PVector> path = trouverChemin(_x, _y, (int)targetCell.x, (int)targetCell.y);
    
    // Convertir les cellules en positions pixels
    for (PVector cell : path) {
      PVector pixelPos = _board.getCellCenter((int)cell.x, (int)cell.y);
      _chemin.add(pixelPos);
    }
  }
  
  // Trouve le meilleur chemin entre deux points
  ArrayList<PVector> trouverChemin(int startX, int startY, int endX, int endY) {
    ArrayList<PVector> path = new ArrayList<PVector>();
    
    // verifier si destination valide
    if (endX < 0 || endX >= _board._nbX || endY < 0 || endY >= _board._nbY) {
      path.add(new PVector(startX, startY));
      return path;
    }
    
    // recherche du chemin
    ArrayList<PVector> queue = new ArrayList<PVector>();
    boolean[][] visited = new boolean[_board._nbX][_board._nbY];
    HashMap<String, PVector> parent = new HashMap<String, PVector>();
    
    queue.add(new PVector(startX, startY));
    visited[startX][startY] = true;
    
    boolean found = false;
    PVector[] directions = {
      new PVector(0, -1),  // haut
      new PVector(0, 1),   // bas
      new PVector(-1, 0),  // gauche
      new PVector(1, 0)    // droite
    };
    
    // chercher le chemin
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
        if (nx >= 0 && nx < _board._nbX && 
            ny >= 0 && ny < _board._nbY &&
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
    if (!DEBUG_GHOST_PATH || _chemin.size() < 2) return;
    
    pushStyle();
    noFill();
    strokeWeight(3);
    
    // Utiliser la couleur du fantôme avec transparence
    color pathColor;
    if (_peur) {
      pathColor = COLOR_GHOST_SCARED;
    } else if (_eyes) {
      pathColor = color(255, 255, 255);
    } else {
      pathColor = _color;
    }
    
    stroke(red(pathColor), green(pathColor), blue(pathColor), 150);
    
    // Dessiner les lignes entre les points
    for (int i = 0; i < _chemin.size() - 1; i++) {
      PVector p1 = _chemin.get(i);
      PVector p2 = _chemin.get(i + 1);
      line(p1.x, p1.y, p2.x, p2.y);
    }
    
    // Dessiner de petits cercles aux points clés (tous les 3 points)
    fill(red(pathColor), green(pathColor), blue(pathColor), 200);
    noStroke();
    for (int i = 0; i < _chemin.size(); i += 3) {
      PVector p = _chemin.get(i);
      ellipse(p.x, p.y, 5, 5);
    }
    
    // Dessiner la cible (dernier point) avec un X
    if (_chemin.size() > 0) {
      PVector target = _chemin.get(_chemin.size() - 1);
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
  
  // affichage fantome
  void drawIt() {
    // trajectoire debug
    drawPath();
    
    // dessin du fantome
    pushMatrix();
    translate(_pos.x, _pos.y);
    
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
      
    } else if (_peur) {
      // Fantôme effrayé : bleu avec clignotement vers la fin
      if (_timerPeur < 100 && frameCount % 20 < 10) {
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
  boolean isScared() { return _peur; }
  boolean isReleased() { return _released; }
  int getCellX() { return _x; }
  int getCellY() { return _y; }
}



