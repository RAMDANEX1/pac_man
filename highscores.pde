// meilleurs scores
class HighScores {
  String[] names;
  int[] scores;
  int maxScores = 5;
  String filepath = "data/scores.txt";
  
  HighScores() {
    names = new String[maxScores];
    scores = new int[maxScores];
    load();
  }
  
  void load() {
    String[] lines = loadStrings(filepath);
    if (lines == null || lines.length == 0) {
      // scores par defaut
      for (int i = 0; i < maxScores; i++) {
        names[i] = "---";
        scores[i] = 0;
      }
      return;
    }
    
    for (int i = 0; i < min(lines.length, maxScores); i++) {
      String[] parts = split(lines[i], ',');
      if (parts.length >= 2) {
        names[i] = parts[0];
        scores[i] = int(parts[1]);
      }
    }
  }
  
  void save() {
    String[] lines = new String[maxScores];
    for (int i = 0; i < maxScores; i++) {
      lines[i] = names[i] + "," + scores[i];
    }
    saveStrings(filepath, lines);
  }
  
  // verifie si top 5
  boolean isHighScore(int score) {
    for (int i = 0; i < maxScores; i++) {
      if (score > scores[i]) {
        return true;
      }
    }
    return false;
  }
  
  // ajout score
  void addScore(String name, int score) {
    // trouver position
    int pos = maxScores;
    for (int i = 0; i < maxScores; i++) {
      if (score > scores[i]) {
        pos = i;
        break;
      }
    }
    
    if (pos >= maxScores) {
      println("Score enregistre mais pas dans top 5: " + name + " - " + score);
      return;
    }
    
    // Decaler les scores inferieurs
    for (int i = maxScores - 1; i > pos; i--) {
      names[i] = names[i-1];
      scores[i] = scores[i-1];
    }
    
    // Inserer le nouveau score
    names[pos] = name;
    scores[pos] = score;
    
    println("Score ajoute au top 5 position " + (pos+1) + ": " + name + " - " + score);
    save();
  }
  
  void display() {
    fill(255, 255, 0);
    textAlign(CENTER);
    textSize(40);
    text("MEILLEURS SCORES", width/2, 120);
    
    textSize(24);
    fill(255);
    int startY = 200;
    
    // afficher seulement les scores valides (non vides et > 0)
    int displayCount = 0;
    for (int i = 0; i < maxScores; i++) {
      // ignorer les scores a 0 ou les noms vides/par defaut
      if (scores[i] > 0 && !names[i].equals("---")) {
        String line = (displayCount+1) + ".  " + names[i];
        // Ajouter des espaces pour aligner
        while (line.length() < 25) {
          line += " ";
        }
        line += scores[i];
        
        text(line, width/2, startY + displayCount * 50);
        displayCount++;
      }
    }
    
    // si aucun score, afficher message
    if (displayCount == 0) {
      fill(150);
      textSize(24);
      text("Aucun score enregistre", width/2, startY + 100);
    }
    
    textSize(18);
    fill(150);
    text("Appuyez sur ESC pour retourner au menu", width/2, height - 50);
  }
}
