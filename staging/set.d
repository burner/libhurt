module hurt.container.set;

import isr;
import rbtree;
import bst;
import hashtable;
import tree;

import hurt.conv.conv;

import std.stdio;

class Set(T) {
	ISR!(T) map;
	ISRType type;

	this(ISRType type=ISRType.RBTree) {
		this.type = type;
		this.makeMap();
	}

	private void makeMap() {
		if(this.type == ISRType.RBTree) {
			this.map = new RBTree!(T)();
		} else if(this.type == ISRType.BinarySearchTree) {
			this.map = new BinarySearchTree!(T)();
		} else if(this.type == ISRType.HashTable) {
			this.map = new HashTable!(T)();
		}
	}

	public size_t getSize() const { return this.map.getSize(); }
	public size_t isEmpty() const { return this.map.isEmpty(); }

	public bool contains(T data) {
		ISRNode!(T) it = this.map.search(data);	
		return it !is null;
	}

	public bool insert(T data) {
		return this.map.insert(data);
	}

	public bool remove(T data) {
		return this.map.remove(data);
	}

	ISRIterator!(T) begin() {
		return this.map.begin();
	}

	ISRIterator!(T) end() {
		return this.map.end();
	}

	public void clear() {
		this.makeMap();
	}

	public Set!(T) dup() {
		Set!(T) ret = new Set!(T)(this.type);
		ISRIterator!(T) it = this.begin();

		for(;it.isValid(); it++)
			ret.insert(*it);

		return ret;
	}

	public override bool opEquals(Object o) {
		Set!(T) s = cast(Set!(T))o;
		ISRIterator!(T) sit = s.begin();
		while(sit.isValid()) {
			if(!this.contains(*sit))
				return false;
			sit++;
		}
		sit = this.begin();
		while(sit.isValid()) {
			if(!s.contains(*sit))
				return false;
			sit++;
		}
		return this.getSize() == s.getSize();
	}
}

void main() {
	Set!(int)[] sa = new Set!(int)[3];
	sa[0] = new Set!(int)(ISRType.RBTree);
	sa[1] = new Set!(int)(ISRType.BinarySearchTree);
	sa[2] = new Set!(int)(ISRType.HashTable);
	for(int i = 0; i < 3; i++) {
		assert(sa[i].insert(i), conv!(int,string)(i));
		assert(sa[i].contains(i), conv!(int,string)(i));
		assert(sa[i].remove(i), conv!(int,string)(i));
		assert(!sa[i].contains(i), conv!(int,string)(i));
		assert(sa[i].insert(i), conv!(int,string)(i));
	}
}
