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

  boolean hasBeenShot(int iq, int bulletX, int bulletY)
  {
    return collisionCalc(iq, bulletX, bulletY, 16);
  }
  
  protected boolean collisionCalc(int iq, int bulletX, int bulletY, int charHeight)
  {
    if (!_alive || _state == 3) return false;
    if (bulletY < _y || bulletY > _y + (charHeight - 1)) return false;

    int bcxs = (bulletX + iq) / 16;
    int bcxe = (bulletX + iq + 8) / 16;

    if (_x > bcxe || _x < bcxs) return false;

    return true;
  }

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

class Charge
{
  float _y;
  boolean _active;
  
  Charge()
  {
    _active = false;
  }
}

class DepthCharger extends Enemy
{
  int _x;
  int _timer;
  int _chargeY;
  Charge[] _charges;
  
  DepthCharger(int x)
  {
    super(x, 12, 0, color(0));

    _x = x;
    _timer = 59;
    _charges = new Charge[10];
    for(int i = 0; i < _charges.length; ++i)
    {
      _charges[i] = new Charge();
    }
    preWarm();
  }

  void destroyed()
  {
  }

  private void preWarm()
  {
    for(int i = 0; i < 300; ++i)
    {
      for (Charge charge : _charges)
      {
        if (!charge._active) continue;
  
        charge._y += 0.5;
        if (worldMap.cell(_x, (int)(charge._y + 4) / 16) != 0)
        {
          charge._active = false;
        }
      }
  
      ++_timer;
      if (_timer == 60)
      {
        _timer = 0;
        for (Charge charge : _charges)
        {
          if (charge._active) continue;
  
          charge._active = true;
          charge._y = 16;
          break;
        }
      }
    }
  }
  
  void update(int q)
  {
    for (Charge charge : _charges)
    {
      if (!charge._active) continue;

      charge._y += 0.5;
      if (worldMap.cell(_x, (int)charge._y / 16) != 0)
      {
        charge._active = false;
      }
      else
      {
        fill(0);
        rect(_x * 16 - q, charge._y, 8, 3);
      }
    }

    ++_timer;
    if (_timer == 60)
    {
      _timer = 0;
      for (Charge charge : _charges)
      {
        if (charge._active) continue;

        charge._active = true;
        charge._y = 16;
        break;
      }
    }
  }

  boolean hasBeenShot(int iq, int bulletX, int bulletY)
  {
    for (Charge charge : _charges)
    {
      _y = (int)charge._y;
      if (super.collisionCalc(iq, bulletX, bulletY, 3))
      {
        println("shot shot shot");
        charge._active = false;
        return true;
      }
    }

    return false;
  }
}

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
      if ((_y < 16) || (_y & 15) == 15 && worldMap.cell(_x, (int)_y / 16) != 0)
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
    if (!_alive) return;

    if(_state == 0)
    {
      _timeToActivate = (int)random(100,500);
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
      ++_y;
      int ccy = _y / 16;
      if (ccy == 9 || worldMap.cell(_x, ccy + 1) != 0)
      {
        _alive = false;
      }
    }

    draw(q);
  }
}