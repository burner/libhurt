module hurt.container.deque;

import hurt.exception.outofrangeexception;
import hurt.io.stdio;
import hurt.math.mathutil;
import hurt.string.formatter;
import hurt.string.stringbuffer;
import hurt.conv.conv;
import hurt.container.iterator;

struct Iterator(T) {
	private size_t pos;
	private size_t id;
	private Deque!(T) deque;

	this(Deque!(T) deque, bool begin, size_t id) {
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
			//println(__LINE__, tmp, head, tail, this.pos > head, this.pos <= tail);
			return this.pos > head || this.pos <= tail;
		}
	}
}

public class Deque(T) {
	private T[] data;
	private long head; // insert first than move
	private long tail; // move first than insert

	public this() {
		this(16);	
	}

	public this(size_t size) {
		this.data = new T[size];
		this.head = 0;
		this.tail = 0;
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
			if(headDis < tailDis && this.head > 0) { 
				// move front headTail n
				this.moveFront(insertIdx);
				this.data[insertIdx] = data;
			} else if(headDis < tailDis && this.head == 0) { 
				// move back headTail n
				this.moveBack(insertIdx);
				this.data[insertIdx] = data;
			} else if(headDis >= tailDis && this.tail < this.data.length-1) { 
				// move back tailHead n
				this.moveBack(insertIdx);
				this.data[insertIdx] = data;
			} else if(headDis >= tailDis && this.tail == this.data.length-1) {
				// move front tailHead n
				this.moveFront(insertIdx);
				this.data[insertIdx] = data;
			} else if(headDis >= tailDis && this.tail == this.data.length-1) {
				// move front tailHead n
				this.moveBack(insertIdx);
				this.data[insertIdx] = data;
			} else {
				assert(false, format("this is a invalid case %d, %s", 
					insertIdx, this.toString()));
			}
		} else {
			if(insertIdx > this.head) { // move head left by one
				for(size_t i = this.head-1; i < insertIdx; i++) {
					this.data[i] = this.data[i+1];
				}
				this.head--;	
			} else if(insertIdx <= this.tail) { // move tail backward by one
				for(size_t i = this.tail; i > insertIdx; i--) {
					this.data[i+1] = this.data[i];
				}
				this.tail++;
			} else {
				assert(false, format("this is a invalid case %d, %s", 
					insertIdx, this.toString()));
			}
		}

		return this;
	}

	public T popFront() {
		if(this.head == this.tail)
			assert(0, "empty");
		this.head = (this.head+1) % this.data.length;
		T ret = this.data[this.head];
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
				format!(char,char)("idx %d head %d tail %d data.size %d len %d",
				idx, this.head, this.head, this.data.length, this.getSize()));
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

	public bool isEmpty() const {
		return this.head == this.tail;
	}

	public size_t getSize() const { 
		if(this.isEmpty())
			return 0;
		if(this.tail > this.head) {
			return this.tail-this.head;
		} else {
			return this.tail + (this.data.length-this.head);
		}
	}

	public void clean() {
		this.head = this.tail = 0;
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
			if(idx == this.head)
				ret.pushBack(format!(char,char)("(%d),",it));
			else if(idx == this.tail)
				ret.pushBack(format!(char,char)("{%d},",it));
			else
				ret.pushBack(format!(char,char)("%d,",it));
		}
		ret.popBack();
		ret.pushBack("]");
		return ret.getString();
	}
}

unittest {
	Deque!(int) di = new Deque!(int);
	di.pushBack(1);
	di.pushBack(3);
	di.insert(1, 2);
	assert(di[0] == 1);
	assert(di[1] == 2);
	assert(di[2] == 3);
	println(di.toString());
	di.clean();
	di.pushFront(3);
	di.pushFront(1);
	di.insert(1, 2);
	assert(di[0] == 1, di.toString());
	assert(di[1] == 2, di.toString());
	assert(di[2] == 3, di.toString());

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

	void pushBackPopFront(Deque!(int) de, int count) {
		for(int i = 0; i < count; i++) {
			de.pushBack(i);	
			for(int j = 0; j <= i; j++) {
				assert(de[j] == j);
				assert(de[-(j+1)] == i-j, format!(char,char)("j %d %d %d", 
					-(j+1), de[-(j+1)], i-j));
			}
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
		}
		assert(count == de.getSize(),
			conv!(size_t,string)(de.getSize()) ~ " " 
			~ conv!(int,string)(count));
		for(int i = 0; i < count; i++) {
			assert(i == de.popFront());
			assert(count-1-i == de.getSize(), 
				conv!(size_t,string)(de.getSize()));
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
		}
		assert(count == de.getSize(),
			conv!(size_t,string)(de.getSize()) ~ " " 
			~ conv!(int,string)(count));
		for(int i = 0; i < count; i++) {
			assert(i == de.popBack());
			assert(count-1-i == de.getSize(), 
				conv!(size_t,string)(de.getSize()));
		}
		assert(de.isEmpty());
	}

	void pushFrontPopFront(Deque!(int) de, int count) {
		for(int i = 0; i < count; i++) {
			de.pushFront(i);	
			assert(i+1 == de.getSize(), format("%d %d %s", i+1, de.getSize(), de.toString()));
			for(int j = 0; j <= i; j++) {
				assert(de[j] == i-j, format("i %d j %d %d != %d %s", i, j, de[j], i-j, 
					de.toString()));
				assert(de[-(j+1)] == j, 
					format!(char,char)("de[%d]=%d ==%d %s", 
					-(j+1), de[-(j+1)], j, de.toString()));
			}
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
		}
		assert(count == de.getSize(),
			conv!(size_t,string)(de.getSize()) ~ " " 
			~ conv!(int,string)(count));
		for(int i = 0; i < count; i++) {
			assert(count-1-i == de.popFront());
			assert(count-1-i == de.getSize(), 
				conv!(size_t,string)(de.getSize()));
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
		}
		assert(count == de.getSize(),
			conv!(size_t,string)(de.getSize()) ~ " " 
			~ conv!(int,string)(count));
		for(int i = 0; i < count; i++) {
			assert(count-1-i == de.popBack());
			assert(count-1-i == de.getSize(), 
				conv!(size_t,string)(de.getSize()));
		}
		assert(de.isEmpty());
	}

	int mul = 1;
	for(int i = 0; i < 600; i++) {
		Deque!(int) de = new Deque!(int)();
		println(__LINE__, mul * (i/10+1));
		switch(i%15) {
			case 0:
				pushBackPopFront(de, mul * (i/10+1));
				pushFrontPopBack(de, mul * (i/10+1));
				pushFrontPopFront(de, mul * (i/10+1));
				pushBackPopBack(de, mul * (i/10+1));
				assert(de.isEmpty());
				break;
			case 1:
				pushBackPopFront(de, mul * (i/10+1));
				pushFrontPopBack(de, mul * (i/10+1));
				pushBackPopBack(de, mul * (i/10+1));
				pushFrontPopFront(de, mul * (i/10+1));
				assert(de.isEmpty());
				break;
			case 2:
				pushBackPopFront(de, mul * (i/10+1));
				pushBackPopBack(de, mul * (i/10+1));
				pushFrontPopBack(de, mul * (i/10+1));
				pushFrontPopFront(de, mul * (i/10+1));
				assert(de.isEmpty());
				break;
			case 3:
				pushBackPopBack(de, mul * (i/10+1));
				pushBackPopFront(de, mul * (i/10+1));
				pushFrontPopBack(de, mul * (i/10+1));
				pushFrontPopFront(de, mul * (i/10+1));
				assert(de.isEmpty());
				break;
			case 4:
				pushBackPopBack(de, mul * (i/10+1));
				pushBackPopFront(de, mul * (i/10+1));
				pushFrontPopFront(de, mul * (i/10+1));
				pushFrontPopBack(de, mul * (i/10+1));
				assert(de.isEmpty());
				break;
			case 5:
				pushBackPopBack(de, mul * (i/10+1));
				pushFrontPopFront(de, mul * (i/10+1));
				pushBackPopFront(de, mul * (i/10+1));
				pushFrontPopBack(de, mul * (i/10+1));
				assert(de.isEmpty());
				break;
			case 6:
				pushFrontPopFront(de, mul * (i/10+1));
				pushBackPopBack(de, mul * (i/10+1));
				pushBackPopFront(de, mul * (i/10+1));
				pushFrontPopBack(de, mul * (i/10+1));
				assert(de.isEmpty());
				break;
			case 7:
				assert(de.isEmpty());
				pushFrontPopFront(de, mul * (i/10+1));
				assert(de.isEmpty());
				pushBackPopBack(de, mul * (i/10+1));
				assert(de.isEmpty());
				pushFrontPopBack(de, mul * (i/10+1));
				assert(de.isEmpty());
				pushBackPopFront(de, mul * (i/10+1));
				assert(de.isEmpty());
				break;
			case 8:
				pushFrontPopFront(de, mul * (i/10+1));
				pushFrontPopBack(de, mul * (i/10+1));
				pushBackPopBack(de, mul * (i/10+1));
				pushBackPopFront(de, mul * (i/10+1));
				assert(de.isEmpty());
				break;
			case 9:
				pushFrontPopBack(de, mul * (i/10+1));
				pushFrontPopFront(de, mul * (i/10+1));
				pushBackPopBack(de, mul * (i/10+1));
				pushBackPopFront(de, mul * (i/10+1));
				assert(de.isEmpty());
				break;
			case 10:
				pushFrontPopBack(de, mul * (i/10+1));
				pushFrontPopFront(de, mul * (i/10+1));
				pushBackPopFront(de, mul * (i/10+1));
				pushBackPopBack(de, mul * (i/10+1));
				assert(de.isEmpty());
				break;
			case 11:
				pushFrontPopBack(de, mul * (i/10+1));
				pushBackPopFront(de, mul * (i/10+1));
				pushFrontPopFront(de, mul * (i/10+1));
				pushBackPopBack(de, mul * (i/10+1));
				assert(de.isEmpty());
				break;
			case 12:
				pushBackPopFront(de, mul * (i/10+1));
				pushFrontPopBack(de, mul * (i/10+1));
				pushFrontPopFront(de, mul * (i/10+1));
				pushBackPopBack(de, mul * (i/10+1));
				assert(de.isEmpty());
				break;
			case 13:
				pushBackPopFront(de, mul * (i/10+1));
				pushFrontPopBack(de, mul * (i/10+1));
				pushBackPopBack(de, mul * (i/10+1));
				pushFrontPopFront(de, mul * (i/10+1));
				assert(de.isEmpty());
				break;
			case 14:
				pushBackPopFront(de, mul * (i/10+1));
				pushBackPopBack(de, mul * (i/10+1));
				pushFrontPopBack(de, mul * (i/10+1));
				pushFrontPopFront(de, mul * (i/10+1));
				assert(de.isEmpty());
				break;
			default:
				assert(false, "not reachable " ~ conv!(int,string)(i));
		}
	}

	debug {
		println("deque test done");
	}
}

void main() {
	Deque!(int) d1 = new Deque!(int)();
}
