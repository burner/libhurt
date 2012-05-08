module hurt.container.fdlist;

import hurt.container.iterator;
import hurt.container.stack;
import hurt.string.formatter;
import hurt.util.slog;
import hurt.io.stdio;
import hurt.exception.outofrangeexception;
import hurt.time.stopwatch;

/** This should be faster than the normal Double LinkedList.
 * 	Tests yields a 2x speed up. 
 */
public struct Iterator(T) {
	private long idx;
	private FDoubleLinkedList!(T) list;

	this(long idx, FDoubleLinkedList!(T) list) {
		this.idx = idx;
		this.list = list;
	}

	public long getIdx() const {
		return this.idx;
	}

	public void opUnary(string s)() if(s == "++") {
		this.idx = this.list.getNext(this.idx);
	}

	public void opUnary(string s)() if(s == "--") {
		this.idx = this.list.getPrev(this.idx);
	}

	public T opUnary(string s)() if(s == "*") {
		return this.list.getDirect(this.idx);
	}

	public bool isValid() const {
		return this.idx != -1;
	}
}

public class FDoubleLinkedList(T) : Iterable!(T) {
	private struct Item(T) {
		T item;
		long prev, next;

		this(long prev, long next) {
			this.prev = prev;
			this.next = next;
		}

		this(T item, long prev, long next) {
			this.item = item;
			this.prev = prev;
			this.next = next;
		}
	}

	private Item!(T)[] items;
	private size_t tail;
	private Stack!(size_t) free;
	private long size;

	private long frontIt, backIt;

	this() {
		this.items = null;	
		this.free = null;	
		this.tail = 0;
		this.size = 0;
		this.grow();
		this.frontIt = -1;
		this.backIt = -1;
	}

	Iterator!(T) begin() {
		return Iterator!(T)(this.frontIt, this);
	}

	Iterator!(T) end() {
		return Iterator!(T)(this.backIt, this);
	}

	public bool isEmpty() const {
		return this.size == 0;
	}

	private void releasePtr(size_t ptr) {
		this.items[ptr].next = -1;
		this.items[ptr].prev = -1;

		if(ptr + 1 == this.tail) {
			this.tail--;
		} else {
			this.free.push(ptr);
		}
	}

	private size_t nextPtr() {
		if(!this.free.isEmpty()) {
			return this.free.pop();
		} else if(this.tail == this.items.length) {
			this.grow();
			return this.tail++;
		} else {
			return this.tail++;
		}
	}

	public void insert(Iterator!(T) it, T item, bool before = false) {
		this.insert(it.getIdx(), item, before);
	}

	public void insert(size_t idx, T item, bool before = false) {
		this.checkIdx!(__FILE__,__LINE__)(idx);
		idx = this.getIdx(idx);

		if(this.getSize() == 0 || (this.frontIt == idx && before)) {
			this.pushFront(item);
			return;
		}

		if(this.backIt == idx && !before) {
			this.pushBack(item);
			return;
		}

		size_t itemPtr = this.nextPtr();
		this.items[itemPtr].item = item;

		if(before) {
			size_t pr = this.items[idx].prev;	
			this.items[pr].next = itemPtr;
			this.items[itemPtr].prev = pr;
			this.items[itemPtr].next = idx;
			this.items[idx].prev = itemPtr;
		} else {
			size_t ne = this.items[idx].next;	
			this.items[ne].prev = itemPtr;
			this.items[itemPtr].next = ne;
			this.items[itemPtr].prev = idx;
			this.items[idx].next = itemPtr;
		}
		this.size++;
	}

	public void pushFront(T item) {
		if(this.isEmpty()) {
			size_t itemPtr = this.nextPtr();
			this.items[itemPtr].item = item;
			this.items[itemPtr].prev = -1;
			this.items[itemPtr].next = -1;
			this.frontIt = this.backIt = itemPtr;
		} else {
			size_t itemPtr = this.nextPtr();
			this.items[this.frontIt].prev = itemPtr;
			this.items[itemPtr].next = this.frontIt;
			this.items[itemPtr].prev = -1;
			this.items[itemPtr].item = item;
			this.frontIt = itemPtr;
		}
		this.size++;
	}

	public void pushBack(T item) {
		if(this.isEmpty()) {
			size_t itemPtr = this.nextPtr();
			this.items[itemPtr].item = item;
			this.items[itemPtr].prev = -1;
			this.items[itemPtr].next = -1;
			this.frontIt = this.backIt = itemPtr;
		} else {
			size_t itemPtr = this.nextPtr();
			this.items[this.backIt].next = itemPtr;
			this.items[itemPtr].prev = backIt;
			this.items[itemPtr].next = -1;
			this.items[itemPtr].item = item;
			this.backIt = itemPtr;
		}
		this.size++;
	}

	public T popFront() {
		if(this.isEmpty()) {
			throw new OutOfRangeException("can't popBack from empty list");
		}

		long f = this.frontIt;
		long p = this.items[f].next;
		if(p != -1) {
			this.items[p].prev = -1;
		}

		this.frontIt = p;

		this.releasePtr(f);
		this.size--;
		return this.items[f].item;
	}

	public T popBack() {
		if(this.isEmpty()) {
			throw new OutOfRangeException("can't popBack from empty list");
		}

		long b = this.backIt;
		long p = this.items[b].prev;
		if(p != -1) {
			this.items[p].next = -1;
		}
		this.backIt = p;

		this.releasePtr(b);
		this.size--;
		return this.items[b].item;
	}

	public T remove(Iterator!(T) it) {
		return this.removeImpl(it.getIdx());
	}

	public T remove(size_t it) {
		it = this.getIdx(it);
		return this.removeImpl(it);
	}

	private T removeImpl(size_t it) {
		if(this.items[it].prev == -1) {
			T tmp = this.popFront();
			return tmp;
		} else if(this.items[it].next == -1) {
			T tmp = this.popBack();
			return tmp;
		} else {
			long prev = this.items[it].prev;
			long next = this.items[it].next;
			this.items[prev].next = next;
			this.items[next].prev = prev;

			this.releasePtr(it);
			this.size--;

			return this.items[it].item;
		}
	}

	package long getNext(long idx) {
		return this.items[idx].next;	
	}

	package long getPrev(long idx) {
		return this.items[idx].prev;	
	}

	package T getDirect(const long idx) {
		return this.items[idx].item;
	}

	private bool checkIdx(string file, int line)(const size_t idx) const {
		if(idx >= this.getSize()) {
			throw new OutOfRangeException(format(
				"out of range with idx %u of %u" ~
				" at %s:%d", idx, this.getSize(), file, line));
		} else {
			return true;
		}
	}

	public size_t getIdx(size_t cnt) const {
		this.checkIdx!(__FILE__,__LINE__)(cnt);
		long it = this.frontIt;
		size_t i;
		for(i = 0; i < cnt; i++) {
			it = this.items[it].next;
		}
		
		return it;
	}

	public T opIndex(const size_t idx) {
		return this.get(idx);
	}

	public const(T) opIndex(const size_t idx) const {
		return this.get(idx);
	}

	public T get(const size_t idx) {
		this.checkIdx!(__FILE__,__LINE__)(idx);
		return this.items[this.getIdx(idx)].item;
	}
	
	public const(T) get(const size_t idx) const {
		this.checkIdx!(__FILE__,__LINE__)(idx);
		return this.items[this.getIdx(idx)].item;
	}

	public void debugPrint() const {
		foreach(size_t idx, Item!(T) it; this.items) {
			if(idx % 6 == 0) {
				println();
			}
			printf("(%u, %d %d), ", idx, it.prev, it.next);
		}
		printfln("size %d", this.size);
	}

	private void grow() {
		size_t oldItemsSize;
		if(this.items is null) {
			this.items = new Item!(T)[16];
			oldItemsSize = 0;
		} else {
			oldItemsSize = this.items.length;
			this.items.length = this.items.length*2;
		}

		for(size_t i = oldItemsSize; i < this.items.length; i++) {
			this.items[i].next = -1;
			this.items[i].prev = -1;
		}

		if(this.free is null) {
			this.free = new Stack!(size_t)(16);
		}
	}

	public bool contains(const T key) const {
		long u = this.frontIt;
		for(; u != -1; u = this.items[u].next) {
			if(this.items[u].item == key) {
				return true;
			}
		}
		return false;
	}

	public size_t getSize() const {
		return this.size;
	}

	public size_t getCapacity() const {
		return (this.items.length - this.tail) + this.free.getSize();
	}

	int opApply(int delegate(ref size_t,ref T) dg) {
 		long it = this.frontIt;
		for(size_t i = 0; i < this.getSize(); i++, it = this.items[it].next) {
			//if(int r = dg(s)) {
			if(int r = dg(i,this.items[it].item)) {
				return r;
			}
		}
		return 0;
	}

	int opApply(int delegate(ref T) dg) {
 		long it = this.frontIt;
		for(size_t i = 0; i < this.getSize(); i++, it = this.items[it].next) {
			//if(int r = dg(s)) {
			if(int r = dg(this.items[it].item)) {
				return r;
			}
		}
		return 0;
	}
}

unittest {
	FDoubleLinkedList!(int) fdll = new FDoubleLinkedList!(int)();
	for(int i = 0; i < 10; i++) {
		fdll.pushBack(i);
	}

	const auto cll = cast(const(FDoubleLinkedList!(int)))fdll;
	for(int i = 0; i < cll.getSize(); i++) {
		assert(cll[i] == i);
	}
}

unittest {
	FDoubleLinkedList!(int) fdll = new FDoubleLinkedList!(int)();
	for(int i = 0; i < 10; i++) {
		fdll.pushBack(i);
	}
	foreach(idx, it; fdll) {
		assert(it == idx);
	}
	int i = 0;
	foreach(it; fdll) {
		assert(it == i++);
	}

	Iterator!(int) it = fdll.begin();
	for(i = 0; it.isValid(); i++, it++) {
		assert(i == *it);
	}
	it = fdll.end();
	for(i = 9; it.isValid(); i--, it--) {
		assert(i == *it);
	}

}

unittest {
	FDoubleLinkedList!(int) fdll = new FDoubleLinkedList!(int)();
	for(int i = 0; i < 10; i++) {
		fdll.pushFront(i);
	}
	fdll.insert(9, -2, true);
	assert(fdll.get(9) == -2);
	assert(fdll.getSize() == 11);
	fdll.insert(10, -6);
	assert(fdll.get(11) == -6);
	assert(fdll.getSize() == 12);
}

unittest {
	FDoubleLinkedList!(int) fdll = new FDoubleLinkedList!(int)();
	for(int i = 0; i < 10; i++) {
		fdll.pushFront(i);
	}
	fdll.insert(5, -2, true);
	assert(fdll.get(5) == -2);
	assert(fdll.getSize() == 11);
	fdll.insert(5, -5);
	assert(fdll.get(6) == -5);
	assert(fdll.getSize() == 12);
}

unittest {
	FDoubleLinkedList!(int) fdll = new FDoubleLinkedList!(int)();
	for(int i = 0; i < 10; i++) {
		fdll.pushFront(i);
	}
	fdll.insert(0, -2, true);
	fdll.insert(0, -1);
	assert(fdll.get(0) == -2);
	assert(fdll.get(1) == -1);
	assert(fdll.getSize() == 12);
}

unittest {
	FDoubleLinkedList!(int) fdll = new FDoubleLinkedList!(int)();
	for(int i = 0; i < 32; i++) {
		fdll.pushFront(i);
		for(int j = 0; j < i; j++) {
			assert(fdll.get(i-j) == j, format("%d != %d", fdll.get(j), j));	
		}
	}
	assert(fdll.getSize() == 32);
	assert(fdll.getCapacity() == 0);
	auto it = fdll.begin();
	fdll.insert(it, 33);
}

unittest {
	FDoubleLinkedList!(int) fdll = new FDoubleLinkedList!(int)();
	for(int i = 0; i < 32; i++) {
		fdll.pushBack(i);
		for(int j = 0; j < i; j++) {
			assert(fdll.get(j) == j);	
		}
	}
	assert(fdll.getSize() == 32);
	assert(fdll.getCapacity() == 0);
}

unittest {
	FDoubleLinkedList!(int) fdll = new FDoubleLinkedList!(int)();
	assert(fdll.getSize() == 0);
	assert(fdll.getCapacity() == 16);
	assert(fdll.isEmpty());
	fdll.pushBack(66);
	assert(fdll.get(0) == 66);
	fdll.pushBack(55);
	assert(fdll.get(0) == 66);
	assert(fdll.get(1) == 55);
	fdll.pushBack(44);
	assert(fdll.get(0) == 66);
	assert(fdll.get(1) == 55);
	assert(fdll.get(2) == 44);

	assert(fdll.popBack() == 44);
	assert(fdll.getSize() == 2);
	assert(fdll.get(0) == 66);
	assert(fdll.get(1) == 55);
	assert(fdll.popBack() == 55);
	assert(fdll.get(0) == 66);
	assert(fdll.popBack() == 66);
	assert(fdll.getSize() == 0);
	assert(fdll.isEmpty());

	fdll.pushFront(66);
	assert(fdll.get(0) == 66);
	fdll.pushFront(55);
	assert(fdll.get(1) == 66);
	assert(fdll.get(0) == 55);
	fdll.pushFront(44);
	assert(fdll.get(2) == 66);
	assert(fdll.get(1) == 55);
	assert(fdll.get(0) == 44);

	assert(fdll.popFront() == 44);
	assert(fdll.getSize() == 2);
	assert(fdll.get(1) == 66);
	assert(fdll.get(0) == 55);
	assert(fdll.popFront() == 55);
	assert(fdll.get(0) == 66);
	assert(fdll.popFront() == 66);
	assert(fdll.getSize() == 0);
	assert(fdll.isEmpty());
}

unittest {
	import hurt.container.dlst;

	int[] t = [0, 31, 32, 1027, 1540, 1541, 1452, 1546, 1547, 1036, 1282, 526,
	2575, 2576, 1554, 531, 1048, 2585, 1563, 2590, 1056, 2081, 548, 1061, 38,
	2091, 2711, 1070, 1583, 1078, 2615, 1081, 1084, 1034, 2997, 578, 2627,
	2629, 1096, 73, 2122, 2743, 1617, 595, 85, 787, 1628, 1124, 1126, 2663,
	1299, 1642, 1265, 621, 112, 1651, 2165, 1146, 2171, 2684, 1152, 2177, 2695,
	1162, 651, 1677, 655, 148, 1685, 662, 1175, 2245, 2211, 943, 1192, 2231,
	2233, 1724, 701, 197, 1057, 1736, 2764, 2766, 2770, 723, 740, 217, 2271,
	737, 228, 744, 2287, 2288, 1320, 2803, 1780, 2806, 1273, 1786, 1275, 2300,
	2302, 767, 2818, 774, 129, 2826, 268, 2833, 1810, 1811, 1814, 1306, 2332,
	2335, 291, 1318, 1832, 2347, 2862, 1327, 2864, 1329, 1954, 307, 2357, 2871,
	1851, 36, 1341, 1342, 2869, 2368, 321, 837, 1350, 344, 345, 2399, 2552,
	2407, 2920, 874, 2923, 366, 2415, 1394, 883, 373, 2422, 2426, 1916, 2197,
	1409, 900, 1927, 1931, 1425, 1938, 2453, 2969, 922, 2460, 1439, 2466, 1956,
	421, 422, 2983, 424, 427, 428, 430, 2479, 437, 2489, 1982, 962, 455, 418,
	977, 2002, 1499, 1500, 992, 2018, 487, 1000, 2471, 2541, 1009, 498, 500,
	1016];

	int runs = 5;
	StopWatch sw;
	sw.start();
	for(int z = 0; z < runs; z++) {
	FDoubleLinkedList!(int) l = new FDoubleLinkedList!(int)();
	foreach(idx, i; t) {
		l.pushBack(i);	
		foreach(j; t[0 .. idx]) {
			assert(l.contains(j));
		}
		foreach(j; t[idx+1 .. $]) {
			assert(!l.contains(j));
		}
	}

	for(int i = 0; !l.isEmpty(); i++) {
		l.remove(t[i] % l.getSize());
	} }
	//log("%f", sw.stop());

	StopWatch sw2;
	sw2.start();
	for(int z = 0; z < runs; z++) {
	DLinkedList!(int) l = new DLinkedList!(int)();
	foreach(idx, i; t) {
		l.pushBack(i);	
		foreach(j; t[0 .. idx]) {
			assert(l.contains(j), format("%u %d", idx, i));
		}
		foreach(j; t[idx+1 .. $]) {
			assert(!l.contains(j));
		}
	}

	for(int i = 0; !l.isEmpty(); i++) {
		l.remove(t[i] % l.getSize());
	} }
	//log("%f", sw2.stop());
}

version(staging) {
void main() {
}
}
