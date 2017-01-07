PImage subSprite;
byte[] mayans;
PGraphics playfield;
CharacterSet cset;
ArrayList<Enemy> enemies;
Bullet[] bullets;
byte[] map;

Sub sub;

int restarts[] = { 0x0000, 0x0048+5, 0x00a8+5, 0x0109+5, 0x017e+5, 0x0218+5 }; 
int restartXY[]= { 12,12, 112,12, 112,34, 112,12, 112,12, 112,12 };

float q = 0;
float hiq = 0;
int restartTimer;
int frameMillis, lastMillis;

int minSubY = 12;
int restartPoint;

void masterReset()
{
  restartPoint = 0;
}

void setup()
{
  size(320, 200);
  
  masterReset();

  cset = new CharacterSet();

  subSprite = loadImage("sub.png");
  subSprite.loadPixels();

  sub = new Sub();

  playfield = createGraphics(600*16, 11*16);
  playfield.beginDraw();
  playfield.noStroke();
  playfield.background(color(0, 0, 255));
  playfield.fill(color(100, 100, 255));
  playfield.rect(0, 0, 600*16, 16);
  playfield.fill(0);
  playfield.rect(0, 160, 600*16, 16);

  map = loadBytes("src/hackery/sdmap.bin");
  for (int i = 0; i < map.length; i++)
  {
    int c = map[i] & 0x3f;
    if (c == 0) continue;
    int d = map[i] & 0xc0;
    if (d == 0) playfield.tint(color(100,40,40));
    else playfield.tint(0);
    playfield.image(cset._charset[c], (i % 600) * 16, (i / 600) * 16);
  }

  bullets = new Bullet[5];
  for(int i = 0; i < bullets.length; ++i)
  {
    bullets[i] = new Bullet();
  }

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

  // debug show the character set
  ///for (int i = 0; i < cset._charset.length; i++)
  ///{
  ///  playfield.tint((i&1)!=0 ? color(200) : color(255));
  ///  playfield.image(cset._charset[i], i * 16, 160);
  ///}

  playfield.endDraw();

  noStroke();
  noTint();
  
  restart();
}

void restart()
{
  restartPoint = 0;
  while(restartPoint < 5 && restarts[restartPoint] <= hiq / 16)
  {
    ++restartPoint;
  }
  --restartPoint;

restartPoint = 4;

  q = restarts[restartPoint] * 16;

  sub.reset(restartXY[restartPoint * 2], restartXY[restartPoint * 2 + 1]);

  restartTimer = 0;
  
  for(Enemy enemy : enemies)
  {
    enemy.reset();
  }

  lastMillis = millis();
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
  
  q = q + 0.5;

  image(playfield, -q, 0);

  int edtf = 0;
  int char0 = (int)(q / 16);
  int nchars = (width + 15) / 16;
  int iq = (int)q;
  
  for(Enemy enemy : enemies)
  {
    if (enemy._x >= char0 && enemy._x < char0 + nchars + 1)
    {
      enemy.update(iq);
      ++edtf;
    }
  }

  noTint();

  if (q > hiq) hiq = q;
  if (sub.update())
  {
      restart();
  }

  noTint();

  for(int i = 0; i < bullets.length; ++i)
  {
    if (bullets[i].update())
    {
      for(Enemy enemy : enemies)
      {
        if (!enemy._alive || enemy._state == 3) continue;
        if (bullets[i]._y < enemy._y || bullets[i]._y > enemy._y + 15) continue;

        int bcxs = (bullets[i]._x + iq) / 16;
        int bcxe = (bullets[i]._x + iq + 8) / 16;

        if (enemy._x > bcxe || enemy._x < bcxs) continue;

        enemy.destroyed();
        break;
      }
    }
  }  
}