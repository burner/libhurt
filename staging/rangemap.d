module hurt.container.rangemap;

import hurt.container.multimap;
import hurt.container.map;
import hurt.algo.sorting;
import hurt.io.stdio;

private class Node(T,S) {
	private T first;
	private T last;
	private S value;
	private bool lastSet;

	private Node!(T,S) left, right;

	this(T first, S value) {
		this.first = first;
		this.value = value;
		this.lastSet = false;
	}

	this(T first, T last, S value) {
		this.first = first;
		this.last = last;
		this.value = value;
		this.lastSet = true;
	}

	public bool canExpend(T next) const {
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

	public void expend(T next) {
		if(!this.canExpend(next)) {
			return;
		}
		if(lastSet) {
			this.last = next;
		} else {
			this.last = next;
			this.lastSet = true;
		}
	}

	public T getFirst() const {
		return this.first;
	}

	public T getLast() const {
		return this.last;
	}

	public Node!(T,S) getLeft() {
		return this.left;
	}

	public Node!(T,S) getRight() {
		return this.right;
	}

	public S getValue() {
		return this.value;
	}

	public bool isLastSet() const {
		return this.lastSet;
	}

	package bool setNode(Node!(T,S) node) {
		if(node is null) {
			return true;
		} else if(node.isLastSet() && node.getLast() < this.first) {
			this.left = node;
		} else if(!node.isLastSet() && node.getFirst() < this.first) {
			this.left = node;
		} else if(this.lastSet && node.getFirst() > this.last) {
			this.right = node;
		} else if(!this.lastSet && node.getFirst() > this.first) {
			this.right = node;
		} else {
			return false;
		}
		return true;
	}
}

unittest {
	Node!(dchar,int) n = new Node!(dchar,int)('a',0);
	assert(n.canExpend('b'));
	assert(!n.canExpend('c'));
	n.expend('b');
	assert(n.canExpend('c'));
	assert(!n.canExpend('b'));

	Node!(dchar,int) m = new Node!(dchar,int)('h', 'i', 0);
	Node!(dchar,int) i = new Node!(dchar,int)('a', 'b', 1);
	Node!(dchar,int) j = new Node!(dchar,int)('m', 'o', 2);
	assert(!m.setNode(m));
	assert(!i.setNode(i));
	assert(!j.setNode(j));
	assert(m.setNode(i));
	assert(m.setNode(j));
	assert(m.getLeft() is i);
	assert(m.getRight() is j);

	Node!(dchar,int) m1 = new Node!(dchar,int)('h', 0);
	Node!(dchar,int) i1 = new Node!(dchar,int)('a', 1);
	Node!(dchar,int) j1 = new Node!(dchar,int)('m', 2);
	assert(!m1.setNode(m1));
	assert(!i1.setNode(i1));
	assert(!j1.setNode(j1));
	assert(m1.setNode(i1));
	assert(m1.setNode(j1));
	assert(m1.getLeft() is i1);
	assert(m1.getRight() is j1);
}

class RangeMap(T,S) {
	private Node!(T,S) root;

	this() { }

	this(Node!(T,S)[] nodes) {
		if(nodes.length == 0)
			return;

		sort!(Node!(T,S))(nodes, 
			function(in Node!(T,S) a, in Node!(T,S) b) {
				return a.getFirst() < b.getFirst(); 
			});

		size_t middle = (0 + nodes.length)/2;
		this.root = nodes[middle];
		assert(this.root.setNode(recursiveTreeCreate(nodes, 0, middle)));
		assert(this.root.setNode(recursiveTreeCreate(nodes, middle+1, 
			nodes.length)));

	}

	private static Node!(T,S) recursiveTreeCreate(Node!(T,S)[] nodes, 
			size_t left, size_t right) {
		if(left >= right) {
			return null;
		}
		size_t middle = (left + right)/2;
		Node!(T,S) mid = nodes[middle];
		assert(mid.setNode(recursiveTreeCreate(nodes, left, middle)));
		assert(mid.setNode(recursiveTreeCreate(nodes, middle+1, right)));
		return mid;
	}

	package static bool validate(Node!(T,S) node) {
		if(node is null)
			return true;

		Node!(T,S) left = node.getLeft();
		Node!(T,S) right = node.getRight();
		if(left !is null) {
			if(left.isLastSet && node.getFirst() < left.getLast())
				return false;
			else if(!left.isLastSet() && node.getFirst() < left.getFirst())
				return false;
		}
		if(right !is null) {
			if(right.isLastSet && node.getLast() > right.getFirst())
				return false;
			else if(!node.isLastSet() && node.getFirst() > right.getFirst())
				return false;
		}
		return validate(left) && validate(right);
	}

	package bool validate() {
		return validate(this.root);
	}
}

unittest {
	Node!(dchar,int)[] ar1 = new Node!(dchar,int)[1];
	ar1[0] = new Node!(dchar,int)('a',0);
	RangeMap!(dchar,int) m1 = new RangeMap!(dchar,int)(ar1);
	assert(m1.validate());
	for(size_t i = 1; i < 26; i++) {
		ar1 = new Node!(dchar,int)[i];
		for(size_t j = 0; j < i; j++) {
			ar1[j] = new Node!(dchar,int)(cast(dchar)(j+97), cast(int)j);
		}
		m1 = new RangeMap!(dchar,int)(ar1);
		assert(m1.validate());
	}
}

void main() {
	RangeMap!(dchar,int) rm = new RangeMap!(dchar,int)();
}
