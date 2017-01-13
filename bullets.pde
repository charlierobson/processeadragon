class Bullet
{
  int _x, _y;
  boolean _active;
  
  Bullet()
  {
    _active = false;
  }

  void activate(float x, float y)
  {
    _x = (int)x;
    _y = (int)y;
    _active = true;
  }
 
  boolean update(PGraphics g)
  {
    if (!_active) return false;

    PImage bullcoll = g.get(_x,_y,8,1);
    bullcoll.loadPixels();

    for(int i = 0; i < bullcoll.pixels.length; ++i)
    {
      int c = bullcoll.pixels[i];
      if ((c & 0xff) == 0xff) continue; // we don't collide with anything that has a full-on blue component

      c &= 0xf8f8f8; // remove 3 least significant bits, as tinting of images has innaccuracies.
      int d = c & 0xff0000;

//println(hex(bullcoll.pixels[i]));
//println(hex(c));

      // enemies are all black, background will have a red component of 0x60
      if (c != 0 && d != 0x600000) continue;

      _active = false;
      return true;
    }
    
    g.fill(255);
    g.rect(_x,_y,8,1);

    _x += 2;

    if (_x > width - 8) _active = false;
    
    return false;
  }
}