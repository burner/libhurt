module hurt.container.tree;

import hurt.container.isr;

import std.stdio;

import hurt.conv.conv;

public class Iterator(T) : ISRIterator!(T) {
	private Node!(T) current;

	this(Node!(T) current) {
		this.current = current;
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

	/*T opUnary(string s)() if(s == "*") {
		return this.current.data;
	}*/
}

public class Node(T) : ISRNode!(T) {
	T data;
	bool red;

	Node!(T) link[2];
	Node!(T) parent;

	this() {
		this.parent = null;
        this.link[0] = null;
        this.link[1] = null;
	}

	this(T data) {
		this.data = data;
		this.red = true;
	}

	override T getData() {
		return this.data;
	}

	bool validate(bool root, const Node!(T) par = null) const {
		if(!root) {
			if(this.parent is null) {
				writeln(__FILE__,__LINE__,": parent is null");
				return false;
			}
			if(this.parent !is par) {
				writeln(__FILE__,__LINE__,": parent is wrong ");
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
	}

	public void print() const {
		//writeln(this.data);
		if(this.link[0] !is null) {
			this.link[0].print();
		}
		if(this.link[1] !is null) {
			this.link[1].print();
		}
	}
}

abstract class Tree(T) : ISR!(T) {
	protected size_t size;
	protected Node!(T) root;

	public size_t getSize() const {
		return this.size;
	}

	Iterator!(T) begin() {
		Node!(T) be = this.root;
		if(be is null)
			return new Iterator!(T)(null);
		int count = 0;
		while(be.link[0] !is null) {
			be = be.link[0];
			count++;
		}
		auto it =  new Iterator!(T)(be);
		//writeln(__LINE__," ",count, " ", be is null, " ", it is null, " ", it.isValid(), " ", *it);
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
		//writeln(__LINE__," ", it.isValid());
		while(it.isValid()) {
			//writeln(ptr, " ", *it);
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
	}

	this() {
		this.root = null;
		this.size = 0;
	}

}
