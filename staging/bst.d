module bst;

import isr;

import hurt.conv.conv;

import std.stdio;

private class Iterator(T) : ISRIterator!(T) {
	Node!(T) data;

	this(Node!(T) current) {
		this.data = current;
	}

	void opUnary(string s)() if(s == "++") {
		Node!(T) y;
		if(null !is (y = this.data.link[true])) {
			while(y.link[false] !is null) {
				y = y.link[false];
			}
			this.data = y;
		} else {
			y = this.data.parent;
			while(y !is null && this.data is y.link[true]) {
				this.data = y;
				y = y.parent;
			}
			this.data = y;
		}
	}	

	void opUnary(string s)() if(s == "--") {
		Node!(T) y;
		if(null !is (y = this.data.link[false])) {
			while(y.link[true] !is null) {
				y = y.link[true];
			}
			this.data = y;
		} else {
			y = this.data.parent;
			while(y !is null && this.data is y.link[false]) {
				this.data = y;
				y = y.parent;
			}
			this.data = y;
		}
	}

	T opUnary(string s)() if(s == "*") {
		return this.data.getData();
	}

	bool isValid() const {
		return this.data !is null;
	}
}

private class Node(T) : ISRNode!(T) {
    // By value storage of the data
    T data;
 
    // Combine the two branches into an array to optimize the logic
    Node!(T) link[2];
	Node!(T) parent;
 
    // Null the branches so we don't have to do it in the implementation
    this() {
		this.parent = null;
        // Left branch
        this.link[0] = null;
 
        // Right branch
        this.link[1] = null;
    }

	T getData() {
		return this.data;
	}

	bool validate(bool root, const Node!(T) par = null) const {
		if(!root) {
			if(this.parent is null) {
				writeln(__FILE__,__LINE__,": parent is null");
				return false;
			}
			if(this.parent !is par) {
				writeln(__FILE__,__LINE__,": parent is wrong ", parent.data, " ",par.data);
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

	void print() const {
		writeln(this.data);
		if(this.link[0] !is null) {
			this.link[0].print();
		}
		if(this.link[1] !is null) {
			this.link[1].print();
		}
	}
}
 
class BinarySearchTree(T) : ISR!(T) { 
	private Node!(T) root;
	private size_t count;

	private bool search(const T item, ref Node!(T) curr, ref Node!(T) prev , 
			ref bool lr) const {
	    while (curr !is null) {
	        if(item == curr.data)
		    return true;
	        lr = curr.data < item;
	        prev = curr;
	        curr = curr.link[lr];
	    }
	    return false;
	}

	this() {
	    this.root = null;
	    count = 0;
	}
	 
	void clear() {
	    this.root = null;
	    this.count = 0;
	}
	 
	bool isEmpty() const {
	    return this.root is null;
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

	 
	bool insert(T item) {
	    if(this.root is null) {
	        this.root = new Node!(T);
	        this.root.data = item;
	        this.count++;
	        return true;
	    }
	    bool lr;
	    Node!(T) curr = this.root, prev;
	 
	    if(search(item, curr, prev, lr))
	        return false;
	    prev.link[lr] = new Node!(T)();
	    prev.link[lr].data = item;
		if(prev !is null) {
	    	prev.link[lr].parent = prev;
		}
	    this.count++;
	    return true;
	}

	public bool remove(Iterator!(T) it, bool dir = true) {
		if(it.isValid()) {
			T value = *it;
			if(dir)
				it++;
			else
				it--;
			return this.remove(value);
		} else {
			return false;
		}
	}
	 
	bool remove(T item) {
		if(this.root !is null ) {
			Node!(T) p = null, succ;
			Node!(T) it = this.root;
			bool dir;

			while(true) {
				if(it is null )
					return false;
				else if(it.data == item)
					break;

				dir = it.data < item;
				p = it;
				it = it.link[dir];
			}

			if(it.link[0] !is null && it.link[1] !is null ) {
				p = it;
				succ = it.link[1];

				while(succ.link[0] !is null ) {
					p = succ;
					succ = succ.link[0];
				}

				it.data = succ.data;
				bool which = p.link[1] is succ;
				p.link[which] = succ.link[1];
				if(p.link[which] !is null) {
					p.link[which].parent = p;
				}
			} else {
				dir = it.link[0] is null;

				if(p is null) {
					this.root = it.link[dir];
					if(this.root !is null) {
						this.root.parent = null;
					}
				} else {
					bool which = p.link[1] is it;
					p.link[which] = it.link[dir];
					if(p.link[which] !is null) {
						p.link[which].parent = p;
					}
				}
			}
		}

    	count--;
    	return true;
	}
	 
	Node!(T) search(const T item) {
	    bool found;
	    Node!(T) curr = root, prev;
	 
	    found = search(item, curr, prev, found);
		if(found) {
			return curr;
		} else {
			return null;
		}
	}

	T[] values() {
		if(this.count == 0)
			return null;
		T[] ret = new T[this.count];
		size_t ptr = 0;
		Iterator!(T) it = this.begin();
		while(it.isValid()) {
			ret[ptr++] = *it;
			it++;
		}
		return ret;	
	}

	size_t getSize() const {
	    return count;
	}
	
	bool validate() const {
		if(this.root is null) 
			return true;
		return this.root.validate(true);
	}

	void print() const {
		this.root.print();
	}
}

bool compare(T)(BinarySearchTree!(T) t, T[T] s) {
	if(t.getSize() != s.length) {
		writeln(__LINE__, " size wrong");
		return false;
	}
	foreach(it; s.values) {
		if(t.search(it) is null) {
			writeln(__LINE__, " size wrong");
			return false;
		}
	}
	return true;
}

unittest {
	int[][] lot = [[2811, 1089, 3909, 3593, 1980, 2863, 676, 258, 2499, 3147,
	3321, 3532, 3009, 1526, 2474, 1609, 518, 1451, 796, 2147, 56, 414, 3740,
	2476, 3297, 487, 1397, 973, 2287, 2516, 543, 3784, 916, 2642, 312, 1130,
	756, 210, 170, 3510, 987], [0,1,2,3,4,5,6,7,8,9,10],
	[10,9,8,7,6,5,4,3,2,1,0],[10,9,8,7,6,5,4,3,2,1,0,11],
	[0,1,2,3,4,5,6,7,8,9,10,-1],[11,1,2,3,4,5,6,7,8,0]];
	foreach(lots; lot) {
		BinarySearchTree!(int) a = new BinarySearchTree!(int)();
		int[int] at;
		foreach(idx, it; lots) {
			assert(a.insert(it));
			assert(a.getSize() == idx+1);
			foreach(jt; lots[0..idx+1]) {
				assert(a.search(jt));
			}
			at[it] = it;
			assert(a.validate());
			assert(compare!(int)(a, at));
			foreach(jt; a.values()) {
				assert(a.search(jt));
			}

			Iterator!(int) ait = a.begin();
			size_t cnt = 0;
			while(ait.isValid()) {
				assert(a.search(*ait));
				ait++;
				cnt++;
			}
			assert(cnt == a.getSize(), conv!(size_t,string)(cnt) ~
				" " ~ conv!(size_t,string)(a.getSize()));

			ait = a.end();
			cnt = 0;
			while(ait.isValid()) {
				assert(a.search(*ait));
				ait--;
				cnt++;
			}
			assert(cnt == a.getSize(), conv!(size_t,string)(cnt) ~
				" " ~ conv!(size_t,string)(a.getSize()));

		}
		//writeln(__LINE__);
		foreach(idx, it; lots) {
			assert(a.remove(it));
			assert(a.getSize() + idx + 1 == lots.length);
			at.remove(it);
			assert(a.validate());
			assert(compare!(int)(a, at));
			foreach(jt; lots[0..idx+1]) {
				assert(!a.search(jt));
			}
			foreach(jt; lots[idx+1..$]) {
				assert(a.search(jt));
			}
			int[] values = a.values();
			//writeln(__LINE__," ", values);
			foreach(jt; values) {
				assert(a.search(jt));
			}
			
			Iterator!(int) ait = a.begin();
			size_t cnt = 0;
			while(ait.isValid()) {
				assert(a.search(*ait));
				ait++;
				cnt++;
			}
			assert(cnt == a.getSize(), conv!(size_t,string)(cnt) ~
				" " ~ conv!(size_t,string)(a.getSize()));

			ait = a.end();
			cnt = 0;
			while(ait.isValid()) {
				assert(a.search(*ait));
				ait--;
				cnt++;
			}
			assert(cnt == a.getSize(), conv!(size_t,string)(cnt) ~
				" " ~ conv!(size_t,string)(a.getSize()));
		}
		//writeln(__LINE__);
	}

	for(int i = 0; i < lot[0].length; i++) {
		BinarySearchTree!(int) itT = new BinarySearchTree!(int)();
		foreach(it; lot[0]) {
			itT.insert(it);
		}
		assert(itT.getSize() == lot[0].length);
		Iterator!(int) be = itT.begin();
		while(be.isValid())
			assert(itT.remove(be, true));
		assert(itT.getSize() == 0);
	}

	for(int i = 0; i < lot[0].length; i++) {
		BinarySearchTree!(int) itT = new BinarySearchTree!(int)();
		foreach(it; lot[0]) {
			itT.insert(it);
		}
		assert(itT.getSize() == lot[0].length);
		Iterator!(int) be = itT.end();
		while(be.isValid())
			assert(itT.remove(be, false));
		assert(itT.getSize() == 0);
	}
}
