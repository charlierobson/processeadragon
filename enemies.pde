abstract class Enemy
{
  int _x, _y, _c;
  
  Enemy(int x, int y, int character)
  {
    _x = x;
    _y = y;
    _c = character;
  }

  abstract void update();

  void draw()
  {
    
  }
}

//

class Mine extends Enemy
{
  Mine(int x, int y)
  {
    super(x, y, 63);
  }

  void update()
  {
  }
}

class Stalactite extends Enemy
{
  Stalactite(int x, int y)
  {
    super(x, y, 55);
  }

  void update()
  {
  }
}