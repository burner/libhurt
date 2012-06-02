module hurt.string.stringstore;

import hurt.container.deque;
import hurt.string.formatter;
import hurt.exception.exception;
import hurt.conv.conv;
import hurt.io.stdio;
import hurt.util.slog;

struct strptr(T) {
	private StringStore!(T) store;
	immutable private size_t storeIdx;
	immutable private size_t blockIdx;
	immutable private size_t length;

	this(StringStore!(T) store, size_t storeIdx, size_t blockIdx, 
			size_t length) {
		this.store = store;
		this.storeIdx = storeIdx;
		this.blockIdx = blockIdx;
		this.length = length;
	}

	public void setStore(StringStore!(T) store) {
		this.store = store;
	}

	public string toString() const {
		return cast(immutable)this.store.getSlice(this.storeIdx, this.blockIdx,
			this.length);
	}
		
}

class StringStore(T) {
	private Deque!(T[]) cache;	
	private Deque!(size_t) cacheIdx;	
	private immutable size_t chuckSize;

	this(size_t chuckSize = 2048) {
		this.chuckSize = chuckSize;
		this.cache = new Deque!(T[])();
		this.cacheIdx = new Deque!(size_t)();
		this.cache.pushBack(new T[this.chuckSize]);
		this.cacheIdx.pushBack(0);
	}

	public const(T[]) getSlice(size_t store, size_t blockIdx, size_t len) 
			const {
		return this.cache[store][blockIdx .. blockIdx+len];
	}

	public strptr!(T) pushBack(string toInsert) {
		enforce(toInsert.length < this.chuckSize, 
			format("string to insert is bigger than chuckSize, string.length %d"
			~ " chucksize %d", toInsert.length, this.chuckSize));
		if(this.cacheIdx.back() + toInsert.length + 1 >= 
				this.cache.back.length) {
			this.cache.pushBack(new T[this.chuckSize]);
			this.cacheIdx.pushBack(0);
		}
		T[] tmp = this.cache.back();
		size_t back = this.cacheIdx.back();
		foreach(idx, it; toInsert) {
			tmp[back+idx] = it;
		}
		tmp[back+toInsert.length] = '\0';
		this.cacheIdx.popBack();
		this.cacheIdx.pushBack(back+toInsert.length+1);
		return strptr!(T)(this, this.cache.getSize()-1, back, 
			toInsert.length);
	}

	public void debugPrint() {
		foreach(jt; this.cache) {
			foreach(it; jt) {
				printf("'%c',", it);
			}
			println("\b\n\n");
		}
	}
}

unittest {
	auto ss = new StringStore!char();
	auto ptr = ss.pushBack("hello world");
	assert(ptr.toString() == "hello world");
	log("%s", ptr.toString());
	auto ptr2 = ss.pushBack("foobar");
	assert(ptr.toString() == "hello world");
	assert(ptr2.toString() == "foobar");
	log("%s", ptr.toString());
	log("%s", ptr2.toString());
	auto ptr3 = ss.pushBack("hello my name is");
	ss.debugPrint();
}

version(staging) {
void main() {
}
}
