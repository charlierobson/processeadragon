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
    } else
    {
      int n = 250 - _timeToActivate * 8;

      tint(color(n, n, 255));
      image(cset._charset[45 + _timeToActivate / 6], _x * 16 - q, _y);

      ++_timeToActivate;
      if (_timeToActivate == 18) _alive = false;
    }
  }
}

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
    for (int i = 0; i < _charges.length; ++i)
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
    for (int i = 0; i < 300; ++i)
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
      } else
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

  StaticMine(int x, int y)
  {
    super(x, y, 63, color(0));

    _tetherlength = 0;

    int ty = y + 1;
    while (ty < mapHeightInChars && worldMap._map[x + ty * mapWidthInChars] == 0)
    {
      ++ty;
      ++_tetherlength;
    }
  }

  void update(int q)
  {
    if (!_alive) return;

    draw(q);

    if (_state != 3)
    {
      tint(20);
      for (int i = 0; i < _tetherlength; ++i)
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

    if (_state == 0)
    {
      _timeToActivate = (int)random(200, 800);
      _state = 1;
    } else if (_state == 1)
    {
      --_timeToActivate;
      if (_timeToActivate == 0)
      {
        _state = 2;
      }
    } else if (_state == 2)
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

    if (_state == 0)
    {
      _timeToActivate = (int)random(100, 500);
      _state = 1;
    } else if (_state == 1)
    {
      --_timeToActivate;
      if (_timeToActivate == 0)
      {
        _state = 2;
      }
    } else if (_state == 2)
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

//

final int staticmine = 0; 
final int mine = 1;
final int depthcharger = 2;
final int shooter = 3;
final int laser = 4;
final int stalactite = 5;

int[] enemyList = {
  8, 6, staticmine, 
  10, 3, staticmine, 
  11, 8, mine, 
  13, 8, mine, 
  14, 8, mine, 
  17, 2, staticmine, 
  19, 4, staticmine, 
  22, 6, mine, 
  24, 6, mine, 
  25, 6, mine, 
  27, 4, staticmine, 
  29, 2, staticmine, 
  31, 8, mine, 
  33, 8, mine, 
  35, 6, mine, 
  38, 5, mine, 
  42, 1, staticmine, 
  45, 1, staticmine, 
  47, 2, staticmine, 
  49, 8, mine, 
  51, 8, mine, 
  52, 8, mine, 
  56, 7, mine, 
  57, 5, staticmine, 
  59, 7, mine, 
  62, 7, mine, 
  63, 7, mine, 
  64, 7, mine, 
  66, 3, staticmine, 
  67, 7, mine, 
  72, 5, mine, 
  73, 3, staticmine, 
  75, 5, mine, 
  78, 4, mine, 
  81, 1, staticmine, 
  87, 2, staticmine, 
  90, 6, mine, 
  92, 6, mine, 
  93, 4, staticmine, 
  95, 7, mine, 
  97, 3, staticmine, 
  98, 8, mine, 
  100, 8, mine, 
  103, 8, mine, 
  106, 9, mine, 
  107, 2, staticmine, 
  109, 9, mine, 
  110, 9, mine, 
  113, 8, mine, 
  114, 4, staticmine, 
  118, 7, mine, 
  126, 9, mine, 
  130, 1, shooter, 
  140, 8, mine, 
  143, 5, shooter, 
  156, 8, staticmine, 
  157, 7, staticmine, 
  162, 7, mine, 
  163, 1, shooter, 
  167, 7, mine, 
  170, 8, mine, 
  174, 6, mine, 
  176, 1, shooter, 
  177, 8, mine, 
  183, 6, mine, 
  185, 2, staticmine, 
  187, 7, mine, 
  188, 7, mine, 
  190, 4, staticmine, 
  192, 8, mine, 
  194, 8, mine, 
  195, 8, mine, 
  197, 0, depthcharger, 
  199, 6, mine, 
  206, 5, mine, 
  209, 3, mine, 
  212, 1, staticmine, 
  214, 1, staticmine, 
  215, 2, staticmine, 
  218, 7, mine, 
  221, 6, mine, 
  223, 0, depthcharger, 
  225, 3, staticmine, 
  226, 8, mine, 
  228, 6, mine, 
  230, 4, mine, 
  232, 2, staticmine, 
  233, 6, mine, 
  234, 4, staticmine, 
  237, 3, mine, 
  238, 3, mine, 
  241, 1, staticmine, 
  244, 1, staticmine, 
  246, 2, staticmine, 
  247, 0, depthcharger, 
  248, 8, mine, 
  252, 6, mine, 
  253, 6, mine, 
  254, 3, staticmine, 
  255, 6, mine, 
  256, 4, staticmine, 
  259, 8, mine, 
  261, 8, mine, 
  262, 2, staticmine, 
  266, 5, mine, 
  270, 0, depthcharger, 
  273, 1, staticmine, 
  283, 2, staticmine, 
  284, 2, staticmine, 
  288, 8, mine, 
  289, 8, staticmine, 
  290, 8, staticmine, 
  291, 8, staticmine, 
  292, 8, staticmine, 
  296, 1, laser, 
  298, 6, staticmine, 
  299, 6, staticmine, 
  300, 6, staticmine, 
  304, 1, laser, 
  307, 6, mine, 
  309, 6, mine, 
  317, 7, staticmine, 
  318, 7, staticmine, 
  319, 7, staticmine, 
  322, 1, laser, 
  326, 9, staticmine, 
  327, 9, staticmine, 
  340, 4, staticmine, 
  341, 4, staticmine, 
  344, 3, shooter, 
  350, 7, staticmine, 
  352, 1, shooter, 
  359, 2, staticmine, 
  362, 9, mine, 
  364, 1, shooter, 
  365, 9, mine, 
  366, 9, mine, 
  367, 9, mine, 
  368, 9, mine, 
  369, 1, laser, 
  371, 9, mine, 
  374, 1, shooter, 
  374, 9, mine, 
  375, 9, mine, 
  376, 9, mine, 
  377, 9, mine, 
  379, 1, laser, 
  380, 9, mine, 
  384, 5, staticmine, 
  385, 5, staticmine, 
  387, 4, staticmine, 
  388, 4, staticmine, 
  390, 3, staticmine, 
  391, 3, staticmine, 
  396, 2, mine, 
  397, 1, staticmine, 
  398, 2, staticmine, 
  401, 7, mine, 
  404, 6, mine, 
  405, 6, mine, 
  406, 2, staticmine, 
  411, 2, mine, 
  413, 1, staticmine, 
  417, 6, mine, 
  418, 6, mine, 
  422, 5, staticmine, 
  423, 8, mine, 
  425, 6, mine, 
  426, 2, staticmine, 
  428, 1, staticmine, 
  429, 1, staticmine, 
  432, 3, mine, 
  433, 2, staticmine, 
  435, 8, mine, 
  436, 4, staticmine, 
  437, 8, mine, 
  438, 8, mine, 
  439, 5, staticmine, 
  444, 8, mine, 
  448, 7, mine, 
  456, 5, staticmine, 
  459, 8, mine, 
  460, 8, mine, 
  469, 8, mine, 
  471, 7, mine, 
  473, 6, mine, 
  475, 5, mine, 
  477, 4, mine, 
  479, 3, mine, 
  481, 2, mine, 
  492, 9, mine, 
  493, 3, stalactite, 
  495, 4, stalactite, 
  496, 9, mine, 
  497, 3, stalactite, 
  501, 4, stalactite, 
  502, 4, stalactite, 
  504, 8, mine, 
  507, 1, stalactite, 
  508, 1, stalactite, 
  509, 9, mine, 
  510, 5, staticmine, 
  512, 2, stalactite, 
  513, 9, mine, 
  515, 4, stalactite, 
  516, 6, staticmine, 
  518, 5, staticmine, 
  520, 1, stalactite, 
  521, 1, stalactite, 
  522, 7, mine, 
  523, 1, stalactite, 
  525, 7, mine, 
  526, 5, staticmine, 
  528, 3, stalactite, 
  529, 7, mine, 
  532, 4, stalactite, 
  533, 7, mine, 
  534, 4, stalactite, 
  545, 8, mine, 
  549, 5, mine, 
  552, 3, mine, 
  553, 1, staticmine, 
  554, 3, mine, 
  555, 3, mine, 
  559, 3, staticmine, 
  562, 7, mine, 
  566, 7, mine, 
  567, 6, staticmine, 
  569, 7, mine, 
  570, 7, mine, 
  573, 5, staticmine, 
  576, 6, mine, 
  580, 1, shooter, 
  584, 1, shooter, 
  597, 5, staticmine // boss
};

Enemy enemyFactory(int x, int y, int type)
{
  switch(type) {
  case staticmine: 
    return new StaticMine(x, y);
  case mine: 
    return new Mine(x, y);
  case depthcharger: 
    return new DepthCharger(x);
  case stalactite: 
    return new Stalactite(x, y);
  case shooter:
    return new Mine(x,y);
  case laser:
    return new Mine(x,y);

  default:
    return null;
  }
}

Enemy[] createAllEnemies()
{
  int enemyCount = enemyList.length / 3;

  Enemy[] allEnemies = new Enemy[enemyCount];

  for (int i = 0; i < enemyCount; ++i)
  {
    allEnemies[i] = enemyFactory(enemyList[i * 3], enemyList[i * 3 + 1], enemyList[i * 3 + 2]);
  }

  return allEnemies;
}