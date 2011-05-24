module hurt.container.deque;

import std.stdio;

class Deque(T) {
	private T[] data;
	private size_t head, tail;

	this() {
		this(16);	
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

	bool empty() const {
		return this.head == this.tail;
	}

	int opApply(int delegate(ref T value) dg) {
		int result;
		for(size_t i = this.head; i < this.tail && result is 0; 
				i = (i+1) % this.data.length) {
			result = dg(this.data[i]);
		}
		return result;
	}

	T popFront() {assert(0, "Not implementet");}
	T popBack() {assert(0, "Not implementet");}

	void pushFront(T toPush) {assert(0, "Not implementet");}

	void pushBack(T toPush) {
		size_t newHead = (this.head-1) % this.data.length;
		if(newHead == this.tail) {
			this.growCapacity();
			newHead = (this.head-1) % this.data.length;
		}
		this.data[newHead] = toPush;
		this.head = newHead;
	}

	size_t getSize() const { return 0; }
}

void main() {
	Deque!(int) de = new Deque!(int)();
	de.pushBack(10);
	de.pushBack(11);
	de.pushBack(12);
	foreach(it;de) {
		writeln(it);
	}
}
