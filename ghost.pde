// classe pour les fantomes (la partie intelligente  du projet)
// chaque fantome a son propre comportement
class Ghost {
  PVector pos;
  
  int x, y;
  
  // affichage
  float size;
  color couleur;
  String nom;
  
  // deplacement
  PVector direction;
  float speed;
  float vitesseNormale;  // vitesse normale selon difficulte
  boolean bouge;
  
  boolean peur;  // mode peur apres super gomme
  int timerPeur;
  boolean released;
  int timerSortie;
  PVector maison;
  boolean eyes;
  int timerBehav;
  
  Board board;
  
  // debug
  ArrayList<PVector> chemin;
  int compteurChemin;
  
  // constructeur
  Ghost(Board b, int startCellX, int startCellY, color ghostColor, String name, int releaseDelay) {
    board = b;
    x = startCellX;
    y = startCellY;
    couleur = ghostColor;
    nom = name;
    size = GHOST_SIZE;
    
    // pos pixel au centre cellule
    PVector cellCenter = board.getCellCenter(x, y);
    pos = cellCenter.copy();
    maison = pos.copy();
    
    // init mouvement - dir aleatoire gauche ou droite
    float dirX = random(1) > 0.5 ? 1 : -1;
    direction = new PVector(dirX, 0);
    speed = GHOST_SPEED;
    vitesseNormale = GHOST_SPEED;  // memorise vitesse normale
    bouge = true;  // commence en mouvement
    
    // etats initiaux
    peur = false;
    timerPeur = 0;
    released = (releaseDelay == 0);
    timerSortie = releaseDelay;
    eyes = false;
    timerBehav = 0;
    
    // init trajectoire pour debug
    chemin = new ArrayList<PVector>();
    compteurChemin = 0;  // marche pas terrible pour linstant
  }
  
  // met a jour le fantome a chaque frame
  // le cerveau du fantome en quelque sorte
  void update(Hero hero) {
    // mode yeux : retour cage
    if (eyes) {
      returnToHome();
      return;
    }
    
    // gestion timer sortie
    if (!released) {
      timerSortie--;
      if (timerSortie <= 0) {
        released = true;
      }
      // IMPORTAnt fantomes restent FIXES dans cage tant que !released
      return;
    }
    
    // gestion mode effrayee du fntom
    if (peur) {
      timerPeur--;
      if (timerPeur <= 0) {
        peur = false;
        // restaure vitesse normale
        speed = vitesseNormale;
      }
    }
    
    // comportement : choisi direction (seulement si released)
    chooseDirection(hero);
    move();
    
    // debug - maj trajectoire
    updatePath(hero);
  }
  
  // quand le fantome est mangé il retourne a la cage
  // comme un boomerang mais en bleu
  void returnToHome() {
    // destination : centre cage
    int homeX = 11;
    int homeY = 10;
    
    // si arrive a la cage on regenere
    if (x == homeX && y == homeY) {
      PVector cellCenter = board.getCellCenter(x, y);
      pos = cellCenter.copy();
      
      // redevient vivant
      eyes = false;
      peur = false;
      timerPeur = 0;
      released = false;
      timerSortie = 180; // attend 3 sec avant ressortir
      direction = new PVector(0, -1); // dir vers haut pour sortir
      speed = vitesseNormale;  // restore vitesse normale
      
      // efface trajectoire
      chemin.clear();
      return;
    }
    
    // vitesse rapide mode yeux
    speed = GHOST_SPEED * 2;
    
    // calcule chemin vers maison
    ArrayList<PVector> pathCells = trouverChemin(x, y, homeX, homeY);
    
    // verifie si on est au centre cellule
    PVector cellCenter = board.getCellCenter(x, y);
    float distToCenter = PVector.dist(pos, cellCenter);
    
    if (distToCenter < speed * 1.5) {
      if (pathCells.size() >= 2) {
        // au centre prend dir vers prochaine cellule du chemin
        // pathCells[0] = pos actuelle, pathCells[1] = prochaine cellule
        PVector nextCell = pathCells.get(1);
        
        // calcule direction vers prochaine cellule
        int dirX = (int)nextCell.x - x;
        int dirY = (int)nextCell.y - y;
        direction = new PVector(dirX, dirY);
      } else {
        // si pas de chemin trouve (bloque), utilise approche greedy
        ArrayList<PVector> possibleDirs = new ArrayList<PVector>();
        PVector[] directions = {
          new PVector(0, -1),  // Haut
          new PVector(0, 1),   // Bas
          new PVector(-1, 0),  // Gauche
          new PVector(1, 0)    // Droite
        };
        
        for (PVector dir : directions) {
          int nextX = x + (int)dir.x;
          int nextY = y + (int)dir.y;
          
          if (!board.isWall(nextX, nextY)) {
            possibleDirs.add(dir);
          }
        }
        
        // choisi direction qui rapproche le plus de cage
        if (possibleDirs.size() > 0) {
          PVector bestDir = null;
          float bestDist = Float.MAX_VALUE;
          
          for (PVector dir : possibleDirs) {
            int nextX = x + (int)dir.x;
            int nextY = y + (int)dir.y;
            float d = dist(nextX, nextY, homeX, homeY);
            
            if (d < bestDist) {
              bestDist = d;
              bestDir = dir;
            }
          }
          
          if (bestDir != null) {
            direction = bestDir.copy();
          }
        }
      }
    }
    
    // deplace normalement (avec collisions)
    move();
    
    // maj trajectoire (pas de hero necessaire pour mode yeux)
    updatePath(null);
  }
  
  // le comportement du fantome qui choisi ou aller
  // chaque fantome a sa propre personnalite
  void chooseDirection(Hero hero) {
    // sortie cage
    boolean inCage = (y == 10 && x >= 9 && x <= 13);
    boolean aboveCage = (y == 9 && x >= 9 && x <= 13);
    
    if (inCage) {
      // Dans la cage : d'abord aller au centre (x=11), puis monter
      if (x < 11) {
        direction = new PVector(1, 0);  // Aller à droite vers le centre
      } else if (x > 11) {
        direction = new PVector(-1, 0);  // Aller à gauche vers le centre
      } else {
        direction = new PVector(0, -1);  // Au centre, monter
      }
      return;
    }
    
    if (aboveCage) {
      direction = new PVector(0, -1);  // Au-dessus de la cage, continuer à monter
      return;
    }
    
    // Vérifier si on est au centre d'une cellule
    PVector cellCenter = board.getCellCenter(x, y);
    float distToCenter = PVector.dist(pos, cellCenter);
    
    if (distToCenter < speed * 1.5) {
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
        if (possibleDirs.size() > 0 && PVector.dot(dir, direction) < -0.5) continue;
        
        int nextX = x + (int)dir.x;
        int nextY = y + (int)dir.y;
        
        if (!board.isWall(nextX, nextY)) {
          possibleDirs.add(dir);
        }
      }
      
      // Si aucune direction trouvée, autoriser le demi-tour
      if (possibleDirs.size() == 0) {
        for (PVector dir : directions) {
          int nextX = x + (int)dir.x;
          int nextY = y + (int)dir.y;
          
          if (!board.isWall(nextX, nextY)) {
            possibleDirs.add(dir);
          }
        }
      }
      
      if (possibleDirs.size() > 0) {
        if (peur) {
          // Mode effrayé : choisir aléatoirement
          direction = possibleDirs.get((int)random(possibleDirs.size())).copy();
        } else {
          // choisir selon type fantome
          PVector targetCell = getTargetCell(hero);
          
          // calculer chemin vers cible
          ArrayList<PVector> pathCells = trouverChemin(x, y, (int)targetCell.x, (int)targetCell.y);
          
          // Si on a un chemin avec au moins 2 cellules (position actuelle + prochaine)
          if (pathCells.size() >= 2) {
            // Prendre la direction vers la prochaine cellule du chemin BFS
            PVector nextCell = pathCells.get(1);
            int dirX = (int)nextCell.x - x;
            int dirY = (int)nextCell.y - y;
            direction = new PVector(dirX, dirY);
          } else {
            // Si pas de chemin, utiliser l'approche greedy comme fallback
            PVector bestDir = null;
            float bestDist = Float.MAX_VALUE;
            
            for (PVector dir : possibleDirs) {
              int nextX = x + (int)dir.x;
              int nextY = y + (int)dir.y;
              float dist = dist(nextX, nextY, targetCell.x, targetCell.y);
              
              if (dist < bestDist) {
                bestDist = dist;
                bestDir = dir;
              }
            }
            
            if (bestDir != null) {
              direction = bestDir.copy();
            }
          }
        }
      }
    }
  }
  
  // cible selon type de fantome
  PVector getTargetCell(Hero hero) {
    if (hero == null) {
      return new PVector(x, y);
    }
    
    int heroX = hero.getCellX();
    int heroY = hero.getCellY();
    
    // comportements differents
    if (nom.equals("Blinky")) {
      // suit pacman directement
      return new PVector(heroX, heroY);
      
    } else if (nom.equals("Pinky")) {
      // anticipe mouvement
      PVector heroDir = hero.getDirection();
      int targetX = heroX + (int)(heroDir.x * 4);
      int targetY = heroY + (int)(heroDir.y * 4);
      return new PVector(targetX, targetY);
      
    } else if (nom.equals("Inky")) {
      // parfois part en direction opposee
      timerBehav--;
      if (timerBehav <= 0) {
        timerBehav = (int)random(180, 300);
      }
      
      if (timerBehav > 240) {
        // direction inverse
        int targetX = x - (heroX - x);
        int targetY = y - (heroY - y);
        return new PVector(targetX, targetY);
      } else {
        // Suit Pac-Man normalement
        return new PVector(heroX, heroY);
      }
      
    } else if (nom.equals("Clyde")) {
      // fuit quand trop proche
      float distToPacman = dist(x, y, heroX, heroY);
      
      if (distToPacman < 3) {
        // fuite
        int targetX = x - (heroX - x);
        int targetY = y - (heroY - y);
        return new PVector(targetX, targetY);
      } else {
        // Pas trop proche : comportement aléatoire/poursuite
        timerBehav--;
        if (timerBehav <= 0) {
          timerBehav = (int)random(120, 240);
        }
        
        if (timerBehav > 180) {
          // Direction aléatoire
          return new PVector(random(board.nbX), random(board.nbY));
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
    PVector nextPos = PVector.add(pos, PVector.mult(direction, speed));
    
    if (canMoveTo(nextPos)) {
      pos = nextPos;
      updateCellPosition();
      
      // Téléportation pour les fantômes aussi
      checkTeleportation();
    } else {
      // Si bloqué, aligner sur le centre de la cellule et forcer un nouveau choix
      PVector cellCenter = board.getCellCenter(x, y);
      pos = cellCenter.copy();
      
      // Chercher une direction valide immédiatement
      PVector[] directions = {
        new PVector(0, -1), new PVector(0, 1), 
        new PVector(-1, 0), new PVector(1, 0)
      };
      
      for (PVector dir : directions) {
        int nextX = x + (int)dir.x;
        int nextY = y + (int)dir.y;
        if (!board.isWall(nextX, nextY)) {
          direction = dir.copy();
          break;
        }
      }
    }
  }
  
  // Vérifie si le fantôme peut se déplacer à une position
  boolean canMoveTo(PVector pos) {
    int cellX = floor((pos.x - board.pos.x) / board.taille);
    int cellY = floor((pos.y - board.pos.y) / board.taille);
    
    // Vérifier si c'est un mur
    if (board.isWall(cellX, cellY)) return false;
    
    // Les fantômes released ne peuvent pas rentrer dans la cage (SAUF en mode yeux OU s'ils sont déjà dans la cage)
    if (!eyes) {
      boolean targetInCage = (cellY == 10 && cellX >= 9 && cellX <= 13);
      boolean currentInCage = (y == 10 && x >= 9 && x <= 13);
      
      // Empêcher entrée dans cage si released et pas dans cage actuellement
      // MAIS permettre le mouvement dans la cage si on y est déjà (pour sortir)
      if (released && !currentInCage && targetInCage) {
        return false;
      }
    }
    
    return true;
  }
  
  // Met à jour la position de cellule
  void updateCellPosition() {
    x = floor((pos.x - board.pos.x) / board.taille);
    y = floor((pos.y - board.pos.y) / board.taille);
  }
  
  // Téléportation entre les bords de la carte
  void checkTeleportation() {
    // Téléportation horizontale (gauche <-> droite)
    if (x < 0) {
      x = board.nbX - 1;
      pos.x = board.pos.x + x * board.taille + board.taille / 2;
    } else if (x >= board.nbX) {
      x = 0;
      pos.x = board.pos.x + x * board.taille + board.taille / 2;
    }
    
    // Téléportation verticale (haut <-> bas) - optionnel
    if (y < 0) {
      y = board.nbY - 1;
      pos.y = board.pos.y + y * board.taille + board.taille / 2;
    } else if (y >= board.nbY) {
      y = 0;
      pos.y = board.pos.y + y * board.taille + board.taille / 2;
    }
  }
  
  // Active le mode effrayé (quand Pac-Man mange une super-gomme)
  void scare(int duration, float scaredSpeed, float scaredSpeedClyde) {
    // Ne pas effrayer les fantômes en mode yeux ou non-released
    if (eyes || !released) return;
    
    peur = true;
    timerPeur = duration;
    
    // Clyde (orange) est un peu plus rapide que les autres en mode effrayé
    if (nom.equals("Clyde")) {
      speed = scaredSpeedClyde;
    } else {
      speed = scaredSpeed;
    }
  }
  
  // Réinitialise le fantôme (quand Pac-Man est mangé OU après être mangé par Pac-Man)
  void reset() {
    // Retourner à la position de départ
    pos = maison.copy();
    x = (int)((pos.x - board.pos.x) / board.taille);
    y = (int)((pos.y - board.pos.y) / board.taille);
    
    // Réinitialiser les états
    peur = false;
    timerPeur = 0;
    eyes = false;
    // NE PAS réinitialiser speed ici pour garder la vitesse de difficulté
    
    // Si c'était Blinky (déjà released au départ), rester released
    // Les autres retournent dans la cage
    if (timerSortie == 0 && nom.equals("Blinky")) {
      released = true;
    } else {
      released = false;
      // Réinitialiser les timers de sortie
      if (nom.equals("Pinky")) timerSortie = 60;
      else if (nom.equals("Inky")) timerSortie = 120;
      else if (nom.equals("Clyde")) timerSortie = 180;
    }
  }
  
  // Vérifie la collision avec Pac-Man
  boolean collidesWith(Hero hero) {
    if (!released || eyes) return false; // Pas de collision si dans la cage ou en mode yeux
    return dist(pos.x, pos.y, hero.pos.x, hero.pos.y) < (size + hero.size) * 0.4;
  }
  
  // DEBUG - Met à jour la trajectoire du fantôme (où il VA, pas d'où il vient)
  void updatePath(Hero hero) {
    if (!DEBUG_GHOST_PATH) return;
    
    // Effacer l'ancienne trajectoire
    chemin.clear();
    
    // Si pas released, ne pas afficher de trajectoire
    if (!released && !eyes) return;
    
    // Déterminer la cible selon le mode
    PVector targetCell;
    if (eyes) {
      // Mode yeux : cible = cage
      targetCell = new PVector(11, 10);
    } else {
      // Mode normal : cible determinee par le comportement
      targetCell = getTargetCell(hero);
      if (targetCell == null) {
        targetCell = new PVector(x, y);
      }
    }
    
    // calculer chemin complet
    ArrayList<PVector> path = trouverChemin(x, y, (int)targetCell.x, (int)targetCell.y);
    
    // Convertir les cellules en positions pixels
    for (PVector cell : path) {
      PVector pixelPos = board.getCellCenter((int)cell.x, (int)cell.y);
      chemin.add(pixelPos);
    }
  }
  
  // Trouve le meilleur chemin entre deux points
  ArrayList<PVector> trouverChemin(int startX, int startY, int endX, int endY) {
    ArrayList<PVector> path = new ArrayList<PVector>();
    
    // verifier si destination valide
    if (endX < 0 || endX >= board.nbX || endY < 0 || endY >= board.nbY) {
      path.add(new PVector(startX, startY));
      return path;
    }
    
    // recherche du chemin
    ArrayList<PVector> queue = new ArrayList<PVector>();
    boolean[][] visited = new boolean[board.nbX][board.nbY];
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
        if (nx >= 0 && nx < board.nbX && 
            ny >= 0 && ny < board.nbY &&
            !visited[nx][ny] && !board.isWall(nx, ny)) {
          
          // Gérer la cage : les fantômes normaux ne peuvent pas y entrer SAUF si c'est la destination
          boolean targetInCage = (ny == 10 && nx >= 9 && nx <= 13);
          if (!eyes && targetInCage) {
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
    if (!DEBUG_GHOST_PATH || chemin.size() < 2) return;
    
    pushStyle();
    noFill();
    strokeWeight(3);
    
    // Utiliser la couleur du fantôme avec transparence
    color pathColor;
    if (peur) {
      pathColor = COLOR_GHOST_SCARED;
    } else if (eyes) {
      pathColor = color(255, 255, 255);
    } else {
      pathColor = couleur;
    }
    
    stroke(red(pathColor), green(pathColor), blue(pathColor), 150);
    
    // Dessiner les lignes entre les points
    for (int i = 0; i < chemin.size() - 1; i++) {
      PVector p1 = chemin.get(i);
      PVector p2 = chemin.get(i + 1);
      line(p1.x, p1.y, p2.x, p2.y);
    }
    
    // Dessiner de petits cercles aux points clés (tous les 3 points)
    fill(red(pathColor), green(pathColor), blue(pathColor), 200);
    noStroke();
    for (int i = 0; i < chemin.size(); i += 3) {
      PVector p = chemin.get(i);
      ellipse(p.x, p.y, 5, 5);
    }
    
    // Dessiner la cible (dernier point) avec un X
    if (chemin.size() > 0) {
      PVector target = chemin.get(chemin.size() - 1);
      stroke(red(pathColor), green(pathColor), blue(pathColor), 255);
      strokeWeight(2);
      float crossSize = 8;
      line(target.x - crossSize, target.y - crossSize, target.x + crossSize, target.y + crossSize);
      line(target.x - crossSize, target.y + crossSize, target.x + crossSize, target.y - crossSize);
      
      // Cercle autour de la ciblee
      noFill();
      stroke(red(pathColor), green(pathColor), blue(pathColor), 150);
      ellipse(target.x, target.y, crossSize * 3, crossSize * 3);
    }
    
    popStyle();
  }
  
  // affichage fatome
  void drawIt() {
    // trajectoire debug
    drawPath();
    
    // dessin du fantome
    pushMatrix();
    translate(pos.x, pos.y);
    
    if (eyes) {
      // Mode yeux : juste des yeux blancs
      fill(255);
      noStroke();
      
      // Yeux (deux cercles blancs)
      ellipse(-size * 0.2, 0, size * 0.35, size * 0.4);
      ellipse(size * 0.2, 0, size * 0.35, size * 0.4);
      
      // Pupilles bleues
      fill(0, 0, 255);
      ellipse(-size * 0.2, 0, size * 0.15, size * 0.2);
      ellipse(size * 0.2, 0, size * 0.15, size * 0.2);
      
    } else if (peur) {
      // Fantôme effrayé : bleu avec clignotement vers la fin
      if (timerPeur < 100 && frameCount % 20 < 10) {
        fill(255, 255, 255); // Blanc clignotant
      } else {
        fill(COLOR_GHOST_SCARED);
      }
      noStroke();
      
      // Corps arrondi
      arc(0, -size * 0.15, size, size * 0.8, PI, TWO_PI, CHORD);
      rect(-size/2, -size * 0.15, size, size * 0.5);
      
      // Bas ondulé
      for (int i = 0; i < 4; i++) {
        float x = -size/2 + i * size/4;
        arc(x + size/8, size * 0.35, size/4, size * 0.3, 0, PI, CHORD);
      }
      
      // Yeux effrayés (blancs)
      fill(255);
      ellipse(-size * 0.2, -size * 0.1, size * 0.25, size * 0.3);
      ellipse(size * 0.2, -size * 0.1, size * 0.25, size * 0.3);
      
    } else {
      // Fantôme normal avec couleur
      fill(couleur);
      noStroke();
      
      // Corps arrondi (demi-cercle en haut)
      arc(0, -size * 0.15, size, size * 0.8, PI, TWO_PI, CHORD);
      rect(-size/2, -size * 0.15, size, size * 0.5);
      
      // Bas ondulé (4 petites vagues)
      for (int i = 0; i < 4; i++) {
        float x = -size/2 + i * size/4;
        arc(x + size/8, size * 0.35, size/4, size * 0.3, 0, PI, CHORD);
      }
      
      // Yeux blancs (normaux)
      fill(COLOR_GHOST_EYES);
      ellipse(-size * 0.2, -size * 0.1, size * 0.3, size * 0.35);
      ellipse(size * 0.2, -size * 0.1, size * 0.3, size * 0.35);
      
      // Pupilles (regardent vers Pac-Man si disponible)
      fill(0, 0, 200);
      ellipse(-size * 0.2, -size * 0.05, size * 0.12, size * 0.15);
      ellipse(size * 0.2, -size * 0.05, size * 0.12, size * 0.15);
    }
    
    popMatrix();
  }
  
  // Getters
  boolean isScared() { return peur; }
  boolean isReleased() { return released; }
  int getCellX() { return x; }
  int getCellY() { return y; }
}





