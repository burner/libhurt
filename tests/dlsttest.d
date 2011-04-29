import hurt.container.dlst;

import hurt.conv.conv;

import std.random;
import std.stdio;

void main() {
	int[] t = [0, 31, 32, 1027, 1540, 1541, 1452, 1546, 1547, 1036, 1282, 526, 
		2575, 2576, 1554, 531, 1048, 2585, 1563, 2590, 1056, 2081, 548, 1061, 
		38, 2091, 2711, 1070, 1583, 1078, 2615, 1081, 1084, 1034, 2997, 578, 
		2627, 2629, 1096, 73, 2122, 2743, 1617, 595, 85, 787, 1628, 1124, 1126, 
		2663, 1299, 1642, 1265, 621, 112, 1651, 2165, 1146, 2171, 2684, 1152, 
		2177, 2695, 1162, 651, 1677, 655, 148, 1685, 662, 1175, 2245, 2211, 943, 
		1192, 2231, 2233, 1724, 701, 197, 1057, 1736, 2764, 2766, 2770, 723, 740, 
		217, 2271, 737, 228, 744, 2287, 2288, 1320, 2803, 1780, 2806, 1273, 1786, 
		1275, 2300, 2302, 767, 2818, 774, 129, 2826, 268, 2833, 1810, 1811, 1814, 
		1306, 2332, 2335, 291, 1318, 1832, 2347, 2862, 1327, 2864, 1329, 1954, 
		307, 2357, 2871, 1851, 36, 1341, 1342, 2869, 2368, 321, 837, 1350, 344, 
		345, 2399, 2552, 2407, 2920, 874, 2923, 366, 2415, 1394, 883, 373, 2422, 
		2426, 1916, 2197, 1409, 900, 1927, 1931, 1425, 1938, 2453, 2969, 922, 2460, 
		1439, 2466, 1956, 421, 422, 2983, 424, 427, 428, 430, 2479, 437, 2489, 1982, 
		962, 455, 418, 977, 2002, 1499, 1500, 992, 2018, 487, 1000, 2471, 2541, 
		1009, 498, 500, 1016];
	DLinkedList!(int) l1 = new DLinkedList!(int)();
	DLinkedList!(int).Iterator!(int) lit = l1.begin();
	DLinkedList!(int).Iterator!(int) kit = l1.end();
	assert(!lit.isValid(), "should be valid");
	assert(!kit.isValid(), "should be valid");
	foreach(idx,it;t) {
		l1.pushBack(it);
		lit = l1.begin();
		assert(lit.isValid(), "should be valid");
		size_t jt = 0;
		while(lit.isValid()) {
			assert(lit.getValue() == t[jt++]);
			lit++;	
		}
		assert(l1.getSize() == idx+1);

		kit = l1.end();
		assert(kit.isValid(), "should be valid");
		jt = idx;
		while(kit.isValid()) {
			assert(kit.getValue() == t[jt], conv!(int,string)(kit.getValue()) ~ " " 
				~ conv!(int,string)(t[jt]) ~ " "
				~ conv!(size_t,string)(jt));
			kit--;	
			jt--;
		}
		jt = idx;
		while(kit.isValid()) {
			assert(*kit == t[jt], conv!(int,string)(*kit) ~ " " 
				~ conv!(int,string)(t[jt]) ~ " "
				~ conv!(size_t,string)(jt));
			kit--;	
			jt--;
		}
		assert(l1.get(idx) == it);
		assert(l1.contains(it));
		assert(l1.validate());
	}
	

	while(l1.getSize() > 0) {
		size_t idx = uniform(0, l1.getSize());
		int tmp = l1.remove(idx);
		assert(l1.validate());
	}

	DLinkedList!(int) l2 = new DLinkedList!(int)();
	foreach(it;t[0..10]) {
		l2.pushBack(it);
	}
	assert(l2.getSize() == 10);
	DLinkedList!(int).Iterator!(int) rit = l2.end();
	assert(rit.isValid());
	l2.remove(rit);
	assert(rit.isValid());
	assert(l2.getSize() == 9);
	foreach_reverse(it;t[0..9]) {
		assert(*rit == it);
		rit--;
		assert(l2.validate());
	}

	rit = l2.begin();
	assert(rit.isValid());
	l2.remove(rit);
	assert(rit.isValid());
	assert(l2.getSize() == 8);
	foreach(it;t[1..9]) {
		assert(*rit == it);
		rit++;
		assert(l2.validate());
	}
	rit = l2.begin();
	rit++;
	rit++;
	rit++;
	rit++;
	rit++;
	while(!l2.isEnd(rit)) {
		l2.remove(rit);	
		assert(l2.validate());
	}
	rit--;
	rit--;
	while(!l2.isBegin(rit)) {
		l2.remove(rit);	
		assert(l2.validate());
	}
	assert(l2.getSize() == 1);

	DLinkedList!(int) l3 = new DLinkedList!(int)();
	l3.pushBack(1);
	assert(l3.getSize() == 1);
	DLinkedList!(int).Iterator!(int) iit = l3.end();
	assert(l3.isEnd(iit));
	assert(l3.isBegin(iit));
	iit = l3.insert(iit, 2, true);
	assert(l3.getSize() == 2);
	assert(l3.isBegin(iit));
	assert(!l3.isEnd(iit));
	iit = l3.insert(iit, 3, false);
	assert(l3.getSize() == 3);
	iit++;
	assert(l3.isEnd(iit));
	iit--;
	iit--;
	assert(l3.isBegin(iit));
	iit++;
	iit = l3.begin();
	iit = l3.insert(iit, 4, false);
	iit--;
	assert(l3.isBegin(iit));
}
