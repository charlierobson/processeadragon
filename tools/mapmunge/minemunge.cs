using System;
using System.IO;

public class MapMunge
{
    static public void Main(string[] args)
    {
        var mines = File.ReadAllBytes(args[0]);

        int blocklen = mines.Length / 3;

        int yoff = 0;
        int xhioff = blocklen;
        int xlooff = blocklen * 2;
        
        for(var i = 0; i < blocklen; ++i)
        {
            var y = mines[yoff];
            var xhi = mines[xhioff];
            var xlo = mines[xlooff];

            var isMover = (xhi & 0x80) != 0;
            var isMine  = (xhi & 0x40) != 0;

            var type = isMover & !isMine ? "stalactite" : isMover ? "mine" : "staticmine";

            xhi &= 0x0f;
            var x = (int)xhi * 256 + (int)xlo;

            Console.WriteLine($"{x,3},{y},{type}");

            ++yoff;
            ++xhioff;
            ++xlooff;
        }
    }
}