import hurt.container.rbtree;

import std.stdio;

void main() {
	int[] t = [0, 31, 32, 1027, 1540, 1541, 1452, 1546, 1547, 1036, 1282, 526, 
		2575, 2576, 1554, 531, 1048, 2585, 1563, 2590, 1056, 2081, 548, 1061, 
		38, 2091, 2711, 1070, 1583, 1078, 2615, 1081, 1084, 1034, 2997, 57];

	RBTree!(int) rbt2 = new RBTree!(int)();
	foreach(it;t[0..10]) {
		rbt2.insert(it);
	}
	rbt2.insert(t[0]);
	rbt2.insert(t[9]);
	auto it = rbt2.begin();
	while(it.isValid()) {
		write(*it, " ");
		it++;
	}
	writeln();

	assert(rbt2.find(t[0]) !is null);
	assert(rbt2.find(32452345) !is null);
}
