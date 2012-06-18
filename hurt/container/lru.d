module hurt.container.lru;

import hurt.container.fdlist;
import hurt.container.map;
import hurt.container.isr;
import hurt.exception.exception;
import hurt.string.formatter;
import hurt.util.pair;
import hurt.util.slog;

class LRU(T,S) {
	FDoubleLinkedList!(Pair!(T,S)) queue;
	Map!(T, Iterator!(Pair!(T,S))) map;
	const size_t size;
	size_t function(S sizeFrom) sizeFunc;

	this(size_t size) {
		this.size = size;
		this.queue = new FDoubleLinkedList!(Pair!(T,S))();
		this.map = new Map!(T, Iterator!(Pair!(T,S)))(ISRType.HashTable);
		this.sizeFunc = null;
	}

	this(size_t size, size_t function(S sizeFrom) sizeFunc) {
		this(size);
		this.sizeFunc = sizeFunc;
	}

	public bool contains(T key) {
		MapItem!(T, Iterator!(Pair!(T,S))) mi = this.map.find(key);
		return mi !is null;
	}

	public S get(T key) {
		MapItem!(T, Iterator!(Pair!(T,S))) mi = this.map.find(key);
		enforce(mi !is null, 
			"object can't be accessed because it is not present");
		Iterator!(Pair!(T,S)) it = mi.getData();
		S ret = (*it).second;
		this.queue.remove(it);
		this.queue.pushFront(Pair!(T,S)(key,ret));
		this.map.insert(key, this.queue.begin());
		return ret;
	}

	public void insert(T key, S data) {
		if(this.queue.getSize() >= size) {
			if(this.sizeFunc !is null) {
				auto it = this.queue.end();
				for(; it.isValid(); it--) {
					if(this.sizeFunc((*it).second) >= this.sizeFunc(data)) {
						auto tmp = this.queue.remove(it);
						this.map.remove(tmp.first);
						goto done;
					}
				}
				assert(false, "could not find something of right size");
			} else {
				Pair!(T,S) p = this.queue.popBack();
				this.map.remove(p.first);
			}
		}
		done:
		this.queue.pushFront(Pair!(T,S)(key, data));
		this.map.insert(key, this.queue.begin());
	}	

	public void remove(T key) {
		MapItem!(T, Iterator!(Pair!(T,S))) mi = this.map.find(key);
		enforce(mi !is null, 
			"object can't be accessed because it is not present");
		Iterator!(Pair!(T,S)) it = mi.getData();
		this.queue.remove(it);
		this.map.remove(key);
	}

	public size_t getSize() const {
		return this.queue.getSize();
	}

	public bool isEmpty() const {
		return this.queue.getSize() == 0;
	}

}

unittest {
	LRU!(int,string) lru = new LRU!(int,string)(8);
	lru.insert(1, "eins");
	assert(lru.get(1) == "eins");
	lru.insert(2, "zwei");
	assert(lru.get(2) == "zwei");
	lru.insert(3, "drei");
	assert(lru.get(3) == "drei");
	lru.insert(4, "vier");
	assert(lru.get(4) == "vier");
	lru.insert(5, "fuenf");
	assert(lru.get(5) == "fuenf");
	lru.insert(6, "sechs");
	assert(lru.get(6) == "sechs");
	lru.insert(7, "sieben");
	assert(lru.get(7) == "sieben");
	lru.insert(8, "acht");
	assert(lru.get(8) == "acht");
	lru.insert(9, "neun");
	assert(lru.get(9) == "neun");
	assert(!lru.contains(1));
	for(int i = 2; i < 10; i++) {
		assert(lru.contains(i));
	}
	assert(lru.getSize() == 8);
	lru.remove(5);
	assert(lru.getSize() == 7);
}

unittest {
	LRU!(int,string) lru = new LRU!(int,string)(8, function(string str) {
		return str.length;});
	lru.insert(1, "one");
	assert(lru.get(1) == "one");
	lru.insert(2, "zwei");
	assert(lru.get(2) == "zwei");
	lru.insert(3, "drei");
	assert(lru.get(3) == "drei");
	lru.insert(4, "vier");
	assert(lru.get(4) == "vier");
	lru.insert(5, "fuenf");
	assert(lru.get(5) == "fuenf");
	lru.insert(6, "sechs");
	assert(lru.get(6) == "sechs");
	lru.insert(7, "sieben");
	assert(lru.get(7) == "sieben");
	lru.insert(8, "acht");
	assert(lru.get(8) == "acht");
	lru.insert(9, "neun");
	assert(lru.get(9) == "neun");
	assert(lru.contains(1));
	assert(!lru.contains(2));
}

version(staging) {
void main() {
}
}
