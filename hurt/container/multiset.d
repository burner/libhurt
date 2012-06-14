module hurt.container.multiset;

import hurt.container.isr;
import hurt.container.binvec;
import hurt.container.bst;
import hurt.container.dlst;
import hurt.container.hashtable;
import hurt.container.rbtree;
import hurt.string.formatter;
import hurt.conv.conv;
import hurt.io.stdio;
import hurt.util.slog;

class Item(T) {
	package T value;
	package Item!(T) next;
	package size_t childs;

	this() {
		this.childs = 0;
	}

	this(T value, Item!(T) next = null) {
		this.value = value;
		this.next = next;
		if(this.next is null) {
			this.childs = 0;
		} else {
			this.childs = this.next.childs+1;
			//log("%d %d", this.childs, this.next.childs);
		}
	}

	T getValue() {
		return this.value;
	}

	override hash_t toHash() const {
		static if(is(T : long) || is(T : int) || is(T : byte) || is(T : char)) {
			return cast(size_t)value;
		} else static if(is(T : long[]) || is(T : int[]) || is(T : byte[])
				|| is(T : char[]) || is(T : immutable(char)[])) {
			size_t ret;
			foreach(it;value) {
				ret = it + (ret << 6) + (ret << 16) - ret;
			}
			return ret;
		} else static if(is(T : Object)) {
			return cast(size_t)value.toHash();
		} else {
			return value.toHash();
		}
	}

	override bool opEquals(Object o) const {
		auto i = cast(Item!T)o;
		return this.toHash() == i.toHash();
	}

	override int opCmp(Object o) const {
		auto i = cast(Item!T)o;
		if(this.toHash() > i.toHash())
			return 1;
		else if(this.toHash() < i.toHash())
			return -1;
		else
			return 0;
	}
}

class MultiSet(T) {
	ISR!(Item!(T)) tree;
	ISRType type;

	this(ISRType type = ISRType.RBTree) {
		this.type = type;
		this.makeMap();
	}

	private void makeMap() {
		if(this.type == ISRType.RBTree) {
			this.tree = new RBTree!(Item!(T))();
		} else if(this.type == ISRType.BinarySearchTree) {
			this.tree = new BinarySearchTree!(Item!(T))();
		} else if(this.type == ISRType.HashTable) {
			this.tree = new HashTable!(Item!(T))();
		} else if(this.type == ISRType.BinVec) {
			this.tree = new BinVec!(Item!(T))();
		}
	}

	size_t insert(T toInsert) {
		auto finder = new Item!(T)(toInsert);
		auto node = this.tree.search(finder);
		
		Item!(T) item;
		if(node is null) {
			item = new Item!(T)(toInsert, null);
		} else {
			//log("item %d %d",toInsert, node.getData().childs);
			auto tmp = node.getData();
			assert(this.tree.remove(finder));
			item = new Item!(T)(toInsert, tmp);
		}

		bool rslt = this.tree.insert(item);
		assert(rslt);
		//this.debugPrint();
		return item.childs;
	}

	size_t contains(T toSearch) {
		auto finder = new Item!(T)(toSearch);
		auto tmp = this.tree.search(finder);
		if(tmp is null) {
			return 0;
		} else {
			return tmp.getData().childs+1;
		}
	}

	T peek(T toPeek) {
		auto finder = new Item!(T)(toPeek);
		auto tmp = this.tree.search(finder);
		if(tmp is null) {
			assert(false);
		} else {
			return tmp.getData().value;
		}
	}

	T remove(T toRemove) {
		auto finder = new Item!(T)(toRemove);
		auto node = this.tree.search(finder);
		auto tmp = node.getData();
		bool rslt = this.tree.remove(finder);
		assert(rslt);
		assert(node !is null);

		// reinsert the next item
		auto next = tmp.next;
		if(next !is null) {
			this.tree.insert(next);
		}

		return node.getData().value;
	}

	void debugPrint() {
		auto it = this.tree.begin();
		for(; it.isValid(); it++) {
			printf("%d: ", (*it).toHash());
			auto jt = *it;
			for(; jt !is null; jt = jt.next) {
				printf("%d,", jt.childs);
			}
			println();
		}
		println("\n\n\n");
	}

	int opApply(int delegate(T, size_t) dg) {
		auto it = this.tree.begin();
		for(; it.isValid(); it++) {
			auto tmp = *it;
			if(int r = dg(tmp.value,tmp.childs+1)) {
				return r;
			}
		}
		return 0;
	}

	size_t getSize() const {
		return this.tree.getSize();
	}

	bool isEmpty() const {
		return this.tree.getSize() == 0;
	}

	override bool opEquals(Object o) {
		auto i = cast(MultiSet!(T))o;
		if(this.getSize() != i.getSize()) {
			return false;
		}

		foreach(value,size; this) {
			if(size != i.contains(value)) {
				return false;
			}
		}
		return true;
	}

}

unittest {
	class Int {
		int a;

		this(int a) {
			this.a = a;
		}

		override hash_t toHash() const {
			return a;
		}

		override int opCmp(Object o) const {
			auto i = cast(Int)o;
			if(this.toHash() > i.toHash())
				return 1;
			else if(this.toHash() < i.toHash())
				return -1;
			else
				return 0;
		}

		override bool opEquals(Object o) const {
			auto i = cast(Int)o;
			return i.toHash() == this.toHash();
		}
	}
	auto zz = new Int(10);
	assert(zz.toHash() == 10, conv!(hash_t,string)(zz.toHash()));

	int data[100] = [
	27, 18, 22, 10, 29, 32, 19, 11, 20, 12, 
	8 , 26, 3 , 27, 4 , 22, 10, 7 , 21, 10, 
	10, 35, 1 , 14, 0 , 16, 1 , 14, 28, 16, 
	36, 15, 7 , 33, 38, 7 , 6 , 35, 32, 24, 
	15, 4 , 10, 17, 9 , 0 , 19, 11, 31, 1 , 
	24, 5 , 31, 28, 10, 20, 19, 32, 23, 39, 
	27, 17, 25, 10, 11, 15, 6 , 8 , 28, 31, 
	1 , 16, 18, 18, 39, 14, 38, 9 , 30, 0 , 
	1 , 31, 20, 36, 35, 22, 35, 31, 29, 7 , 
	19, 4 , 9 , 18, 13, 12, 34, 27, 35, 43];

	int check[50];

	MultiSet!(Int) set = new MultiSet!(Int)();
	foreach(idx, it; data) {
		size_t t = set.insert(new Int(it));
		check[it]++;
		assert(check[it] == set.contains(new Int(it)),
			format("at pos %u %d contained %d != %d childs %d",idx, it, check[it], 
			set.contains(new Int(it)), t));
	}

	foreach(idx, it; data) {
		assert(set.contains(new Int(it)));
	}

	foreach(value,size;set) {
		//log("%2d %2d", value.a, size);
	}
	
	foreach(idx, it; data) {
		set.remove(new Int(it));
		check[it]--;
		assert(check[it] == set.contains(new Int(it)),
			format("at pos %u %d contained %d != %d",idx, it, check[it], 
			set.contains(new Int(it))));
	}

	foreach(idx, it; data) {
		assert(!set.contains(new Int(it)));
	}
	assert(set.isEmpty());

}

unittest {
	int data[100] = [
	27, 18, 22, 10, 29, 32, 19, 11, 20, 12, 
	8 , 26, 3 , 27, 4 , 22, 10, 7 , 21, 10, 
	10, 35, 1 , 14, 0 , 16, 1 , 14, 28, 16, 
	36, 15, 7 , 33, 38, 7 , 6 , 35, 32, 24, 
	15, 4 , 10, 17, 9 , 0 , 19, 11, 31, 1 , 
	24, 5 , 31, 28, 10, 20, 19, 32, 23, 39, 
	27, 17, 25, 10, 11, 15, 6 , 8 , 28, 31, 
	1 , 16, 18, 18, 39, 14, 38, 9 , 30, 0 , 
	1 , 31, 20, 36, 35, 22, 35, 31, 29, 7 , 
	19, 4 , 9 , 18, 13, 12, 34, 27, 35, 43];

	int check[50];

	MultiSet!(int) set = new MultiSet!(int)();
	foreach(idx, it; data) {
		size_t t = set.insert(it);
		check[it]++;
		assert(check[it] == set.contains(it), 
			format("at pos %u %d contained %d != %d childs %d",idx, it, check[it], 
			set.contains(it), t));
	}

	foreach(idx, it; data) {
		assert(set.contains(it));
	}

	/*foreach(value,size;set) {
		log("%2d %2d", value, size);
	}*/
	
	foreach(idx, it; data) {
		set.remove(it);
		check[it]--;
		assert(check[it] == set.contains(it), 
			format("at pos %u %d contained %d != %d",idx, it, check[it], 
			set.contains(it)));
	}

	foreach(idx, it; data) {
		assert(!set.contains(it));
	}
	assert(set.isEmpty());
	
}

version(staging) {
void main() {
}
}

