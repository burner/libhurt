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
	size_t size;

	this(size_t size) {
		this.size = size;
		this.queue = new FDoubleLinkedList!(Pair!(T,S))();
		this.map = new Map!(T, Iterator!(Pair!(T,S)))(ISRType.HashTable);
	}

	public bool contains(T key) {
		MapItem!(T, Iterator!(Pair!(T,S))) mi = this.map.find(key);
		return mi !is null;
	}

	public S get(T key) {
		MapItem!(T, Iterator!(Pair!(T,S))) mi = this.map.find(key);
		enforce(mi !is null, 
			"object can't be accessed because it is not placed");
		Iterator!(Pair!(T,S)) it = mi.getData();
		S ret = (*it).second;
		this.queue.remove(it);
		this.queue.pushFront(Pair!(T,S)(key,ret));
		this.map.insert(key, this.queue.begin());
		return ret;
	}

	public void insert(T key, S data) {
		if(this.queue.getSize() >= size) {
			Pair!(T,S) p = this.queue.popBack();
			this.map.remove(p.first);
		}
		this.queue.pushFront(Pair!(T,S)(key, data));
		this.map.insert(key, this.queue.begin());
	}	

}

version(staging) {
void main() {
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
}
}
