// classe pacman (le personnage principal)
// au debut j'appelais ca Pacman mais Hero c'est plus generique
class Hero {
  PVector pos;
  PVector offset;
  
  // position sur grille
  int x, y;
  
  // affichage
  float size;
  float angle;
  float angleDir;  // TODO ameliorer animation (un jour peut etre hihi)
  
  // Animation de mort
  boolean dying;
  int timer;
  int duration;
  
  // Déplacement  du mr pacman
  PVector direction;
  PVector nextDir;
  boolean bouge;
  float vitesse;
  
  Board board;
  
  // constructeur
  Hero(Board b, int startCellX, int startCellY) {
    board = b;
    x = startCellX;
    y = startCellY;
    
    // pos pixel au centre de la case de depart
    PVector cellCenter = board.getCellCenter(x, y);
    pos = cellCenter.copy();
    offset = new PVector(0, 0);
    
    direction = new PVector(0, 0);
    nextDir = new PVector(0, 0);
    bouge = false;
    vitesse = PACMAN_SPEED;
    
    size = PACMAN_SIZE;
    angle = 0;
    angleDir = 1;
    
    dying = false;
    timer = 0;
    duration = 60; // 1 sec
  }
  
  // quand on appui sur une touche ca stock la direction voulue
  void launchMove(PVector dir) {
    // normalise la direction
    if (dir.mag() > 0) {
      nextDir = dir.copy().normalize();
    }
  }
  
  // deplace pacman dans la direction actuelle
  // verifie aussi les colisions avec les murs
  void move(Board board) {
    if (!bouge) return;  // fait rien si bouge pas
    
    // nouvelle pos
    PVector nextPos = PVector.add(pos, PVector.mult(direction, vitesse));
    
    // verifie si on peut bouger (pas de mur)
    if (canMoveTo(nextPos, board)) {
      pos = nextPos;
      
      // maj position cellule
      updateCellPosition();
      
      // teleportation si sort du bord
      checkTeleportation(board);
    } else {
      // bloque contre mur, on aligne sur centre
      PVector cellCenter = board.getCellCenter(x, y);
      
      // aligne centre
      pos = cellCenter.copy();
      
      // stop mouvement
      bouge = false;
    }
  }
  
  // teleporte pacman quand il sort du bord
  // la magie du tunnel comme dans le vrai jeu (par contre ça ne marche pas correctement comme les phantomes) )
  void checkTeleportation(Board board) {
    // horizontale
    if (x < 0) {
      x = board.nbX - 1;
      pos.x = board.pos.x + x * board.taille + board.taille / 2;
    } else if (x >= board.nbX) {
      x = 0;
      pos.x = board.pos.x + x * board.taille + board.taille / 2;
    }
    
    // teleportation verticale (optionel)
    if (y < 0) {
      y = board.nbY - 1;
      pos.y = board.pos.y + y * board.taille + board.taille / 2;
    } else if (y >= board.nbY) {
      y = 0;
      pos.y = board.pos.y + y * board.taille + board.taille / 2;
    }
  }
  
  // verifie si pacman peut aller a cette position
  // les murs c'est pas son ami :)
  boolean canMoveTo(PVector pos, Board board) {
    // calcule les coord de cellule pour cette pos
    int cellX = floor((pos.x - board.pos.x) / board.taille);
    int cellY = floor((pos.y - board.pos.y) / board.taille);
    
    // verifie limites et murs
    return !board.isWall(cellX, cellY);
  }
  
  // maj position cellule avec position pixel 
  void updateCellPosition() {
    x = floor((pos.x - board.pos.x) / board.taille);
    y = floor((pos.y - board.pos.y) / board.taille);
  }
  
  // essaye de changer direction (depuis buffer nextDir)
  void tryChangeDirection() {
    if (nextDir.mag() == 0) return;  // pas de nvelle direction
    
    // verifie si on est assez centre sur cellule
    PVector cellCenter = board.getCellCenter(x, y);
    float distToCenter = PVector.dist(pos, cellCenter);
    
    // si proche du centre on peut tourner
    if (distToCenter < vitesse * 2.5) {
      // calcule pos apres mouvement dans nvelle direction
      PVector testPos = PVector.add(cellCenter, PVector.mult(nextDir, vitesse));
      
      if (canMoveTo(testPos, board)) {
        // ok on peut changer : aligne sur centre et change dir
        pos = cellCenter.copy();
        direction = nextDir.copy();
        bouge = true;
        nextDir.set(0, 0);  // reset buffer
      }
    }
  }
  
  // fonction principal de pacman appellé chaque frame
  void update(Board board) {
    // si entrain de mourir, joue animation
    if (dying) {
      timer++;
      
      // ouvre bouche progressivement jusqu'a 180 degres
      float progress = (float)timer / duration;
      angle = 180 * progress;  // de 0 a 180
      
      return;  // bouge pas pendant animation mort
    }
    
    // essaye changer direction si demande
    tryChangeDirection();
    
    // deplace pacman
    move(board);
    
    // anime bouche
    animateMouth();
    
    // NOTE: verif gommes geree dans game.pde maintenant
  }
  
  // pacman se fait manger par un fantome
  // RIP petit bonhomme jaune
  void die() {
    dying = true;
    timer = 0;
    bouge = false;
  }
  
  // retourne true si animation mort terminee
  boolean deathAnimationComplete() {
    return dying && timer >= duration;
  }
  
  // animation bouche (ouverture/fermeture)
  void animateMouth() {
    if (bouge) {
      angle += MOUTH_SPEED * angleDir * 10;
      
      // inverse direction animation
      if (angle >= MOUTH_ANGLE) {
        angle = MOUTH_ANGLE;
        angleDir = -1;
      } else if (angle <= 0) {
        angle = 0;
        angleDir = 1;
      }
    } else {
      // si immobile bouche legerement ouverte
      angle = MOUTH_ANGLE * 0.3;
    }
  }
  
  // affiche  monsieur pacman
  void drawIt() {
    // si animation mort terminee, dessine pas
    if (dying && timer >= duration) {
      return;
    }
    
    // calcule angle rotation selon direction
    float rotationAngle = 0;
    if (direction.mag() > 0 && !dying) {
      rotationAngle = atan2(direction.y, direction.x);
    }
    
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(rotationAngle);
    
    // calcule opacite pendant mort
    float alpha = 255;
    if (dying) {
      float progress = (float)timer / duration;
      alpha = 255 * (1 - progress);  // disparait progressivement
    }
    
    // dessine pacman comme un pac (cercle avec bouche)
    fill(COLOR_PACMAN, alpha);
    noStroke();
    
    // Arc de cercle avec ouverture pour la bouche
    arc(0, 0, size, size, 
        radians(angle), 
        radians(360 - angle), 
        PIE);
    
    // oeil pacman (sauf pdt mort)
    if (!dying) {
      fill(0);
      float eyeX = size * 0.15;
      float eyeY = -size * 0.15;
      circle(eyeX, eyeY, size * 0.12);
    }
    
    popMatrix();
  }
  
  // retourne position cellule actuelle
  int getCellX() { return x; }
  int getCellY() { return y; }
  
  // retourne direction actuelle
  PVector getDirection() { return direction.copy(); }
}



