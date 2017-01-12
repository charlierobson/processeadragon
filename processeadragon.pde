// ** TODO **
//
// LIVES
// SCORE
// LAZER
// SHOOTER
// BOSS

PImage subSprite;
byte[] mayans;
PGraphics playfield;
CharacterSet cset;

Bullet[] bullets;

Enemy[] allEnemies;
Enemy[] activeEnemies;

Map worldMap;

Sub sub;
float air;

boolean pause = false;

int restarts[] = { 0x0000, 0x004A, 0x00AA, 0x010B, 0x0180, 0x021A, 0xfff }; 
int restartXY[]= { 12, 12, 130, 12, 130, 34, 130, 12, 130, 12, 130, 12 };

int depthChargeXs[] = { 0x0c5, 0x0df, 0x0f7, 0x10e };

int mapWidthInChars = 600;
int mapHeightInChars = 10;

int screenWidthInChars = 20;

int characterWidthInPixels = 16;
int characterHeightInPixels = 16;

int surfaceLevel = 15; // sub is under water when Y > this value

float q = 0;
float airLossRate = 0.025;
float scrollSpeed = 0.5;
float levelEndPosition = (mapWidthInChars-screenWidthInChars) * characterWidthInPixels;

int frameMillis, lastMillis;
int restartPoint, showRestart;

void masterReset()
{
  restartPoint = 1;
}


void restart()
{
  q = restarts[restartPoint] * characterWidthInPixels;
  
  sub.reset(restartXY[restartPoint * 2], restartXY[restartPoint * 2 + 1]);

  for (Enemy enemy : allEnemies)
  {
    enemy.reset();
  }

  lastMillis = millis();

  pause = false;
  showRestart = 0;

  air = 100;
}

boolean DEBUG = false;

void setup()
{
  size(320, 176); // normal
  //size(320, 192); // DEBUG

  masterReset();

  cset = new CharacterSet();

  subSprite = loadImage("sub.png");
  subSprite.loadPixels();

  sub = new Sub();

  playfield = createGraphics(mapWidthInChars * characterWidthInPixels, 11*16);
  playfield.beginDraw();
  playfield.noStroke();

  worldMap = new Map();
  
  for (int i = 0; i < worldMap._map.length; ++i)
  {
    int b = worldMap._map[i];

    if (b == 0) continue;

    int colourBit = b & 0xc0;
    b = b & 0x3f;

    if (colourBit == 0) playfield.tint(255);
    else playfield.tint(0);

    playfield.image(cset._charset[b], (i % worldMap._width) * characterWidthInPixels, (i / worldMap._width) * characterWidthInPixels);
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

  noStroke();
  noTint();

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
    if (sub._y > surfaceLevel)
    {
      if (air != 0)
      {
        air -= airLossRate;
        if (air <= 0)
        {
          air = 0;
          sub.destroy();
        }
      }
    }
    else
    {
      if (air < 100)
      {
        air += 3 * airLossRate;
      }
    }
  
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

  background(color(0, 0, 255));
  fill(color(100, 100, 255));
  rect(0, 0, width, characterHeightInPixels);
  fill(0);
  rect(0, 160, width, characterHeightInPixels);

  tint(0x63, (showRestart * 2)+0x23, (showRestart * 2)+0x23);
  if (showRestart != 0) --showRestart;

  image(playfield, -q, 0);

  int edtf = 0;
  int nchars = (width + (characterWidthInPixels-1)) / characterWidthInPixels; // flips between widthInChars and widthInChars+1, depending on scroll value

  for (Enemy enemy : allEnemies)
  {
    if (enemy._x >= char0 && enemy._x <= char0 + nchars)
    {
      enemy.update(iq);
      activeEnemies[edtf] = enemy;
      ++edtf;
    }
  }

  noTint();

  if (sub.update())
  {
    restart();
  }

  noTint();

  for (int i = 0; i < bullets.length; ++i)
  {
    if (bullets[i].update())
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

  cset.csText(0,10, "AIR:", color(255));
  fill(0,200,0);
  float rsize = map(air,0,100,0x00,0xf0);
  rect(0x48,163,rsize,10);

  if (DEBUG)
  {
    fill(255);
    textSize(16);
    text(String.format("%03x %d,%d [%d] %d", char0, (int)sub._x, (int)sub._y, restartPoint, edtf), 10, 170);
  }
}