// Dimensions
final int CELL_SIZE = 40;           // Taille d'une cellule en pixels
final int BOARD_WIDTH = 19;         // Nombre de cellules en largeur
final int BOARD_HEIGHT = 21;        // Nombre de cellules en hauteur
final int BOARD_OFFSET_X = 50;      // Décalage du plateau (x)
final int BOARD_OFFSET_Y = 100;     // Décalage du plateau (y)

// Scores
final int SCORE_DOT = 10;           // Points pour une gomme normale
final int SCORE_SUPER_DOT = 50;     // Points pour une super-gomme
final int SCORE_GHOST = 200;        // Points pour manger un fantôme

// Couleurs
final color COLOR_WALL = #2121DE;         // Bleu foncé pour les murs
final color COLOR_BG = #000000;           // Fond noir
final color COLOR_DOT = #FFB897;          // Beige pour les gommes
final color COLOR_SUPER_DOT = #FFA500;    // Orange pour super-gommes
final color COLOR_EMPTY = #000000;        // Noir pour cases vides
final color COLOR_TEXT = #FFFFFF;         // Blanc pour le texte
final color COLOR_PACMAN = #FFFF00;       // Jaune pour Pac-Man

// Pac-Man
final float PACMAN_SIZE = 30;             // Taille de Pac-Man
final float PACMAN_SPEED = 4.0;           // Vitesse de déplacement (pixels par frame)
final float MOUTH_ANGLE = 45;             // Angle d'ouverture de la bouche (degrés)
final float MOUTH_SPEED = 0.15;           // Vitesse d'animation de la bouche

// Fantômes
final int GHOST_COUNT = 4;                // Nombre de fantômes
final float GHOST_SIZE = 28;              // Taille des fantômes
final float GHOST_SPEED = 2.5;            // Vitesse normale des fantômes
final float GHOST_SCARED_SPEED = 3.2;     // Vitesse quand effrayés (un peu moins que Pac-Man)
final float GHOST_SCARED_SPEED_CLYDE = 3.5; // Clyde un peu plus rapide en mode effrayé
final int GHOST_SCARED_TIME = 300;        // Durée de l'effet super-gomme (frames)
final int GHOST_RELEASE_DELAY = 120;      // Délai entre sorties de fantômes

// Couleurs des fantômes
final color COLOR_GHOST_RED = #FF0000;    // Blinky (rouge)
final color COLOR_GHOST_PINK = #FFB8FF;   // Pinky (rose)
final color COLOR_GHOST_CYAN = #00FFFF;   // Inky (cyan)
final color COLOR_GHOST_ORANGE = #FFB852; // Clyde (orange)
final color COLOR_GHOST_SCARED = #0000FF; // Bleu quand effrayés
final color COLOR_GHOST_EYES = #FFFFFF;   // Blanc pour les yeux

// Gameplay
final int INITIAL_LIVES = 3;              // Nombre de vies au départ

// Difficulté
final int DIFFICULTY_EASY = 0;
final int DIFFICULTY_MEDIUM = 1;
final int DIFFICULTY_HARD = 2;

// Classe pour stocker les paramètres de difficulté
class DifficultySettings {
  int lives;
  float ghostSpeed;
  float ghostScaredSpeed;
  float ghostScaredSpeedClyde;
  int scaredDuration;
  int releaseDelay;
  int extraLifeScore;
  
  DifficultySettings(int l, float gs, float gss, float gssc, int sd, int rd, int els) {
    lives = l;
    ghostSpeed = gs;
    ghostScaredSpeed = gss;
    ghostScaredSpeedClyde = gssc;
    scaredDuration = sd;
    releaseDelay = rd;
    extraLifeScore = els;
  }
}

// Paramètres pour chaque niveau
DifficultySettings getDifficultySettings(int difficulty) {
  switch(difficulty) {
    case 0: // EASY (Niveau Chèvre)
      return new DifficultySettings(
        5,      // 5 vies
        1.5,    // Fantômes très lents
        2.0,    // Fantômes effrayés très lents
        2.2,    // Clyde effrayé très lent
        500,    // Super-gomme dure très longtemps
        240,    // Sortie de cage très lente
        3000    // Vie bonus à 3000 points
      );
    case 2: // HARD
      return new DifficultySettings(
        2,      // 2 vies seulement
        4.2,    // Fantômes TRÈS rapides (plus que Pac-Man!)
        4.5,    // Fantômes effrayés très rapides
        4.8,    // Clyde effrayé extrêmement rapide
        150,    // Super-gomme dure très peu de temps
        20,     // Sortie de cage quasi instantanée
        20000   // Vie bonus à 20000 points
      );
    default: // MEDIUM (1)
      return new DifficultySettings(
        3,      // 3 vies
        3.0,    // Vitesse augmentée
        3.5,    // Vitesse effrayé augmentée
        3.8,    // Clyde effrayé rapide
        250,    // Durée réduite
        90,     // Sortie plus rapide
        10000   // Vie bonus à 10000 points
      );
  }
}

// Bonus
final int BONUS_SPAWN_TIME = 600;         // Apparition bonus (10 secondes à 60fps)
final int BONUS_DURATION = 300;           // Durée bonus à l'écran

// Debug
final boolean DEBUG_GHOST_PATH = true;    // Afficher les trajectoires des fantômes
final int PATH_MAX_POINTS = 100;          // Nombre maximum de points dans la trajectoire
final int PATH_UPDATE_INTERVAL = 3;       // Ajouter un point tous les X frames
