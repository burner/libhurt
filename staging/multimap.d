module multimap;

import hurt.conv.conv;
import hurt.container.iterator;
import hurt.container.rbtree;
import hurt.container.dlst;
import hurt.exception.invaliditeratorexception;

class Iterator(T,S) {
	private hurt.container.rbtree.Iterator!(Item!(T,S)) treeIt;
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
