module hurt.container.map;

import hurt.container.rbtree;

class MapItem(T,S) : Node {
	T key;
	S data;

	this() {}
	
	this(T key, S data) {
		this.key = key;
		this.data = data;
	}

	override bool opEquals(Object o) {
		Map!(T,S) f = cast(Map!(T,S))o;
		return this.key == f.key;
	}

	override void set(Node toSet) {
		Map!(T,S) c = cast(Map!(T,S))toSet;
		this.key = c.key;
		this.data = c.data;
	}

	override int opCmp(Object o) {
		Map!(T,S) f = cast(Map!(T,S))o;
		T fHash = f.key;
		T thisHash = this.key;
		if(thisHash > fHash)
			return 1;
		else if(thisHash < fHash)
			return -1;
		else
			return 0;
	}
}

class Map(T,S) {
	RBTree!(MapItem!(T,S)) map;

	MapItem!(T,S) finder;

	this() {
		this.map = new RBTree!(MapItem!(T,S))();
		this.finder = new MapItem!(T,S)();
	}

	MapItem!(T,S) find(T key) {
		return null;
	}
}
