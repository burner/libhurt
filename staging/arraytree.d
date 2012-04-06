module hurt.container.arraytree;

import hurt.container.isr;
import hurt.container.stack;
import hurt.conv.conv;
import hurt.util.random.random;
import hurt.util.datetime;
import hurt.io.stdio;

/*
public class Iterator(T) : ISRIterator!(T) {
	private Node!(T) current;

	this(Node!(T) current) {
		this.current = current;
	}

	override ISRIterator!(T) dup() {
		return new Iterator!(T)(this.current);
	}

	//void opUnary(string s)() if(s == "++") {
	override void increment() {
		Node!(T) y;
		if(null !is (y = this.current.link[true])) {
			while(y.link[false] !is null) {
				y = y.link[false];
			}
			this.current = y;
		} else {
			y = this.current.parent;
			while(y !is null && this.current is y.link[true]) {
				this.current = y;
				y = y.parent;
			}
			this.current = y;
		}
	}	

	override T getData() {
		return this.current.getData();
	}

	//void opUnary(string s)() if(s == "--") {
	override void decrement() {
		Node!(T) y;
		if(null !is (y = this.current.link[false])) {
			while(y.link[true] !is null) {
				y = y.link[true];
			}
			this.current = y;
		} else {
			y = this.current.parent;
			while(y !is null && this.current is y.link[false]) {
				this.current = y;
				y = y.parent;
			}
			this.current = y;
		}
	}

	override bool isValid() const {
		return this.current !is null;
	}

	T opUnary(string s)() if(s == "*") {
		return this.current.data;
	}
}*/

public struct Node(T) {
	ArrayTree!(T) tree;
	T data;
	bool red;
	bool invalid;

	long link[2];
	long parent;

	this(ArrayTree!(T) tree) {
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
	}

	T getData() {
		return this.data;
	}

	bool isValid() const {
		return !this.invalid;
	}

	/*bool validate(bool root, const Node!(T) par = null) const {
		if(!root) {
			if(this.parent is null) {
				println(__FILE__,__LINE__,": parent is null");
				return false;
			}
			if(this.parent !is par) {
				println(__FILE__,__LINE__,": parent is wrong ");
					//, parent.data, 
					//" ",par.data);
				return false;
			}
		}
		bool left = true;
		bool right = true;
		if(this.link[0] !is null) {
			assert(this.link[0].parent is this);
			left = this.link[0].validate(false, this);
		}
		if(this.link[1] !is null) {
			assert(this.link[1].parent is this);
			right = this.link[1].validate(false, this);
		}
		return left && right;
	}*/

	public void print() const {
		//println(this.data);
		if(this.link[0] != -1) {
			this.tree.nodes[this.link[0]].print();
		}
		if(this.link[1] != -1) {
			this.tree.nodes[this.link[1]].print();
		}
	}
}

abstract class ArrayTree(T) {
	protected size_t size;
	package Node!(T)[] nodes;
	private Stack!(size_t) inBetween;
	private size_t tail;
	protected long root;

	this() {
		this.nodes = new Node!(T)[32];
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

	/*Iterator!(T) begin() {
		Node!(T) be = this.root;
		if(be is null)
			return new Iterator!(T)(null);
		int count = 0;
		while(be.link[0] !is null) {
			be = be.link[0];
			count++;
		}
		auto it =  new Iterator!(T)(be);
		//println(__LINE__," ",count, " ", be is null, " ", it is null, " ", it.isValid(), " ", *it);
		return it;	
	}

	Iterator!(T) end() {
		Node!(T) end = this.root;
		if(end is null)
			return new Iterator!(T)(null);
		while(end.link[1] !is null)
			end = end.link[1];
		return new Iterator!(T)(end);
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
			it++;
		}
		assert(ptr == ret.length, conv!(size_t,string)(ptr) ~ " " ~
			conv!(size_t, string)(ret.length));
		return ret;
	}

	public ISRIterator!(T) searchIt(T data) {
		return new Iterator!(T)(cast(Node!(T))search(data));
	}

	void clear() {
	    this.root = null;
	    this.size = 0;
	}
	 
	bool isEmpty() const {
	    return this.root is null;
	}*/
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
