import hurt.container.rbtree;
import hurt.container.dlst;

class Iterator(T,S) {
	hurt.container.rbtree.Iterator!(Item!(T,S)) treeIt;
	DLinkedList!(S).Iterator!(S) listIt;
	private bool valid;
	private bool range;

	this(hurt.container.rbtree.Iterator!(Item!(T,S)) it, bool begin = true, bool range = true) {
		this.treeIt = it;
		this.range = range;
		if(this.treeIt is null) {
			this.valid = false;
			return;
		}
		if(begin) {
			this.listIt = (*this.treeIt).getFirst();
		} else {
			this.listIt = (*this.treeIt).getLast();
		}
		this.valid = true;
	}

	bool isValid() const {
		return this.valid;
	}
}

class Item(T,S) : Node {
	private T key;
	private DLinkedList!(S) values;

	this() { }

	this(T key, S first) {
		this.key = key;
		this.values = new DLinkedList!(S)();
		this.values.pushBack(first);
	}	

	public void append(S value) {
		this.values.pushBack(value);
	}

	protected DLinkedList!(S).Iterator!(S) getFirst() {
		return this.values.begin();
	}

	protected DLinkedList!(S).Iterator!(S) getLast() {
		return this.values.end();
	}

	override bool opEquals(Object o) const {
		Item!(T,S) f = cast(Item!(T,S))o;
		return this.key == f.key;
	}

	override void set(Node toSet) {
		Item!(T,S) c = cast(Item!(T,S))toSet;
		this.key = c.key;
		this.values = c.values;
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
	RBTree!(Item!(T,S)) tree;
	Item!(T,S) finder;

	this() {
		this.tree = new RBTree!(Item!(T,S));
		this.finder = new Item!(T,S);
	}

	Iterator!(T,S) insert(T key, S value) {
		this.finder.key = key;
		Item!(T,S) found = cast(Item!(T,S))this.tree.find(this.finder);
		if(found is null) {
			this.tree.insert(new Item!(T,S)(key, value));
			return null; // TODO upper limit
		} else {
			found.append(value);
			return null; // TODO upper limit
		}
	}

	Iterator!(T,S) begin() {
		auto tmp = this.tree.begin();
		return new Iterator!(T,S)(tmp);
	}

	Iterator!(T,S) end() {
		auto tmp = this.tree.end();
		return new Iterator!(T,S)(tmp, false, false);
	}
		
	Iterator!(T,S) upper(T key) {
		this.finder.key = key;
		Item!(T,S) found = cast(Item!(T,S))this.tree.find(this.finder);
		return new Iterator!(T,S)(found, false, true);
	}

	Iterator!(T,S) lower(T key) {
		this.finder.key = key;
		Item!(T,S) found = cast(Item!(T,S))this.tree.find(this.finder);
		return new Iterator!(T,S)(found, true, true);
	}
		
}

void main() {
	auto mm = new MultiMap!(uint, string)();	
}
