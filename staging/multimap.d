module multimap;

import hurt.conv.conv;
import hurt.container.iterator;
import hurt.container.rbtree;
import hurt.container.dlst;
import hurt.exception.invaliditeratorexception;

class Iterator(T,S) {
	private ISRIterator!(Item!(T,S)) treeIt;
	private MultiMap!(T,S) map;
	private hurt.container.dlst.Iterator!(S) listIt;
	private bool range;

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
		return (*this.treeIt).getKey();
	}

	protected hurt.container.dlst.Iterator!(S) getListIt() {
		return this.listIt;
	}

	protected ISRIterator!(Item!(T,S)) getTreeIt() {
		return this.treeIt;
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
		if(this.listIt.isValid()) {
			return *this.listIt;
		}
		throw new InvalidIteratorException("MultiMap Iterator is not valid");	
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
		return this.values.empty();
	}

	size_t getSize() const {
		return values.getSize();
	}

	override bool opEquals(Object o) const {
		Item!(T,S) f = cast(Item!(T,S))o;
		return this.key == f.key;
	}

	override int opCmp(Object o) {
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
	private ISR!(T,S) tree;
	private Item!(T,S) finder;
	private size_t size;

	this() {
		this.finder = new Item!(T,S);
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
		ISRIterator!(Item!(T,S)) found = this.tree.find(this.finder);
		this.size++;
		if(found.isValid()) {
			(*found).append(value);
			return new Iterator!(T,S)(found, false, true);
		} else {
			auto treeIt = this.tree.insert(new Item!(T,S)(key, value));
			return new Iterator!(T,S)(this,treeIt, true, true);
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

	Iterator!(T,S) lower(T key) {
		this.finder.key = key;
		hurt.container.rbtree.Iterator!(Item!(T,S)) found = this.tree.findIt(this.finder);
		return new Iterator!(T,S)(this,found, true, false);
	}

	Iterator!(T,S) upper(T key) {
		this.finder.key = key;
		hurt.container.rbtree.Iterator!(Item!(T,S)) found = this.tree.findIt(this.finder);
		Iterator!(T,S) ret = new Iterator!(T,S)(this,found, false, false);
		ret++;
		return ret;
	}
		
	Iterator!(T,S) range(T key) {
		this.finder.key = key;
		hurt.container.rbtree.Iterator!(Item!(T,S)) found = this.tree.findIt(this.finder);
		return new Iterator!(T,S)(this,found, true, true);
	}
	
	size_t getCountKeys() const {
		return this.tree.getSize();
	}

	size_t getSize() const {
		return this.size;
	}

	bool empty() const {
		return this.size == 0;
	}

	T[] keys() {
		T[] ret = new T[this.getCountKeys()];
		auto it = this.tree.begin();
		foreach(ref jt; ret) {
			jt = (*it).getKey();
			it++;
		}
		return ret;
	}

	override bool opEquals(Object o) {
		MultiMap!(T,S) m = cast(MultiMap!(T,S))o;
		T[] tkey = this.keys();
		T[] mkey = m.keys();
		if(!compare!(T)(tkey, mkey)) {
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
		size_t oldSize = (*it.getTreeIt()).getSize();
		size_t newSize = oldSize-1;
		bool listEmpty = it.remove();					
		if(listEmpty) {
			this.size--;
			this.tree.remove(*it.getTreeIt());
		} else {
			oldSize = (*it.getTreeIt()).getSize();
		}
		if(oldSize > newSize) 
			this.size--;
		return listEmpty;
	}

	DLinkedList!(S) removeRange(T key) {
		this.finder.key = key;
		Item!(T,S) it = cast(Item!(T,S))this.tree.find(this.finder);
		if(it !is null) {
			this.tree.remove(this.finder);
			this.size -= it.getSize();
			return it.values;
		} else {
			return null;
		}		
	}

	int validate() {
		return this.tree.validate();
	}

	void clear() {
		this.tree = new RBTree!(Item!(T,S));
	}
}
