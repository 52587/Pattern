class Building {
  float x, y;
  float w, h;
  int floors;
  boolean isLight;
  
  int windowCols, windowRows;
  boolean[][] windows;
  boolean[][] nextWindows;
  
  float hue;
  float brightness;
  
  Building(float x_, float y_, float w_, float h_, int floors_, boolean isLight_) {
    x = x_;
    y = y_;
    w = w_;
    h = h_;
    floors = floors_;
    isLight = isLight_;
    
    hue = random(200, 240);
    brightness = random(10, 20);
    
    if (!isLight) {
      windowCols = max(2, int(w / cellSize));
      windowRows = max(2, int(h / cellSize));
      
      windows = new boolean[windowCols][windowRows];
      nextWindows = new boolean[windowCols][windowRows];
      
      for (int i = 0; i < windowCols; i++) {
        for (int j = 0; j < windowRows; j++) {
          windows[i][j] = random(1) < 0.3;
        }
      }
    }
  }
  
  void display() {
    if (isLight) {
      stroke(60, 80, 100);
      strokeWeight(2);
      line(x, y, x, y - h);
      
      noStroke();
      fill(60, 60, 100, 80);
      ellipse(x, y - h, 20, 20);
      fill(60, 80, 100);
      ellipse(x, y - h, 12, 12);
    } else {
      fill(hue, 40, brightness);
      stroke(hue, 60, brightness + 5);
      strokeWeight(1);
      rect(x - w/2, y - h, w, h);
      
      noStroke();
      for (int i = 0; i < windowCols; i++) {
        for (int j = 0; j < windowRows; j++) {
          if (windows[i][j]) {
            float brightness = random(70, 100);
            fill(45, 80, brightness);
          } else {
            fill(hue, 30, 5);
          }
          
          float wx = x - w/2 + i * cellSize + 2;
          float wy = y - h + j * cellSize + 2;
          rect(wx, wy, cellSize - 2, cellSize - 2);
        }
      }
    }
  }
  
  void updateWindows() {
    if (isLight) return;
    
    for (int i = 0; i < windowCols; i++) {
      for (int j = 0; j < windowRows; j++) {
        int neighbors = countNeighbors(i, j);
        
        if (currentRule == 0) {
          if (windows[i][j]) {
            nextWindows[i][j] = (neighbors == 2 || neighbors == 3);
          } else {
            nextWindows[i][j] = (neighbors == 3);
          }
        } else if (currentRule == 1) {
          if (windows[i][j]) {
            nextWindows[i][j] = (neighbors == 2 || neighbors == 3);
          } else {
            nextWindows[i][j] = (neighbors == 3 || neighbors == 6);
          }
        } else if (currentRule == 2) {
          if (windows[i][j]) {
            nextWindows[i][j] = (neighbors == 3 || neighbors == 4 || neighbors == 6 || neighbors == 7 || neighbors == 8);
          } else {
            nextWindows[i][j] = (neighbors == 3 || neighbors == 6 || neighbors == 7 || neighbors == 8);
          }
        }
      }
    }
    
    for (int i = 0; i < windowCols; i++) {
      for (int j = 0; j < windowRows; j++) {
        windows[i][j] = nextWindows[i][j];
      }
    }
    
    if (random(1) < 0.02) {
      int ri = int(random(windowCols));
      int rj = int(random(windowRows));
      windows[ri][rj] = !windows[ri][rj];
    }
  }
  
  int countNeighbors(int x, int y) {
    int count = 0;
    for (int i = -1; i <= 1; i++) {
      for (int j = -1; j <= 1; j++) {
        if (i == 0 && j == 0) continue;
        
        int col = (x + i + windowCols) % windowCols;  // Wrap around
        int row = (y + j + windowRows) % windowRows;
        
        if (windows[col][row]) {
          count++;
        }
      }
    }
    return count;
  }
}
