module hurt.container.rangemap;

import hurt.container.multimap;
import hurt.container.map;

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

	public S getValue() {
		return this.value;
	}

	public bool isLastSet() const {
		return this.lastSet;
	}

	package void setNode(Node!(T,S) node) {
		if(node.getFirst() < this.first && node.getLast < this.first) {
			this.left = node;
		} else if(node.isLastSet() && this.lastSet && 
				node.getFirst() > this.last) {
			this.right = node;
		} else if(node.isLastSet() && !this.lastSet && 
				node.getFirst() > this.first) {
			this.right = node;
		} else {
			assert(0, "node is not smaller nor bigger, thats wrong");
		}
	}

}

unittest {
	Node!(dchar,int) n = new Node!(dchar,int)('a',0);
	assert(n.canExpend('b'));
	assert(!n.canExpend('c'));
	n.expend('b');
	assert(n.canExpend('c'));
	assert(!n.canExpend('b'));
}

class RangeMap(T,S) {
}

void main() {
	RangeMap!(dchar,int) rm = new RangeMap!(dchar,int)();
}
