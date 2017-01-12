using System;
using System.IO;
using System.Collections.Generic;

public class MapMunge
{
    static public void Main(string[] args)
    {
        var types = new Dictionary<int, string>{{30,"boatL"},{31,"boatR"},{32,"shooter"},{33,"laser"}};
        var map = File.ReadAllBytes(args[0]);
        for(var x = 0; x < 600; ++x)
        {
            for(var y = 0; y < 10; ++y)
            {
                var idx = x + 600 * y;
                if(map[idx] == 0) continue;
                if (map[idx] < 64) continue;

                Console.WriteLine($"{x,3},{y},{types[map[idx] & 0x3f]}");
            }
        }
    }
}