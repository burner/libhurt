module hurt.container.dlst;

import hurt.conv.conv;
import hurt.util.random.random;
import hurt.container.iterator;
import hurt.exception.nullexception;
import hurt.exception.invaliditeratorexception;
import hurt.io.stdio;

public class Iterator(T) : hurt.container.iterator.Iterator!(T) {
	private DLinkedList!(T).Elem!(T) elem;

	public this(DLinkedList!(T).Elem!(T) elem) {
		this.elem = elem;
	}

	public Iterator!(T) dup() {
		return new Iterator!(T)(this.elem);
	}

	public T getValue() {
		if(elem is null) {
			throw new NullException("Iterator value is null");
		} else {
			return elem.getStore();
		}
	}

	public void opUnary(string s)() if(s == "++") {
		this.elem = elem.getNext();
	}

	public void opUnary(string s)() if(s == "--") {
		this.elem = elem.getPrev();
	}

	public T opUnary(string s)() if(s == "*") {
		return this.getValue();
	}

	public override bool opEquals(Object o) {
		Iterator!(T) it = cast(Iterator!(T))o;
		return this.elem.getStore() == it.getElem().getStore();
	}

	public bool isValid() const {
		return this.elem !is null;
	}

	public DLinkedList!(T).Elem!(T) getElem() {
		return this.elem;
	}

	public void setElem(DLinkedList!(T).Elem!(T) elem) {
		this.elem = elem;
	}
}

public class DLinkedList(T) : Iterable!(T) {
	private class Elem(T) {
		private T store;
		private Elem!(T) prev;
		private Elem!(T) next;

		public this(T store) {
			this.store = store;
		}
	
		public this(T store, Elem!(T) prev) {
			this(store);
			this.prev = prev;
		}
	
		public void setPrev(Elem!(T) prev) {
			this.prev = prev;
		}
	
		public void setNext(Elem!(T) next) {
			this.next = next;
		}
	
		public Elem!(T) getPrev() {
			return this.prev;
		}
	
		public Elem!(T) getNext() {
			return this.next;
		}
	
		public T getStore() {
			return this.store;
		}

		public override bool opEquals(Object o) const {
			Elem!(T) t = cast(Elem!(T))o;
			return t.getStore() == this.store &&
				t.getPrev() is this.prev &&
				t.getNext() is this.next;
		}
	}

	private Elem!(T) head;
	private Elem!(T) tail;
	private ulong size;

	public this() {
		this.head = null;
		this.tail = null;
		this.size = 0L;
	}

	public this(DLinkedList!(T) toCopy) {
		this.head = null;
		this.tail = null;
		this.size = 0L;
		foreach(it; toCopy) {
			this.pushBack(it);
		}
	}

	public Iterator!(T) pushBack(T store) {
		if(this.size == 0) {
			this.head = new Elem!(T)(store, null);
			this.tail = head;
			this.size++;
			return new Iterator!(T)(this.head);
		} else {
			Elem!(T) tmp = new Elem!(T)(store, this.tail);
			this.tail.setNext(tmp);
			this.tail = tmp;
			this.size++;
			return new Iterator!(T)(tmp);
		}
	}

	public Iterator!(T) pushFront(T store) {
		if(this.size == 0) {	
			this.head = new Elem!(T)(store, null);
			this.tail = head;
			this.size++;
			return new Iterator!(T)(this.head);
		} else {
			Elem!(T) tmp = new Elem!(T)(store, null);
			tmp.setNext(this.head);
			this.head.setPrev(tmp);
			this.head = tmp;
			this.size++;
			return new Iterator!(T)(tmp);
		}
	}

	public T popBack() {
		if(this.size > 1) {
			Elem!(T) tmp = this.tail;
			this.tail = tail.getPrev();
			this.tail.setNext(null);
			this.size--;
			return tmp.getStore();
		} else if(this.size == 0) {
			assert(0);
		} else {
			Elem!(T) tmp = this.tail;
			this.head = this.tail = null;
			this.size--;
			return tmp.getStore();
		}	
	}	

	public T popFront() {
		if(this.size > 1) {
			Elem!(T) tmp = this.head;
			this.head = head.getNext();
			this.head.setPrev(null);
			this.size--;
			return tmp.getStore();
		} else if(this.size == 0) {
			assert(0);
		} else if(this.size == 1) {
			assert(this.head is this.tail, "head and tail should be the same");
			assert(this.head !is null);
			T tmp = this.head.getStore();
			this.head = null;
			this.tail = null;
			this.size--;
			return tmp;
		}	
		assert(0);
	}

	public bool isEnd(Iterator!(T) tt) const {
		return tt.getElem() == this.tail;
	}

	public bool isBegin(Iterator!(T) tt) const {
		return tt.getElem() == this.head;
	}

	int opApply(int delegate(ref size_t,ref T) dg) {
		size_t cnt = 0;
		for(Elem!(T) e = this.head; e; e = e.getNext(), cnt++) {
			T s = e.getStore();
			if(int r = dg(cnt,s)) {
				return r;
			}
		}
		return 0;
	}

	public int opApply(scope int delegate(ref T) dg) {
		for(Elem!(T) e = this.head; e; e = e.getNext()) {
			T s = e.getStore();
			if(int r = dg(s)) {
				return r;
			}
		}
		return 0;
	}

	public void clean() {
		this.head = null;
		this.tail = null;
		this.size = 0;
	}

	public bool isEmpty() const {
		return this.size == 0;
	}
	
	public size_t getSize() const {
		return this.size;
	}	

	public bool contains(T value) {
		for(Elem!(T) e = this.head; e !is this.tail; e = e.getNext()) {
			if(e.getStore() == value) {
				return true;
			}
		}
		if(this.tail.getStore() == value) {
			return true;
		}
		return false;	
	}

	public T remove(size_t idx) {
		if(idx > this.size-1) {
			assert(0, "index out of bound");
		}

		if(idx == 0L) {
			return this.popFront();
		} else if(idx == this.size-1) {
			return this.popBack();
		} else {
			Elem!(T) tmp = this.head;
			size_t it = 0;
			while(it < idx) {
				tmp = tmp.getNext();
				assert(tmp !is null, "tmp should not be null here. it = " 
					~ conv!(size_t,string)(it));
				it++;
			}
			Elem!(T) prev = tmp.getPrev();
			Elem!(T) next = tmp.getNext();
			prev.setNext(next);
			next.setPrev(prev);
			this.size--;
			return tmp.getStore();
		}
	}

	public Iterator!(T) begin() {
		Iterator!(T) tmp = new Iterator!(T)(this.head);
		return tmp;
	}

	public Iterator!(T) end() {
		Iterator!(T) tmp = new Iterator!(T)(this.tail);
		return tmp;
	}

	public T remove(Iterator!(T) it) {
		if(!it.isValid()) {
			throw new InvalidIteratorException(__FILE__ ~ 
				conv!(int,string)(__LINE__) ~ ": Iterator not valid");
		}
		if(it.getElem().getPrev() is null) {
			T tmp = this.popFront();
			it.setElem(this.head);	
			return tmp;
		} else if(it.getElem().getNext() is null) {
			T tmp = this.popBack();
			it.setElem(this.tail);	
			return tmp;
		} else {
			Elem!(T) prev = it.getElem().getPrev();
			Elem!(T) next = it.getElem().getNext();
			it.setElem(next);
			prev.setNext(next);
			next.setPrev(prev);
			this.size--;
			return it.getValue();
		}
	}

	public T get(ulong idx) {
		if(idx > this.size) {
			assert(0, "index out of bound");
		}

		if(this.size - idx < idx) {
			Elem!(T) tmp = this.tail;
			ulong it = this.size - 1u;
			while(it > idx) {
				tmp = tmp.getPrev();
				it--;
			}
			return tmp.getStore();
		} else {
			Elem!(T) tmp = this.head;
			ulong it = 0u;
			while(it < idx) {
				tmp = tmp.getNext();
				it--;
			}
			return tmp.getStore();
		}
	}

	public Iterator!(T) insert(Iterator!(T) it, T value, bool before = false) {
		if(it !is null && it.isValid()) {
			if(this.size == 0 || (this.head == it.getElem() && before)) {
				this.pushFront(value);
				return this.begin();
			}
			if(this.tail == it.getElem() && !before) {
				this.pushBack(value);
				return this.end();
			}
			if(before) {
				Elem!(T) tmp = it.getElem();
				Elem!(T) prev = tmp.getPrev();
				Elem!(T) tIn = new Elem!(T)(value);
				prev.setNext(tIn);
				tIn.setPrev(prev);
				tIn.setNext(tmp);
				tmp.setPrev(tIn);
				this.size++;
				return new Iterator!(T)(tIn);
			} else {
				Elem!(T) tmp = it.getElem();
				Elem!(T) next = tmp.getNext();
				Elem!(T) tIn = new Elem!(T)(value);
				next.setPrev(tIn);
				tIn.setNext(next);
				tIn.setPrev(tmp);
				tmp.setNext(tIn);
				this.size++;
				return new Iterator!(T)(tIn);
			}
		} else {
			throw new InvalidIteratorException(__FILE__ ~ conv!(int,string)(__LINE__) ~ ": Iterator not valid");
		}
	}

	public bool validate() {
		size_t itIdx = 0;
		Elem!(T) tmp = this.head;
		if(this.size == 0) {
			return true;
		}
		if(tmp.getNext() is null) {
			assert(this.tail is tmp, "head and tail should be the same");
		}
		while(tmp !is null) {
			Elem!(T) tmpNext = tmp.getNext();
			if(tmpNext !is null) {
				assert(tmpNext.getPrev() is tmp, "prev pointer is wrong for index " ~ conv!(size_t,string)(itIdx+1));	
			}
			if(tmpNext is null) {
				assert(tmp is this.tail, "the tail pointer is not set correctly"); 
			}
			itIdx++;
			tmp = tmpNext;
		}
		assert(itIdx == this.size, "size is not stored correctly");
		return true;
	}
}

unittest {
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
	Iterator!(int) lit = l1.begin();
	Iterator!(int) kit = l1.end();
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
	
	Random random = new Random();
	while(l1.getSize() > 0) {
		size_t idx = random.uniformR!(size_t)(l1.getSize());
		int tmp = l1.remove(idx);
		assert(l1.validate());
	}

	DLinkedList!(int) l2 = new DLinkedList!(int)();
	foreach(it;t[0..10]) {
		l2.pushBack(it);
	}
	assert(l2.getSize() == 10);
	Iterator!(int) rit = l2.end();
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
	Iterator!(int) iit = l3.end();
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
