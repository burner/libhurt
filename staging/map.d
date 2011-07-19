module hurt.container.map;

import isr;
import rbtree;
import bst;
import hashtable;
import tree;

import hurt.conv.conv;

import std.stdio;

class MapItem(T,S) {
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

	override int opCmp(Object o) const {
		MapItem!(T,S) f = cast(MapItem!(T,S))o;
		if(this.key > f.key)
			return 1;
		else if(this.key < f.key)
			return -1;
		else
			return 0;
	}

	override size_t toHash() const {
		static if(is(T : long) || is(T : int) || is(T : byte) || is(T : char)) {
			return cast(size_t)key;
		} else static if(is(T : long[]) || is(T : int[]) || is(T : byte[])
				|| is(T : char[]) || is(T : immutable(char)[])) {
			size_t ret;
			foreach(it;key) {
				ret = it + (ret << 6) + (ret << 16) - ret;
			}
			return ret;
		} else static if(is(T : Object)) {
			return cast(size_t)key.toHash();
		} else {
			assert(0);
		}
	}

	override string toString() const {
		return conv!(T,string)(this.key) ~ ":" ~ conv!(S,string)(this.data);
	}
}

class Map(T,S) {
	private ISR!(MapItem!(T,S)) map;
	private ISRType type;
	private MapItem!(T,S) finder;


	this(ISRType type=ISRType.RBTree) {
		this.type = type;
		this.finder = new MapItem!(T,S)();
		this.makeMap();
	}

	private void makeMap() {
		if(this.type == ISRType.RBTree) {
			this.map = new RBTree!(MapItem!(T,S))();
		} else if(this.type == ISRType.BinarySearchTree) {
			this.map = new BinarySearchTree!(MapItem!(T,S))();
		} else if(this.type == ISRType.HashTable) {
			this.map = new HashTable!(MapItem!(T,S))();
		}
	}

	public size_t getSize() const { return this.map.getSize(); }
	public size_t isEmpty() const { return this.map.isEmpty(); }

	private MapItem!(T,S) find(T key) {
		this.finder.key = key;
		return cast(MapItem!(T,S))this.map.search(this.finder);
	}

	public bool insert(T key, S data) {
		MapItem!(T,S) fnd = this.find(key);
		if(fnd !is null) {
			fnd.data = data;
			return false;
		} else {
			this.map.insert(new MapItem!(T,S)(key,data));
			return true;
		}
	}
}

void main() {
	Map!(string,int) m1 = new Map!(string,int)();
	m1.insert("foo", 1337);
}
