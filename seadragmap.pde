int ppl = 16 * 600;
int ppcl = 16 * ppl;

PImage pixes;
PImage sub;
byte[] charset;
byte[] mayans;

void setup()
{
  size(1000,200);
  pixes = createImage(ppl, 11*16, RGB); 
  pixes.loadPixels();

  sub = loadImage("sub-x2.png");
  sub.loadPixels();
  for(int i = 0; i < sub.pixels.length; i++)
  {
    println(hex(sub.pixels[i]));
  }
  
  color c = color(100,100,255);
  for(int i = 0; i < pixes.pixels.length; i++)
  {
    pixes.pixels[i] = c;
    if (i == 600*16*16) c = color(0,0,255);
    if (i == 600*16*16*10) c = color(0);
  }
  
  charset  = loadBytes("src\\hackery\\charsets.bin");

  mayans  = loadBytes("src\\hackery\\mines.bin");
  
  byte[] map = loadBytes("src\\hackery\\sdmap.bin");
  for(int i = 0; i < map.length; i++)
  {
    plotCharacter(i % 600, i / 600, map[i] & 0x3f, color(255));
  }

  for(int i = 0; i < charset.length / 8; i++)
  {
    plotCharacter(i, 10, i, (i & 1) != 0 ?color(255):color(128));
  }

  int mc = 0xd8;
  int my = 0;
  int mxh = mc;
  int mxl = mc*2;
  
  for (int i = 0; i < mc; i++)
  {
    short m = (short)(((mayans[i+mxh] & 0xFF) << 8) | (mayans[i+mxl] & 0xFF));
    
    boolean isMover = (m & 0x8000) != 0;
    boolean isMine = (m & 0x4000) != 0;
    
    int cn = isMine ? 63 : isMover ? 55 : 63;

    c = isMover ? color(255,0,0) : color(255,80,0);

    int x = m & 0x3ff;

    plotCharacter(x, mayans[i+my], cn, c);
  }

  pixes.updatePixels();
}

void plotCharacter(int x, int y, int charv, color c)
{
  if (charv < 0 | charv > 127) return;

  int charvc = charv * 8;
  if (charvc >= charset.length - 7) return;

  int n = x * 16 + y * ppcl;

  for(int j = 0; j < 8; j++)
  {
    byte charb = charset[charvc+j];
    if ((charb & 0x80) != 0) { pixes.pixels[n+0] = c; pixes.pixels[n+1] = c; }
    if ((charb & 0x40) != 0) { pixes.pixels[n+2] = c; pixes.pixels[n+3] = c; }
    if ((charb & 0x20) != 0) { pixes.pixels[n+4] = c; pixes.pixels[n+5] = c; }
    if ((charb & 0x10) != 0) { pixes.pixels[n+6] = c; pixes.pixels[n+7] = c; }
    if ((charb & 0x8) != 0) { pixes.pixels[n+8] = c; pixes.pixels[n+9] = c; }
    if ((charb & 0x4) != 0) { pixes.pixels[n+10] = c; pixes.pixels[n+11] = c; }
    if ((charb & 0x2) != 0) { pixes.pixels[n+12] = c; pixes.pixels[n+13] = c; }
    if ((charb & 0x1) != 0) { pixes.pixels[n+14] = c; pixes.pixels[n+15] = c; }
    n += ppl;
    if ((charb & 0x80) != 0) { pixes.pixels[n+0] = c; pixes.pixels[n+1] = c; }
    if ((charb & 0x40) != 0) { pixes.pixels[n+2] = c; pixes.pixels[n+3] = c; }
    if ((charb & 0x20) != 0) { pixes.pixels[n+4] = c; pixes.pixels[n+5] = c; }
    if ((charb & 0x10) != 0) { pixes.pixels[n+6] = c; pixes.pixels[n+7] = c; }
    if ((charb & 0x8) != 0) { pixes.pixels[n+8] = c; pixes.pixels[n+9] = c; }
    if ((charb & 0x4) != 0) { pixes.pixels[n+10] = c; pixes.pixels[n+11] = c; }
    if ((charb & 0x2) != 0) { pixes.pixels[n+12] = c; pixes.pixels[n+13] = c; }
    if ((charb & 0x1) != 0) { pixes.pixels[n+14] = c; pixes.pixels[n+15] = c; }
    n += ppl;
  }
}

boolean up = false;
boolean down = false;
boolean left = false;
boolean right = false;

void keyPressed()
{
  if (key == 'w') { up = true; down = false; }
  else if (key == 's') { down = true; up = false; }
  else if (key == 'a') { left = true; right = false; }
  else if (key == 'd') { right = true; left = false; }
  else if (key == CODED)
  {
    if (keyCode == UP) { up = true; down = false; }
    else if (keyCode == DOWN) { down = true; up = false; }
    else if (keyCode == LEFT) { left = true; right = false; }
    else if (keyCode == RIGHT) { right = true; left = false; }
  }
}

void keyReleased()
{
  if (key == 'w') { up = false; }
  else if (key == 's') { down = false; }
  else if (key == 'a') { left = false; }
  else if (key == 'd') { right = false; }
  else if (key == CODED)
  {
    if (keyCode == UP) { up = false; }
    else if (keyCode == DOWN) { down = false; }
    else if (keyCode == LEFT) { left = false; }
    else if (keyCode == RIGHT) { right = false; }
  }
}

float q = 0;
float subY = 12;
float subX = 100;
boolean alive = true;

void draw()
{
  q = q + 0.5;

  if (up && subY > 6) --subY;
  else if (down) ++subY;
  
  if (left) --subX;
  else if (right) ++subX;
  
  image(pixes, -q, 0);

  if(alive)
  {
    PImage collision = get((int)subX,(int)subY,56,24);
  
    image(sub, subX, subY);
  
    collision.loadPixels();
    for(int i = 0; i < sub.pixels.length; i++)
    {
      if((sub.pixels[i] & 0xff000000) != 0)
      {
        if((collision.pixels[i] & 0x000000ff) != 0xff)
        {
          alive = false;
          break;
        }
      }
    }
    collision.updatePixels();
    image(collision,0,height-24);
  }
}