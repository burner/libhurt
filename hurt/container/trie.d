module hurt.container.trie;

import hurt.container.deque;
import hurt.container.map;
import hurt.container.isr;
import hurt.io.stdio;

private class TrieNode(T,S) {
	private Deque!(T) member;
	private Map!(S,TrieNode!(T,S)) follow;

	this() {
		this.follow = new Map!(S,TrieNode!(T,S))(ISRType.HashTable);
		this.member = new Deque!(T)();
	}

	bool insert(Deque!(S) path, size_t idx, T object) {
		if(idx >= path.getSize()-1) { // reached the end of the path
			this.member.pushBack(object);
			return true;
		} else if(follow.contains(path[idx])) { // has a follow for the path 
			return this.follow.find(path[idx]).getData().
				insert(path, idx+1, object);
		} else if(!follow.contains(path[idx])) { // path not present 
			TrieNode!(T,S) node = new TrieNode!(T,S)();
			this.follow.insert(path[idx], node);
			return node.insert(path, idx+1, object);
		} else {
			assert(false, "shouldn't be reached");
		}
	}

	bool contains(Deque!(S) path, size_t idx) {
		if(idx >= path.getSize()-1) {
			return this.member.getSize() > 0;
		} else {
			//return this.follow.find(path[idx]).getData().
				//contains(path, idx+1);
			MapItem!(S,TrieNode!(T,S)) mapItem = this.follow.find(path[idx]);
			if(mapItem is null) {
				return false;
			}
			assert(mapItem !is null);
			TrieNode!(T,S) tmp =  mapItem.getData();
			assert(tmp !is null);
			return tmp.contains(path, idx+1);
		}
	}

	T find(Deque!(S) path, size_t idx) {
		if(idx >= path.getSize()-1) {
			return this.member[0];
		} else {
			return this.follow.find(path[idx]).getData().
				find(path, idx+1);
		}
	}
}

class Trie(T,S) {
	private Map!(S,TrieNode!(T,S)) follow;
	private size_t size;

	this() {
		this.size = 0;
		this.follow = new Map!(S,TrieNode!(T,S))(ISRType.HashTable);
	}

	bool insert(Deque!(S) path, T object) {
		assert(path.getSize() > 0);
		if(this.follow.contains(path[0])) { // first symbol allready present
			return this.follow.find(path[0]).getData().insert(path, 1, object);
		} else { // need to insert the first symbol into the root
			TrieNode!(T,S) node = new TrieNode!(T,S)();
			this.follow.insert(path[0], node);
			return node.insert(path, 1, object);
		}
	}

	bool contains(Deque!(S) path) {
		// trie path must be at least one element long
		assert(path !is null);
		assert(path.getSize() > 0);
		if(this.follow.contains(path[0])) { 
			TrieNode!(T,S) tmp =  this.follow.find(path[0]).getData();
			assert(tmp !is null);
			return tmp.contains(path, 1);
		} else {
			return false;
		}
	}

	T find(Deque!(S) path) {
		// trie path must be at least one element long
		assert(path !is null);
		assert(path.getSize() > 0);
		if(this.follow.contains(path[0])) { 
			return this.follow.find(path[0]).getData().
				find(path, 1);
		} else {
			static if(is(T : Object)) {
				return null;
			} else {
				return T.init;
			}
		}
	}
}

unittest {
	Trie!(int,int) t = new Trie!(int,int)();
	t.insert(new Deque!(int)([1,2,3,4,5,6,7,8]), 99);
	t.insert(new Deque!(int)([1,2,3,4,5,6,7,8,9]), 999);
	assert(t.contains(new Deque!(int)([1,2,3,4,5,6,7,8])));
	assert(t.contains(new Deque!(int)([1,2,3,4,5,6,7,8,9])));
	t.insert(new Deque!(int)([4,5,6,7,8,9]), 312);
	assert(t.contains(new Deque!(int)([4,5,6,7,8,9])));
	assert(312 == t.find(new Deque!(int)([4,5,6,7,8,9])));
	assert(!t.contains(new Deque!(int)([3,4,5,6,7,8,9])));
}

