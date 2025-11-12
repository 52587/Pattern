// Flowing City

float noiseOffsetX = 0;
float noiseOffsetY = 0;
float noiseScale = 0.005;

float cityDensity = 0.03;
int minBuildingDist = 20;
ArrayList<Building> buildings;

int cellSize = 4;
int genSpeed = 5;
int framesBetweenGen = 0;
int currentRule = 0;
String[] ruleNames = {"Conway", "HighLife", "DayNight"};

int currentPreset = 1;
String[] presetNames = {"Sparse Harbor", "Medium Commercial", "Dense Downtown"};

void setup() {
  size(1200, 800);
  colorMode(HSB, 360, 100, 100);
  
  framesBetweenGen = int(60.0 / genSpeed);
  
  applyPreset(currentPreset);
  generateCity();
}

void draw() {
  background(0);
  
  drawTerrain();
  
  if (frameCount % framesBetweenGen == 0) {
    updateCellularAutomaton();
  }
  
  for (Building b : buildings) {
    b.display();
  }
  
  drawUI();
}

void drawTerrain() {
  loadPixels();
  for (int y = 0; y < height; y += 4) {
    for (int x = 0; x < width; x += 4) {
      float nx = (x % width) * noiseScale;
      float ny = (y % height) * noiseScale;
      
      float s = width * noiseScale / TWO_PI;
      float t = height * noiseScale / TWO_PI;
      
      float nx1 = s * cos(TWO_PI * nx / (width * noiseScale));
      float ny1 = t * cos(TWO_PI * ny / (height * noiseScale));
      float nx2 = s * sin(TWO_PI * nx / (width * noiseScale));
      
      float heightValue = noise(nx1 + noiseOffsetX, ny1 + noiseOffsetY, nx2 + 100);
      float hueValue = noise(nx1 + noiseOffsetX + 500, ny1 + noiseOffsetY + 500);
      
      float h = 220 + hueValue * 40;
      float sat = 30 + heightValue * 20;
      float bri = 5 + heightValue * 10;
      
      fill(h, sat, bri);
      noStroke();
      rect(x, y, 4, 4);
    }
  }
  updatePixels();
}

void drawUI() {
  fill(0, 0, 100);
  textAlign(LEFT);
  textSize(14);
  text("Preset [1-3]: " + presetNames[currentPreset], 10, 20);
  text("Rule [Q/W]: " + ruleNames[currentRule], 10, 40);
  text("Speed [E/R]: " + genSpeed + " gen/s", 10, 60);
  text("Density: " + nf(cityDensity, 1, 3) + " | Frequency: " + nf(noiseScale, 1, 4), 10, 80);
  text("[Space] Regenerate | [S] Save frame", 10, 100);
}

void generateCity() {
  buildings = new ArrayList<Building>();
  
  ArrayList<PVector> points = poissonDiscSampling(width, height, minBuildingDist, 30);
  
  for (PVector p : points) {
    if (random(1) < cityDensity) {
      float bw = random(20, 60);
      float bh = random(40, 120);
      int floors = int(bh / 10);
      
      buildings.add(new Building(p.x, p.y, bw, bh, floors, false));
    }
  }
}

ArrayList<PVector> poissonDiscSampling(float w, float h, float minDist, int k) {
  ArrayList<PVector> points = new ArrayList<PVector>();
  ArrayList<PVector> active = new ArrayList<PVector>();
  
  float cellSize = minDist / sqrt(2);
  int cols = ceil(w / cellSize);
  int rows = ceil(h / cellSize);
  int[][] grid = new int[cols][rows];
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      grid[i][j] = -1;
    }
  }
  
  PVector initial = new PVector(random(w), random(h));
  points.add(initial);
  active.add(initial);
  int col = int(initial.x / cellSize);
  int row = int(initial.y / cellSize);
  grid[col][row] = 0;
  
  while (active.size() > 0) {
    int randIndex = int(random(active.size()));
    PVector pos = active.get(randIndex);
    boolean found = false;
    
    for (int n = 0; n < k; n++) {
      float angle = random(TWO_PI);
      float radius = random(minDist, 2 * minDist);
      float newX = pos.x + cos(angle) * radius;
      float newY = pos.y + sin(angle) * radius;
      
      if (newX >= 0 && newX < w && newY >= 0 && newY < h) {
        int newCol = int(newX / cellSize);
        int newRow = int(newY / cellSize);
        
        boolean ok = true;
        for (int i = max(0, newCol - 2); i <= min(cols - 1, newCol + 2); i++) {
          for (int j = max(0, newRow - 2); j <= min(rows - 1, newRow + 2); j++) {
            if (grid[i][j] != -1) {
              PVector neighbor = points.get(grid[i][j]);
              if (dist(newX, newY, neighbor.x, neighbor.y) < minDist) {
                ok = false;
                break;
              }
            }
          }
          if (!ok) break;
        }
        
        if (ok) {
          PVector newPos = new PVector(newX, newY);
          points.add(newPos);
          active.add(newPos);
          grid[newCol][newRow] = points.size() - 1;
          found = true;
          break;
        }
      }
    }
    
    if (!found) {
      active.remove(randIndex);
    }
  }
  
  return points;
}

void updateCellularAutomaton() {
  for (Building b : buildings) {
    if (!b.isLight) {
      b.updateWindows();
    }
  }
}

void applyPreset(int preset) {
  if (preset == 0) {
    cityDensity = 0.015;
    minBuildingDist = 35;
    noiseScale = 0.003;
  } else if (preset == 1) {
    cityDensity = 0.03;
    minBuildingDist = 20;
    noiseScale = 0.005;
  } else if (preset == 2) {
    cityDensity = 0.06;
    minBuildingDist = 12;
    noiseScale = 0.008;
  }
}

void keyPressed() {
  if (key >= '1' && key <= '3') {
    currentPreset = key - '1';
    applyPreset(currentPreset);
    generateCity();
  } else if (key == 'q' || key == 'Q') {
    currentRule = (currentRule - 1 + 3) % 3;
  } else if (key == 'w' || key == 'W') {
    currentRule = (currentRule + 1) % 3;
  } else if (key == 'e' || key == 'E') {
    genSpeed = max(1, genSpeed - 1);
    framesBetweenGen = int(60.0 / genSpeed);
  } else if (key == 'r' || key == 'R') {
    genSpeed = min(30, genSpeed + 1);
    framesBetweenGen = int(60.0 / genSpeed);
  } else if (key == ' ') {
    noiseSeed(int(random(100000)));
    randomSeed(int(random(100000)));
    noiseOffsetX = random(1000);
    noiseOffsetY = random(1000);
    generateCity();
  } else if (key == 's' || key == 'S') {
    saveFrame("flowing_city_####.png");
    println("Frame saved!");
  }
}
