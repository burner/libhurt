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
		if(begin) {
			this.pos = this.deque.getHeadPos();
			this.pos++;
		} else {
			this.pos = this.deque.getTailPos();
		}
	}

	public void opUnary(string s)() if(s == "++") {
		this.pos++;
		if(this.pos >= this.deque.getLength()) {
			this.pos = 0;
		}
	}

	public void opUnary(string s)() if(s == "--") {
		this.pos--;
		if(this.pos > this.deque.getLength()) {
			this.pos = this.deque.getLength-1;
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
		if(tail > head) {
			return this.pos > head && this.pos < tail;
		} else {
			return !(this.pos <= head && this.pos > tail);
		}
	}
}

class Deque(T) {
	private T[] data;
	private long head, tail;

	this() {
		this(16);	
	}

	this(size_t size) {
		this.data = new T[size];
		this.head = 0;
		this.tail = 0;
	}

	protected size_t getHeadPos() const {
		return this.head;
	}

	protected T getValue(size_t idx) {
		return this.data[idx];
	}

	protected size_t getTailPos() const {
		return this.tail;
	}

	protected size_t getLength() const {
		return this.data.length;
	}

	Iterator!(T) begin() {
		return Iterator!(T)(this, true, size_t.max);
	}

	Iterator!(T) end() {
		return Iterator!(T)(this, false, size_t.max);
	}

	private void growCapacity() {
		T[] n = new T[this.data.length];
		size_t oldNLength = n.length;
		if(this.tail > this.head) {
			n = this.data[0..this.tail+1] ~ n ~ this.data[$-this.head..$];
		} else {
			n = this.data[0..this.head+1] ~ n ~ this.data[this.tail+1..$];
			this.head = this.head + oldNLength +1;
		}
		this.data = n;
	}

	T getFront() {
		return this.data[this.head];
	}

	T getBack() {
		return this.data[this.tail];
	}

	T popFront() {
		if(this.head == this.tail)
			assert(0, "empty");
		this.head = (this.head+1) % this.data.length;
		T ret = this.data[this.head];
		return ret;
	}

	T popBack() {
		if(this.head == this.tail)
			assert(0, "empty");
		T ret = this.data[this.tail];
		this.tail = this.tail-1;
		if(this.tail > this.data.length)
			this.tail = this.data.length-1;
		return ret;
	}

	void pushFront(T toPush) {
		if((this.head-1) % this.data.length == this.tail) {
			this.growCapacity();
		}	
		this.data[this.head] = toPush;
		//this.head = (this.head-1) % this.data.length;
		if((this.head-1) < 0) {
			this.head = this.data.length-1;
		} else {
			this.head--;	
		}
	}

	void pushBack(T toPush) {
		if((this.tail+1) % this.data.length == this.head) {
			this.growCapacity();
		}	
		this.tail = (this.tail+1) % this.data.length;
		this.data[this.tail] = toPush;
	}

	T opIndex(long idx) {
		//println(__LINE__, this.head, this.tail);
		if(idx > 0 &&  idx >= this.getSize()) {
			throw new OutOfRangeException(
				format!(char,char)("idx %d head %d tail %d data.size %d len %d",
				idx, this.head, this.head, this.data.length, this.getSize()));
		} else if(idx < 0 &&  abs(idx)-1 > this.getSize()) {
			throw new OutOfRangeException(
				format!(char,char)("idx %d head %d tail %d data.size %d len %d",
				idx, this.head, this.head, this.data.length, this.getSize()));
		}

		if(idx >= 0) {
			return this.data[(this.head + idx + 1) % this.data.length];
		} else {
			if(this.head < this.tail) {
				// plus one because the tail moves after insert
				return this.data[this.tail - abs(idx) + 1];
			} else {
				if(this.tail - abs(idx) + 1 < 0) {
					long tmp = abs(this.tail - abs(idx) +1);
					return this.data[$ - tmp];
				} else {
					return this.data[this.tail - abs(idx) + 1];
				}

			}
		}
		assert(false, "not reachable");
	}

	bool isEmpty() const {
		return this.head == this.tail;
	}

	size_t getSize() const { 
		if(this.isEmpty())
			return 0;
		if(this.tail > this.head) {
			return this.tail-this.head;
		} else {
			return this.tail + (this.data.length-this.head);
		}
	}

	void print() {
		hurt.io.stdio.print(this.head, this.tail, this.data.length, ":");
		foreach(it; this.data)
			printf("%d ", it);
		println();
	}

	override string toString() {
		StringBuffer!(char) ret = new StringBuffer!(char)(this.data.length*2);
		ret.pushBack(format!(char,char)("deque - %d %d %d [", this.head, 
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
	Deque!(int) deIT = new Deque!(int);
	deIT.pushBack(10);
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
		}
		assert(count == de.getSize(),
			conv!(size_t,string)(de.getSize()) ~ " " 
			~ conv!(int,string)(count));
		for(int i = 0; i < count; i++) {
			assert(i == de.popFront());
			/*assert(count-1-i == de.getSize(), 
				conv!(size_t,string)(de.getSize()));*/
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
			assert(i+1 == de.getSize());
			for(int j = 0; j <= i; j++) {
				assert(de[j] == i-j);
				assert(de[-(j+1)] == j, 
					format!(char,char)("de[%d]=%d ==%d %s", 
					-(j+1), de[-(j+1)], j, de.toString()));
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
	for(int i = 0; i < 400; i++) {
		Deque!(int) de = new Deque!(int)();
		println(__LINE__, i);
		switch(i%15) {
			case 0:
				pushBackPopFront(de, mul * (i+1));
				pushFrontPopBack(de, mul * (i+1));
				pushFrontPopFront(de, mul * (i+1));
				pushBackPopBack(de, mul * (i+1));
				assert(de.isEmpty());
				break;
			case 1:
				pushBackPopFront(de, mul * (i+1));
				pushFrontPopBack(de, mul * (i+1));
				pushBackPopBack(de, mul * (i+1));
				pushFrontPopFront(de, mul * (i+1));
				assert(de.isEmpty());
				break;
			case 2:
				pushBackPopFront(de, mul * (i+1));
				pushBackPopBack(de, mul * (i+1));
				pushFrontPopBack(de, mul * (i+1));
				pushFrontPopFront(de, mul * (i+1));
				assert(de.isEmpty());
				break;
			case 3:
				pushBackPopBack(de, mul * (i+1));
				pushBackPopFront(de, mul * (i+1));
				pushFrontPopBack(de, mul * (i+1));
				pushFrontPopFront(de, mul * (i+1));
				assert(de.isEmpty());
				break;
			case 4:
				pushBackPopBack(de, mul * (i+1));
				pushBackPopFront(de, mul * (i+1));
				pushFrontPopFront(de, mul * (i+1));
				pushFrontPopBack(de, mul * (i+1));
				assert(de.isEmpty());
				break;
			case 5:
				pushBackPopBack(de, mul * (i+1));
				pushFrontPopFront(de, mul * (i+1));
				pushBackPopFront(de, mul * (i+1));
				pushFrontPopBack(de, mul * (i+1));
				assert(de.isEmpty());
				break;
			case 6:
				pushFrontPopFront(de, mul * (i+1));
				pushBackPopBack(de, mul * (i+1));
				pushBackPopFront(de, mul * (i+1));
				pushFrontPopBack(de, mul * (i+1));
				assert(de.isEmpty());
				break;
			case 7:
				assert(de.isEmpty());
				pushFrontPopFront(de, mul * (i+1));
				assert(de.isEmpty());
				pushBackPopBack(de, mul * (i+1));
				assert(de.isEmpty());
				pushFrontPopBack(de, mul * (i+1));
				assert(de.isEmpty());
				pushBackPopFront(de, mul * (i+1));
				assert(de.isEmpty());
				break;
			case 8:
				pushFrontPopFront(de, mul * (i+1));
				pushFrontPopBack(de, mul * (i+1));
				pushBackPopBack(de, mul * (i+1));
				pushBackPopFront(de, mul * (i+1));
				assert(de.isEmpty());
				break;
			case 9:
				pushFrontPopBack(de, mul * (i+1));
				pushFrontPopFront(de, mul * (i+1));
				pushBackPopBack(de, mul * (i+1));
				pushBackPopFront(de, mul * (i+1));
				assert(de.isEmpty());
				break;
			case 10:
				pushFrontPopBack(de, mul * (i+1));
				pushFrontPopFront(de, mul * (i+1));
				pushBackPopFront(de, mul * (i+1));
				pushBackPopBack(de, mul * (i+1));
				assert(de.isEmpty());
				break;
			case 11:
				pushFrontPopBack(de, mul * (i+1));
				pushBackPopFront(de, mul * (i+1));
				pushFrontPopFront(de, mul * (i+1));
				pushBackPopBack(de, mul * (i+1));
				assert(de.isEmpty());
				break;
			case 12:
				pushBackPopFront(de, mul * (i+1));
				pushFrontPopBack(de, mul * (i+1));
				pushFrontPopFront(de, mul * (i+1));
				pushBackPopBack(de, mul * (i+1));
				assert(de.isEmpty());
				break;
			case 13:
				pushBackPopFront(de, mul * (i+1));
				pushFrontPopBack(de, mul * (i+1));
				pushBackPopBack(de, mul * (i+1));
				pushFrontPopFront(de, mul * (i+1));
				assert(de.isEmpty());
				break;
			case 14:
				pushBackPopFront(de, mul * (i+1));
				pushBackPopBack(de, mul * (i+1));
				pushFrontPopBack(de, mul * (i+1));
				pushFrontPopFront(de, mul * (i+1));
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
