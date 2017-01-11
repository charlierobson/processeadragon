PImage subSprite;
byte[] mayans;
PGraphics playfield;
CharacterSet cset;
ArrayList<Enemy> enemies;
Bullet[] bullets;
byte[] map;

Sub sub;

boolean pause = false;

int restarts[] = { 0x0000, 0x004A, 0x00AA, 0x010B, 0x0180, 0x021A, 0xfff }; 
int restartXY[]= { 12,12, 130,12, 130,34, 130,12, 130,12, 130,12 };

float q = 0;
float hiq = 0;
int restartTimer;
int frameMillis, lastMillis;

int minSubY = 12;
int restartPoint;
int showRestart;

void masterReset()
{
  restartPoint = 0;
}


void restart()
{
  q = restarts[restartPoint] * 16;

  sub.reset(restartXY[restartPoint * 2], restartXY[restartPoint * 2 + 1]);

  restartTimer = 0;
  
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
  size(320, 200);
  
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

  q = q + 0.5;

  int iq = (int)q;
  int char0 = (int)(q / 16);

  if (char0 == restarts[restartPoint+1])
  {
    ++restartPoint;
    restartTimer = 15;
  }

  background(color(0, 0, 255));
  fill(color(100, 100, 255));
  rect(0, 0, width, 16);
  fill(0);
  rect(0, 160, width, 16);

  tint(0x63,(restartTimer * 4)+0x23,(restartTimer * 4)+0x23);
  image(playfield, -q, 0);

  int edtf = 0;
  int nchars = (width + 15) / 16;
  
  for(Enemy enemy : enemies)
  {
    if (enemy._x >= char0 && enemy._x < char0 + nchars + 1)
    {
      enemy.update(iq);
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

  if (restartTimer != 0) --restartTimer;
  
  fill(255);
  textSize(16);
  text(String.format("%03x %d,%d [%d] %d",char0,(int)sub._x,(int)sub._y,restartPoint,edtf),10,170);
}