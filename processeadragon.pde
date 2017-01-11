// ** TODO **
//
// AIR
// LIVES
// SCORE
// LAZER
// SHOOTER
// BOSS

PImage subSprite;
byte[] mayans;
PGraphics playfield;
CharacterSet cset;
ArrayList<Enemy> enemies;
Bullet[] bullets;
Enemy[] activeEnemies;
byte[] map;
Sub sub;

boolean pause = false;

int restarts[] = { 0x0000, 0x004A, 0x00AA, 0x010B, 0x0180, 0x021A, 0xfff }; 
int restartXY[]= { 12,12, 130,12, 130,34, 130,12, 130,12, 130,12 };

int depthChargeXs[] = { 0x0c5, 0x0df, 0x0f7, 0x10e };

float q = 0;

int frameMillis, lastMillis;
int restartPoint, showRestart;

void masterReset()
{
  restartPoint = 2;
}


void restart()
{
  q = restarts[restartPoint] * 16;
  sub.reset(restartXY[restartPoint * 2], restartXY[restartPoint * 2 + 1]);
  
  for(Enemy enemy : enemies)
  {
    enemy.reset();
  }

  lastMillis = millis();

  pause = false;
  showRestart = 0;
}


void setup()
{
  size(320, 176);
  
  masterReset();

  cset = new CharacterSet();

  subSprite = loadImage("sub.png");
  subSprite.loadPixels();

  sub = new Sub();

  playfield = createGraphics(600*16, 11*16);
  playfield.beginDraw();
  playfield.noStroke();

  map = loadBytes("src/hackery/sdmap.bin");
  for (int i = 0; i < map.length; i++)
  {
    int c = map[i] & 0x3f;
    if (c == 0) continue;
    int d = map[i] & 0xc0;
    if (d == 0) playfield.tint(255);
    else playfield.tint(0);
    playfield.image(cset._charset[c], (i % 600) * 16, (i / 600) * 16);
  }

  bullets = new Bullet[5];
  for(int i = 0; i < bullets.length; ++i)
  {
    bullets[i] = new Bullet();
  }

  activeEnemies = new Enemy[25];

  enemies = new ArrayList<Enemy>();

  mayans  = loadBytes("src/hackery/mines.bin");

  int mc = mayans.length / 3;
  int my = 0;
  int mxh = mc;
  int mxl = mc*2;

  playfield.tint(color(0));

  for (int i = 0; i < mc; i++)
  {
    short m = (short)(((mayans[i+mxh] & 0xFF) << 8) | (mayans[i+mxl] & 0xFF));

    int x = m & 0x3ff;
    int y = mayans[i+my];

    // type 0 = passive mine
    // type 1 = tethered mine
    // type 2 = stalactite
    // type 3 = active mine
    int type = (m & 0xc000) >> 14;

    if (type == 2) enemies.add(new Stalactite(x, y));
    else if (type == 3) enemies.add(new Mine(x, y));
    else
    {
      int ty = y + 1;
      int tetherlen = 0;
      while(ty < 10 && map[x + ty * 600] == 0)
      {
        ++tetherlen;
        ++ty;
      }
      enemies.add(new StaticMine(x, y, tetherlen));
    }
  }

  for (int i = 0; i < depthChargeXs.length; ++i)
  {
      enemies.add(new DepthCharger(depthChargeXs[i]));
  }

  // debug show the character set
  for (int i = 0; i < cset._charset.length; i++)
  {
   playfield.tint((i&1)!=0 ? color(200) : color(255));
    playfield.image(cset._charset[i], i * 16, 160);
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

  if (q < (600-20) * 16)
  {
    q = q + 0.5;
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
  rect(0, 0, width, 16);
  fill(0);
  rect(0, 160, width, 16);

  tint(0x63,(showRestart * 2)+0x23,(showRestart * 2)+0x23);
  if (showRestart != 0) --showRestart;

  image(playfield, -q, 0);

  int edtf = 0;
  int nchars = (width + 15) / 16;
  
  for(Enemy enemy : enemies)
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

  for(int i = 0; i < bullets.length; ++i)
  {
    if (bullets[i].update())
    {
      for(int j = 0; j < edtf; ++j)
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

  fill(255);
  textSize(16);
  text(String.format("%03x %d,%d [%d] %d",char0,(int)sub._x,(int)sub._y,restartPoint,edtf),10,170);
}