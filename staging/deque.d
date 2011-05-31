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
		this.data.length = this.data.length * 2;
	}

	T getFront() {
		return this.data[this.head];
	}

	T getBack() {
		return this.data[this.tail];
	}

	T popFront() {
		if(this.empty())
			assert(0);
		this.head = (this.head+1) % this.data.length;
		T ret = this.data[this.head];
		this.data[this.head] = T.init;
		return ret;
	}

	T popBack() {
		if(this.empty())
			assert(0);
		T ret = this.data[this.tail];
		this.data[this.tail] = T.init;
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
		return this.head == this.tail && this.head >= this.tail;
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
		de.print();
	}
}
