class CharacterSet
{
  PImage[] _charset;

  CharacterSet()
  {
    color c = color(255);

    byte[] chardata = loadBytes("src\\hackery\\charsets.bin");
    
    int nChars = chardata.length / 8;

    _charset = new PImage[nChars];

    for(int i = 0; i < nChars; ++i)
    {
      _charset[i] = createImage(16, 16, ARGB);

      PImage pg = _charset[i];
      pg.loadPixels();
      
      int n = 0;
      for(int j = 0; j < 8; j++)
      {
        byte charb = chardata[i * 8 + j];

        if ((charb & 0x80) != 0) { pg.pixels[n+0] = c; pg.pixels[n+1] = c; }
        if ((charb & 0x40) != 0) { pg.pixels[n+2] = c; pg.pixels[n+3] = c; }
        if ((charb & 0x20) != 0) { pg.pixels[n+4] = c; pg.pixels[n+5] = c; }
        if ((charb & 0x10) != 0) { pg.pixels[n+6] = c; pg.pixels[n+7] = c; }
        if ((charb & 0x8) != 0) { pg.pixels[n+8] = c; pg.pixels[n+9] = c; }
        if ((charb & 0x4) != 0) { pg.pixels[n+10] = c; pg.pixels[n+11] = c; }
        if ((charb & 0x2) != 0) { pg.pixels[n+12] = c; pg.pixels[n+13] = c; }
        if ((charb & 0x1) != 0) { pg.pixels[n+14] = c; pg.pixels[n+15] = c; }
        n += pg.width;
        if ((charb & 0x80) != 0) { pg.pixels[n+0] = c; pg.pixels[n+1] = c; }
        if ((charb & 0x40) != 0) { pg.pixels[n+2] = c; pg.pixels[n+3] = c; }
        if ((charb & 0x20) != 0) { pg.pixels[n+4] = c; pg.pixels[n+5] = c; }
        if ((charb & 0x10) != 0) { pg.pixels[n+6] = c; pg.pixels[n+7] = c; }
        if ((charb & 0x8) != 0) { pg.pixels[n+8] = c; pg.pixels[n+9] = c; }
        if ((charb & 0x4) != 0) { pg.pixels[n+10] = c; pg.pixels[n+11] = c; }
        if ((charb & 0x2) != 0) { pg.pixels[n+12] = c; pg.pixels[n+13] = c; }
        if ((charb & 0x1) != 0) { pg.pixels[n+14] = c; pg.pixels[n+15] = c; }
        n += pg.width;
      }

      pg.updatePixels();
    }
  }
}