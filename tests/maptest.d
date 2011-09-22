import hurt.container.map;
import hurt.conv.conv;
import hurt.algo.sorting;

import std.stdio;

void main() {
	int[] k = [0, 31, 32, 1027, 1540, 1541, 1452, 1546, 1547, 1036, 1282, 526, 
		2575, 2576, 1554, 531, 1048, 2585, 1563, 2590, 1056, 2081, 548, 1061];

	int[] v	= [2663, 1299, 1642, 1265, 621, 112, 1651, 2165, 1146, 2171, 2684, 1152, 
		2177, 2695, 1162, 651, 1677, 148, 1685, 662, 1175, 2245, 2211, 943];

	Map!(int, string) map = new Map!(int,string)();
	foreach(idx, it; k) {
		map.insert(it, conv!(int,string)(v[idx]));
	}

	bool contains(int[] a, int tf) {
		foreach(it; a) 
			if(it == tf)
				return true;

		return false;
	}

	sort!(int)(k, function(in int a, in int b) { return a < b; });

	string old = *map.find(31);
	map.insert(31, "666");
	assert((*map.find(31)) == "666");
	map.insert(31, old);


	/*size_t idx = 0;
	foreach(key, value; map) {
		assert(key == k[idx] && contains(v,conv!(string,int)(value)));
		idx++;
	}*/
}
