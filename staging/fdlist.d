module hurt.container.fdlist;

import hurt.container.iterator;
import hurt.container.stack;
import hurt.string.formatter;
import hurt.util.slog;
import hurt.io.stdio;
import hurt.exception.outofrangeexception;

public class FDoubleLinkedList(T) : Iterable!(T) {
	private struct Item(T) {
		T item;
		long prev, next;

		this(long prev, long next) {
			this.prev = prev;
			this.next = next;
		}

		this(T item, long prev, long next) {
			this.item = item;
			this.prev = prev;
			this.next = next;
		}
	}

	private Item!(T)[] items;
	private Stack!(size_t) free;

	private long frontIt, backIt;

	this() {
		this.items = null;	
		this.free = null;	
		this.grow();
		this.frontIt = -1;
		this.backIt = -1;
	}

	public bool isEmpty() const {
		return this.free.getSize() == this.items.length;
	}

	private size_t nextPtr() {
		if(this.free.isEmpty()) {
			this.grow();
		}

		return this.free.pop();
	}

	public void insert(size_t idx, T item, bool before = false) {
		this.checkIdx!(__FILE__,__LINE__)(idx);
		idx = this.getIdx(idx);

		if(this.getSize() == 0 || (this.frontIt == idx && before)) {
			this.pushFront(item);
			return;
		}

		if(this.backIt == idx && !before) {
			this.pushBack(item);
			return;
		}

		size_t itemPtr = this.nextPtr();
		this.items[itemPtr].item = item;

		if(before) {
			size_t pr = this.items[idx].prev;	
			this.items[pr].next = itemPtr;
			this.items[itemPtr].prev = pr;
			this.items[itemPtr].next = idx;
			this.items[idx].prev = itemPtr;
		} else {
			size_t ne = this.items[idx].next;	
			this.items[ne].prev = itemPtr;
			this.items[itemPtr].next = ne;
			this.items[itemPtr].prev = idx;
			this.items[idx].next = itemPtr;
		}
	}

	public void pushFront(T item) {
		if(this.isEmpty()) {
			size_t itemPtr = this.nextPtr();
			this.items[itemPtr].item = item;
			this.items[itemPtr].prev = -1;
			this.items[itemPtr].next = -1;
			this.frontIt = this.backIt = itemPtr;
		} else {
			size_t itemPtr = this.nextPtr();
			this.items[this.frontIt].prev = itemPtr;
			this.items[itemPtr].next = this.frontIt;
			this.items[itemPtr].prev = -1;
			this.items[itemPtr].item = item;
			this.frontIt = itemPtr;
		}
	}

	public void pushBack(T item) {
		if(this.isEmpty()) {
			size_t itemPtr = this.nextPtr();
			this.items[itemPtr].item = item;
			this.items[itemPtr].prev = -1;
			this.items[itemPtr].next = -1;
			this.frontIt = this.backIt = itemPtr;
		} else {
			size_t itemPtr = this.nextPtr();
			this.items[this.backIt].next = itemPtr;
			this.items[itemPtr].prev = backIt;
			this.items[itemPtr].next = -1;
			this.items[itemPtr].item = item;
			this.backIt = itemPtr;
		}
	}

	public T popFront() {
		if(this.isEmpty()) {
			throw new OutOfRangeException("can't popBack from empty list");
		}

		long f = this.frontIt;
		long p = this.items[f].next;
		if(p != -1) {
			this.items[p].prev = -1;
		}
		this.items[f].next = -1;
		this.items[f].prev = -1;

		this.frontIt = p;

		this.free.push(f);
		return this.items[f].item;
	}

	public T popBack() {
		if(this.isEmpty()) {
			throw new OutOfRangeException("can't popBack from empty list");
		}

		long b = this.backIt;
		long p = this.items[b].prev;
		if(p != -1) {
			this.items[p].next = -1;
		}
		this.items[b].next = -1;
		this.items[b].prev = -1;

		this.backIt = p;

		this.free.push(b);
		return this.items[b].item;
	}

	private bool checkIdx(string file, int line)(size_t idx) const {
		if(idx >= this.getSize()) {
			throw new OutOfRangeException(format(
				"out of range with idx %u of %u" ~
				" at %s:%d", idx, this.getSize(), file, line));
		} else {
			return true;
		}
	}

	public size_t getIdx(size_t cnt) const {
		this.checkIdx!(__FILE__,__LINE__)(cnt);
		long it = this.frontIt;
		size_t i;
		for(i = 0; i < cnt; i++) {
			it = this.items[it].next;
		}
		
		return it;
	}

	public T get(size_t idx) {
		this.checkIdx!(__FILE__,__LINE__)(idx);
		
		return this.items[this.getIdx(idx)].item;
	}

	public void debugPrint() const {
		foreach(size_t idx, Item!(T) it; this.items) {
			if(idx % 6 == 0) {
				println();
			}
			printf("(%d %d), ", it.prev, it.next);
		}
		println();
	}

	private void grow() {
		size_t oldItemsSize;
		if(this.items is null) {
			this.items = new Item!(T)[16];
			oldItemsSize = 0;
		} else {
			oldItemsSize = this.items.length;
			this.items.length = this.items.length*2;
		}

		for(size_t i = oldItemsSize; i < this.items.length; i++) {
			this.items[i].next = -1;
			this.items[i].prev = -1;
		}

		if(this.free is null) {
			this.free = new Stack!(size_t)();
		}

		for(size_t i = oldItemsSize; i < this.items.length; i++) {
			this.free.push(i);
		}
	}

	public size_t getSize() const {
		return this.items.length - this.free.getSize();
	}

	public size_t getCapacity() const {
		return this.free.getSize();
	}

	int opApply(int delegate(ref size_t,ref T) dg) {
		return 0;
	}

	int opApply(int delegate(ref T) dg) {
		return 0;
	}
}

unittest {
	FDoubleLinkedList!(int) fdll = new FDoubleLinkedList!(int)();
	for(int i = 0; i < 10; i++) {
		fdll.pushFront(i);
	}
	fdll.insert(9, -2, true);
	assert(fdll.get(9) == -2);
	assert(fdll.getSize() == 11);
	fdll.insert(10, -6);
	assert(fdll.get(11) == -6);
	assert(fdll.getSize() == 12);
}

unittest {
	FDoubleLinkedList!(int) fdll = new FDoubleLinkedList!(int)();
	for(int i = 0; i < 10; i++) {
		fdll.pushFront(i);
	}
	fdll.insert(5, -2, true);
	assert(fdll.get(5) == -2);
	assert(fdll.getSize() == 11);
	fdll.insert(5, -5);
	assert(fdll.get(6) == -5);
	assert(fdll.getSize() == 12);
}

unittest {
	FDoubleLinkedList!(int) fdll = new FDoubleLinkedList!(int)();
	for(int i = 0; i < 10; i++) {
		fdll.pushFront(i);
	}
	fdll.insert(0, -2, true);
	fdll.insert(0, -1);
	assert(fdll.get(0) == -2);
	assert(fdll.get(1) == -1);
	assert(fdll.getSize() == 12);
}

unittest {
	FDoubleLinkedList!(int) fdll = new FDoubleLinkedList!(int)();
	for(int i = 0; i < 32; i++) {
		fdll.pushFront(i);
		for(int j = 0; j < i; j++) {
			assert(fdll.get(i-j) == j, format("%d != %d", fdll.get(j), j));	
		}
	}
	assert(fdll.getSize() == 32);
	assert(fdll.getCapacity() == 0);
}

unittest {
	FDoubleLinkedList!(int) fdll = new FDoubleLinkedList!(int)();
	for(int i = 0; i < 32; i++) {
		fdll.pushBack(i);
		for(int j = 0; j < i; j++) {
			assert(fdll.get(j) == j);	
		}
	}
	assert(fdll.getSize() == 32);
	assert(fdll.getCapacity() == 0);
}

unittest {
	FDoubleLinkedList!(int) fdll = new FDoubleLinkedList!(int)();
	assert(fdll.getSize() == 0);
	assert(fdll.getCapacity() == 16);
	assert(fdll.isEmpty());
	fdll.pushBack(66);
	assert(fdll.get(0) == 66);
	fdll.pushBack(55);
	assert(fdll.get(0) == 66);
	assert(fdll.get(1) == 55);
	fdll.pushBack(44);
	assert(fdll.get(0) == 66);
	assert(fdll.get(1) == 55);
	assert(fdll.get(2) == 44);

	assert(fdll.popBack() == 44);
	assert(fdll.getSize() == 2);
	assert(fdll.get(0) == 66);
	assert(fdll.get(1) == 55);
	assert(fdll.popBack() == 55);
	assert(fdll.get(0) == 66);
	assert(fdll.popBack() == 66);
	assert(fdll.getSize() == 0);
	assert(fdll.isEmpty());

	fdll.pushFront(66);
	assert(fdll.get(0) == 66);
	fdll.pushFront(55);
	assert(fdll.get(1) == 66);
	assert(fdll.get(0) == 55);
	fdll.pushFront(44);
	assert(fdll.get(2) == 66);
	assert(fdll.get(1) == 55);
	assert(fdll.get(0) == 44);

	assert(fdll.popFront() == 44);
	assert(fdll.getSize() == 2);
	assert(fdll.get(1) == 66);
	assert(fdll.get(0) == 55);
	assert(fdll.popFront() == 55);
	assert(fdll.get(0) == 66);
	assert(fdll.popFront() == 66);
	assert(fdll.getSize() == 0);
	assert(fdll.isEmpty());
}

version(staging) {
void main() {
}
}
