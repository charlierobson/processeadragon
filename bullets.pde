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
 
  boolean update()
  {
    if (!_active) return false;

    PImage bullcoll = get(_x,_y,8,1);
    bullcoll.loadPixels();
    for(int i = 0; i < bullcoll.pixels.length; ++i)
    {
      int c = bullcoll.pixels[i] & 0xffffff;
      if ((c & 0xff) == 0xff) continue;

      c &= 0xf8f8f8;
      int d = c & 0xff0000;

//println(hex(bullcoll.pixels[i]));
//println(hex(c));

      if (c != 0 && d != 0x600000) continue;

      _active = false;
      return true;
    }
    
    fill(255);
    rect(_x,_y,8,1);

    _x += 2;

    if (_x > width - 8) _active = false;
    
    return false;
  }
}