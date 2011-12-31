module hurt.container.multimap;

import hurt.container.isr;
import hurt.container.rbtree;
import hurt.container.bst;
import hurt.container.hashtable;
import hurt.conv.conv;
import hurt.container.iterator;
import hurt.container.dlst;
import hurt.exception.invaliditeratorexception;
import hurt.util.array;

import std.stdio;

class Iterator(T,S) {
	private ISRIterator!(Item!(T,S)) treeIt;
	private MultiMap!(T,S) map;
	private hurt.container.dlst.Iterator!(S) listIt;
	private bool range;

	Iterator!(T,S) dup() {
		return new Iterator!(T,S)(true, this.map, this.treeIt, this.listIt, 
			this.range);	
	}

	this(bool dup, MultiMap!(T,S) map, ISRIterator!(Item!(T,S)) tit, 
			hurt.container.dlst.Iterator!(S) lit, bool range) {
		this.map = map;
		this.treeIt = tit.dup;
		this.listIt = lit.dup;
		this.range = range;
		assert(this.map !is null);
		assert(this.treeIt !is null);
		assert(this.listIt !is null);
	}

	this(MultiMap!(T,S) map, ISRIterator!(Item!(T,S)) it, bool begin = true, 
			bool range = true) {
		this.treeIt = it;
		this.range = range;
		this.map = map;
		if(this.treeIt is null || !this.treeIt.isValid()) {
			return;
		}
		if(begin) {
			this.listIt = (*this.treeIt).getFirst();
		} else {
			this.listIt = (*this.treeIt).getLast();
		}
	}

	this(ISRIterator!(Item!(T,S)) it, bool begin = true, bool range = true) {
		this.treeIt = it;
		this.range = range;
		if(this.treeIt is null || !this.treeIt.isValid()) {
			return;
		}
		if(begin) {
			this.listIt = (*this.treeIt).getFirst();
		} else {
			this.listIt = (*this.treeIt).getLast();
		}
	}

	public void opUnary(string s)() if(s == "++") {
		++this.listIt;
		if(this.listIt.isValid()) {
			return;
		} else if(!this.range) {
			++this.treeIt;
			if(this.treeIt.isValid()) {
				this.listIt = (*this.treeIt).getFirst();
			}
		}
	}

	protected bool remove() {
		Item!(T,S) item = (*this.treeIt);
		return item.remove(this.listIt);
	}

	T getKey() {
		return (*this.treeIt).key;
	}

	protected hurt.container.dlst.Iterator!(S) getListIt() {
		return this.listIt;
	}

	protected ISRIterator!(Item!(T,S)) getTreeIt() {
		return this.treeIt;
	}

	public S getData() {
		if(this.listIt.isValid()) {
			return *this.listIt;
		}
		throw new InvalidIteratorException("MultiMap Iterator is not valid");	
	}

	public void opUnary(string s)() if(s == "--") {
		--this.listIt;
		if(this.listIt.isValid()) {
			return;
		} else if(!this.range) {
			--this.treeIt;
			if(this.treeIt.isValid()) {
				this.listIt = (*this.treeIt).getLast();
			}
		}
	}

	public S opUnary(string s)() if(s == "*") {
		/*if(this.listIt.isValid()) {
			return *this.listIt;
		}
		throw new InvalidIteratorException("MultiMap Iterator is not valid");
		*/
		return this.getData();
	}

	public bool isValid() const {
		return this.listIt !is null && this.listIt.isValid();
	}

	public override bool opEquals(Object o) {
		Iterator!(T,S) i = cast(Iterator!(T,S))o;
		if(this.isValid() != i.isValid()) {
			return false;
		}
		if(this.isValid() == false && i.isValid() == false) {
			return true;
		}
		if(this.getKey() != i.getKey()) {
			return false;
		}
		bool a = (*this.getListIt()) == (*i.getListIt());
		bool b = (*this.getTreeIt()) is (*i.getTreeIt());
		bool c = this.map is i.map;
		return a && b && c;
	}
}

class Item(T,S) {
	T key;
	DLinkedList!(S) values;

	this() { }

	this(T key, S first) {
		this.key = key;
		this.values = new DLinkedList!(S)();
		this.values.pushBack(first);
	}	

	public void append(S value) {
		this.values.pushBack(value);
	}

	protected hurt.container.dlst.Iterator!(S) getFirst() {
		return this.values.begin();
	}

	protected hurt.container.dlst.Iterator!(S) getLast() {
		return this.values.end();
	}

	bool remove(hurt.container.dlst.Iterator!(S) it) {
		this.values.remove(it);
		return this.values.isEmpty();
	}

	size_t getSize() const {
		return values.getSize();
	}

	override bool opEquals(Object o) const {
		Item!(T,S) f = cast(Item!(T,S))o;
		return this.key == f.key;
	}

	override size_t toHash() const {
		static if(is(T : long) || is(T : int) || is(T : byte) || is(T : char)) {
			return cast(size_t)key;
		} else static if(is(T : long[]) || is(T : int[]) || is(T : byte[])
				|| is(T : char[]) || is(T : immutable(char)[])) {
			size_t ret;
			foreach(it;key) {
				ret = it + (ret << 6) + (ret << 16) - ret;
			}
			return ret;
		} else static if(is(T : Object)) {
			return cast(size_t)key.toHash();
		} else {
			assert(0);
		}
	}

	override int opCmp(Object o) const {
		Item!(T,S) f = cast(Item!(T,S))o;
		if(this.key > f.key)
			return 1;
		else if(this.key < f.key)
			return -1;
		else
			return 0;
	}
}

class MultiMap(T,S) {
	private ISR!(Item!(T,S)) tree;
	private Item!(T,S) finder;
	private size_t size;
	private ISRType type;

	this(ISRType type = ISRType.RBTree) {
		this.finder = new Item!(T,S);
		this.makeMap();
	}

	private void makeMap() {
		if(this.type == ISRType.RBTree) {
			this.tree = new RBTree!(Item!(T,S))();
		} else if(this.type == ISRType.BinarySearchTree) {
			this.tree = new BinarySearchTree!(Item!(T,S))();
		} else if(this.type == ISRType.HashTable) {
			this.tree = new HashTable!(Item!(T,S))();
		}
	}


	Iterator!(T,S) insert(T key, S value) {
		this.finder.key = key;
		ISRIterator!(Item!(T,S)) found = this.tree.searchIt(this.finder);
		this.size++;
		if(found.isValid()) {
			(*found).append(value);
			return new Iterator!(T,S)(found, false, true);
		} else {
			auto treeIt = this.tree.insert(new Item!(T,S)(key, value));
			ISRIterator!(Item!(T,S)) it = this.tree.searchIt(this.finder);
			return new Iterator!(T,S)(this,it, true, true);
		}
	}

	Iterator!(T,S) begin() {
		auto tmp = this.tree.begin();
		return new Iterator!(T,S)(this,tmp, true, false);
	}

	Iterator!(T,S) end() {
		auto tmp = this.tree.end();
		return new Iterator!(T,S)(this,tmp, false, false);
	}

	Iterator!(T,S) invalidIterator() {
		auto tmp = this.tree.end();
		Iterator!(T,S) ret = new Iterator!(T,S)(this,tmp, false, false);
		if(ret.isValid()) {
			ret++;
		}
		return ret;
	}

	Iterator!(T,S) lower(T key) {
		this.finder.key = key;
		ISRIterator!(Item!(T,S)) found = this.tree.searchIt(this.finder);
		return new Iterator!(T,S)(this,found, true, false);
	}

	Iterator!(T,S) upper(T key) {
		this.finder.key = key;
		ISRIterator!(Item!(T,S)) found = this.tree.searchIt(this.finder);
		Iterator!(T,S) ret = new Iterator!(T,S)(this,found, false, false);
		ret++;
		return ret;
	}
		
	Iterator!(T,S) range(T key) {
		this.finder.key = key;
		ISRIterator!(Item!(T,S)) found = this.tree.searchIt(this.finder);
		return new Iterator!(T,S)(this,found, true, true);
	}

	bool contains(T key) {
		return this.lower(key).isValid();
	}
	
	size_t getCountKeys() const {
		return this.tree.getSize();
	}

	size_t getSize() const {
		return this.size;
	}

	bool isEmpty() const {
		return this.size == 0;
	}

	T[] keys() {
		T[] ret = new T[this.getCountKeys()];
		auto it = this.tree.begin();
		foreach(ref jt; ret) {
			jt = (*it).key;
			it++;
		}
		return ret;
	}

	override bool opEquals(Object o) {
		MultiMap!(T,S) m = cast(MultiMap!(T,S))o;
		T[] tkey = this.keys();
		T[] mkey = m.keys();
		if(!hurt.util.array.compare!(T)(tkey, mkey)) {
			return false;
		}
		foreach(it; tkey) {
			Iterator!(T,S) tit = this.range(it);
			outer: for(; tit.isValid(); tit++) {
				Iterator!(T,S) mit = m.range(it);
				for(; mit.isValid(); mit++) {
					if((*tit) == (*mit)) {
						continue outer;	
					}
				}
				return false;
			}
		}
		return true;
	}

	bool remove(Iterator!(T,S) it) {
		if(it is null || !it.isValid())
			throw new InvalidIteratorException("Iterator is null or not valid");

		Item!(T,S) item = *(it.getTreeIt());
		DLinkedList!(S) list = item.values;
		size_t os = list.getSize();
		list.remove(it.getListIt());
		if(os != list.getSize())
			this.size--;
		if(list.isEmpty()) {
			this.tree.remove(it.getTreeIt());
			return true;
		} else {
			return false;
		}
	}

	DLinkedList!(S) removeRange(T key) {
		this.finder.key = key;
		//Item!(T,S) it = cast(Item!(T,S))this.tree.search(this.finder);
		ISRNode!(Item!(T,S)) item = this.tree.search(this.finder);
		if(item is null)
			return null;

		Item!(T,S) it = item.getData();
		if(it !is null) {
			this.tree.remove(this.finder);
			this.size -= it.getSize();
			return it.values;
		} else {
			return null;
		}		
	}

	void clear() {
		this.makeMap();
		this.size = 0;
	}
}

unittest {
	MultiMap!(int, string) mm1 = new MultiMap!(int,string)();
	assert(!mm1.begin().isValid());
	assert(!mm1.end().isValid());
	mm1.insert(0, "zero");
	mm1.insert(0, "null");
	assert(mm1.contains(0));
	auto it = mm1.range(0);
	assert(*it == "zero");
	it++;
	assert(*it == "null");
	mm1.insert(1, "one");
	mm1.insert(1, "eins");
	assert(mm1.contains(1));
	it = mm1.range(1);
	assert(*it == "one");
	it++;
	assert(*it == "eins");
	mm1.insert(2, "two");
	mm1.insert(2, "zwei");
	assert(mm1.contains(2));
	it = mm1.range(2);
	assert(*it == "two");
	it++;
	assert(*it == "zwei");
	mm1.insert(3, "three");
	mm1.insert(3, "drei");
	assert(mm1.contains(3));
	it = mm1.range(3);
	assert(*it == "three");
	it++;
	assert(*it == "drei");
	assert(mm1.getSize() == 8, conv!(size_t,string)(mm1.getSize()));

	auto mn = new MultiMap!(int, string)();
	mn.insert(0, "null");
	mn.insert(0, "zero");
	mn.insert(1, "eins");
	mn.insert(1, "one");
	mn.insert(3, "three");
	mn.insert(3, "drei");
	mn.insert(2, "two");
	mn.insert(2, "zwei");
	assert(mn.getSize() == 8);

	assert(mm1 == mn);

	it = mm1.range(0);
	while(it.isValid()) {
		mm1.remove(it);
	}
	assert(mm1.getSize() == 6, conv!(size_t,string)(mm1.getSize()));

	assert(hurt.util.array.compare(mm1.keys(), [1,2,3]));
	size_t old = mm1.getSize();
	auto rr = mm1.removeRange(1);
	assert(old != mm1.getSize());
	assert(rr !is null);
	string[] expectValues = ["one", "eins"];
	foreach(idx, it; rr) {
		assert(it == expectValues[idx]);
	}
	
	size_t nSi = mm1.getSize();
	assert(old != nSi);
	assert(mm1.getSize() == 4, conv!(size_t,string)(mm1.getSize()));
	
	assert(mm1 != mn);
	assert(mm1.begin() == mm1.begin());
	it = mm1.range(3);
	auto jt = mn.range(3);
	assert(it != jt);
	it = mm1.range(3);
	jt = mm1.range(3);
	assert(it == jt);
	jt++;
	assert(it != jt);
	it++;
	assert(it == jt, *it ~ *jt);
	it = mm1.lower(2);
	jt = mm1.upper(3);
	expectValues = ["two", "zwei", "three", "drei"];
	for(size_t idx = 0; it != jt; it++, idx++) {
		assert(*it == expectValues[idx]);
	}

	int[][] lot = [[2811, 1089, 3909, 3593, 1980, 2863, 676, 258, 2499, 3147,
	3321, 3532, 3009, 1526, 2474, 1609, 518, 1451, 796, 2147, 56, 414, 3740,
	2476, 3297, 487, 1397, 973, 2287, 2516, 543, 3784, 916, 2642, 312, 1130,
	756, 210, 170, 3510, 987], [0,1,2,3,4,5,6,7,8,9,10],
	[10,9,8,7,6,5,4,3,2,1,0],[10,9,8,7,6,5,4,3,2,1,0,11],
	[0,1,2,3,4,5,6,7,8,9,10,-1],[11,1,2,3,4,5,6,7,8,0],[]];
	MultiMap!(string,int)[] sa = new MultiMap!(string,int)[3];
	sa[0] = new MultiMap!(string,int)(ISRType.RBTree);
	sa[1] = new MultiMap!(string,int)(ISRType.BinarySearchTree);
	sa[2] = new MultiMap!(string,int)(ISRType.HashTable);
	for(int j = 0; j < 3; j++) {
		foreach(zt;lot) {
			foreach(idx,ht;zt) {
				for(int i = 0; i < 3; i++) {
					assert(!sa[i].contains(conv!(int,string)(ht)));
					sa[i].insert(conv!(int,string)(ht), ht);
					sa[i].insert(conv!(int,string)(ht), ht+1);
					sa[i].insert(conv!(int,string)(ht), ht+2);
					assert(sa[i].contains(conv!(int,string)(ht)));
				}
				assert(sa[0] == sa[1] && sa[1] == sa[2] && sa[0] == sa[2]);
			}
			switch(j) {
			case 0:
				sa[0].clear(); sa[1].clear; sa[2].clear;
				break;
			case 1:
				foreach(kt; sa[0].keys()) {
					sa[0].removeRange(kt);
					sa[1].removeRange(kt);
					sa[2].removeRange(kt);
				}
				break;
			case 2:
				for(int k = 0; k < 3; k++) {
					foreach(kt; sa[k].keys()) {
						while(sa[k].contains(kt))
							sa[k].remove(sa[k].lower(kt));	
					}
				}
				break;
			default:
				assert(0);
			}
			assert(sa[0] == sa[1] && sa[1] == sa[2] && sa[0] == sa[2]);
			assert(sa[0].getSize() == 0, 
				conv!(size_t,string)(sa[0].getSize()) ~ " " ~
				conv!(int,string)(j));
		}
	}
}
