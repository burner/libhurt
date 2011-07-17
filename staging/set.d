module hurt.container.set;

import isr;
import rbtree;
import bst;
import hashtable;
import tree;

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

	public override bool opEquals(Object o) const {
		Set!(T) s = cast(Set!(T))o;
		Iterator!(T) sit = s.begin();
		while(sit.isValid()) {
			if(!this.contains(*sit))
				return false;
		}
	}
}

void main() {
	Set!(int) s1 = new Set!(int)(ISRType.RBTree);
	Set!(int) s2 = new Set!(int)(ISRType.BinarySearchTree);
	Set!(int) s3 = new Set!(int)(ISRType.HashTable);
	s1.insert(5);
	assert(s1.contains(5));
	s1.insert(5);
	s1.remove(5);
	assert(!s1.contains(5));
	s1.insert(5);
	auto it = s1.begin();
	while(it.isValid()) {
		writeln(*it);
		it++;
	}
}
