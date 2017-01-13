// ** TODO **
//
// LIVES
// SCORE
// LAZER
// SHOOTER
// BOSS

PImage subSprite;

PGraphics playfield, g, g2;

CharacterSet cset;

Bullet[] bullets;

Enemy[] allEnemies;
Enemy[] activeEnemies;

Map worldMap;

Sub sub;

boolean pause = false;

int restarts[] = { 0x0000, 0x004A, 0x00AA, 0x010B, 0x0180, 0x021A, 0xfff }; 
int restartXY[]= { 12, 12, 130, 12, 130, 34, 130, 12, 130, 12, 130, 12 };

int pfWidth = Map._windowWidth * CharacterSet._width;
int pfHeight = Map._height * CharacterSet._height;

final int surfaceLevel = CharacterSet._height; // sub is under water when Y >= this value

float q = 0;
float scrollSpeed = 0.5;
float levelEndPosition = (Map._width-Map._windowWidth) * CharacterSet._width;

int frameMillis, lastMillis;
int restartPoint, showRestart;

void masterReset()
{
  restartPoint = 0;
}


void restart()
{
  q = restarts[restartPoint] * CharacterSet._width;
  
  sub.reset(restartXY[restartPoint * 2], restartXY[restartPoint * 2 + 1]);

  for (Enemy enemy : allEnemies)
  {
    enemy.reset();
  }

  lastMillis = millis();

  shoot = false; // CONTROLS class??
  
  pause = false;
  showRestart = 0;

  air = 100;
}

boolean DEBUG;

void setup()
{
  DEBUG = false;
  size(640, 400);

  masterReset();

  cset = new CharacterSet();

  subSprite = loadImage("sub.png");
  subSprite.loadPixels();

  sub = new Sub();

  g = createGraphics(Map._windowWidth * CharacterSet._width, Map._height * CharacterSet._height);
  g2 = createGraphics(Map._windowWidth * CharacterSet._width, (Map._height + 2) * CharacterSet._height);

  playfield = createGraphics(Map._width * CharacterSet._width, Map._height * CharacterSet._height);
  playfield.beginDraw();
  playfield.noStroke();

  worldMap = new Map();
  
  for (int i = 0; i < worldMap._map.length; ++i)
  {
    int c = worldMap._map[i];
    if (c == 0) continue;

    playfield.image(cset._charset[c], (i % Map._width) * CharacterSet._width, (i / Map._width) * CharacterSet._width);
  }

  bullets = new Bullet[5];
  for (int i = 0; i < bullets.length; ++i)
  {
    bullets[i] = new Bullet();
  }

  activeEnemies = new Enemy[25];
  allEnemies = createAllEnemies();

  if (DEBUG)
  {
    // show the character set
    for (int i = 0; i < cset._charset.length; i++)
    {
      playfield.tint((i&1)!=0 ? color(200) : color(255));
      playfield.image(cset._charset[i], i * 16, 17);
    }
  }

  playfield.endDraw();

  restart();
}

void mousePressed()
{
  q = map(mouseX, 0, width, 0, 600*16-width);
  println((int)(mouseX + q) / 16);
}

void draw()
{
  frameMillis = millis() - lastMillis;
  lastMillis = millis();

  if (pause)
    return;

  if (sub.isAlive())
  {
    if (q < levelEndPosition)
    {
      q = q + scrollSpeed;
    }
  }

  int iq = (int)q;
  int char0 = (int)(q / 16);

  if (char0 == restarts[restartPoint+1])
  {
    ++restartPoint;
    showRestart = 31;
  }

  g.beginDraw();
  g.noStroke();
  g.background(color(0, 0, 255));
  g.fill(0);
  g.rect(0, 0, pfWidth, CharacterSet._height);
  g.fill(color(100, 100, 255));
  g.rect(0, CharacterSet._height, pfWidth, CharacterSet._height);
  g.fill(0);
  g.rect(0, pfHeight + CharacterSet._height, pfWidth, CharacterSet._height);

  g.tint(0x63, (showRestart * 2)+0x23, (showRestart * 2)+0x23);
  if (showRestart != 0) --showRestart;

  g.image(playfield, -q, 16);

  int edtf = 0;
  int nchars = (width + (CharacterSet._width-1)) / CharacterSet._width; // flips between widthInChars and widthInChars+1, depending on scroll value

  for (Enemy enemy : allEnemies)
  {
    if (enemy._x >= char0 && enemy._x <= char0 + nchars)
    {
      enemy.update(g, iq);
      activeEnemies[edtf] = enemy;
      ++edtf;
    }
  }

  g.noTint();

  if (sub.update(g))
  {
    restart();
  }

  g.noTint();

  for (int i = 0; i < bullets.length; ++i)
  {
    if (bullets[i].update(g))
    {
      for (int j = 0; j < edtf; ++j)
      {
        Enemy enemy = activeEnemies[j];

        if (enemy.hasBeenShot(iq, bullets[i]._x, bullets[i]._y))
        {
          enemy.destroyed();
          break;
        }
      }
    }
  }
  g.endDraw();

  g2.beginDraw();
  g2.image(g, 0, 16);
  cset.csText(g2, 0, 10, "AIR:", color(255));
  g2.fill(0,200,0);
  float rsize = map(sub._air,0,100,0x00,0xf0);
  g2.rect(0x48,163,rsize,10);
  g2.endDraw();

  image(g2, 0, 0, width, height);
  
  if (DEBUG)
  {
    fill(255);
    textSize(16);
    text(String.format("%03x %d,%d [%d] %d", char0, (int)sub._x, (int)sub._y, restartPoint, edtf), 10, 170);
  }
}