class Map
{
  static final int _width = 600;
  static final int _height = 10;

  static final int _windowWidth = 20;

  byte[] _map;

  Map()
  {
    _map = loadBytes("mungedmap.bin");
  }

  byte cell(int x, int y)
  {
    return _map[x + y * _width];
  }
  
  void draw(PGraphics target, int mapOffset)
  {
    target.beginDraw();
    target.noStroke();
    target.noTint();
    target.clear();

    for(int y = 0; y < 10; ++y)
    {
      for(int i = 0; i < target.width / 16; ++i)
      {
        target.image(cset._charset[cell(mapOffset + i, y)], i * 16, y * 16);
      }
    }
    target.endDraw();
  }
}