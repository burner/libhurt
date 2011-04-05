import hurt.container.dlst;

import std.random;
import std.stdio;

void main() {
	int[] t = [123,13,5345,752,12,3,1,654,22];
	DLinkedList!(int) l1 = new DLinkedList!(int)();
	foreach(idx,it;t) {
		l1.pushBack(it);
		writeln("after insert ", it);
		assert(l1.get(idx) == it);
		writeln("after get ", it);
		assert(l1.contains(it));
		writeln("after assert ", it);
	}
	
	writeln("after first loop");

	while(l1.getSize() > 0) {
		long idx = uniform(0L, l1.getSize());
		writeln(idx, " size ", l1.getSize());
		int tmp = l1.remove(idx);
	}
}
