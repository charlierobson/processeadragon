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
    _x = (int)x + 56;
    _y = (int)y + 14;
    _active = true;
  }
 
  boolean update()
  {
    if (!_active) return false;

    PImage bullcoll = get(_x,_y,8,2);
    bullcoll.loadPixels();
    for(int i = 0; i < bullcoll.pixels.length; ++i)
    {
      if ((bullcoll.pixels[i] & 0xff) != 0xff)
      {
        _active = false;
        return true;
      }
    }
    
    fill(255);
    rect(_x,_y,8,2);

    _x += 2;

    if (_x > width) _active = false;
    
    return false;
  }
}