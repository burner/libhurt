import hurt.container.dlst;

import std.random;

void main() {
	int[] t = [123,13,5345,752,12,3,1,654,22];
	DLinkedList!(int) l1 = new DLinkedList!(int)();
	foreach(idx,it;t) {
		l1.pushBack(it);
		assert(l1.get(idx) == it);
		assert(l1.contains(it));
	}

	while(l1.getSize() > 0) {
		int tmp = l1.remove(uniform(0,l1.getSize()));
		
	}
}
