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
		MapItem!(T,S) f = cast(MapItem!(T,S))o;
		return this.key == f.key;
	}

	override void set(Node toSet) {
		MapItem!(T,S) c = cast(MapItem!(T,S))toSet;
		this.key = c.key;
		this.data = c.data;
	}

	override int opCmp(Object o) {
		MapItem!(T,S) f = cast(MapItem!(T,S))o;
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

public class Map(T,S) {
	RBTree!(MapItem!(T,S)) map;

	MapItem!(T,S) finder;

	this() {
		this.map = new RBTree!(MapItem!(T,S))();
		this.finder = new MapItem!(T,S)();
	}

	MapItem!(T,S) find(T key) {
		this.finder.key = key;
		MapItem!(T,S) found = cast(MapItem!(T,S))this.map.find(this.finder);
		return found;
	}

	MapItem!(T,S) insert(T key, S data) {
		MapItem!(T,S) found = this.find(key);
		if(found is null) {
			found = new MapItem!(T,S)(key, data);
			this.map.insert(found);
			return found;
		} else {
			found.data = data;
			return found;
		}
	}

	Iterator!(MapItem!(T,S)) begin() {
		return this.map.begin();
	}

	Iterator!(MapItem!(T,S)) end() {
		return this.map.end();
	}

	int opApply(scope int delegate(ref T, ref S) dg) {
		Iterator!(MapItem!(T,S)) it = this.begin();
		while(it.isValid()) {
			T key = cast(T)(*it).key;
			S data = cast(S)(*it).data;
			if(int r = dg(key, data)) {
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
