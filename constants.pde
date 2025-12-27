// ===== DIMENSIONS DU JEU =====
final int CELL_SIZE = 40;           // Taille d'une cellule en pixels
final int BOARD_WIDTH = 19;         // Nombre de cellules en largeur
final int BOARD_HEIGHT = 21;        // Nombre de cellules en hauteur
final int BOARD_OFFSET_X = 50;      // Décalage du plateau (x)
final int BOARD_OFFSET_Y = 100;     // Décalage du plateau (y)

// ===== SCORES =====
final int SCORE_DOT = 10;           // Points pour une gomme normale
final int SCORE_SUPER_DOT = 50;     // Points pour une super-gomme
final int SCORE_BONUS = 100;        // Points pour un bonus

// ===== COULEURS =====
final color COLOR_WALL = #2121DE;         // Bleu foncé pour les murs
final color COLOR_BG = #000000;           // Fond noir
final color COLOR_DOT = #FFB897;          // Beige pour les gommes
final color COLOR_SUPER_DOT = #FFA500;    // Orange pour super-gommes
final color COLOR_EMPTY = #000000;        // Noir pour cases vides
final color COLOR_TEXT = #FFFFFF;         // Blanc pour le texte
final color COLOR_PACMAN = #FFFF00;       // Jaune pour Pac-Man

// ===== PAC-MAN =====
final float PACMAN_SIZE = 30;             // Taille de Pac-Man
final float PACMAN_SPEED = 4.0;           // Vitesse de déplacement (pixels par frame)
final float MOUTH_ANGLE = 45;             // Angle d'ouverture de la bouche (degrés)
final float MOUTH_SPEED = 0.15;           // Vitesse d'animation de la bouche

// ===== FANTÔMES =====
final int GHOST_COUNT = 4;                // Nombre de fantômes
final float GHOST_SIZE = 28;              // Taille des fantômes
final float GHOST_SPEED = 2.5;            // Vitesse normale des fantômes
final float GHOST_SCARED_SPEED = 1.0;     // Vitesse quand effrayés
final int GHOST_SCARED_TIME = 300;        // Durée de l'effet super-gomme (frames)
final int GHOST_RELEASE_DELAY = 120;      // Délai entre sorties de fantômes

// Couleurs des fantômes
final color COLOR_GHOST_RED = #FF0000;    // Blinky (rouge)
final color COLOR_GHOST_PINK = #FFB8FF;   // Pinky (rose)
final color COLOR_GHOST_CYAN = #00FFFF;   // Inky (cyan)
final color COLOR_GHOST_ORANGE = #FFB852; // Clyde (orange)
final color COLOR_GHOST_SCARED = #0000FF; // Bleu quand effrayés
final color COLOR_GHOST_EYES = #FFFFFF;   // Blanc pour les yeux

// ===== GAMEPLAY =====
final int INITIAL_LIVES = 3;              // Nombre de vies au départ
final int SCORE_GHOST = 200;              // Points pour manger un fantôme

// ===== BONUS =====
final int BONUS_CHERRY_SCORE = 100;       // Points cerise
final int BONUS_DIAMOND_SCORE = 300;      // Points diamant
final int BONUS_SPAWN_TIME = 600;         // Apparition bonus (10 secondes à 60fps)
final int BONUS_DURATION = 300;           // Durée bonus à l'écran

// ===== SPRITES =====
final int SPRITE_SIZE = 48;               // Taille d'un sprite dans le spritesheet (6 carreaux × 8 pixels)
final boolean USE_SPRITES = false;        // Activer/désactiver les sprites (DÉSACTIVÉ POUR DEBUG)
final boolean DEBUG_SPRITES = false;      // Mode debug : afficher la grille du spritesheet
