module hurt.container.deque;

import hurt.container.iterator;
import hurt.conv.conv;
import hurt.exception.outofrangeexception;
import hurt.container.iterator;
import hurt.io.stdio;
import hurt.math.mathutil;
import hurt.string.formatter;
import hurt.string.stringbuffer;

struct Iterator(T) {
	private size_t pos;
	private size_t id;
	private Deque!(T) deque;

	this(Deque!(T) deque, const bool begin, const size_t id) {
		this.deque = deque;
		this.id = id;
		size_t head = this.deque.getHeadPos();
		size_t tail = this.deque.getTailPos();
		if(begin) {
			if(head+1 > this.deque.getLength() - 1)
				this.pos = 0;
			else 
				this.pos = head+1;
		} else {
			this.pos = tail;
		}
	}

	package size_t getPos() const {
		return this.pos;
	}

	public void opUnary(string s)() if(s == "++") {
		this.pos++;
		if(this.pos >= this.deque.getLength()) {
			this.pos = 0;
		}
	}

	public void opUnary(string s)() if(s == "--") {
		if(this.pos == 0) {
			this.pos = this.deque.getLength-1;
		} else {
			this.pos--;
		}
	}

	public T opUnary(string s)() if(s == "*") {
		return this.deque.getValue(this.pos);
	}

	public bool opEquals(ref const Iterator!(T) it) const {
		return this.id == it.id;
	}	

	public bool isValid() const {
		size_t head = this.deque.getHeadPos();
		size_t tail = this.deque.getTailPos();
		if(head == tail) {
			//println(__LINE__);
			return false;
		} else if(head < tail) {
			//println(__LINE__);
			return this.pos > head && this.pos <= tail;
		} else {
			size_t tmp = this.pos;
			//println(__LINE__, tmp, head, tail, this.pos > head, 
			//	this.pos <= tail);
			return this.pos > head || this.pos <= tail;
		}
	}
}

public class Deque(T) : Iterable!(T) {
	private T[] data;
	private long head; // insert first than move
	private long tail; // move first than insert

	public this() {
		this(16);	
	}

	public this(const size_t size) {
		this.data = new T[size];
		this.head = 0;
		this.tail = 0;
	}

	public this(Deque!(T) toCopy) {
		this.data = toCopy.data.dup;
		this.head = toCopy.head;
		this.tail = toCopy.tail;
	}

	public this(T[] arr) {
		this(arr.length*2);
		assert(this.data.length == arr.length*2);
		foreach(it; arr) {
			this.pushBack(it);
		}
	}

	package size_t getHeadPos() const {
		return this.head;
	}

	package T getValue(size_t idx) {
		return this.data[idx];
	}

	package size_t getTailPos() const {
		return this.tail;
	}

	package size_t getLength() const {
		return this.data.length;
	}

	public Iterator!(T) begin() {
		return Iterator!(T)(this, true, size_t.max);
	}

	public Iterator!(T) end() {
		return Iterator!(T)(this, false, size_t.max);
	}

	private void growCapacity() {
		T[] n = new T[this.data.length*2];
		assert(n !is null);
		size_t oldNLength = this.getSize();
		if(this.tail > this.head) {
			foreach(size_t idx, T it; this.data[this.head .. this.tail+1]) {
				n[this.head+idx] = it;
			}
		} else { // this.head >= this.tail
			foreach(size_t idx, T it; this.data[0 .. this.tail+1]) {
				n[idx] = it;
			}
			foreach(size_t idx, T it; this.data[head .. $]) {
				n[1 + this.data.length + idx] = it;
			}
			this.head = this.head + this.data.length;
		}
		this.data = n;
		size_t size = this.getSize();
		assert(oldNLength == size, format("%d %d", oldNLength, size));
		assert(this.data !is null);
	}

	private void moveFront(const size_t idx) {
		for(size_t i = this.head-1; i < idx; i++) {
			this.data[i] = this.data[i+1];	
		}
		if((this.head-1) < 0) {
			this.head = this.data.length-1;
		} else {
			this.head--;	
		}
	}

	private void moveBack(const size_t idx) {
		for(size_t i = this.tail+1; i > idx; i--) {
			this.data[i] = this.data[i-1];
		}
		this.tail = (this.tail+1) % this.data.length;
	}

	public Deque!(T) insert(const long idx, T data) {
		// check if the array needs to grow
		if( ((this.head-1) % this.data.length == this.tail) ||
				((this.tail+1) % this.data.length == this.head) ) {
			this.growCapacity();
		}

		size_t insertIdx = this.getIdx(idx);
		size_t headDis = distance!(typeof(this.head))(this.head, insertIdx);
		size_t tailDis = distance!(typeof(this.head))(this.tail, insertIdx);

		if(this.head < this.tail) {
			if(this.head > 0) { 
				// move front headTail n
				this.moveFront(insertIdx);
				this.data[insertIdx] = data;
			} else if(this.head == 0) { 
				// move back headTail n
				this.moveBack(insertIdx);
				this.data[insertIdx] = data;
			} else {
				assert(false, format("this is a invalid case %d, %s", 
					insertIdx, this.toString()));
			}
		} else {
			if(insertIdx > this.head) { // move head left by one
				for(size_t i = this.head; i < insertIdx; i++) {
					this.data[i] = this.data[i+1];
				}
				this.head--;	
				this.data[insertIdx-1] = data;
			} else if(insertIdx <= this.tail) { // move tail backward by one
				for(size_t i = this.tail+1; i > insertIdx; i--) {
					this.data[i] = this.data[i-1];
				}
				this.tail++;
				this.data[insertIdx] = data;
			} else {
				assert(false, format("this is a invalid case %d, %s", 
					insertIdx, this.toString()));
			}
		}

		return this;
	}

	public T remove(const long idx) {
		size_t toRemove = getIdx(idx);
		if(idx == 0 || (idx < 0 && abs(idx) == this.getSize()-1)) {
			//printfln("%s:%d", __FILE__, __LINE__);
			return this.popFront();
		} else if(idx == this.getSize() || idx == -1) {
			//printfln("%s:%d", __FILE__, __LINE__);
			return this.popBack();
		} else if(this.head < this.tail) {
			//printfln("%s:%d", __FILE__, __LINE__);
			T ret = this.data[toRemove];
			for(size_t i = toRemove; i < this.tail; i++) {
				this.data[i] = this.data[i+1];
			}
			this.tail--;
			return ret;
		} else {
			if(toRemove > this.head) {
				T ret = this.data[toRemove];
				for(size_t i = toRemove; i < this.head; i--) {
					this.data[i] = this.data[i-1];
				}
				this.head = (this.head+1) % this.data.length;
				return ret;
			} else if(toRemove <= this.tail) {
				T ret = this.data[toRemove];
				for(size_t i = toRemove; i < this.tail; i--) {
					this.data[i] = this.data[i+1];
				}
				this.tail = this.tail-1;
				if(this.tail > this.data.length) {
					this.tail = this.data.length-1;
				}
				return ret;
			}
		}

		assert(0,format("idx=%d toRemove=%d %s", idx, toRemove, 
			this.toString()));
	}

	public T front() {
		if(this.head == this.tail)
			assert(0, "empty");
		long head = (this.head+1) % this.data.length;
		T ret = this.data[head];
		return ret;
	}

	public T popFront() {
		if(this.head == this.tail)
			assert(0, "empty");
		this.head = (this.head+1) % this.data.length;
		T ret = this.data[this.head];
		return ret;
	}

	public T back() {
		if(this.head == this.tail)
			assert(0, "empty");
		T ret = this.data[this.tail];
		return ret;
	}

	public T popBack() {
		if(this.head == this.tail)
			assert(0, "empty");
		T ret = this.data[this.tail];
		this.tail = this.tail-1;
		if(this.tail > this.data.length)
			this.tail = this.data.length-1;
		return ret;
	}

	public bool contains(const T toFind) {
		Iterator!(T) b = this.begin();	
		for(; b.isValid(); b++) {
			if(toFind == *b)
				return true;
		}
		return false;
	}

	public void pushFront(T toPush) {
		if((this.head-1) % this.data.length == this.tail) {
			this.growCapacity();
		}	
		assert(this.head < this.data.length, format("%d %d", this.head, 
			this.data.length));

		this.data[this.head] = toPush;
		if((this.head-1) < 0) {
			this.head = this.data.length-1;
		} else {
			this.head--;	
		}
	}

	public void pushBack(T toPush) {
		if((this.tail+1) % this.data.length == this.head) {
			this.growCapacity();
		}	
		this.tail = (this.tail+1) % this.data.length;
		this.data[this.tail] = toPush;
	}

	private size_t getIdx(const long idx) const {
		if( (idx > 0 && idx >= this.getSize()) || this.isEmpty() ||
				(idx < 0 &&  abs(idx) > this.getSize()) ) {
			throw new OutOfRangeException(
				format!(char,char)
					("idx %d head %d tail %d data.size %d len %d", idx, 
					this.head, this.head, this.data.length, this.getSize()));
		}

		if(idx >= 0) {
			return (this.head + idx + 1) % this.data.length;
		} else {
			if(this.head < this.tail) {
				// plus one because the tail moves after insert
				return this.tail - abs(idx) + 1;
			} else {
				if(this.tail - abs(idx) + 1 < 0) {
					long tmp = abs(this.tail - abs(idx) +1);
					return this.data.length - tmp;
				} else {
					return this.tail - abs(idx) + 1;
				}

			}
		}
		assert(false, "not reachable");

	}

	public T opIndex(const long idx) {
		return this.data[this.getIdx(idx)];
	}

	public T get(const long idx) {
		if(idx >= this.getSize()) {
			return this.back();
		} else {
			return this.data[this.getIdx(idx)];
		}
	}

	public const(T) opIndexConst(const long idx) const {
		return this.data[this.getIdx(idx)];
	}

	public int opIndexAssign(T value, const size_t idx) {
		size_t assignIdx = this.getIdx(idx);
		this.data[assignIdx] = value;
		return 1;
	}

	public bool isEmpty() const {
		return this.head == this.tail;
	}

	int opApplyReverse(int delegate(ref size_t, ref T) dg) {
		for(size_t idx = 0; idx < this.getSize(); idx++) {
			if(int r = dg(idx, this.data[
				this.getIdx(this.getSize() - 1 -idx)] ))
				return r;
		}
		return 0;
	}

	int opApplyReverse(int delegate(ref T) dg) {
		for(size_t idx = 0; idx < this.getSize(); idx++) {
			if(int r = dg(this.data[this.getIdx(this.getSize() - 1 -idx)]))
				return r;
		}
		return 0;
	}

	int opApply(int delegate(ref size_t, ref T) dg) {
		for(size_t idx = 0; idx < this.getSize(); idx++) {
			if(int r = dg(idx, this.data[this.getIdx(idx)]))
				return r;
		}
		return 0;
	}

	int opApply(int delegate(ref T) dg) {
		for(size_t idx = 0; idx < this.getSize(); idx++) {
			if(int r = dg(this.data[this.getIdx(idx)]))
				return r;
		}
		return 0;
	}

	public size_t getSize() const { 
		if(this.isEmpty()) {
			return 0;
		} else if(this.tail > this.head) {
			return this.tail-this.head;
		} else {
			return this.tail + (this.data.length-this.head);
		}
	}

	public void clean() {
		this.head = this.tail = 0;
	}

	public override bool opEquals(Object o) {
		Deque!(T) d = cast(Deque!(T))o;
		if(this.getSize() != d.getSize()) {
			return false;
		}
		Iterator!(T) it = d.begin();
		for(size_t idx = 0; it.isValid(); it++, idx++) {
			if(this[idx] != *it) {
				return false;
			}
		}
		return true;
	}

	package void print() const {
		hurt.io.stdio.print(this.head, this.tail, this.data.length, ":");
		foreach(it; this.data)
			printf("%d ", it);
		println();
	}

	public override string toString() const {
		StringBuffer!(char) ret = new StringBuffer!(char)(this.data.length*2);
		ret.pushBack(format!(char,char)("deque - (%d) {%d} %d [", this.head, 
			this.tail, this.data.length));
		foreach(idx, it; this.data) {
			static if(is(T == int)) {
				if(idx == this.head)
					ret.pushBack(format!(char,char)("(%d),",it));
				else if(idx == this.tail)
					ret.pushBack(format!(char,char)("{%d},",it));
				else
					ret.pushBack(format!(char,char)("%d,",it));
			} else static if(is(T : Object)) {
				if(idx == this.head)
					ret.pushBack(format("(%s),",typeid(it)));
				else if(idx == this.tail)
					ret.pushBack(format("{%s},",typeid(it)));
				else
					ret.pushBack(format("%s,",typeid(it)));
			}
		}
		ret.popBack();
		ret.pushBack("]");
		return ret.getString();
	}
}

unittest {
	Deque!(int) di = new Deque!(int);
	Deque!(int) dj = new Deque!(int)(di);
	assert(di == dj);
	di.pushBack(1);
	di.pushBack(3);
	di.insert(1, 2);
	assert(di[0] == 1,di.toString());
	assert(di[1] == 2,di.toString());
	assert(di[2] == 3,di.toString());
	di.clean();
	di.pushFront(3);
	di.pushFront(1);
	di.insert(1, 2);
	assert(di[0] == 1, di.toString());
	assert(di[1] == 2, di.toString());
	assert(di[2] == 3, di.toString());
	di = new Deque!(int)([10,9,8,7,6,5,4,3,2,1,0]);
	for(int i = 0; i < 11; i++) {
		assert(di.contains(i));
	}

	di = new Deque!(int);
	di.pushFront(3);
	di.pushFront(1);
	di.insert(1, 2);
	assert(di[0] == 1, di.toString());
	assert(di[1] == 2, di.toString());
	assert(di[2] == 3, di.toString());
	di = new Deque!(int);
	di.pushBack(1);
	di.pushBack(2);
	di.pushBack(4);
	di.insert(2, 3);
	assert(di[0] == 1, di.toString());
	assert(di[1] == 2, di.toString());
	assert(di[2] == 3, di.toString());
	assert(di[3] == 4, di.toString());
	di.pushBack(5);
	di.pushBack(6);
	di.pushBack(7);
	di.pushBack(9);
	assert(di[0] == 1, di.toString());
	assert(di[1] == 2, di.toString());
	assert(di[2] == 3, di.toString());
	assert(di[3] == 4, di.toString());
	assert(di[4] == 5, di.toString());
	assert(di[5] == 6, di.toString());
	assert(di[6] == 7, di.toString());
	assert(di[7] == 9, di.toString());
	//di.insert(7, 8);
	di.insert(-1, 8);
	assert(di[7] == 8, di.toString());
	assert(di[8] == 9, di.toString());
	di.pushFront(0);
	di.pushFront(-1);
	di.pushFront(-3);
	di.insert(1, -2);
	assert(di[0] == -3, di.toString());
	assert(di[1] == -2, di.toString());
	assert(di[2] == -1, di.toString());
	assert(di[3] == 0, di.toString());
	assert(di[4] == 1, di.toString());
	assert(di[5] == 2, di.toString());
	assert(di[6] == 3, di.toString());
	assert(di[7] == 4, di.toString());
	di = new Deque!(int)();
	di.pushBack(0);
	di.pushBack(1);
	di.pushBack(3);
	di.pushBack(4);
	assert(0 == di.popFront());
	di.insert(0,2);
	assert(di[0] == 1, di.toString());
	assert(di[1] == 2, di.toString());
	assert(di[2] == 3, di.toString());
	assert(di[3] == 4, di.toString());
	di = new Deque!(int)();
	di.pushBack(0);
	di.pushBack(2);
	di.pushBack(3);
	di.pushBack(4);
	di.insert(1,1);
	assert(di[0] == 0, di.toString());
	assert(di[1] == 1, di.toString());
	assert(di[2] == 2, di.toString());
	assert(di[3] == 3, di.toString());
	assert(di[4] == 4, di.toString());
	dj = new Deque!(int)(di);
	assert(di == dj);
	di[4] = 99;
	assert(di[4] == 99, di.toString());
	assert(di.remove(0) == 0, di.toString());
	assert(di.remove(-1) == 99, di.toString());
	assert(di.remove(-1) == 3, di.toString());
	assert(di.remove(1) == 2, di.toString());

	Deque!(int) deIT = new Deque!(int);
	bool fail = false;
	try {
		int a = deIT[0];
	} catch(OutOfRangeException e) {
		fail = true;
	} 
	assert(fail);
	try {
		int a = deIT[-1];
	} catch(OutOfRangeException e) {
		fail = true;
	} 
	assert(fail);

	deIT.pushBack(10);
	fail = false;
	try {
		int a = deIT[1];
	} catch(OutOfRangeException e) {
		fail = true;
	}
	assert(fail);

	fail = false;
	try {
		int a = deIT[-2];
	} catch(OutOfRangeException e) {
		fail = true;
	}
	assert(fail, format("%d", deIT.getSize()));

	assert(deIT.getSize() == 1);
	assert(deIT[0] == 10, conv!(int,string)(deIT[0]));
	assert(deIT[-1] == 10, deIT.toString());
	deIT.pushBack(11);
	assert(deIT[-2] == 10, conv!(int,string)(deIT[-2]));
	assert(deIT[-1] == 11, conv!(int,string)(deIT[-1]));
	deIT = new Deque!(int);
	deIT.pushFront(10);
	assert(deIT.getSize() == 1);
	assert(deIT[0] == 10, conv!(int,string)(deIT[0]));
	assert(deIT[-1] == 10, conv!(int,string)(deIT[-1]));
	deIT.pushFront(11);
	assert(deIT[-1] == 10, conv!(int,string)(deIT[-1]));
	assert(deIT[-2] == 11, deIT.toString());

	immutable int[30] reArr = [0,15,5,4,22,
		56, 33, 76, 21, 1,
		96, 54, 77, 91, 2, 
		-8,-15,-5,-4,-22,
		-56, -33, -76, -21, -1,
		-96, -54, -77, -91, -2];

	void pushBackPopFront(Deque!(int) de, int count) {
		for(int i = 0; i < count; i++) {
			de.pushBack(i);	
			for(int j = 0; j <= i; j++) {
				assert(de[j] == j);
				assert(de[-(j+1)] == i-j, format!(char,char)("j %d %d %d", 
					-(j+1), de[-(j+1)], i-j));
			}
			int h = 0;
			foreach(int t; de) {
				h++;
			}
			h--;
			assert(h == i, format("%d %d",h,i));
			h = 0;
			foreach(size_t idx, int t; de) {
				assert(t == idx);
				h++;
			}
			h--;
			assert(h == i, format("%d %d",h,i));

			foreach_reverse(size_t idx, int t; de) {
				assert(t == i-idx);
			}

			size_t idx = 0;
			foreach(int t; de) {
				assert(t == idx);
				idx++;
			}
			idx--;
			assert(idx == i, format("%d %d", idx, i));
			assert(i+1 == de.getSize());

			// test iterator
			auto it = de.begin();
			assert(it.isValid());
			for(int j = 0; j <= i; j++) {
				assert(it.isValid());
				assert(*it == j, format("%d %d pos %d size %s", *it, j, 
					it.pos, de.toString()));
				it++;
			}
			it = de.end();
			assert(it.isValid());
			for(int j = 0; j <= i; j++) {
				assert(it.isValid());
				assert(*it == i-j, format("%d %d pos %d size %s", *it, i-j, 
					it.pos, de.toString()));
				it--;
			}
			for(int j = 0; j <= i; j++) {
				assert(de.contains(j));
			}
		}
		Deque!(int) dh = new Deque!(int)(de);
		assert(dh == de);
		assert(count == de.getSize(),
			conv!(size_t,string)(de.getSize()) ~ " " 
			~ conv!(int,string)(count));
		for(int i = 0; i < count; i++) {
			assert(i == de.popFront());
			assert(count-1-i == de.getSize(), 
				conv!(size_t,string)(de.getSize()));
		}
		assert(de.isEmpty());

		for(int j = 0; j < count; j++) {
			//printfln("%d", j);
			de.pushBack(j);
		}
		assert(de.getSize() == count);
		for(int j = 0; j < count; j++) {
			//printfln("%d %d", j, reArr[j%reArr.length] % de.getSize());
			de.remove(reArr[j % reArr.length] % de.getSize());	
		}
		assert(de.isEmpty());
	}

	void pushFrontPopBack(Deque!(int) de, int count) {
		assert(count > 0);
		assert(de.isEmpty());
		for(int i = 0; i < count; i++) {
			de.pushFront(i);	
			for(int j = 0; j <= i; j++) {
				assert(de[j] == i-j);
				assert(de[-(j+1)] == j, format!(char,char)("j %d %d %d %s", 
					-(j+1), de[-(j+1)], i-j, de.toString()));
			}

			int h = 0;
			foreach(size_t idx, int t; de) {
				assert(t == i-idx);
				h++;
			}
			h--;
			assert(h == i, format("%d %d", h,i));
			h = 0;

			foreach_reverse(size_t idx, int t; de) {
				assert(t == idx);
				h++;
			}
			h--;
			assert(h == i, format("%d %d", h,i));

			size_t idx = 0;
			foreach(int t; de) {
				assert(t == i-idx);
				idx++;
			}
			idx--;
			assert(idx == i,format("%d %d", idx,i));
			assert(i+1 == de.getSize());
			if(i+1 != de.getSize())
				de.print();
			assert(i+1 == de.getSize(),
				conv!(size_t,string)(de.getSize()) ~ " " 
				~ conv!(int,string)(i+1));
			// test iterator
			auto it = de.begin();
			assert(it.isValid());
			for(int j = 0; j <= i; j++, it++) {
				assert(it.isValid());
				assert(*it == i-j);
			}
			it = de.end();
			assert(it.isValid());
			for(int j = 0; j <= i; j++, it--) {
				assert(it.isValid());
				assert(*it == j);
			}
			for(int j = 0; j <= i; j++) {
				assert(de.contains(j));
			}
		}
		Deque!(int) dh = new Deque!(int)(de);
		assert(dh == de);

		assert(count == de.getSize(),
			conv!(size_t,string)(de.getSize()) ~ " " 
			~ conv!(int,string)(count));
		for(int i = 0; i < count; i++) {
			assert(i == de.popBack());
			assert(count-1-i == de.getSize(), 
				conv!(size_t,string)(de.getSize()));
		}
		assert(de.isEmpty());

		for(int j = 0; j < count; j++) {
			//printfln("%d", j);
			de.pushFront(j);
		}
		assert(de.getSize() == count);
		for(int j = 0; j < count; j++) {
			//printfln("%d %d", j, reArr[j%reArr.length] % de.getSize());
			de.remove(reArr[j % reArr.length] % de.getSize());	
		}
		assert(de.isEmpty());
	}

	void pushFrontPopFront(Deque!(int) de, int count) {
		for(int i = 0; i < count; i++) {
			de.pushFront(i);	
			assert(i+1 == de.getSize(), 
				format("%d %d %s", i+1, de.getSize(), de.toString()));
			for(int j = 0; j <= i; j++) {
				assert(de[j] == i-j, 
					format("i %d j %d %d != %d %s", i, j, de[j], i-j, 
					de.toString()));
				assert(de[-(j+1)] == j, 
					format!(char,char)("de[%d]=%d ==%d %s", 
					-(j+1), de[-(j+1)], j, de.toString()));
			}
			int h = 0;
			foreach(size_t idx, int t; de) {
				assert(t == i-idx);
				h++;
			}
			h--;
			assert(h == i, format("%d %d", h,i));
			h = 0;
			foreach_reverse(size_t idx, int t; de) {
				assert(t == idx);
				h++;
			}
			h--;
			assert(h == i, format("%d %d", h,i));

			size_t idx = 0;
			foreach(int t; de) {
				assert(t == i-idx);
				idx++;
			}
			idx--;
			assert(idx == i, format("%d %d", idx,i));
			// test iterator
			auto it = de.begin();
			assert(it.isValid(), format("pos %d %s", it.pos, de.toString()));
			for(int j = 0; j <= i; j++, it++) {
				assert(it.isValid());
				//assert(*it == i-j);
				assert(*it == i-j, format("%d %d pos %d size %s", *it, j, 
					it.pos, de.toString()));
			}
			it = de.end();
			assert(it.isValid());
			for(int j = 0; j <= i; j++, it--) {
				assert(it.isValid());
				assert(*it == j);
			}
			for(int j = 0; j <= i; j++) {
				assert(de.contains(j));
			}
		}
		Deque!(int) dh = new Deque!(int)(de);
		assert(dh == de);

		assert(count == de.getSize(),
			conv!(size_t,string)(de.getSize()) ~ " " 
			~ conv!(int,string)(count));
		for(int i = 0; i < count; i++) {
			assert(count-1-i == de.popFront());
			assert(count-1-i == de.getSize(), 
				conv!(size_t,string)(de.getSize()));
		}
		assert(de.isEmpty());

		for(int j = 0; j < count; j++) {
			//printfln("%d", j);
			de.pushFront(j);
		}
		assert(de.getSize() == count);
		for(int j = 0; j < count; j++) {
			//printfln("%d %d", j, reArr[j%reArr.length] % de.getSize());
			de.remove(reArr[j % reArr.length] % de.getSize());	
		}
		assert(de.isEmpty());
	}

	void pushBackPopBack(Deque!(int) de, int count) {
		for(int i = 0; i < count; i++) {
			de.pushBack(i);	
			assert(i+1 == de.getSize());
			for(int j = 0; j <= i; j++) {
				assert(de[j] == j);
				assert(de[-(j+1)] == i-j, format!(char,char)("j %d %d %d", 
					-(j+1), de[-(j+1)], i-j));
			}
			int h = 0;
			foreach(size_t idx, int t; de) {
				assert(t == idx);
				h++;
			}
			h--;
			assert(h == i, format("%d %d", h,i));
			h = 0;
			foreach_reverse(size_t idx, int t; de) {
				assert(t == i-idx);
				h++;
			}
			h--;
			assert(h == i, format("%d %d", h,i));
			size_t idx = 0;
			foreach(int t; de) {
				assert(t == idx);
				idx++;
			}
			idx--;
			assert(idx == i, format("%d %d", idx,i));
			// test iterator
			auto it = de.begin();
			assert(it.isValid());
			for(int j = 0; j <= i; j++, it++) {
				assert(it.isValid());
				assert(*it == j);
			}
			it = de.end();
			assert(it.isValid());
			for(int j = 0; j <= i; j++, it--) {
				assert(it.isValid());
				assert(*it == i-j);
			}
			for(int j = 0; j <= i; j++) {
				assert(de.contains(j));
			}
		}
		Deque!(int) dh = new Deque!(int)(de);
		assert(dh == de);

		assert(count == de.getSize(),
			conv!(size_t,string)(de.getSize()) ~ " " 
			~ conv!(int,string)(count));
		for(int i = 0; i < count; i++) {
			assert(count-1-i == de.popBack());
			assert(count-1-i == de.getSize(), 
				conv!(size_t,string)(de.getSize()));
		}
		assert(de.isEmpty());

		for(int j = 0; j < count; j++) {
			//printfln("%d", j);
			de.pushBack(j);
		}
		assert(de.getSize() == count);
		for(int j = 0; j < count; j++) {
			//printfln("%d %d", j, reArr[j%reArr.length] % de.getSize());
			de.remove(reArr[j % reArr.length] % de.getSize());	
		}
		assert(de.isEmpty());
	}

	int mul = 10;
	for(int i = 0; i < 50; i++) {
		Deque!(int) de = new Deque!(int)();
		//println(__LINE__, i);
		switch(i%15) {
			case 0:
				pushBackPopFront(de, mul * (i/9+1));
				pushFrontPopBack(de, mul * (i/9+1));
				pushFrontPopFront(de, mul * (i/9+1));
				pushBackPopBack(de, mul * (i/9+1));
				assert(de.isEmpty());
				break;
			case 1:
				pushBackPopFront(de, mul * (i/9+1));
				pushFrontPopBack(de, mul * (i/9+1));
				pushBackPopBack(de, mul * (i/9+1));
				pushFrontPopFront(de, mul * (i/9+1));
				assert(de.isEmpty());
				break;
			case 2:
				pushBackPopFront(de, mul * (i/9+1));
				pushBackPopBack(de, mul * (i/9+1));
				pushFrontPopBack(de, mul * (i/9+1));
				pushFrontPopFront(de, mul * (i/9+1));
				assert(de.isEmpty());
				break;
			case 3:
				pushBackPopBack(de, mul * (i/9+1));
				pushBackPopFront(de, mul * (i/9+1));
				pushFrontPopBack(de, mul * (i/9+1));
				pushFrontPopFront(de, mul * (i/9+1));
				assert(de.isEmpty());
				break;
			case 4:
				pushBackPopBack(de, mul * (i/9+1));
				pushBackPopFront(de, mul * (i/9+1));
				pushFrontPopFront(de, mul * (i/9+1));
				pushFrontPopBack(de, mul * (i/9+1));
				assert(de.isEmpty());
				break;
			case 5:
				pushBackPopBack(de, mul * (i/9+1));
				pushFrontPopFront(de, mul * (i/9+1));
				pushBackPopFront(de, mul * (i/9+1));
				pushFrontPopBack(de, mul * (i/9+1));
				assert(de.isEmpty());
				break;
			case 6:
				pushFrontPopFront(de, mul * (i/9+1));
				pushBackPopBack(de, mul * (i/9+1));
				pushBackPopFront(de, mul * (i/9+1));
				pushFrontPopBack(de, mul * (i/9+1));
				assert(de.isEmpty());
				break;
			case 7:
				assert(de.isEmpty());
				pushFrontPopFront(de, mul * (i/9+1));
				assert(de.isEmpty());
				pushBackPopBack(de, mul * (i/9+1));
				assert(de.isEmpty());
				pushFrontPopBack(de, mul * (i/9+1));
				assert(de.isEmpty());
				pushBackPopFront(de, mul * (i/9+1));
				assert(de.isEmpty());
				break;
			case 8:
				pushFrontPopFront(de, mul * (i/9+1));
				pushFrontPopBack(de, mul * (i/9+1));
				pushBackPopBack(de, mul * (i/9+1));
				pushBackPopFront(de, mul * (i/9+1));
				assert(de.isEmpty());
				break;
			case 9:
				pushFrontPopBack(de, mul * (i/9+1));
				pushFrontPopFront(de, mul * (i/9+1));
				pushBackPopBack(de, mul * (i/9+1));
				pushBackPopFront(de, mul * (i/9+1));
				assert(de.isEmpty());
				break;
			case 10:
				pushFrontPopBack(de, mul * (i/9+1));
				pushFrontPopFront(de, mul * (i/9+1));
				pushBackPopFront(de, mul * (i/9+1));
				pushBackPopBack(de, mul * (i/9+1));
				assert(de.isEmpty());
				break;
			case 11:
				pushFrontPopBack(de, mul * (i/9+1));
				pushBackPopFront(de, mul * (i/9+1));
				pushFrontPopFront(de, mul * (i/9+1));
				pushBackPopBack(de, mul * (i/9+1));
				assert(de.isEmpty());
				break;
			case 12:
				pushBackPopFront(de, mul * (i/9+1));
				pushFrontPopBack(de, mul * (i/9+1));
				pushFrontPopFront(de, mul * (i/9+1));
				pushBackPopBack(de, mul * (i/9+1));
				assert(de.isEmpty());
				break;
			case 13:
				pushBackPopFront(de, mul * (i/9+1));
				pushFrontPopBack(de, mul * (i/9+1));
				pushBackPopBack(de, mul * (i/9+1));
				pushFrontPopFront(de, mul * (i/9+1));
				assert(de.isEmpty());
				break;
			case 14:
				pushBackPopFront(de, mul * (i/9+1));
				pushBackPopBack(de, mul * (i/9+1));
				pushFrontPopBack(de, mul * (i/9+1));
				pushFrontPopFront(de, mul * (i/9+1));
				assert(de.isEmpty());
				break;
			default:
				assert(false, "not reachable " ~ conv!(int,string)(i));
		}
	}

	debug {
		//println("deque test done");
	}
}

/*
void main() {
	Deque!(int) d1 = new Deque!(int)();
<<<<<<< HEAD
}
*/
