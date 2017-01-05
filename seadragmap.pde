PImage sub;
byte[] mayans;
PGraphics playfield;
CharacterSet cset;
ArrayList<Enemy> enemies;

void setup()
{
  size(1000, 200);

  cset = new CharacterSet();

  sub = loadImage("sub-x2.png");
  sub.loadPixels();

  playfield = createGraphics(600*16, 11*16);
  playfield.beginDraw();
  playfield.noStroke();
  playfield.background(color(0, 0, 255));
  playfield.fill(color(100, 100, 255));
  playfield.rect(0, 0, 600*16, 16);
  playfield.fill(0);
  playfield.rect(0, 160, 600*16, 16);


  byte[] map = loadBytes("src\\hackery\\sdmap.bin");
  for (int i = 0; i < map.length; i++)
  {
    if (map[i] == 0) continue;

    if (map[i] > 0 && map[i] < 64)
    {
      playfield.tint(color(80));
      playfield.image(cset._charset[map[i]], (i % 600) * 16, (i / 600) * 16);
    } else
    {
      playfield.tint(color(180));
      playfield.image(cset._charset[map[i] & 0x3f], (i % 600) * 16, (i / 600) * 16);
    }
  }

  enemies = new ArrayList<Enemy>();

  mayans  = loadBytes("src\\hackery\\mines.bin");

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
    else if (type == 2) enemies.add(new Mine(x, y));
    else
    {
      playfield.image(cset._charset[63], x * 16, y * 16);
      if (type == 1)
      {
        // tether the mine
        int mapY = y + 1;
        while (mapY < 10 && map[x + 600 * mapY] == 0)
        {
          playfield.image(cset._charset[34], x * 16, mapY * 16);
          mapY++;
        }
      }
    }
  }

  ///for (int i = 0; i < cset._charset.length; i++) {
  ///playfield.tint((i&1)!=0 ? color(200) : color(255));
  ///playfield.image(cset._charset[i], i * 16, 160);
  ///}

  playfield.endDraw();
}

boolean up = false;
boolean down = false;
boolean left = false;
boolean right = false;

void keyPressed()
{
  if (key == 'w') { 
    up = true; 
    down = false;
  } else if (key == 's') { 
    down = true; 
    up = false;
  } else if (key == 'a') { 
    left = true; 
    right = false;
  } else if (key == 'd') { 
    right = true; 
    left = false;
  } else if (key == CODED)
  {
    if (keyCode == UP) { 
      up = true; 
      down = false;
    } else if (keyCode == DOWN) { 
      down = true; 
      up = false;
    } else if (keyCode == LEFT) { 
      left = true; 
      right = false;
    } else if (keyCode == RIGHT) { 
      right = true; 
      left = false;
    }
  }
}

void keyReleased()
{
  if (key == 'w') { 
    up = false;
  } else if (key == 's') { 
    down = false;
  } else if (key == 'a') { 
    left = false;
  } else if (key == 'd') { 
    right = false;
  } else if (key == CODED)
  {
    if (keyCode == UP) { 
      up = false;
    } else if (keyCode == DOWN) { 
      down = false;
    } else if (keyCode == LEFT) { 
      left = false;
    } else if (keyCode == RIGHT) { 
      right = false;
    }
  }
}


float q = 0;
float subY = 6;
float subX = 0;
boolean alive = true;


void mousePressed()
{
  q = map(mouseX, 0, width, 0, 600*16-width);
  println((int)(mouseX + q) / 16);
}


void draw()
{
  q = q + 0.5;

  if (up && subY > 6) --subY;
  else if (down) ++subY;

  if (left) --subX;
  else if (right) ++subX;

  image(playfield, -q, 0);

  if (alive)
  {
    PImage collision = get((int)subX, (int)subY, 56, 24);

    image(sub, subX, subY);

    collision.loadPixels();
    for (int i = 0; i < sub.pixels.length; i++)
    {
      if ((sub.pixels[i] & 0xff000000) != 0)
      {
        if ((collision.pixels[i] & 0x000000ff) != 0xff)
        {
          alive = false;
          break;
        }
      }
    }
    ///collision.updatePixels();
    ///image(collision, 0, height-24);
  }
}