module hurt.container.deque;

import hurt.container.iterator;
import hurt.container.store;
import hurt.conv.conv;
import hurt.exception.outofrangeexception;
import hurt.container.iterator;
import hurt.io.stdio;
import hurt.math.mathutil;
import hurt.util.pair;
import hurt.string.formatter;
import hurt.string.stringbuffer;
import hurt.util.slog;
import hurt.time.stopwatch;

struct ConstIterator(T) {
	private size_t pos;
	private size_t id;
	private Deque!(T) deque;

	this(Deque!(T) deque, const size_t id, size_t pos) {
		this.deque = deque;
		this.id = id;
		size_t head = this.deque.getHeadPos();
		size_t tail = this.deque.getTailPos();
		this.pos = pos;
	}

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

	public const(T) opUnary(string s)() if(s == "*") {
		return this.deque.getValue(this.pos);
	}

	public bool opEquals(ref const Iterator!(T) it) const {
		return this.id == it.id;
	}	

	public bool isValid() const {
		size_t head = this.deque.getHeadPos();
		size_t tail = this.deque.getTailPos();
		if(head == tail) {
			return false;
		} else if(head < tail) {
			return this.pos > head && this.pos <= tail;
		} else {
			size_t tmp = this.pos;
			return this.pos > head || this.pos <= tail;
		}
	}
}

struct Iterator(T) {
	private size_t pos;
	private size_t id;
	private Deque!(T) deque;

	this(Deque!(T) deque, const size_t id, size_t pos) {
		this.deque = deque;
		this.id = id;
		size_t head = this.deque.getHeadPos();
		size_t tail = this.deque.getTailPos();
		this.pos = pos;
	}

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
			return false;
		} else if(head < tail) {
			return this.pos > head && this.pos <= tail;
		} else {
			size_t tmp = this.pos;
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

	public this(strPtr ptr) {
		size_t* tmp = cast(size_t*)ptr.getPointer();
		this.head = *tmp;
		tmp++;

		this.tail = *tmp;
		tmp++;

		byte* dataPtr = cast(byte*)tmp;
		byte* end = cast(byte*)(ptr.getPointer()+ptr.getSize());
		ptrdiff_t diff = end-dataPtr;

		size_t numElements = diff / T.sizeof;
		T* realDataPtr = cast(T*)dataPtr;
		this.data = realDataPtr[0 .. numElements];
	}

	public this(const size_t size) {
		this.data = new T[size];
		this.head = 0;
		this.tail = 0;
	}

	public this(Deque!(T) toCopy, bool slice = false) {
		if(!slice) {
			this.data = toCopy.data.dup;
		} else {
			this.data = toCopy.data;
		}
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

	package T[] getArray() {
		return this.data;
	}

	package size_t getHeadPos() const {
		return this.head;
	}

	package T getValue(const size_t idx) {
		return this.data[idx];
	}

	package const(T) getValue(const size_t idx) const {
		return this.data[idx];
	}

	package const(T) getConstValue(const size_t idx) const {
		return this.data[idx];
	}

	package size_t getTailPos() const {
		return this.tail;
	}

	package size_t getLength() const {
		return this.data.length;
	}

	public Iterator!(T) iterator(const size_t pos) {
		return Iterator!(T)(this, size_t.max, this.getIdx(pos));
	}

	public ConstIterator!(T) cIterator(const size_t pos) {
		return ConstIterator!(T)(this, size_t.max, this.getIdx(pos));
	}

	public Iterator!(T) begin() {
		return Iterator!(T)(this, true, size_t.max);
	}

	public Iterator!(T) end() {
		return Iterator!(T)(this, false, size_t.max);
	}

	public ConstIterator!(T) cBegin() {
		return ConstIterator!(T)(this, true, size_t.max);
	}

	public ConstIterator!(T) cEnd() {
		return ConstIterator!(T)(this, false, size_t.max);
	}

	public T[] values() {
		T[] ret = new T[this.getSize()];
		foreach(idx, it; this) {
			ret[idx] = it;
		}
		
		return ret;
	}

	private void growCapacity() {
		T[] n = new T[this.data.length*2];
		assert(n !is null);
		Iterator!(T) it = this.begin();
		size_t idx = 0;
		for(; it.isValid(); it++, idx++) {
			n[idx] = *it;
		}
		assert(this.data !is null);
		this.data = n;
		this.head = n.length-1;
		this.tail = idx-1;
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

	public void removeFalse(bool delegate(T toTest) test) {
		for(size_t idx = 0; idx < this.getSize();) {
			if(!test(this[idx])) {
				this.remove(idx);
			} else {
				idx++;
			}
		}
	}

	public size_t count(bool delegate(T toTest) test) {
		size_t ret = 0;
		foreach(size_t idx, T it; this) {
			if(test(it)) {
				ret++;
			}
		}
		return ret;
	}

	public T front() {
		if(this.head == this.tail)
			assert(0, "empty");
		long head = (this.head+1) % this.data.length;
		T ret = this.data[head];
		return ret;
	}

	public const(T) front() const {
		if(this.head == this.tail)
			assert(0, "empty");
		long head = (this.head+1) % this.data.length;
		const(T) ret = this.data[head];
		return ret;
	}

	public T popFront() {
		if(this.head == this.tail)
			assert(0, "empty");
		this.head = (this.head+1) % this.data.length;
		T ret = this.data[this.head];
		return ret;
	}

	public const(T) back() const {
		if(this.head == this.tail)
			assert(0, "empty");
		const(T) ret = this.data[this.tail];
		return ret;
	}

	public ref T backRef() {
		if(this.head == this.tail) {
			assert(0, "empty");
		}
		return this.data[this.tail];
	}

	public T back() {
		if(this.head == this.tail) {
			assert(0, "empty");
		}
		T ret = this.data[this.tail];
		return ret;
	}

	public T popBack(size_t cnt) {
		if(this.getSize() < cnt) {
			throw new OutOfRangeException(
				format(" Deque size of %u not big enough to pop %u",
				this.getSize(), cnt));
		}
		//T last;
		for(size_t i = 0; i < (cnt-1); i++) {
			//last = this.popBack();
			this.popBack();
		}
		return this.popBack();
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

	public bool containsNot(const T toFind) {
		return !this.contains(toFind);
	}

	public bool contains(const T toFind) {
		ConstIterator!(T) b = this.cBegin();	
		for(; b.isValid(); b++) {
			if(toFind == *b)
				return true;
		}
		return false;
	}

	public size_t find(T toFind) {
		foreach(size_t idx, T item; this) {
			if(item == toFind) {
				return idx;
			}
		}
		return this.getSize();
	}

	public Iterator!(T) findIt(T toFind) {
		foreach(size_t idx, T id; this) {
			if(id == toFind) {
				return Iterator!(T)(this, size_t.max, this.getIdx(idx));
			}
		}
		Iterator!(T) it = this.end();
		it++;
		return it;
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

	private bool checkIdx(const long idx) const {
		if( (idx > 0 && idx >= this.getSize()) || this.isEmpty() ||
				(idx < 0 &&  abs(idx) > this.getSize()) ) {
			throw new OutOfRangeException(
				format!(char,char)
					("idx %d head %d tail %d data.size %d len %d", idx, 
					this.head, this.head, this.data.length, this.getSize()));
		}
		return true;
	}

	private size_t getIdx(const long idx) const {
		/*if( (idx > 0 && idx >= this.getSize()) || this.isEmpty() ||
				(idx < 0 &&  abs(idx) > this.getSize()) ) {
			throw new OutOfRangeException(
				format!(char,char)
					("idx %d head %d tail %d data.size %d len %d", idx, 
					this.head, this.head, this.data.length, this.getSize()));
		}*/
		this.checkIdx(idx);

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

	public const(T) opIndex(const long idx) const {
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

	int opApplyReverse(int delegate(const ref size_t, const ref T) dg) const {
		for(size_t idx = 0; idx < this.getSize(); idx++) {
			if(int r = dg(idx, this.data[
				this.getIdx(this.getSize() - 1 -idx)] )) {
				return r;
			}
		}
		return 0;
	}

	int opApplyReverse(int delegate(const ref T) dg) const {
		for(size_t idx = 0; idx < this.getSize(); idx++) {
			if(int r = dg(this.data[this.getIdx(this.getSize() - 1 -idx)])) {
				return r;
			}
		}
		return 0;
	}


	int opApplyReverse(int delegate(ref size_t, ref T) dg) {
		for(size_t idx = 0; idx < this.getSize(); idx++) {
			if(int r = dg(idx, this.data[
				this.getIdx(this.getSize() - 1 -idx)] )) {
				return r;
			}
		}
		return 0;
	}

	int opApplyReverse(int delegate(ref T) dg) {
		for(size_t idx = 0; idx < this.getSize(); idx++) {
			if(int r = dg(this.data[this.getIdx(this.getSize() - 1 -idx)])) {
				return r;
			}
		}
		return 0;
	}

	int opApply(int delegate(const ref size_t, const ref T) dg) const {
		for(size_t idx = 0; idx < this.getSize(); idx++) {
			if(int r = dg(idx, this.data[this.getIdx(idx)])) {
				return r;
			}
		}
		return 0;
	}

	int opApply(int delegate(ref size_t, ref T) dg) {
		for(size_t idx = 0; idx < this.getSize(); idx++) {
			if(int r = dg(idx, this.data[this.getIdx(idx)])) {
				return r;
			}
		}
		return 0;
	}
	
	int opApply(int delegate(const ref T) dg) const {
		for(size_t idx = 0; idx < this.getSize(); idx++) {
			if(int r = dg(this.data[this.getIdx(idx)])) {
				return r;
			}
		}
		return 0;
	}

	int opApply(int delegate(ref T) dg) {
		for(size_t idx = 0; idx < this.getSize(); idx++) {
			if(int r = dg(this.data[this.getIdx(idx)])) {
				return r;
			}
		}
		return 0;
	}

	public size_t opDollar() const {
		return this.getSize();
	}

	public Deque!(T) opSlice(long begin, long end, bool reAlloc = true) {
		if(begin <= end && begin >= 0 && end >= 0) {
			Deque!(T) ret = new Deque!(T)(this, true && reAlloc);
			long eCnt = ret.getSize() - end;
			for(long i = 0; i < begin; i++) {
				ret.popFront();
			}
			for(long i = 0; i < eCnt; i++) {
				ret.popBack();
			}
			return ret;
		} else if(begin <= end && begin < 0 && end >= 0) {
			Deque!(T) ret = new Deque!(T)(this.getSize() + abs(begin));
			long eCnt = this.getSize() - abs(end);
			long till = conv!(size_t,long)(this.getSize()-eCnt);
			for(long i = begin; i < till; i++) {
				ret.pushBack(this[i]);
			}
			return ret;
		} else if(begin > end && begin >= 0 && end >= 0) {
			auto tmp =  this.opSlice(end, begin+1, false);
			tmp.reverse();
			return tmp;
		}
		assert(false);
	}

	public void reverse() {
		size_t tSize = this.getSize();
		for(long i = 0; i < tSize/2; i++) {
			T tmp = this[i];
			this[i] = this[tSize-1-i];
			this[tSize-1-i] = tmp;
		}
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

	public size_t getCapacity() const {
		return this.data.length;
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
			hurt.io.stdio.printf("%d ", it);
		hurt.io.stdio.println();
	}

	public override string toString() const {
		StringBuffer!(char) ret = new StringBuffer!(char)(this.data.length*2);
		ret.pushBack(format!(char,char)("deque - (%d) {%d} %d [", this.head, 
			this.tail, this.data.length));
		foreach(idx, it; this.data) {
			static if(is(T == int)) {
				if(idx == this.head) {
					ret.pushBack(format!(char,char)("(%d),",it));
				} else if(idx == this.tail) {
					ret.pushBack(format!(char,char)("{%d},",it));
				} else {
					ret.pushBack(format!(char,char)("%d,",it));
				}
			} else static if(is(T : Object)) {
				if(idx == this.head) {
					ret.pushBack(format("(%s),", it !is null ? it.stringof : 
						"null"));
				} else if(idx == this.tail) {
					ret.pushBack(format("{%s},", it !is null ? it.stringof : 
						"null"));
				} else {
					ret.pushBack(format("%s,", it !is null ? it.stringof : 
					"null"));
				}
			}
		}
		ret.popBack();
		ret.pushBack("]");
		return ret.getString();
	}
}

unittest {
	Deque!(int) t = new Deque!(int)([1,2,3,4,5,6,7]);
	Deque!(int) tc1 = t[1 .. t.getSize()-2];
	Deque!(int) test = new Deque!(int)([2,3,4,5]);
	assert(tc1 == test);

	test = new Deque!(int)([2,3,4,5,6]);
	tc1 = t[1 .. t.getSize()-1];
	assert(tc1 == test);

	t = new Deque!(int)([2,3,4,5]);
	auto r = t[t.getSize()-1 .. 0];
	test = new Deque!(int)([5,4,3,2]);
	assert(test == r);

	test = new Deque!(int)([2,3,4,5]);
	assert(t == test);

	r = t[-2 .. t.getSize()];
	assert(r.getSize() == 6);
	test = new Deque!(int)([4,5,2,3,4,5]);
	assert(r == test);
}

unittest {
	auto r = new Deque!(int)([1,2,3,4,5,6]);
	r.reverse();
	auto t = new Deque!(int)([6,5,4,3,2,1]);
	assert(r == t);

	r = new Deque!(int)();
	r.reverse();
	assert(r.isEmpty());
}

unittest {
	auto r = new Deque!(int)([1,2,3,4,5,6,7]);
	r.reverse();
	auto t = new Deque!(int)([7,6,5,4,3,2,1]);
	assert(r == t);
}

unittest {
	Deque!(int) d = new Deque!(int)(128);
	assert(d.getSize() == 0);
	d.pushBack(44);
	d.pushBack(54);
	d.pushFront(34);
	assert(d.values() == [34,44,54]);
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
			Iterator!(int) it = de.begin();
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

			ConstIterator!(int) cit = de.cBegin();
			assert(cit.isValid());
			for(int j = 0; j <= i; j++) {
				assert(cit.isValid());
				assert(*cit == j, format("%d %d pos %d size %s", *cit, j, 
					cit.pos, de.toString()));
				cit++;
			}
			cit = de.cEnd();
			assert(cit.isValid());
			for(int j = 0; j <= i; j++) {
				assert(cit.isValid());
				assert(*cit == i-j, format("%d %d pos %d size %s", *cit, i-j, 
					cit.pos, de.toString()));
				cit--;
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
			de.pushBack(j);
		}
		assert(de.getSize() == count);
		for(int j = 0; j < count; j++) {
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

			ConstIterator!(int) cit = de.cBegin();
			assert(cit.isValid());
			for(int j = 0; j <= i; j++) {
				assert(cit.isValid());
				assert(*cit == i-j, format("%d %d pos %d size %s", *cit, j, 
					cit.pos, de.toString()));
				cit++;
			}
			cit = de.cEnd();
			assert(cit.isValid());
			for(int j = 0; j <= i; j++) {
				assert(cit.isValid());
				assert(*cit == j, format("%d %d pos %d size %s", *cit, i-j, 
					cit.pos, de.toString()));
				cit--;
			}

			for(int j = 0; j <= i; j++) {
				assert(de.contains(j));
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
			de.pushFront(j);
		}
		assert(de.getSize() == count);
		for(int j = 0; j < count; j++) {
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
				assert(*it == i-j, format("%d %d pos %d size %s", *it, j, 
					it.pos, de.toString()));
			}
			it = de.end();
			assert(it.isValid());
			for(int j = 0; j <= i; j++, it--) {
				assert(it.isValid());
				assert(*it == j);
			}

			ConstIterator!(int) cit = de.cBegin();
			assert(cit.isValid());
			for(int j = 0; j <= i; j++) {
				assert(cit.isValid());
				assert(*cit == i-j, format("%d %d pos %d size %s", *cit, j, 
					cit.pos, de.toString()));
				cit++;
			}
			cit = de.cEnd();
			assert(cit.isValid());
			for(int j = 0; j <= i; j++) {
				assert(cit.isValid());
				assert(*cit == j, format("%d %d pos %d size %s", *cit, i-j, 
					cit.pos, de.toString()));
				cit--;
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
			de.pushFront(j);
		}
		assert(de.getSize() == count);
		for(int j = 0; j < count; j++) {
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

			ConstIterator!(int) cit = de.cBegin();
			assert(cit.isValid());
			for(int j = 0; j <= i; j++) {
				assert(cit.isValid());
				assert(*cit == j, format("%d %d pos %d size %s", *cit, j, 
					cit.pos, de.toString()));
				cit++;
			}
			cit = de.cEnd();
			assert(cit.isValid());
			for(int j = 0; j <= i; j++) {
				assert(cit.isValid());
				assert(*cit == i-j, format("%d %d pos %d size %s", *cit, i-j, 
					cit.pos, de.toString()));
				cit--;
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
			de.pushBack(j);
		}
		assert(de.getSize() == count);
		for(int j = 0; j < count; j++) {
			de.remove(reArr[j % reArr.length] % de.getSize());	
		}
		assert(de.isEmpty());
	}

	int mul = 10;
	for(int i = 0; i < 50; i++) {
		Deque!(int) de = new Deque!(int)();
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
}

unittest {
	Deque!(bool) bd = new Deque!(bool)([false, true, false, false, true]);
	bd.removeFalse(delegate(bool toTest) {
		return toTest;
	});
	assert(bd.getSize() == 2);

	bd = new Deque!(bool)(true);
	bd.removeFalse(delegate(bool toTest) {
		return toTest;
	});
	assert(bd.getSize() == 0);
}

private struct test {
	int t;

	this(int t) {
		this.t = t;
	}

	int opCmp(ref test s) {
		return this.t = s.t;
	}
}

unittest {
	Deque!(test) t = new Deque!(test)();
	t.pushBack(test(99));
	assert(t.backRef().t == 99);
	t.backRef().t = 77;
	assert(t.backRef().t == 77, conv!(int,string)(t.back().t));
}

public Deque!(T) lstExpr(T, string it = "x", string con = "true")
		(T[] input, T delegate(T t) func[]) {
	Deque!(T) ret = new Deque!(T)(input.getSize());
	immutable string loop = "foreach("~it~"; input) {
		if("~con~") {
			T tmp = "~it~";	
			foreach(jt; func) {
				tmp = jt(tmp);
			}
			ret.pushBack(tmp);
		}
	}";
	mixin(loop);
	return ret;
}

public Deque!(T) lstExpr(T, string it = "x", string con = "true")
		(Iterable!(T) input, T delegate(T t) func[]) {
	Deque!(T) ret = new Deque!(T)(input.getSize());
	immutable string loop = "foreach("~it~"; input) {
		if("~con~") {
			T tmp = "~it~";	
			foreach(jt; func) {
				tmp = jt(tmp);
			}
			ret.pushBack(tmp);
		}
	}";
	mixin(loop);
	return ret;
}

unittest {
	auto de = new Deque!(int)([1,2,3,4,5]);
	auto rslt = lstExpr!(int,"x","x != 2")(de, [delegate(int x) { return x*x; }, delegate(int x) { return x + 1; }]);
	auto rsltTst = new Deque!(int)([2,10,17,26]);
	assert(rslt == rsltTst);
}

public strPtr toStore(T)(Store store, Deque!T deque) {

	size_t toAlloc = size_t.sizeof * 2 + T.sizeof * deque.getCapacity();
	strPtr ht = store.alloc(toAlloc);

	size_t* headPtr = cast(size_t*)ht.getPointer();
	*headPtr = deque.getHeadPos();

	size_t* tailPtr = headPtr+1;
	*tailPtr = deque.getTailPos();

	T* tmp = cast(T*)(tailPtr+1);
	size_t highAdr = cast(size_t)(ht.getPointer() + ht.getSize());

	T* ptr = tmp;
	foreach(it;deque.getArray()) {
		T* oPtr = ptr;
		*ptr = it;
		ptr++;
	}

	return ht;
}

unittest {
	struct S {
		int a, b, c;

		this(int a, int b, int c) {
			this.a = a;
			this.b = b;
			this.c = c;
		}

		bool opEquals(const(S) s) const {
			return this.a == s.a && this.b == s.b && this.c == s.c;
		}
	}

	auto d1 = new Deque!(S)();
	auto s = S(1,2,3);
	d1.pushBack(s);
	s = S(4,5,6);
	d1.pushBack(s);
	s = S(7,8,9);
	d1.pushBack(s);
	s = S(10,11,12);
	d1.pushFront(s);

	auto store = new Store(256);

	auto tmp = toStore(store, d1);

	auto d2 = new Deque!(S)(tmp);

	assert(d1.getHeadPos() == d2.getHeadPos());
	assert(d1.getTailPos() == d2.getTailPos());
	assert(d1 == d2);
}

unittest {
	Deque!(int) d1 = new Deque!(int)([1,2,3,4,5,6]);
	d1.pushFront(-1);

	auto store = new Store(128);

	auto tmp = toStore(store,d1);

	Deque!(int) d2 = new Deque!(int)(tmp);
	assert(d1.getHeadPos() == d2.getHeadPos());
	assert(d1.getTailPos() == d2.getTailPos());
	assert(d1 == d2);
}

unittest {
	Deque!(int) d1 = new Deque!(int)([1,2,3,4,5,6]);

	auto store = new Store(128);

	auto tmp = toStore(store,d1);

	Deque!(int) d2 = new Deque!(int)(tmp);
	assert(d1.getHeadPos() == d2.getHeadPos());
	assert(d1.getTailPos() == d2.getTailPos());
	assert(d1 == d2);
}

version(staging) {
void main() {
}
}

