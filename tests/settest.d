import hurt.container.set;

import std.stdio;

void main() {
	int[] t = [ 0, 31, 32, 105, 526, 531, 1027, 1036, 1048, 1282, 1452, 1540,
		1541, 1546, 1547, 1554, 1563, 2575, 2576, 2585, 2590];
	Set!(int) s = new Set!(int)();
	s.insert(5);
	assert(s.contains(5));
	s.remove(5);
	assert(!s.contains(5));
	foreach(idx,it; t) {
		s.insert(it);
		foreach(jt; t[0..idx]) {
			assert(s.contains(jt));
		}
	}
	writeln("set test passed");
}
