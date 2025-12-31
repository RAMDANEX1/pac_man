// Classe Bonus (fruits)
class Bonus {
  int _cellX, _cellY;
  PVector _position;
  int _score;
  String _type;
  color _color;
  boolean _active;
  int _timer;
  int _spawnTimer;
  Board _board;
  int _spawnCount;
  boolean _hasSpawned;
  
  // Constructeur
  Bonus(Board board, int cellX, int cellY, String type) {
    _board = board;
    _cellX = cellX;
    _cellY = cellY;
    _type = type;
    _active = false;
    _timer = BONUS_DURATION;
    _spawnTimer = BONUS_SPAWN_TIME;
    _spawnCount = 0;
    _hasSpawned = false;
    
    // Choisir une position aléatoire au début
    chooseRandomPosition();
    
    // Choisir une position aléatoire au début
    chooseRandomPosition();
    
    // Configuration selon le type
    switch(type) {
      case "cherry":
        _score = 100;
        _color = color(255, 0, 0);  // Rouge
        break;
      case "strawberry":
        _score = 300;
        _color = color(255, 105, 180);  // Rose
        break;
      case "orange":
        _score = 500;
        _color = color(255, 165, 0);  // Orange
        break;
      case "apple":
        _score = 700;
        _color = color(255, 0, 0);  // Rouge foncé
        break;
      case "melon":
        _score = 1000;
        _color = color(0, 255, 0);  // Vert
        break;      case "diamond":
        _score = 3000;
        _color = color(0, 255, 255);  // Cyan brillant
        break;      default:
        _score = 500;
        _color = color(255, 255, 0);  // Jaune par défaut
        break;
    }
    
    PVector cellCenter = _board.getCellCenter(_cellX, _cellY);
    _position = cellCenter.copy();
  }
  
  // Mise à jour du bonus
  void update(int dotsEaten, int totalDots) {
    if (!_active) {
      // Déterminer quel fruit faire apparaître selon les gommes mangées
      String newType = null;
      boolean shouldSpawn = false;
      
      if (dotsEaten >= 70 && _spawnCount == 0) {
        newType = "cherry";     // 70 gommes -> cerise (100 pts)
        shouldSpawn = true;
        _spawnCount = 1;
      } else if (dotsEaten >= 100 && _spawnCount == 1) {
        newType = "strawberry"; // 100 gommes -> fraise (300 pts)
        shouldSpawn = true;
        _spawnCount = 2;
      } else if (dotsEaten >= 130 && _spawnCount == 2) {
        newType = "orange";     // 130 gommes -> orange (500 pts)
        shouldSpawn = true;
        _spawnCount = 3;
      } else if (dotsEaten >= 160 && _spawnCount == 3) {
        newType = "apple";      // 160 gommes -> pomme (700 pts)
        shouldSpawn = true;
        _spawnCount = 4;
      } else if (dotsEaten >= 190 && _spawnCount == 4) {
        newType = "melon";      // 190 gommes -> melon (1000 pts)
        shouldSpawn = true;
        _spawnCount = 5;
      } else if (dotsEaten >= 220 && _spawnCount == 5) {
        newType = "diamond";    // 220 gommes -> diamant (3000 pts)
        shouldSpawn = true;
        _spawnCount = 6;
      }
      
      if (shouldSpawn && newType != null) {
        changeType(newType);
        spawn();
      }
    } else {
      // Décrémenter le timer
      _timer--;
      if (_timer <= 0) {
        _active = false;
        println("Bonus disparu!");
      }
    }
  }
  
  // Fait apparaître le bonus
  void spawn() {
    // Choisir une nouvelle position aléatoire à chaque apparition
    chooseRandomPosition();
    
    _active = true;
    _timer = BONUS_DURATION;
    println("Bonus actif! Type: " + _type + ", Score: " + _score + ", Position: (" + _cellX + ", " + _cellY + ")");
  }
  
  // Change le type de fruit
  void changeType(String newType) {
    _type = newType;
    
    // Mettre à jour le score et la couleur selon le nouveau type
    switch(newType) {
      case "cherry":
        _score = 100;
        _color = color(255, 0, 0);  // Rouge
        break;
      case "strawberry":
        _score = 300;
        _color = color(255, 105, 180);  // Rose
        break;
      case "orange":
        _score = 500;
        _color = color(255, 165, 0);  // Orange
        break;
      case "apple":
        _score = 700;
        _color = color(255, 0, 0);  // Rouge foncé
        break;
      case "melon":
        _score = 1000;
        _color = color(0, 255, 0);  // Vert
        break;
      case "diamond":
        _score = 3000;
        _color = color(0, 255, 255);  // Cyan brillant
        break;
    }
    
    println("Nouveau type de fruit: " + _type + " (" + _score + " points)");
  }
  
  // Collecte le bonus
  int collect() {
    if (_active) {
      _active = false;
      return _score;
    }
    return 0;
  }
  
  // Vérifie si le héros touche le bonus
  boolean collidesWith(Hero hero) {
    if (!_active) return false;
    
    float distance = dist(_position.x, _position.y, hero._position.x, hero._position.y);
    return distance < 20;
  }
  
  // Affiche le bonus
  void drawIt() {
    if (!_active) return;
    
    pushMatrix();
    translate(_position.x, _position.y);
    
    // Effet de pulsation
    float pulse = 1 + 0.1 * sin(frameCount * 0.15);
    
    // Dessiner le fruit selon le type
    if (_type.equals("cherry")) {
      drawCherry(pulse);
    } else if (_type.equals("strawberry")) {
      drawStrawberry(pulse);
    } else if (_type.equals("orange")) {
      drawOrange(pulse);
    } else if (_type.equals("apple")) {
      drawApple(pulse);
    } else if (_type.equals("melon")) {
      drawMelon(pulse);
    } else if (_type.equals("diamond")) {
      drawDiamond(pulse);
    } else {
      // Bonus générique
      fill(_color);
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
    return _active;
  }
  
  int getScore() {
    return _score;
  }
  
  void reset() {
    _active = false;
    _spawnTimer = BONUS_SPAWN_TIME;
    _timer = BONUS_DURATION;
  }
  
  // Choisit une position aléatoire parmi les espaces vides/gommes
  void chooseRandomPosition() {
    // Lister toutes les positions possibles (vides, gommes, super-gommes)
    ArrayList<PVector> validPositions = new ArrayList<PVector>();
    
    for (int y = 1; y < _board._nbCellsY - 1; y++) {
      for (int x = 1; x < _board._nbCellsX - 1; x++) {
        TypeCell cell = _board.getCellType(x, y);
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
      _cellX = (int)chosen.x;
      _cellY = (int)chosen.y;
      
      // Mettre à jour la position pixel
      PVector cellCenter = _board.getCellCenter(_cellX, _cellY);
      _position = cellCenter.copy();
    }
  }
  
  String getType() {
    return _type;
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
