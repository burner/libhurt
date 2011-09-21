module hurt.algo.binaryrangesearch;

struct Range(T,S) {
	S value;
	T first, last;
	bool firstSet, lastSet;

	this(S value) {
		this.value = value;
		this.firstSet = true;
		this.lastSet = true;
	}

	this(T first, S value) {
		this.first = first;
		this.firstSet = true;
		this.value = value;
	}

	this(T first, T last, S value) {
		this.first = first;
		this.firstSet = true;
		this.last = last;
		this.lastSet = true;
		this.value = value;
	}

	bool isFirstSet() const {
		return this.firstSet;
	}

	bool isLastSet() const {
		return this.lastSet;
	}

	bool canExpend(T next) const {
		if(!this.firstSet)
			return true;

		if(this.lastSet) {
			if((cast(int)this.last)+1 == (cast(int)next)) {
				return true;
			} else {
				return false;
			}
		} else {
			if((cast(int)this.first)+1 == (cast(int)next)) {
				return true;
			} else {
				return false;
			}
		}
	}

	void expend(T next) {
		if(!this.canExpend(next)) {
			return;
		}
		if(!this.firstSet) {
			this.first = next;
			this.firstSet = true;
			return;
		}
			
		if(this.lastSet) {
			this.last = next;
		} else {
			this.last = next;
			this.lastSet = true;
		}
	}
}

unittest {
	Range!(dchar,int) r1 = Range!(dchar,int)(9);
	assert(r1.canExpend('a'));
	assert(r1.canExpend('b'));
	r1.expend('a');
	r1.first = 'a';
	assert(r1.canExpend('b'));
	r1.expend('b');
	r1.last = 'b';
}

S binarySearch(T,S)(Range!(T,S) r[], T key) {
	size_t l = 0;	
	size_t h = r.length-1;	
	size_t m;	
	while(h >= l) {
		m = l + ((h - l) / 2);
		//printfln("%3d %3d %5d", l, h,m);
		if(h < l) {
			throw new Exception("failed to find the range");
		}

		if((r[m].first == key) ||
				(r[m].isLastSet() && r[m].first <= key && r[m].last >= key)) {
			return r[m].value;
		}

		if(r[m].first > key)
			h = m-1;
		else
			l = m+1;
	}
	throw new Exception("failed to find the range");
}

unittest {
	Range!(dchar,int) m[3];
	m[0] = Range!(dchar,int)('a', 'b', 1);
	m[1] = Range!(dchar,int)('d', 2);
	m[2] = Range!(dchar,int)('e','h', 3);
	assert(1 == binarySearch!(dchar,int)(m, 'a'));
	assert(1 == binarySearch!(dchar,int)(m, 'b'));
	assert(2 == binarySearch!(dchar,int)(m, 'd'));
	assert(3 == binarySearch!(dchar,int)(m, 'h'));
	assert(3 == binarySearch!(dchar,int)(m, 'f'));
	assert(3 == binarySearch!(dchar,int)(m, 'e'));
	bool cougth = false;
	try {
		assert(3 == binarySearch!(dchar,int)(m, 'z'));
	} catch(Exception e) { cougth = true;}
	assert(cougth);
}
