// ===== CLASSE BONUS : FRUITS ET BONUS =====
class Bonus {
  int _cellX, _cellY;           // Position sur la grille
  PVector _position;            // Position pixel
  int _score;                   // Points donnés
  String _type;                 // Type de bonus ("cherry", "strawberry", "orange"...)
  color _color;                 // Couleur du bonus
  boolean _active;              // Actif ou non
  int _timer;                   // Temps restant avant disparition
  int _spawnTimer;              // Timer avant apparition
  Board _board;                 // Référence au plateau
  
  // Constructeur
  Bonus(Board board, int cellX, int cellY, String type) {
    _board = board;
    _cellX = cellX;
    _cellY = cellY;
    _type = type;
    _active = false;
    _timer = BONUS_DURATION;
    _spawnTimer = BONUS_SPAWN_TIME;
    
    // Configuration selon le type
    switch(type) {
      case "cherry":
        _score = 100;
        _color = #FF0000;  // Rouge
        break;
      case "strawberry":
        _score = 300;
        _color = #FF69B4;  // Rose
        break;
      case "orange":
        _score = 500;
        _color = #FFA500;  // Orange
        break;
      case "apple":
        _score = 700;
        _color = #FF0000;  // Rouge foncé
        break;
      case "melon":
        _score = 1000;
        _color = #00FF00;  // Vert
        break;
      default:
        _score = 500;
        _color = #FFFF00;  // Jaune par défaut
        break;
    }
    
    PVector cellCenter = _board.getCellCenter(_cellX, _cellY);
    _position = cellCenter.copy();
  }
  
  // Mise à jour du bonus
  void update(int dotsEaten, int totalDots) {
    if (!_active) {
      // Vérifier si on doit faire apparaître le bonus
      // Apparaît après avoir mangé 50% des gommes
      if (dotsEaten >= totalDots * 0.5 && _spawnTimer > 0) {
        _spawnTimer--;
        if (_spawnTimer <= 0) {
          spawn();
        }
      }
    } else {
      // Décrémenter le timer
      _timer--;
      if (_timer <= 0) {
        _active = false;
      }
    }
  }
  
  // Fait apparaître le bonus
  void spawn() {
    _active = true;
    _timer = BONUS_DURATION;
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
    fill(#FF0000);
    ellipse(-8 * scale, 0, 15 * scale, 15 * scale);
    ellipse(8 * scale, 0, 15 * scale, 15 * scale);
    
    // Tiges
    stroke(#8B4513);
    strokeWeight(2);
    line(-8 * scale, -7 * scale, 0, -15 * scale);
    line(8 * scale, -7 * scale, 0, -15 * scale);
  }
  
  // Dessine une fraise
  void drawStrawberry(float scale) {
    noStroke();
    
    // Corps de la fraise
    fill(#FF1744);
    beginShape();
    vertex(0, -12 * scale);
    vertex(10 * scale, 0);
    vertex(8 * scale, 10 * scale);
    vertex(0, 12 * scale);
    vertex(-8 * scale, 10 * scale);
    vertex(-10 * scale, 0);
    endShape(CLOSE);
    
    // Feuilles
    fill(#00FF00);
    triangle(-8 * scale, -10 * scale, 0, -14 * scale, 8 * scale, -10 * scale);
    
    // Points
    fill(#FFFF00);
    for (int i = 0; i < 6; i++) {
      float angle = i * PI / 3;
      ellipse(cos(angle) * 5 * scale, sin(angle) * 5 * scale, 2 * scale, 2 * scale);
    }
  }
  
  // Dessine une orange
  void drawOrange(float scale) {
    noStroke();
    
    // Corps de l'orange
    fill(#FFA500);
    ellipse(0, 0, 25 * scale, 25 * scale);
    
    // Texture
    stroke(#FF8C00);
    strokeWeight(1);
    for (int i = 0; i < 8; i++) {
      float angle = i * TWO_PI / 8;
      line(0, 0, cos(angle) * 12 * scale, sin(angle) * 12 * scale);
    }
    
    // Feuille
    noStroke();
    fill(#00FF00);
    ellipse(8 * scale, -10 * scale, 6 * scale, 4 * scale);
  }
  
  // Dessine une pomme
  void drawApple(float scale) {
    noStroke();
    
    // Corps de la pomme
    fill(#DC143C);
    ellipse(0, 2 * scale, 22 * scale, 20 * scale);
    ellipse(-5 * scale, -5 * scale, 15 * scale, 18 * scale);
    ellipse(5 * scale, -5 * scale, 15 * scale, 18 * scale);
    
    // Tige
    stroke(#8B4513);
    strokeWeight(2);
    line(0, -10 * scale, 0, -15 * scale);
    
    // Feuille
    noStroke();
    fill(#00FF00);
    ellipse(5 * scale, -14 * scale, 8 * scale, 5 * scale);
  }
  
  // Dessine un melon
  void drawMelon(float scale) {
    noStroke();
    
    // Corps du melon
    fill(#90EE90);
    ellipse(0, 0, 28 * scale, 25 * scale);
    
    // Rayures
    stroke(#228B22);
    strokeWeight(2);
    for (int i = -2; i <= 2; i++) {
      line(i * 6 * scale, -12 * scale, i * 6 * scale, 12 * scale);
    }
    
    // Tige
    stroke(#8B4513);
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
}
