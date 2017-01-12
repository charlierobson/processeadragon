class Map
{
  byte[] _map;

  int _width = 600;
  int _height = 10;

  Map()
  {
    _map = loadBytes("src/hackery/sdmap.bin");
  }

  byte cell(int x, int y)
  {
    return _map[x + y * _width];
  }
}