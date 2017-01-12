class Sub
{
  float _x, _y;
  int _state;
  int _timer;
  
  boolean isAlive()
  {
    return _state == 0;
  }

  void reset(int x, int y)
  {
    _x = x;
    _y = y;
    _state = 0;
  }

  void destroy()
  {
    _state = 1;
    _timer = 0;
    shoot = false;
  }
  
  boolean update()
  {
    if (_state == 0)
    {
      if (up && _y > 12) _y -= 0.5;
      else if (down) _y += 0.5;
    
      if (left && _x >= 0.5) _x -= 0.5;
      else if (right && _x < 130) _x += 0.5;
    
      PImage collision = get((int)_x, (int)_y, subSprite.width, subSprite.height);

      image(subSprite, _x, _y);

      collision.loadPixels();
      for (int i = 0; i < subSprite.pixels.length; i++)
      {
        if ((subSprite.pixels[i] & 0xff000000) != 0)
        {
          if ((collision.pixels[i] & 0x000000ff) < 0xfe)
          {
            destroy();
            break;
          }
        }
      }

      if (shoot)
      {
        for(int i = 0; i < bullets.length; ++i)
        {
          if (bullets[i]._active) continue;
          bullets[i].activate(_x + subSprite.width, _y + subSprite.height / 2);
          break;
        }
        shoot = false;
      }
    }
    else if (_state == 1)
    {
      int n = 250 - _timer * 2;
      
      tint(color(n,n,255));
      image(cset._charset[41 + _timer / 16], _x - 8, _y - 8);
      image(cset._charset[41 + _timer / 16], _x + 8, _y - 8);
      image(cset._charset[41 + _timer / 16], _x - 8, _y + 8);
      image(cset._charset[41 + _timer / 16], _x + 8, _y + 8);

      ++_timer;
      if (_timer == 96) _state = 2;
    }

    return _state == 2;
  }
}

boolean up = false;
boolean down = false;
boolean left = false;
boolean right = false;
boolean shoot = false;

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
  } else if (key == ' ') { 
    pause = !pause;
  } else if (key == CODED)
  {
    if (keyCode == SHIFT) {
      shoot = true;
    }
    else if (keyCode == UP) { 
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