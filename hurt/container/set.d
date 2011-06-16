module hurt.container.map;

import hurt.container.rbtree;

import std.stdio;

class SetItem(T) : Node {
	T key;

	this() {}
	
	this(T key) {
		this.key = key;
	}

	override bool opEquals(Object o) {
		SetItem!(T) f = cast(SetItem!(T))o;
		return this.key == f.key;
	}

	override void set(Node toSet) {
		SetItem!(T) c = cast(SetItem!(T))toSet;
		this.key = c.key;
	}

	override int opCmp(Object o) {
		SetItem!(T) f = cast(SetItem!(T))o;
		T fHash = f.key;
		T thisHash = this.key;
		if(thisHash > fHash)
			return 1;
		else if(thisHash < fHash)
			return -1;
		else
			return 0;
	}

	public S opUnary(string s)() if(s == "*") {
		return this.data;
	}
}

class Set(T) {
	RBTree!(SetItem!(T)) map;

	SetItem!(T) finder;

	this() {
		this.map = new RBTree!(SetItem!(T))();
		this.finder = new SetItem!(T)();
	}

	SetItem!(T) find(T key) {
		this.finder.key = key;
		SetItem!(T) found = cast(SetItem!(T))this.map.find(this.finder);
		return found;
	}

	SetItem!(T) insert(T key) {
		SetItem!(T) found = this.find(key);
		if(found is null) {
			found = new SetItem!(T)(key);
			this.map.insert(found);
		}
		return found;
	}

	Iterator!(SetItem!(T)) begin() {
		return this.map.begin();
	}

	Iterator!(SetItem!(T)) end() {
		return this.map.end();
	}

	bool contains(T key) {
		this.finder.key = key;
		return this.map.findIt(this.finder).isValid();
	}

	int opApply(scope int delegate(ref T) dg) {
		Iterator!(SetItem!(T)) it = this.begin();
		while(it.isValid()) {
			T key = cast(T)(*it).key;
			if(int r = dg(key)) {
				return r;
			}
			it++;
		}
		return 0;
	}

	bool remove(T key) {
		this.finder.key = key;
		return this.map.remove(this.finder);
	}
	
	size_t getSize() const {
		return map.getSize();
	}
}
