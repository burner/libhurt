module hurt.container.store;

import hurt.container.multiset;
import hurt.container.mapset;
import hurt.container.set;
import hurt.container.isr;
import hurt.string.stringbuffer;
import hurt.string.formatter;
import hurt.util.slog;
import hurt.time.stopwatch;

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

	size_t back() const {
		return this.base + this.size;
	}

	void markInvalid() {
		this.base = 0;
		this.size = 0;
	}

	T* getPointer() {
		return this.store.getBase() + (T.sizeof * this.base);
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

	T* getBase() {
		return store.ptr;
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

		if(this.low + size > this.store.length) {
			if(!this.growable) {
				return strPtr!T(this,0,0);
			} else {
				this.grow();
			}
		}

		assert(this.low + size <= this.store.length);
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

		//log("%d + %d ?= %d", ptr.getBase(), ptr.getSize(), this.low);
		if(ptr.getBase() + ptr.getSize() == this.low) {
			//log();
			this.low = ptr.getBase();
			this.storePointer.remove(ptr);
			this.storeObjOfSize.remove(ptr.getSize(), ptr);
			//log("%s", this.toString());
		}
		assert(this.low >= 0);
	}

	strPtr!T realloc(strPtr!T old, size_t newSize) {
		assert(newSize > 0);
		if(old.getSize() == newSize) {
			return old;
		} else if(old.getSize() > newSize) {
			auto tmp = strPtr!T(this, old.getBase()+newSize, 
				old.getSize()-newSize);
			auto ret = strPtr!T(this, old.getBase(), newSize);
			this.storePointer.insert(tmp);
			this.storeObjOfSize.insert(newSize, tmp);
			return ret;
		} else if(old.getSize() < newSize) {
			auto toSearch = strPtr!T(this,old.getBase()+old.getSize(), newSize);
			auto found = this.storePointer.find(toSearch);
			assert(found.isValid());
			// inplace realloc can be done
			if(found.isValid() && 
					((*found).getSize() + old.getSize()) >= newSize) {
				auto foundPtr = *found;
				this.storePointer.remove(foundPtr);
				this.storeObjOfSize.remove(foundPtr.getSize(), foundPtr);

				auto ret = strPtr!T(this, old.getBase(), newSize);
				auto nBase = ret.back();
				auto nSize = foundPtr.back()-ret.back();
				auto tmp = strPtr!T(this, nBase, nSize);
				this.storePointer.insert(tmp);
				this.storeObjOfSize.insert(newSize, tmp);
				return ret;
			} else { // real realloc
				this.storePointer.remove(old);
				this.storeObjOfSize.remove(old.getSize(), old);
				strPtr!T ret = this.alloc(newSize);

				// new blit the memory
				for(size_t idx = 0; idx < old.getSize(); idx++) {
					this.store[ret.getBase()+idx] = 
						this.store[old.getBase()+idx];	
				}

				// make the rest 0
				for(size_t idx = old.back(); idx < ret.back(); idx++) {
					this.store[0] = T.init;
				}

				return ret;
			}
		}
		assert(false);
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

	public size_t getLow() const {
		return this.low;
	}

	public size_t getFragments() {
		return this.storePointer.getSize();
	}
		
}

unittest {
	StopWatch sw;
	sw.start();
	Store!byte store = new Store!byte(16);

	auto s1 = store.alloc(8);
	assert(s1.isValid());
	assert(s1.getBase() == 0 && s1.getSize() == 8);
	//log("%s", store.toString());
	//store.free(s1);
	//log("%s", store.toString());
	auto s2 = store.alloc(4);
	assert(s2.isValid());
	assert(s2.getBase() == 8 && s2.getSize() == 4);
	//log("%s", store.toString());
	auto s3 = store.alloc(2);
	assert(s3.getBase() == 12 && s3.getSize() == 2);
	assert(s3.isValid());
	auto s4 = store.alloc(2);
	assert(s4.isValid());
	assert(s4.getBase() == 14 && s4.getSize() == 2);
	assert(s3.getPointer() + 2 == s4.getPointer());
	//log("%s", store.toString());
	//log("%s", store.toString());
	store.free(s2);
	//log("%s", store.toString());
	store.free(s1);
	//log("%s", store.toString());
	store.free(s3);
	//log("%s", store.toString());
	store.free(s4);
	//log("%s", store.toString());
	assert(store.getLow() == 0, store.toString());

	s1 = store.alloc(16);
	assert(s1.isValid());
	store.free(s1);
	
	s1 = store.alloc(8);
	assert(s1.isValid() && s1.getBase() == 0);
	//log("%s", store.toString());
	s2 = store.alloc(8);
	assert(s2.isValid() && s2.getBase() == 8, format("%b %d",
		s2.isValid(), s2.getBase()));
	//log("%s", store.toString());
	//log("all that took %f", sw.stop());
	warn(sw.stop > 0.5, "took longer than expected");
	int[] a;
	log("print the size of an array ref %d", a.sizeof);
	log("%d:%d", *(cast(size_t*)(&a)), cast(size_t)(&a)+(size_t.sizeof));
}

unittest {
	struct ThreeInt {
		int a,b,c;
	}
}

version(staging) {
void main() {
}
}
