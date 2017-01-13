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
}