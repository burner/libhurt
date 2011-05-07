import hurt.container.map;

import std.stdio;

void main() {
	int[] k = [0, 31, 32, 1027, 1540, 1541, 1452, 1546, 1547, 1036, 1282, 526, 
		2575, 2576, 1554, 531, 1048, 2585, 1563, 2590, 1056, 2081, 548, 1061];

	int[] v	= [2663, 1299, 1642, 1265, 621, 112, 1651, 2165, 1146, 2171, 2684, 1152, 
		2177, 2695, 1162, 651, 1677, 148, 1685, 662, 1175, 2245, 2211, 943];

	Map!(int, int) map = new Map!(int,int)();
	foreach(idx, it; k) {
		map.insert(it, v[idx]);
		assert(map.find(it));
	}
}
