module hurt.container.map;

import hurt.container.rbtree;

class Value(T,S) {
	T key;
	S value;

	this(T key, S value) {
		this.key = key;
		this.value = value;
	}

	override int opCmp(Object o) {
		if(is(o == Value!(T,S))) {
			Value!(T,S) f = cast(Value!(T,S))o;
			if(this.key > f.key)
				return 1;
			else if(this.key < f.key)
				return -1;
			else
				return 0;
		} else if(is(o == T)) {
			T f = cast(T)o;
			if(this.key > f)
				return 1;
			else if(this.key < f)
				return -1;
			else
				return 0;
		}
		return 1;
	}
}

class Map(T,S) : RBTree!(Value!(T,S)) {
	this() {
		super();
	}

	Value!(T,S) insert(T key, S data) {
		Value!(T,S) it = new Value!(T,S)(key,data);
		Node!(Value!(T,S)) tmp = super.find(it);
		if(tmp is null) {
			super.insert(it);
			return it;
		} else {
			return tmp.data;
		}
	}

	Value!(T,S) find(T key) {
			return null;
	}

	Value!(T,S) remove(T key) {
		return null;
	}
}
