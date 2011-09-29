module hurt.container.deque;

import hurt.io.stdio;
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
		this.head = (this.head-1) % this.data.length;
	}

	void pushBack(T toPush) {
		if((this.tail+1) % this.data.length == this.head) {
			this.growCapacity();
		}	
		this.tail = (this.tail+1) % this.data.length;
		this.data[this.tail] = toPush;
	}

	bool isEmpty() const {
		return this.head == this.tail;
	}

	size_t getSize() const { 
		if(this.tail >= this.head) {
			return this.tail-this.head;
		} else {
			return this.tail + (this.data.length-this.head);
		}
	}

	void print() {
		println(this.data, " ", this.head, " ", this.tail);
	}
}

unittest {
	void pushBackPopFront(Deque!(int) de, int count) {
		for(int i = 0; i < count; i++) {
			de.pushBack(i);	
			assert(i+1 == de.getSize());
		}
		for(int i = 0; i < count; i++) {
			assert(i == de.popFront());
			assert(count-1-i == de.getSize(), 
				conv!(size_t,string)(de.getSize()));
		}
		assert(de.isEmpty());
	}

	void pushFrontPopBack(Deque!(int) de, int count) {
		for(int i = 0; i < count; i++) {
			de.pushFront(i);	
			assert(i+1 == de.getSize(),
				conv!(size_t,string)(de.getSize()) ~ " " 
				~ conv!(int,string)(i+1));
		}
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
		}
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
		}
		for(int i = 0; i < count; i++) {
			assert(count-1-i == de.popBack());
			assert(count-1-i == de.getSize(), 
				conv!(size_t,string)(de.getSize()));
		}
		assert(de.isEmpty());
	}

	for(int i = 0; i < 16; i++) {
		Deque!(int) de = new Deque!(int)();
		println(__LINE__, i);
		switch(i) {
			case 0:
				pushBackPopFront(de, 10 * (i+1));
				pushFrontPopBack(de, 10 * (i+1));
				pushFrontPopFront(de, 10 * (i+1));
				pushBackPopBack(de, 10 * (i+1));
				break;
			case 1:
				pushBackPopFront(de, 10 * (i+1));
				pushFrontPopBack(de, 10 * (i+1));
				pushBackPopBack(de, 10 * (i+1));
				pushFrontPopFront(de, 10 * (i+1));
				break;
			case 2:
				pushBackPopFront(de, 10 * (i+1));
				pushBackPopBack(de, 10 * (i+1));
				pushFrontPopBack(de, 10 * (i+1));
				pushFrontPopFront(de, 10 * (i+1));
				break;
			case 3:
				pushBackPopBack(de, 10 * (i+1));
				pushBackPopFront(de, 10 * (i+1));
				pushFrontPopBack(de, 10 * (i+1));
				pushFrontPopFront(de, 10 * (i+1));
				break;
			case 4:
				pushBackPopBack(de, 10 * (i+1));
				pushBackPopFront(de, 10 * (i+1));
				pushFrontPopFront(de, 10 * (i+1));
				pushFrontPopBack(de, 10 * (i+1));
				break;
			case 5:
				pushBackPopBack(de, 10 * (i+1));
				pushFrontPopFront(de, 10 * (i+1));
				pushBackPopFront(de, 10 * (i+1));
				pushFrontPopBack(de, 10 * (i+1));
				break;
			case 6:
				pushFrontPopFront(de, 10 * (i+1));
				pushBackPopBack(de, 10 * (i+1));
				pushBackPopFront(de, 10 * (i+1));
				pushFrontPopBack(de, 10 * (i+1));
				break;
			case 7:
				pushFrontPopFront(de, 10 * (i+1));
				pushBackPopBack(de, 10 * (i+1));
				pushFrontPopBack(de, 10 * (i+1));
				pushBackPopFront(de, 10 * (i+1));
				break;
			case 8:
				pushFrontPopFront(de, 10 * (i+1));
				pushFrontPopBack(de, 10 * (i+1));
				pushBackPopBack(de, 10 * (i+1));
				pushBackPopFront(de, 10 * (i+1));
				break;
			case 9:
				pushFrontPopBack(de, 10 * (i+1));
				pushFrontPopFront(de, 10 * (i+1));
				pushBackPopBack(de, 10 * (i+1));
				pushBackPopFront(de, 10 * (i+1));
				break;
			case 10:
				pushFrontPopBack(de, 10 * (i+1));
				pushFrontPopFront(de, 10 * (i+1));
				pushBackPopFront(de, 10 * (i+1));
				pushBackPopBack(de, 10 * (i+1));
				break;
			case 11:
				pushFrontPopBack(de, 10 * (i+1));
				pushBackPopFront(de, 10 * (i+1));
				pushFrontPopFront(de, 10 * (i+1));
				pushBackPopBack(de, 10 * (i+1));
				break;
			case 13:
				pushBackPopFront(de, 10 * (i+1));
				pushFrontPopBack(de, 10 * (i+1));
				pushFrontPopFront(de, 10 * (i+1));
				pushBackPopBack(de, 10 * (i+1));
				break;
			case 14:
				pushBackPopFront(de, 10 * (i+1));
				pushFrontPopBack(de, 10 * (i+1));
				pushBackPopBack(de, 10 * (i+1));
				pushFrontPopFront(de, 10 * (i+1));
				break;
			case 15:
				pushBackPopFront(de, 10 * (i+1));
				pushBackPopBack(de, 10 * (i+1));
				pushFrontPopBack(de, 10 * (i+1));
				pushFrontPopFront(de, 10 * (i+1));
				break;
			default:
				assert(false, "not reachable");
		}
	}

	debug {
		println("deque test done");
	}
}

void main() {
	Deque!(int) d1 = new Deque!(int)();
}
