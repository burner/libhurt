module hurt.algo.binaryrangesearch;

import hurt.algo.sorting;
import hurt.io.stdio;

struct Range(T,S) {
	S value;
	T first, last;
	bool firstSet = false, lastSet = false;

	this(S value) {
		this.value = value;
		assert(this.value == value);
		assert(!this.firstSet);
		assert(!this.lastSet);
	}

	this(T first, S value) {
		this.first = first;
		this.value = value;
		this.firstSet = true;
		assert(this.first == first);
		assert(this.value == value);
		assert(this.firstSet);
		assert(!this.lastSet);
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

S linearSearch(T,S)(in Range!(T,S) r[], T key) {
	foreach(it; r) {
		if(it.first == key || 
				(it.isLastSet() && it.first <= key && it.last >= key)) {
			return it.value;
		}
	}
	throw new Exception("failed to find the range");
}

S binarySearch(T,S)(in Range!(T,S) r[], T key) {
	size_t l = 0;	
	size_t h = r.length-1;	
	size_t m;	
	while(h >= l) {
		m = l + ((h - l) / 2);
		//printfln("%d %d %d %d", l, m, h, cast(int)r[m].first);
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
	Range!(dchar,size_t)[55] inputRange = [
		Range!(dchar,size_t)('\t',0),Range!(dchar,size_t)('\n',1),Range!(dchar,size_t)(' ',2),
		Range!(dchar,size_t)('!',3),Range!(dchar,size_t)('"',4),Range!(dchar,size_t)('$',5),
		Range!(dchar,size_t)('%',6),Range!(dchar,size_t)('&',7),Range!(dchar,size_t)('ß',7),
		Range!(dchar,size_t)('ö',7),Range!(dchar,size_t)('(',8),Range!(dchar,size_t)(')',9),
		Range!(dchar,size_t)('*',10),Range!(dchar,size_t)('+',11),Range!(dchar,size_t)(',',12),
		Range!(dchar,size_t)('-',13),Range!(dchar,size_t)('.',14),Range!(dchar,size_t)('0',15),
		Range!(dchar,size_t)('1',16),Range!(dchar,size_t)('2','7',17),Range!(dchar,size_t)('8','9',18),
		Range!(dchar,size_t)(';',19),Range!(dchar,size_t)('<',20),Range!(dchar,size_t)('=',21),
		Range!(dchar,size_t)('>',22),Range!(dchar,size_t)('?',23),Range!(dchar,size_t)('A','Z',24),
		Range!(dchar,size_t)('k',24),Range!(dchar,size_t)('s',24),Range!(dchar,size_t)('z',24),
		Range!(dchar,size_t)('[',25),Range!(dchar,size_t)(']',26),Range!(dchar,size_t)('_',27), Range!(dchar,size_t)('a',28),Range!(dchar,size_t)('b',29),Range!(dchar,size_t)('c',30),
		Range!(dchar,size_t)('d',31),Range!(dchar,size_t)('e',32),Range!(dchar,size_t)('f',33),
		Range!(dchar,size_t)('g',34),Range!(dchar,size_t)('h',35),Range!(dchar,size_t)('i',36),
		Range!(dchar,size_t)('l',37),Range!(dchar,size_t)('m',38),Range!(dchar,size_t)('n',39),
		Range!(dchar,size_t)('o',40),Range!(dchar,size_t)('p',41),Range!(dchar,size_t)('r',42),
		Range!(dchar,size_t)('t',43),Range!(dchar,size_t)('u',44),Range!(dchar,size_t)('v',45),
		Range!(dchar,size_t)('w',46),Range!(dchar,size_t)('x',47),Range!(dchar,size_t)('{',48),
		Range!(dchar,size_t)('}',49)];
	sort!(Range!(dchar,size_t))(inputRange, function(in Range!(dchar,size_t) a, in Range!(dchar,size_t) b) {
			return a.first < b.first; });
	foreach(it; inputRange) {
		//printf("%d ", cast(int)it.first);
	}
	//println();
	
	try {
		assert(0 == binarySearch!(dchar,size_t)(inputRange, '\t'));
	} catch(Exception e) {
		assert(false, e.msg);
	}
	try {
		assert(49 == binarySearch!(dchar,size_t)(inputRange, '}'));
	} catch(Exception e) {
		assert(false, e.msg);
	}
	try {
		assert(17 == binarySearch!(dchar,size_t)(inputRange, '5'));
	} catch(Exception e) {
		assert(false, e.msg);
	}
	try {
		assert(36 == binarySearch!(dchar,size_t)(inputRange, 'i'));
	} catch(Exception e) {
		assert(false, e.msg);
	}
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
