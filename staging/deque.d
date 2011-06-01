module hurt.container.deque;

import std.stdio;
import hurt.conv.conv;

class Deque(T) {
	private T[] data;
	private size_t head, tail;

	this() {
		this(4);	
	}

	this(size_t size) {
		this.data = new T[size];
		this.head = 0;
		this.tail = 0;
	}

	private void growCapacity() {
		T[] n = new T[this.data.length];
		writeln(__LINE__, " ", this.data, " ",this.head, " ", this.tail);
		if(this.tail > this.head) {
			n = this.data[0..this.tail+1] ~ n ~ this.data[$-this.head..$];
		} else {
			n = this.data[0..this.head+1] ~ n ~ this.data[$-this.tail..$];
			this.head = n.length-this.head;
		}
		writeln(__LINE__, " ", n," ", head," ", tail);
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
		this.tail = (this.tail-1) % this.data.length;
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

	size_t getSize() const { return 0; }

	void print() {
		writeln(this.data, " ", this.head, " ", this.tail);
	}
}

void main() {
	Deque!(int) de = new Deque!(int)();
	de.pushBack(10);
	de.pushBack(11);
	de.pushBack(12);
	de.pushFront(9);
	de.pushFront(8);
	de.pushFront(7);
	de.pushFront(6);
	de.pushBack(13);
	writeln("pop", de.empty());
	while(!de.empty()) {
		writeln(de.popFront());
	}
}
