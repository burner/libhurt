module hurt.container.deque;

import std.stdio;
import hurt.conv.conv;

class Iterator(T) {
	private size_t pos;
	Deque!(T) deque;
	
	this(Deque!(T) deque, bool begin) {
		this.deque = deque;
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
		//writeln("deref ", this.pos, " ", this.deque.getValue(this.pos));
		return this.deque.getValue(this.pos);
	}

	public bool isValid() const {
		size_t head = this.deque.getHeadPos();
		size_t tail = this.deque.getTailPos();
		//writeln("valid ", this.pos, " ",head, " ", tail);
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
		this(4);	
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
		return new Iterator!(T)(this, true);
	}

	Iterator!(T) end() {
		return new Iterator!(T)(this, false);
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

	bool empty() const {
		return this.head == this.tail;
	}

	size_t getSize() const { 
		if(this.tail > this.head) {
			return this.tail-this.head;
		} else {
			return this.tail + (this.data.length-this.head);
		}
	}

	void print() {
		writeln(this.data, " ", this.head, " ", this.tail);
	}
}

void main() {
	Deque!(int) de = new Deque!(int)();
	de.pushBack(10);
	de.pushBack(11);
	de.pushBack(12);
	writeln("size ", de.getSize());
	de.pushFront(9);
	de.pushFront(8);
	de.pushFront(7);
	de.pushFront(6);
	de.pushBack(13);
	writeln("size ", de.getSize());
	de.pushFront(5);
	de.pushFront(4);
	de.pushFront(3);
	de.pushFront(2);
	writeln("size ", de.getSize());
	de.pushFront(1);
	de.pushFront(0);
	de.pushFront(-1);
	de.pushFront(-2);
	writeln("size ", de.getSize());
	de.pushFront(-3);
	de.pushBack(14);
	de.pushBack(15);
	writeln("size ", de.getSize());
	auto it = de.begin();
	writeln(__LINE__, it.isValid());
	for(; it.isValid(); it++) {
		write(*it, " ");
	}
	writeln();
	it = de.end();
	for(; it.isValid(); it--) {
		write(*it, " ");
	}
	writeln();
	//for(int i = 16; i < 23; i++)
	//	de.pushBack(i);
	//de.print();
	//writeln("pop", de.empty());
	//for(int i = 0; i < 5; i++)
	//	writeln(de.popBack());
	//writeln(__LINE__);
	//while(!de.empty()) {
	//	writeln(de.popFront());
	//}
	Deque!(int) de2 = new Deque!int();
	de2.pushFront(1);
	de2.pushFront(2);
	de2.pushFront(3);
	de2.print();
	writeln(de2.popBack());
	writeln(de2.popBack());
	de2.print();
	de2.pushFront(4);
	de2.pushFront(5);
	de2.print();
	writeln(de2.popBack());
	writeln(de2.popBack());
}
