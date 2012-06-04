module hurt.string.stringstore;

import hurt.container.deque;
import hurt.string.formatter;
import hurt.string.stringbuffer;
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
	private immutable size_t chunckSize;

	this(size_t chunckSize = 2048) {
		this.chunckSize = chunckSize;
		this.cache = new Deque!(T[])();
		this.cacheIdx = new Deque!(size_t)();
		this.cache.pushBack(new T[this.chunckSize]);
		this.cacheIdx.pushBack(0);
	}

	public const(T[]) getSlice(size_t store, size_t blockIdx, size_t len) 
			const {
		return this.cache[store][blockIdx .. blockIdx+len];
	}

	private static size_t size(S)(S from) {
		static if(is(S == StringBuffer!(T))) {
			return from.getSize();
		} else static if(is(S == immutable(T)[])) {
			return from.length;
		} else {
			assert(false);
		}
	}

	public strptr!(T) pushBack(S)(S toInsert) {
		enforce(size(toInsert) < this.chunckSize, 
			format("string to insert is bigger than chunckSize, " ~
			" string.length %d chucksize %d", size(toInsert), this.chunckSize));
		if(this.cacheIdx.back() + size(toInsert)+1 >= 
				this.cache.back.length) {
			this.cache.pushBack(new T[this.chunckSize]);
			this.cacheIdx.pushBack(0);
		}
		T[] tmp = this.cache.back();
		size_t back = this.cacheIdx.back();
		foreach(idx, it; toInsert) {
			tmp[back+idx] = it;
		}
		tmp[back+size(toInsert)] = '\0';
		this.cacheIdx.popBack();
		this.cacheIdx.pushBack(back+size(toInsert)+1);
		return strptr!(T)(this, this.cache.getSize()-1, back, 
			size(toInsert));
	}

	public const(Deque!(size_t)) getChunckSizes() const {
		return this.cacheIdx;
	}

	public size_t getChunchSize() const {
		return this.chunckSize;
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
	//log("%s", ptr.toString());
	auto ptr2 = ss.pushBack("foobar");
	assert(ptr.toString() == "hello world");
	assert(ptr2.toString() == "foobar");
	//log("%s", ptr.toString());
	//log("%s", ptr2.toString());
	auto ptr3 = ss.pushBack("hello my name is");
	//ss.debugPrint();
}

unittest {
	auto ss = new StringStore!char();
	auto ptr = ss.pushBack(new StringBuffer!(char)("hello world"));
	assert(ptr.toString() == "hello world");
	//log("%s", ptr.toString());
	auto ptr2 = ss.pushBack(new StringBuffer!(char)("foobar"));
	assert(ptr.toString() == "hello world");
	assert(ptr2.toString() == "foobar");
	//log("%s", ptr.toString());
	//log("%s", ptr2.toString());
	auto ptr3 = ss.pushBack(new StringBuffer!(char)("hello my name is"));
	//ss.debugPrint();
}

version(staging) {
void main() {
}
}
