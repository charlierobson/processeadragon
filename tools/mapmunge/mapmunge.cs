using System;
using System.IO;
using System.Collections.Generic;

public class MapMunge
{
    static public void Main(string[] args)
    {
        var types = new Dictionary<int, string>{{31,"depthcharger"},{32,"shooter"},{33,"laser"}};
        var map = File.ReadAllBytes(args[0]);
        for(var x = 0; x < 600; ++x)
        {
            for(var y = 0; y < 10; ++y)
            {
                var idx = x + 600 * y;
                if (map[idx] < 64) continue;

                var c = map[idx] & 0x3f;

                if (types.ContainsKey(c))
                    Console.WriteLine($"{x,3},{y},{types[c]}");
            }
        }

        map = File.ReadAllBytes(args[0]);
        for(var i = 0; i < map.Length; ++i)
        {
            if (map[i] < 64) continue;
            map[i] = 0;
        }

        File.WriteAllBytes("mungedmap.bin", map);
    }
}