module hurt.container.arraytree;

import hurt.container.isr;
import hurt.container.stack;
import hurt.conv.conv;
import hurt.util.random.random;
import hurt.util.datetime;
import hurt.io.stdio;
import hurt.string.formatter;
import hurt.util.slog;

public class Iterator(T) : ISRIterator!(T) {
	private ArrayTree!(T) tree;
	private long idx;

	this(ArrayTree!(T) tree, long idx) {
		this.tree = tree;
		this.idx = idx;
	}

	override ISRIterator!(T) dup() {
		return new Iterator!(T)(this.tree, this.idx);
	}

	//void opUnary(string s)() if(s == "++") {
	override void increment() {
		long y;
		if(-1 != (y = this.tree.nodes[this.idx].link[true])) {
			while(this.tree.nodes[y].link[false] != -1) {
				y = this.tree.nodes[y].link[false];
			}
			this.idx = y;
		} else {
			y = this.tree.nodes[this.idx].parent;
			while(y != -1 && this.idx == this.tree.nodes[y].link[true]) {
				this.idx = y;
				y = this.tree.nodes[y].parent;
			}
			this.idx = y;
		}
	}	

	override T getData() {
		return this.tree.nodes[this.idx].getData();
	}

	//void opUnary(string s)() if(s == "--") {
	override void decrement() {
		long y;
		if(-1 !is (y = this.tree.nodes[this.idx].link[false])) {
			while(this.tree.nodes[y].link[true] != -1) {
				y = this.tree.nodes[y].link[true];
			}
			this.idx = y;
		} else {
			y = this.tree.nodes[this.idx].parent;
			while(y !is -1 && this.idx == this.tree.nodes[y].link[false]) {
				this.idx = y;
				y = this.tree.nodes[y].parent;
			}
			this.idx = y;
		}
	}

	override bool isValid() const {
		return this.idx != -1 && 
			this.tree.nodes[this.idx] != Node!(T)(this.tree);
	}

	T opUnary(string s)() if(s == "*") {
		return this.tree.nodes[this.idx].data;
	}
}

public struct Node(T) {
	private ArrayTree!(T) tree;
	T data;
	bool red;
	bool invalid;

	long link[2];
	long parent;

	package this(const ArrayTree!(T) tree) {
		//this.tree = tree;
		this.parent = -1;
        this.link[0] = -1;
        this.link[1] = -1;
		this.invalid = true;
	}

	package this(ArrayTree!(T) tree) {
		this.tree = tree;
		this.parent = -1;
        this.link[0] = -1;
        this.link[1] = -1;
		this.invalid = true;
	}

	this(ArrayTree!(T) tree, T data) {
		this.tree = tree;
		this.data = data;
		this.red = true;
        this.link[0] = -1;
        this.link[1] = -1;
		this.parent = -1;
		this.invalid = false;
	}

	T getData() {
		return this.data;
	}

	bool isValid() const {
		return !this.invalid;
	}

	bool validate(bool root, const Node!(T) par) const {
		if(!root) {
			if(this.parent == -1) {
				println(__FILE__,__LINE__,": parent is null");
				return false;
			}
			if(this.tree.nodes[this.parent] != par) {
				println(__FILE__,__LINE__,": parent is wrong ");
					//, parent.data, 
					//" ",par.data);
				return false;
			}
		}
		bool left = true;
		bool right = true;
		if(this.link[0] != -1 && this.tree.nodes[this.link[0]].isValid()) {
			assert(this.tree.nodes[this.tree.nodes[this.link[0]].parent] == 
				this);
			left = this.tree.nodes[this.link[0]].validate(false, this);
		}
		if(this.link[1] != -1 && this.tree.nodes[this.link[1]].isValid()) {
			assert(this.tree.nodes[this.tree.nodes[this.link[1]].parent] ==
				this);
			right = this.tree.nodes[this.link[1]].validate(false, this);
		}
		return left && right;
	}

	/*public void print() const {
		//println(this.data);
		if(this.link[0] != -1) {
			this.tree.nodes[this.link[0]].print();
		}
		if(this.link[1] != -1) {
			this.tree.nodes[this.link[1]].print();
		}
	}*/

	public string toString() const {
		static if(is(T : int)) {
			return format("[%d:%d:%d= %d]", this.parent, this.link[0], 
				this.link[1], this.data);
		} else {
			return format("[%d:%d:%d]", this.parent, this.link[0], 
				this.link[1]);
		}
	}
}

abstract class ArrayTree(T) {
	protected size_t size;
	package Node!(T)[] nodes;
	protected Stack!(size_t) inBetween;
	protected size_t tail;
	protected long root;

	this() {
		this.grow();
		this.size = 0;
		this.root = -1;
		this.tail = 0;
		this.inBetween = new Stack!(size_t)(32);
	}

	private void grow() {
		size_t old;
		if(this.nodes is null) {
			old = 0;
			this.nodes = new Node!(T)[32];
		} else {
			this.nodes.length = this.nodes.length * 2;
		}

		for(size_t i = old; i < this.nodes.length; i++) {
			this.nodes[i] = Node!(T)(this);
		}
	}

	public size_t getSize() const {
		return this.size;
	}

	protected void releaseNode(size_t idx) {
		this.nodes[idx] = Node!(T)(this);
		if(idx + 1 == this.tail) {
			this.tail--;
		} else {
			this.inBetween.push(idx);
		}
	}

	protected size_t newNode() {
		if(!this.inBetween.isEmpty()) {
			return this.inBetween.pop();
		} else if(this.tail == nodes.length) {
			this.grow();
			return this.tail++;
		} else {
			return this.tail++;
		}
	}

	Iterator!(T) begin() {
		long be = this.root;
		if(be == -1) {
			return new Iterator!(T)(this, -1);
		}

		int count = 0;
		while(this.nodes[be].link[0] != -1) {
			be = this.nodes[be].link[0];
			count++;
		}
		auto it = new Iterator!(T)(this, be);
		return it;	
	}

	Iterator!(T) end() {
		long end = this.root;
		if(end == -1) {
			return new Iterator!(T)(this, -1);
		}
		while(this.nodes[end].link[1] != -1) {
			end = this.nodes[end].link[1];
		}
		return new Iterator!(T)(this, end);
	}

	public T[] values() {
		if(this.size == 0) {
			return null;
		}
		T[] ret = new T[this.size];
		size_t ptr = 0;
		Iterator!(T) it = this.begin();
		//println(__LINE__," ", it.isValid());
		while(it.isValid()) {
			//println(ptr, " ", *it);
			ret[ptr++] = *it;
			it.increment();
		}
		assert(ptr == ret.length, conv!(size_t,string)(ptr) ~ " " ~
			conv!(size_t, string)(ret.length));
		return ret;
	}

	void clear() {
		for(size_t i = 0; i < this.nodes.length; i++) {
			this.nodes[i] = Node!(T)(this);
		}
	    this.size = 0;
	}
	 
	bool isEmpty() const {
	    return this.root == -1;
	}
}
/*
unittest {
	bool compare(T)(RBTree!(T) rb, HashTable!(T) ht, BinarySearchTree!(T) bst, 
			T[T] dht) {
		assert(bst.getSize() == rb.getSize() 
			&& ht.getSize() == dht.length
			&& bst.getSize() == ht.getSize());
		bool ret = true;
		foreach(it;dht.values()) {
			ret = bst.search(it) ? true : false;	
			ret = ret && rb.search(it) ? true : false;	
			ret = ret && ht.search(it) ? true : false;	
			if(!ret) {
				println(__LINE__);
				return false;
			}
		}

		foreach(it;rb.values()) {
			ret = bst.search(it) ? true : false;	
			ret = ret && it in dht ? true : false;	
			ret = ret && ht.search(it) ? true : false;	
			if(!ret) {
				println(__LINE__);
				return false;
			}
		}
				
		foreach(it;ht.values()) {
			ret = bst.search(it) ? true : false;	
			ret = ret && it in dht ? true : false;	
			ret = ret && rb.search(it) ? true : false;	
			if(!ret) {
				println(__LINE__);
				return false;
			}
		}
				
		foreach(it;bst.values()) {
			ret = ht.search(it) ? true : false;	
			ret = ret && it in dht ? true : false;	
			ret = ret && rb.search(it) ? true : false;	
			if(!ret) {
				println(__LINE__);
				return false;
			}
		}
				
		return true;
	}
	
	Random rand = new Random();

	int dim = 15;
	int[][] num = new int[][dim];
	int startSize = 32;
	foreach(ref it; num) {
		it = new int[startSize*=2];
		foreach(ref jt;it) {
			jt = rand.uniform!(int)();
		}
	}

	int iteration = 4;
	long[][][] times = new long[][][](4,3,dim);
	long start;
	for(int i = 0; i < iteration; i++) {
		foreach(idx, it; num) {
			BinarySearchTree!(int) bst = new BinarySearchTree!(int)();
			start = getMilli();
			foreach(jt; it)
				bst.insert(jt);
			times[0][0][idx] += getMilli() - start;

			RBTree!(int) rb = new RBTree!(int)();
			start = getMilli();
			foreach(jt; it)
				rb.insert(jt);
			times[1][0][idx] += getMilli() - start;

			int[int] das;
			start = getMilli();
			foreach(jt; it)
				das[jt] = jt;
			times[2][0][idx] += getMilli() - start;

			HashTable!(int) ht = new HashTable!(int)(false);
			start = getMilli();
			foreach(jt; it)
				ht.insert(jt);
			times[3][0][idx] += getMilli() - start;

			assert(compare!(int)(rb, ht, bst, das));

			start = getMilli();
			foreach(jt; it)
				assert(bst.search(jt));
			times[0][1][idx] += getMilli() - start;

			start = getMilli();
			foreach(jt; it)
				assert(rb.search(jt));
			times[1][1][idx] += getMilli() - start;

			start = getMilli();
			foreach(jt; it)
				assert(jt in das);
			times[2][1][idx] += getMilli() - start;

			start = getMilli();
			foreach(jt; it)
				assert(ht.search(jt));
			times[3][1][idx] += getMilli() - start;

			/*start = getMilli();
			foreach(jt; it)
				bst.remove(jt);
			times[0][2][idx] += getMilli() - start;

			start = getMilli();
			foreach(jt; it)
				rb.remove(jt);
			times[1][2][idx] += getMilli() - start;

			start = getMilli();
			foreach(jt; it)
				das.remove(jt);	
			times[2][2][idx] += getMilli() - start;

			start = getMilli();
			foreach(jt; it)
				ht.remove(jt);	
			times[3][2][idx] += getMilli() - start;

			//println(it.length);
			
		}
	}
	/*writefln("%7s: %5s %5s %5s %5s","insert", "bst", "rbtree", "d", "hm");
	for(int i = 0; i < dim; i++) {	
		writefln("%7d:  %5d %5d %5d %5d", num[i].length,
			times[0][0][i]/iteration, times[1][0][i]/iteration,
			times[2][0][i]/iteration,times[3][0][i]/iteration);
	}

	writefln("\n%7s: %5s %5s %5s %5s","search", "bst", "rbtree", "d", "hm");
	for(int i = 0; i < dim; i++) {	
		writefln("%7d: %5d  %5d %5d %5d", num[i].length,
			times[0][1][i]/iteration, times[1][1][i]/iteration,
			times[2][1][i]/iteration,times[3][1][i]/iteration);
	}

	writefln("\n%7s: %5s %5s %5s %5s","remove", "bst", "rbtree", "d", "hm");
	for(int i = 0; i < dim; i++) {	
		writefln("%7d: %5d  %5d %5d %5d", num[i].length,
			times[0][2][i]/iteration, times[1][2][i]/iteration,
			times[2][2][i]/iteration,times[3][2][i]/iteration);
	}

}*/
