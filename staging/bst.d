module bst;

import isr;

import std.stdio;

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

	private bool search(const T item, ref Node!(T) curr, ref Node!(T) prev , ref bool lr) 
			const {
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
		T[] ret = new T[this.count];
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
			at[it] = it;
			assert(compare!(int)(a,at));
			assert(a.validate());
			assert(a.getSize() == idx+1);
			foreach(jt; lots[0..idx+1]) {
				assert(a.search(jt) !is null);
			}
		}
		foreach(idx, it; lots) {
			assert(a.remove(it));
			at.remove(it);
			assert(compare!(int)(a,at));
			assert(a.getSize() == lots.length-idx-1);
			assert(a.validate());
			foreach(jt; lots[0..idx]) {
				assert(a.search(jt) is null);
			}
			foreach(jt; lots[idx+1..$]) {
				assert(a.search(jt) !is null);
			}
		}
	}
}
