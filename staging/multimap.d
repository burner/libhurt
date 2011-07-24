import hurt.container.dlst;

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
