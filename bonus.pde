// gestion des bonus/fruits qui apparaissent
// j'ai du refaire cette partie plusieurs fois avant que ca marche
class Bonus {
  int x, y;
  PVector pos;
  int score;
  String type;
  color couleur;
  boolean active;
  int timer;
  int spawnTimer;
  Board board;
  int spawnCount;
  boolean hasSpawned;
  
  // constructeur
  Bonus(Board b, int cellX, int cellY, String t) {
    board = b;
    x = cellX;
    y = cellY;
    type = t;
    active = false;
    timer = BONUS_DURATION;
    spawnTimer = BONUS_SPAWN_TIME;
    spawnCount = 0;
    hasSpawned = false;
    
    // choisi position aleatoire au debut
    chooseRandomPosition();
    
    // choisi position aleatoire au debut
    chooseRandomPosition();
    
    // config selon type
    switch(type) {
      case "cherry":
        score = 100;
        couleur = color(255, 0, 0);  // rouge
        break;
      case "strawberry":
        score = 300;
        couleur = color(255, 105, 180);  // rose
        break;
      case "orange":
        score = 500;
        couleur = color(255, 165, 0);  // orange
        break;
      case "apple":
        score = 700;
        couleur = color(255, 0, 0);  // rouge fonce
        break;
      case "melon":
        score = 1000;
        couleur = color(0, 255, 0);  // vert
        break;      case "diamond":
        score = 3000;
        couleur = color(0, 255, 255);  // cyan brillant
        break;      default:
        score = 500;
        couleur = color(255, 255, 0);  // jaune par defaut
        break;
    }
    
    PVector cellCenter = board.getCellCenter(x, y);
    pos = cellCenter.copy();
  }
  
  // verifie si un bonus doit apparaitre selon les gommes mangees
  // plus tu manges plus tu as de cadeaux
  void update(int dotsEaten, int totalDots) {
    if (!active) {
      // quel fruit apparait
      String newType = null;
      boolean shouldSpawn = false;
      
      if (dotsEaten >= 70 && spawnCount == 0) {
        newType = "cherry";     // 70 gommes -> cerise (100 pts)
        shouldSpawn = true;
        spawnCount = 1;  // marche bien
      } else if (dotsEaten >= 100 && spawnCount == 1) {
        newType = "strawberry"; // 100 gommes -> fraise (300 pts)
        shouldSpawn = true;
        spawnCount = 2;
      } else if (dotsEaten >= 130 && spawnCount == 2) {
        newType = "orange";     // 130 gommes -> orange (500 pts)
        shouldSpawn = true;
        spawnCount = 3;
      } else if (dotsEaten >= 160 && spawnCount == 3) {
        newType = "apple";      // 160 gommes -> pomme (700 pts)
        shouldSpawn = true;
        spawnCount = 4;
      } else if (dotsEaten >= 190 && spawnCount == 4) {
        newType = "melon";      // 190 gommes -> melon (1000 pts)
        shouldSpawn = true;
        spawnCount = 5;
      } else if (dotsEaten >= 220 && spawnCount == 5) {
        newType = "diamond";    // 220 gommes -> diamant (3000 pts)
        shouldSpawn = true;
        spawnCount = 6;
      }
      
      if (shouldSpawn && newType != null) {
        changeType(newType);
        spawn();
      }
    } else {
      // Décrémenter le timer
      timer--;
      if (timer <= 0) {
        active = false;
        println("Bonus disparu!");
      }
    }
  }
  
  // fait apparaitre le bonus sur le plateau
  // surprise pour pacman
  void spawn() {
    // nouvelle position random
    chooseRandomPosition();
    
    active = true;
    timer = BONUS_DURATION;
    println("Bonus actif! Type: " + type + ", Score: " + score + ", Position: (" + x + ", " + y + ")");
  }
  
  // Change le type de fruit
  void changeType(String newType) {
    type = newType;
    
    // Mettre à jour le score et la couleur selon le nouveau type
    switch(newType) {
      case "cherry":
        score = 100;
        couleur = color(255, 0, 0);  // Rouge
        break;
      case "strawberry":
        score = 300;
        couleur = color(255, 105, 180);  // Rose
        break;
      case "orange":
        score = 500;
        couleur = color(255, 165, 0);  // Orange
        break;
      case "apple":
        score = 700;
        couleur = color(255, 0, 0);  // Rouge foncé
        break;
      case "melon":
        score = 1000;
        couleur = color(0, 255, 0);  // Vert
        break;
      case "diamond":
        score = 3000;
        couleur = color(0, 255, 255);  // Cyan brillant
        break;
    }
    
    println("Nouveau type de fruit: " + type + " (" + score + " points)");
  }
  
  // Collecte le bonus
  int collect() {
    if (active) {
      active = false;
      return score;
    }
    return 0;
  }
  
  // Vérifie si le héros touche le bonus
  boolean collidesWith(Hero hero) {
    if (!active) return false;
    
    float distance = dist(pos.x, pos.y, hero.pos.x, hero.pos.y);
    return distance < 20;
  }
  
  // Affiche le bonus
  void drawIt() {
    if (!active) return;
    
    pushMatrix();
    translate(pos.x, pos.y);
    
    // Effet de pulsation
    float pulse = 1 + 0.1 * sin(frameCount * 0.15);
    
    // Dessiner le fruit selon le type
    if (type.equals("cherry")) {
      drawCherry(pulse);
    } else if (type.equals("strawberry")) {
      drawStrawberry(pulse);
    } else if (type.equals("orange")) {
      drawOrange(pulse);
    } else if (type.equals("apple")) {
      drawApple(pulse);
    } else if (type.equals("melon")) {
      drawMelon(pulse);
    } else if (type.equals("diamond")) {
      drawDiamond(pulse);
    } else {
      // Bonus générique
      fill(couleur);
      noStroke();
      ellipse(0, 0, 20 * pulse, 20 * pulse);
    }
    
    popMatrix();
  }
  
  // Dessine une cerise
  void drawCherry(float scale) {
    noStroke();
    
    // Cerises
    fill(255, 0, 0);
    ellipse(-8 * scale, 0, 15 * scale, 15 * scale);
    ellipse(8 * scale, 0, 15 * scale, 15 * scale);
    
    // Tiges
    stroke(139, 69, 19);
    strokeWeight(2);
    line(-8 * scale, -7 * scale, 0, -15 * scale);
    line(8 * scale, -7 * scale, 0, -15 * scale);
  }
  
  // Dessine une fraise
  void drawStrawberry(float scale) {
    noStroke();
    
    // Corps de la fraise
    fill(255, 23, 68);
    beginShape();
    vertex(0, -12 * scale);
    vertex(10 * scale, 0);
    vertex(8 * scale, 10 * scale);
    vertex(0, 12 * scale);
    vertex(-8 * scale, 10 * scale);
    vertex(-10 * scale, 0);
    endShape(CLOSE);
    
    // Feuilles
    fill(0, 255, 0);
    triangle(-8 * scale, -10 * scale, 0, -14 * scale, 8 * scale, -10 * scale);
    
    // Points
    fill(255, 255, 0);
    for (int i = 0; i < 6; i++) {
      float angle = i * PI / 3;
      ellipse(cos(angle) * 5 * scale, sin(angle) * 5 * scale, 2 * scale, 2 * scale);
    }
  }
  
  // Dessine une orange
  void drawOrange(float scale) {
    noStroke();
    
    // Corps de l'orange
    fill(255, 165, 0);
    ellipse(0, 0, 25 * scale, 25 * scale);
    
    // Texture
    stroke(255, 140, 0);
    strokeWeight(1);
    for (int i = 0; i < 8; i++) {
      float angle = i * TWO_PI / 8;
      line(0, 0, cos(angle) * 12 * scale, sin(angle) * 12 * scale);
    }
    
    // Feuille
    noStroke();
    fill(0, 255, 0);
    ellipse(8 * scale, -10 * scale, 6 * scale, 4 * scale);
  }
  
  // Dessine une pomme
  void drawApple(float scale) {
    noStroke();
    
    // Corps de la pomme
    fill(220, 20, 60);
    ellipse(0, 2 * scale, 22 * scale, 20 * scale);
    ellipse(-5 * scale, -5 * scale, 15 * scale, 18 * scale);
    ellipse(5 * scale, -5 * scale, 15 * scale, 18 * scale);
    
    // Tige
    stroke(139, 69, 19);
    strokeWeight(2);
    line(0, -10 * scale, 0, -15 * scale);
    
    // Feuille
    noStroke();
    fill(0, 255, 0);
    ellipse(5 * scale, -14 * scale, 8 * scale, 5 * scale);
  }
  
  // Dessine un melon
  void drawMelon(float scale) {
    noStroke();
    
    // Corps du melon
    fill(144, 238, 144);
    ellipse(0, 0, 28 * scale, 25 * scale);
    
    // Rayures
    stroke(34, 139, 34);
    strokeWeight(2);
    for (int i = -2; i <= 2; i++) {
      line(i * 6 * scale, -12 * scale, i * 6 * scale, 12 * scale);
    }
    
    // Tige
    stroke(139, 69, 19);
    strokeWeight(2);
    line(0, -12 * scale, 0, -16 * scale);
  }
  
  // Getters
  boolean isActive() {
    return active;
  }
  
  int getScore() {
    return score;
  }
  
  void reset() {
    active = false;
    spawnTimer = BONUS_SPAWN_TIME;
    timer = BONUS_DURATION;
  }
  
  // position aleatoire
  void chooseRandomPosition() {
    // liste positions possibles
    ArrayList<PVector> validPositions = new ArrayList<PVector>();
    
    for (int y = 1; y < board.nbY - 1; y++) {
      for (int x = 1; x < board.nbX - 1; x++) {
        TypeCell cell = board.getCellType(x, y);
        // Accepter les espaces vides, gommes et super-gommes (pas les murs)
        if (cell == TypeCell.EMPTY || cell == TypeCell.DOT || cell == TypeCell.SUPER_DOT) {
          // Éviter la zone de la cage des fantômes (autour de x=11, y=10)
          if (abs(x - 11) > 3 || abs(y - 10) > 2) {
            validPositions.add(new PVector(x, y));
          }
        }
      }
    }
    
    // Choisir une position au hasard
    if (validPositions.size() > 0) {
      int randomIndex = (int)random(validPositions.size());
      PVector chosen = validPositions.get(randomIndex);
      x = (int)chosen.x;
      y = (int)chosen.y;
      
      // Mettre à jour la position pixel
      PVector cellCenter = board.getCellCenter(x, y);
      pos = cellCenter.copy();
    }
  }
  
  String getType() {
    return type;
  }
  
  // Dessine un diamant brillant
  void drawDiamond(float scale) {
    noStroke();
    
    // Corps du diamant - forme de losange
    fill(0, 255, 255);  // Cyan brillant
    beginShape();
    vertex(0, -15 * scale);      // Haut
    vertex(10 * scale, 0);       // Droite
    vertex(0, 15 * scale);       // Bas
    vertex(-10 * scale, 0);      // Gauche
    endShape(CLOSE);
    
    // Facettes intérieures pour effet brillant
    fill(255, 255, 255, 150);  // Blanc semi-transparent
    beginShape();
    vertex(0, -15 * scale);
    vertex(6 * scale, 0);
    vertex(0, 8 * scale);
    vertex(-6 * scale, 0);
    endShape(CLOSE);
    
    // Éclat central
    fill(255, 255, 255, 200);
    ellipse(-3 * scale, -5 * scale, 5 * scale, 5 * scale);
    
    // Contour du diamant
    noFill();
    stroke(255, 255, 255, 180);
    strokeWeight(2);
    beginShape();
    vertex(0, -15 * scale);
    vertex(10 * scale, 0);
    vertex(0, 15 * scale);
    vertex(-10 * scale, 0);
    endShape(CLOSE);
    
    // Lignes de facettes
    stroke(255, 255, 255, 120);
    strokeWeight(1);
    line(0, -15 * scale, 0, 15 * scale);  // Verticale
    line(-10 * scale, 0, 10 * scale, 0);  // Horizontale
  }
}




