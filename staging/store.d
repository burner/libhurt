module hurt.container.store;

import hurt.container.multiset;
import hurt.container.mapset;
import hurt.container.set;
import hurt.container.isr;
import hurt.string.stringbuffer;
import hurt.util.slog;

struct strPtr(T) {
	Store!T store;

	public size_t base;
	public size_t size;

	this(Store!T store, size_t base, size_t size) {
		this.store = store;
		this.base = base;
		this.size = size;
	}

	size_t getBase() const {
		return this.base;
	}

	size_t getSize() const {
		return this.size;
	}

	void setSize(size_t size) {
		this.size = size;
	}

	hash_t toHash() const nothrow @safe {
		return this.base;
	}

	int opCmp(const strPtr!T i) const {
		if(this.toHash() > i.toHash())
			return 1;
		else if(this.toHash() < i.toHash())
			return -1;
		else
			return 0;
	}

	bool opEquals(const strPtr!T i) const {
		return i.toHash() == this.toHash();
	}

	bool isValid() const {
		return this.size > 0;
	}
}

struct StorePair(T) {
	private size_t size;
	private strPtr!T ptr;

	this(size_t size, strPtr!T ptr) {
		this.size = size;
		this.ptr = ptr;
	}

	this(size_t size) {
		this.size = size;
	}

	hash_t toHash() const nothrow @safe {
		return cast(hash_t)this.size;
	}

	int opCmp(StorePair!T i) const {
		if(this.toHash() > i.toHash())
			return 1;
		else if(this.toHash() < i.toHash())
			return -1;
		else
			return 0;
	}

	bool opEquals(strPtr!T i) const {
		return i.toHash() == this.toHash();
	}

	strPtr!T getPtr() {
		return this.ptr;
	}
}

class Store(T) {
	private T[] store;
	private size_t low;
	private bool growable;

	MapSet!(size_t,strPtr!T) storeObjOfSize;
	Set!(strPtr!(T)) storePointer;

	this(size_t initSize, bool growable = true) {
		this.store = new T[initSize];
		this.storeObjOfSize = new MapSet!(size_t,strPtr!T)();
		// this must be a RBTree must must must, this is needed to search the
		// set for the first strPtr thats has a suitable size for alloc
		this.storePointer = new Set!(strPtr!(T))(ISRType.RBTree);
		this.low = 0;
		this.growable = growable;
	}

	void grow() {
		this.store.length = this.store.length * 2;
	}

	/*
		When freeing a strPtr it is inserted into storePointer.
		If the freed strPtr base plus its length equals the base of the next
		strPtr in the set both are removed, combined and reinserted.
		Nothing happends if they are not equal. In either case the strPtr
		is placed in the multiset grouped by their size.
	*/

	private void storeStrPtr(strPtr!T ptr) {
		assert(!this.storePointer.contains(ptr));
		this.storePointer.insert(ptr);
		this.storeObjOfSize.insert(ptr.getSize(), ptr);
	}

	strPtr!T alloc(const size_t size) {
		if(this.storeObjOfSize.containsMapping(size)) {
			// remove from both and than return the pointer
			auto set = this.storeObjOfSize.getSet(size);
			auto begin = set.begin();
			assert(begin.isValid());
			strPtr!T item = *begin;
			set.remove(item);

			this.storePointer.remove(item);
			return item;
		}

		// check if the last iterator fits
		auto it = this.storePointer.begin();
		for(; it.isValid(); it++) {
			if((*it).getSize() >= size) {
				break;
			}
		}

		if(it.isValid()) {
			strPtr!T tmp = *it;
			if(tmp.getSize() == size) {
				this.storePointer.remove(tmp);
				this.storeObjOfSize.remove(tmp.getSize, tmp);
				return tmp;
			} else if(tmp.getSize() > size) {
				this.storePointer.remove(tmp);
				this.storeObjOfSize.remove(tmp.getSize, tmp);
				size_t newBase = tmp.getBase+size;
				size_t newSize = tmp.getSize()-size;
				tmp.setSize(size);
				auto toInsert = strPtr!T(this,newBase,newSize);
				this.storeStrPtr(toInsert);
				return tmp;
			}
		}

		if(this.low + size >= this.store.length) {
			if(!this.growable) {
				return strPtr!T(this,0,0);
			} else {
				this.grow();
			}
		}

		assert(this.low + size < this.store.length);
		size_t tmpLow = this.low;
		this.low += size;
		return strPtr!T(this, tmpLow, size);
	}

	void free(strPtr!T ptr) {
		// check if there is a ptr below that would line up
		// if so merge and make it the ptr variable
		this.storePointer.insert(ptr);
		this.storeObjOfSize.insert(ptr.getSize(), ptr);
		ISRIterator!(strPtr!T) it = this.storePointer.find(ptr);
		bool before, after;
		if(it.isValid()) {
			auto jt = it.dup();
			assert(jt.isValid());
			jt--;
			if(jt.isValid() && // they line up
					(*jt).getBase() + (*jt).getSize() == ptr.getBase()) {
				auto jtPtr = *jt;	
				this.storePointer.remove(jt);
				this.storePointer.remove(it);
				this.storeObjOfSize.remove((*jt).getSize(), (*jt));
				this.storeObjOfSize.remove((*it).getSize(), (*it));

				ptr = strPtr!T(this, jtPtr.getBase(), 
					jtPtr.getSize() + ptr.getSize());
				this.storeObjOfSize.insert(ptr.getSize(), ptr);
				this.storePointer.insert(ptr);
				before = true;
			}
		}
		it = this.storePointer.find(ptr);
		if(it.isValid()) {
			auto jt = it.dup();
			assert(jt.isValid());
			jt++;
			log("%b", jt.isValid());
			if(jt.isValid() && // they line up
					(*it).getBase() + (*it).getSize() == (*jt).getBase()) {
				auto itPtr = *it;	
				auto newSize = (*it).getSize() + (*jt).getSize();
				this.storePointer.remove(jt);
				this.storePointer.remove(it);
				this.storeObjOfSize.remove((*jt).getSize(), (*jt));
				this.storeObjOfSize.remove((*it).getSize(), (*it));

				ptr = strPtr!T(this,itPtr.getBase(), newSize);
				this.storeObjOfSize.insert(ptr.getSize(), ptr);
				this.storePointer.insert(ptr);
				after = true;
			}
		}

		/*if(!before && !after) {
			this.storePointer.insert(ptr);
		}*/

		if(ptr.getBase() + ptr.getSize() == this.low) {
			this.low = this.low - ptr.getSize();
			this.storePointer.remove(ptr);
			this.storeObjOfSize.remove(ptr.getSize(), ptr);
		}
		assert(this.low >= 0);
	}

	public override string toString() {
		auto ret = new StringBuffer!(char)(1024);
		ret.pushBack("store size %d: low idx %d\n", this.store.length,
			this.low);

		foreach(ptr; this.storePointer) {
			ret.pushBack("ptr base %d size %d\n", ptr.getBase(), ptr.getSize());
		}

		return ret.getString();
	}
		
}

unittest {
	Store!byte store = new Store!byte(16);

	auto s1 = store.alloc(8);
	assert(s1.isValid());
	assert(s1.getBase() == 0 && s1.getSize() == 8);
	log("%s", store.toString());
	//store.free(s1);
	log("%s", store.toString());
	auto s2 = store.alloc(4);
	log("%s", store.toString());
	auto s3 = store.alloc(2);
	log("%s", store.toString());
	store.free(s2);
	log("%s", store.toString());
	store.free(s1);
	log("%s", store.toString());
	store.free(s3);
	log("%s", store.toString());
}

version(staging) {
void main() {
}
}
