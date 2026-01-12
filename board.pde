// les differents types de cases possibles dans la map
// je suis pas sur si c'est la meilleure facon de faire mais ça fonctionne
enum TypeCell 
{
  EMPTY,
  WALL,
  DOT,
  SUPER_DOT
}

// classe pour gerer le plateau de jeu
// ca m'a pris du temps au debut mais j'ai reussi
class Board 
{
  TypeCell[][] grille;
  PVector pos;
  int nbX;
  int nbY;
  int taille;
  
  
  // constructeur qui charge le niveau depuis un fichier txt
  Board(PVector position, int cellSize, String filename) {
    pos = position;
    taille = cellSize;
    
    // Charger le niveau depuis le fichier
    loadFromFile(filename);
  }
  
  // charge le niveau depuis le fichier texte
  // j'ai eu quelques bugs au debut mais c'est regle maintenant
  void loadFromFile(String filename) {
    String[] lines = loadStrings(filename);
    
    if (lines == null || lines.length == 0) {
      println("ERREUR : fichier introuvable try again " + filename);
      initializeHardcodedLevel();
      return;
    }
    
    // ignore premiere ligne (commentaire)
    int startLine = 0;
    if (lines[0].contains("Niveau") || lines[0].contains("Level")) {
      startLine = 1;
    }
    
    // calcule dimensions plateau
    nbY = lines.length - startLine;
    nbX = lines[startLine].length();
    
    // alloue tableau
    grille = new TypeCell[nbY][nbX];
    
    // lis chaque ligne et cree plateau
    for (int y = 0; y < nbY; y++) {
      String line = lines[y + startLine];
      for (int x = 0; x < min(line.length(), nbX); x++) {
        char c = line.charAt(x);
        
        switch(c) {  // parse les caracteres du fichier
          case 'x': // mur
            grille[y][x] = TypeCell.WALL;
            break;
          case 'o': // Gomme normale
            grille[y][x] = TypeCell.DOT;
            break;
          case 'O': // Super-gomme
            grille[y][x] = TypeCell.SUPER_DOT;
            break;
          case 'V': // Case EMPTY (zone fantômes)
          case 'P': // Position Pac-Man (devient EMPTY)
          case ' ': // Espace EMPTY
            grille[y][x] = TypeCell.EMPTY;
            break;
          default:
            grille[y][x] = TypeCell.EMPTY;
            break;
        }
      }
    }
    
    println("Niveau chargé !congrats : " + filename + " (" + nbX + "x" + nbY + ")");
  }
  
  // cherche ou est le P dans le fichier pour savoir ou placer pacman
  // P comme Pacman evidemment
  PVector findStartPosition(String filename) {
    String[] lines = loadStrings(filename);
    
    if (lines == null) return new PVector(9, 10);
    
    int startLine = (lines[0].contains("Niveau") || lines[0].contains("Level")) ? 1 : 0;
    
    for (int y = 0; y < lines.length - startLine; y++) {
      String line = lines[y + startLine];
      for (int x = 0; x < line.length(); x++) {
        if (line.charAt(x) == 'P') {
          return new PVector(x, y);
        }
      }
    }
    
    return new PVector(9, 10); // Position par défaut si 'P' non trouvé
  }
  
  // compte combien il y a de gommes au total
  // pour savoir quand pacman a tout mange
  int countTotalDots() {
    int count = 0;
    for (int y = 0; y < nbY; y++) {
      for (int x = 0; x < nbX; x++) {
        if (grille[y][x] == TypeCell.DOT || grille[y][x] == TypeCell.SUPER_DOT) {
          count++;
        }
      }
    }
    return count;
  }
  
  // niveau de secours si le fichier ne charge pas
  // le plan B au   /cas ou 
  void initializeHardcodedLevel() {
    // Créer un labyrinthe simple et original
    // W = mur, E = EMPTY, D = gomme, S = super-gomme
    
    // Remplir tout d'abord avec des murs
    for (int y = 0; y < nbY; y++) {
      for (int x = 0; x < nbX; x++) {
        grille[y][x] = TypeCell.WALL;
      }
    }
    
    // Créer un labyrinthe original en forme de croix avec des chemins
    // Zone centrale horizontale
    for (int x = 3; x < 16; x++) {
      for (int y = 9; y < 12; y++) {
        grille[y][x] = TypeCell.DOT;
      }
    }
    
    // Zone centrale verticale
    for (int y = 3; y < 18; y++) {
      for (int x = 8; x < 11; x++) {
        grille[y][x] = TypeCell.DOT;
      }
    }
    
    // Coins avec chemins
    // Haut-gauche
    for (int x = 1; x < 6; x++) {
      for (int y = 1; y < 4; y++) {
        grille[y][x] = TypeCell.DOT;
      }
    }
    
    // Haut-droite
    for (int x = 13; x < 18; x++) {
      for (int y = 1; y < 4; y++) {
        grille[y][x] = TypeCell.DOT;
      }
    }
    
    // Bas-gauche
    for (int x = 1; x < 6; x++) {
      for (int y = 17; y < 20; y++) {
        grille[y][x] = TypeCell.DOT;
      }
    }
    
    // Bas-droite
    for (int x = 13; x < 18; x++) {
      for (int y = 17; y < 20; y++) {
        grille[y][x] = TypeCell.DOT;
      }
    }
    
    // Connexions verticales vers les coins
    for (int y = 4; y < 9; y++) {
      grille[y][3] = TypeCell.DOT;
      grille[y][15] = TypeCell.DOT;
    }
    
    for (int y = 12; y < 17; y++) {
      grille[y][3] = TypeCell.DOT;
      grille[y][15] = TypeCell.DOT;
    }
    
    // Placer 4 super-gommes aux quatre coins
    grille[1][1] = TypeCell.SUPER_DOT;
    grille[1][17] = TypeCell.SUPER_DOT;
    grille[19][1] = TypeCell.SUPER_DOT;
    grille[19][17] = TypeCell.SUPER_DOT;
    
    // Ajouter quelques zones EMPTYs pour la variété
    grille[10][9] = TypeCell.EMPTY;  // Centre
  }
  
  // centre cellule en pixels
  PVector getCellCenter(int x, int y) {
    float centerX = pos.x + x * taille + taille / 2.0;
    float centerY = pos.y + y * taille + taille / 2.0;
    return new PVector(centerX, centerY);
  }
  
  // desine le plateau case par case
  void drawIt() {
    // parcours toutes cellules et les dessine
    for (int y = 0; y < nbY; y++) {
      for (int x = 0; x < nbX; x++) {
        drawCell(x, y, grille[y][x]);
      }
    }
  }
  
  // Dessine une cellule individuelle selon son type
  void drawCell(int x, int y, TypeCell type) {
    float posX = pos.x + x * taille;
    float posY = pos.y + y * taille;
    
    switch(type) {
      case WALL:
        // Mur : style Pac-Man classique - ligne bleue simple
        fill(COLOR_WALL);
        noStroke();
        rect(posX, posY, taille, taille);
        break;
        
      case DOT:
        // Gomme : petit cercle beige sur fond noir
        fill(COLOR_EMPTY);
        noStroke();
        rect(posX, posY, taille, taille);
        fill(COLOR_DOT);
        circle(posX + taille/2, posY + taille/2, taille * 0.2);
        break;
        
      case SUPER_DOT:
        // Super-gomme : cercle orange plus gros, légèrement pulsant
        fill(COLOR_EMPTY);
        noStroke();
        rect(posX, posY, taille, taille);
        fill(COLOR_SUPER_DOT);
        float pulseSize = taille * 0.4 + sin(frameCount * 0.1) * 2;
        circle(posX + taille/2, posY + taille/2, pulseSize);
        break;
        
      case EMPTY:
        // Case EMPTY : juste le fond noir
        fill(COLOR_EMPTY);
        noStroke();
        rect(posX, posY, taille, taille);
        break;
    }
  }
  
  // Vérifie si une cellule est un mur
  boolean isWall(int x, int y) {
    if (x < 0 || x >= nbX || y < 0 || y >= nbY) {
      return true;  // Hors limites = mur
    }
    return grille[y][x] == TypeCell.WALL;
  }
  
  // Retourne le type d'une cellule
  TypeCell getCellType(int x, int y) {
    if (x < 0 || x >= nbX || y < 0 || y >= nbY) {
      return TypeCell.WALL;
    }
    return grille[y][x];
  }
  
  // Modifie le type d'une cellule (utile pour manger les gommes)
  void setCellType(int x, int y, TypeCell newType) {
    if (x >= 0 && x < nbX && y >= 0 && y < nbY) {
      grille[y][x] = newType;
    }
  }
}



