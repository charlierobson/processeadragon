abstract class Enemy
{
  int _x, _iy, _y, _c, _state;
  color _colour;
  
  boolean _alive;

  int _timeToActivate;
  
  Enemy(int x, int y, int character, color colour)
  {
    _x = x;
    _iy = y * 16;
    _c = character;
    _colour = colour;
    _alive = true;
    _state = 0;
  }

  abstract void update(int q);

  void destroyed()
  {
    _state = 3;
    _timeToActivate = 0;
  }
  
  void reset()
  {
    _y = _iy;
    _state = 0;
    _alive = true;
  }
  
  void draw(int q)
  {
    if (!_alive) return;

    if (_state != 3)
    {
      tint(_colour);
      image(cset._charset[_c], _x * 16 - q, _y);
    }
    else
    {
      int n = 250 - _timeToActivate * 8;
      
      tint(color(n,n,255));
      image(cset._charset[45 + _timeToActivate / 6], _x * 16 - q, _y);

      ++_timeToActivate;
      if (_timeToActivate == 18) _alive = false;
    }
  }
}

//

class StaticMine extends Enemy
{
  int _tetherlength;

  StaticMine(int x, int y, int tetherlength)
  {
    super(x, y, 63, color(0));
    _tetherlength = tetherlength;
  }
  
  void update(int q)
  {
    if (!_alive) return;
    
    draw(q);
    if (_state != 3)
    {
      tint(20);
      for(int i = 0; i < _tetherlength; ++i)
      {
        image(cset._charset[34], _x * 16 - q, _y + (16 * (i + 1)));
      }
    }
  }
}

class Mine extends Enemy
{
  Mine(int x, int y)
  {
    super(x, y, 63, color(0));
  }

  void update(int q)
  {
    if (!_alive) return;

    if(_state == 0)
    {
      _timeToActivate = (int)random(200,800);
      _state = 1;
    }
    else if (_state == 1)
    {
      --_timeToActivate;
      if (_timeToActivate == 0)
      {
        _state = 2;
      }
    }
    else if (_state == 2)
    {
      --_y;
      if ((_y < 16) || (_y & 15) == 15 && map[_x + (_y / 16) * 600] != 0)
      {
        _state = 3;
        _timeToActivate = 0;
      }
    }

    draw(q);
  }
}

class Stalactite extends Enemy
{
  Stalactite(int x, int y)
  {
    super(x, y, 55, color(0));
  }

  void update(int q)
  {
    draw(q);
  }
}