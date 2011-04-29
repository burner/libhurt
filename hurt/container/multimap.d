module hurt.container.multimap;

import hurt.util.array;

class MultiMap(T,S) {
	private class Value(S) {
		version(X86) {
			int idx;
		} else {
			long idx;
		}	
		S[] multi;

		this(S value) {
			this.idx = 0;
			this.multi = new S[16];
			this.multi[this.idx++] = value;
		}

		public void insert(S value) {
			if(this.idx == multi.length) {
				this.multi.length *= 2u;
			}
			this.multi[this.idx++] = value;
		}

		public S[] remove() {
			S[] ret = this.multi[0..this.idx].dup;
			this.idx = 0;
			return ret;
		}

		public S[] remove(uint rIdx) {
			if(rIdx >= this.idx) {
				assert(0, "not allowed to remove out of index");
			}
			uint upIdx = rIdx + 1u;
			uint lowIdx = rIdx;
			while(lowIdx < this.idx - 1u) {
				this.multi[lowIdx] = this.multi[upIdx];
				upIdx++;
				lowIdx++;
			}
			if(this.idx == 1u) {
				return null;
			} else {
				this.idx--;
				return this.multi[0..this.idx];
			}
		}

		public object.size_t getSize() {
			return this.idx;
		}

		public S[] values() {
			return this.multi[0..this.idx];
		}
	}

	Value!(S)[T] multi;

	MultiMap!(T,S) insert(T key, S value) {
		if(key in this.multi) {
			Value!(S) tmp = this.multi[key];
			tmp.insert(value);
		} else {
			this.multi[key] = new Value!(S)(value);
		}
		return this;
	}

	S[] remove(T key, uint idx) {
		if(key in this.multi) {	
			S[] tmp = this.multi[key].remove(idx);	
			if(tmp is null) {
				return null;
			} else {
				return tmp;
			}
		} else {
			return null;
		}
	}

	S[] remove(T key) {
		if(key in this.multi) {	
			S[] tmp = this.multi[key].remove();	
			this.multi.remove(key);
			return tmp;
		} else {
			return null;
		}
	}

	bool remove(S value) {
		foreach(ref it; this.multi.values()) {
			foreach(idx, jt; it.values()) {
				if(jt == value) {
					it.multi = hurt.util.array.remove!(S)(it.values(), idx);	
					it.idx--;
				}
			}
		}
		return true;
	}

	bool replace(S old, S replace) {
		foreach(ref it; this.multi.values()) {
			foreach(ref jt; it.values()) {
				if(jt == old) {
					jt = replace;
					return true;
				}
			}
		}
		return false;

	}

	S[] find(T key) {
		if(key in this.multi) {	
			S[] tmp = this.multi[key].values();	
			return tmp;
		} else {
			return null;
		}
	}

	bool find(S value) {
		foreach(it; this.multi.values()) {
			foreach(jt; it.values()) {
				if(jt == value)
					return true;
			}
		}
		return true;
	}

	bool find(T key, S value) {
		Value!(S) tmp = this.multi[key];
		foreach(it; tmp.values()) {
			if(it == value)
				return true;
		}
		return true;
	}

	T[] keys() {
		return this.multi.keys();
	}

	bool empty() const {
		return this.multi.length == 0;
	}

	bool opEquals(Object o) {
		MultiMap!(T,S) t = cast(MultiMap!(T,S))o;
		foreach(kit; this.keys()) {
			foreach(oit; this.find(kit)) {
				if(!t.find(kit, oit))
					return false;
			}
		}
		return true;
	}
}

unittest {
	MultiMap!(char,int) mm1 = new MultiMap!(char,int)();
	mm1.insert('t', 12);
	mm1.insert('t', 22);
	mm1.remove(22);
	mm1.insert('t', 32);
	mm1.insert('t', 42);
	assert(mm1.find('t') == [12,32,42]);
	mm1.remove('t', 0u);
	assert(mm1.find('t') == [32,42]);
	assert(mm1.find('r') is null);
	mm1.insert('r', 92);
	assert(mm1.find('r') !is null);
	mm1.insert('r', 32);
	mm1.insert('r', 82);
	assert(mm1.find('r') == [92,32,82]);
	mm1.remove('r', 1u);
	assert(mm1.find('r') == [92,82]);
	assert(mm1.replace(92, 93));
	mm1.remove('t');
	assert(mm1.find('t') is null);
}
