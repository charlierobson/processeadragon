abstract class Enemy
{
  int _x, _y, _c;
  color _colour;
  
  boolean _alive;
  boolean _active;
  
  float _timeToActivate;
  
  Enemy(int x, int y, int character, color colour)
  {
    _x = x;
    _y = y * 16;
    _c = character;
    _colour = colour;
    _alive = true;
    _active = false;
  }

  abstract void update();

  void draw(int q)
  {
    if (!_alive) return;
    
    tint(_colour);
    image(cset._charset[_c], _x * 16 - q, _y);
  }
}

//

class Mine extends Enemy
{
  Mine(int x, int y)
  {
    super(x, y, 63, color(0));
  }

  void update()
  {
    if (!_alive) return;
    
    if(!_active)
    {
      _active = true;
      _timeToActivate = random(200,800);
    }

    if (_active)
    {
      if (_timeToActivate < 0)
      {
        --_y;
        if (_y < 16)
        {
          _alive = false;
        }
      }
      --_timeToActivate;
    }
  }
}

class Stalactite extends Enemy
{
  Stalactite(int x, int y)
  {
    super(x, y, 55, color(200));
  }

  void update()
  {
  }
}