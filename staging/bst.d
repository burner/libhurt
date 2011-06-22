import std.stdio;

class Node(T) {
    // By value storage of the data
    T key;
 
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
				writeln(__FILE__,__LINE__,": parent is wrong ", parent.key, " ",par.key);
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
		writeln(key);
		if(this.link[0] !is null) {
			this.link[0].print();
		}
		if(this.link[1] !is null) {
			this.link[1].print();
		}
	}

	public override int toHash() const {
		return this.key;
	}

}
 
class BinarySearchTree(T) { 
	Node!(T) root;
	size_t count;

	void clear(Node!(T) ptr) {
	    if(ptr !is null) {
	        clear(ptr.link[0]);
	        clear(ptr.link[1]);
	    }
	}
	 
	bool search(const T item, ref Node!(T) curr, ref Node!(T) prev , ref bool lr) 
			const {
	    while (curr !is null) {
	        if(item == curr.key)
		    return true;
	        lr = (item > curr.key);
	        prev = curr;
	        curr = curr.link[lr];
	    }
	    return false;
	}

	private static bool equal(const Node!(T) a, const Node!(T) b) {
		return a.toHash() == b.toHash();
	}

	private static bool compare(const Node!(T) a, const Node!(T) b) {
		return a.toHash() < b.toHash();
	}
	 
	T inOrder(Node!(T) ptr) const {
	    bool lr = true;
	    T temp;
	    Node!(T) prev = ptr;
	 
	    ptr = ptr.link[1];
	    while (ptr.link[0] !is null) {
	        prev = ptr;
	        ptr = ptr.link[lr = false];
	    }
	    prev.link[lr] = ptr.link[true];
	    temp = ptr.key;
	    return temp;
	}
	 
	int subNode(Node!(T) ptr) const {
	    if(ptr.link[true] !is null) {
	        if(ptr.link[false] !is null)
	            return 3;
	        else
	            return 2;
	    } else if(ptr.link[false] !is null)
	        return 1;
	    else
	        return 0;
	}
	 
	int height(const Node!(T) ptr) const {
	    if(ptr is null)
	        return 0;
	 
	    int lt = height(ptr.link[false]), rt = height(ptr.link[true]);
	 
	    if(lt < rt)
	        return rt + 1;
	    return lt + 1;
	}
	 
	Node!(T) minmax(Node!(T) ptr, in bool lr) const {
	    while (ptr.link[lr] !is null)
	        ptr = ptr.link[lr];
	    return ptr;
	}
	 
	this() {
	    this.root = null;
	    count = 0;
	}
	 
	void clear() {
	    this.clear(this.root);
	    this.root = null;
	    this.count = 0;
	}
	 
	bool isEmpty() const {
	    return this.root is null;
	}
	 
	bool insert(const T item) {
	    if(this.root is null) {
	        this.root = new Node!(T);
	        this.root.key = item;
	        this.count++;
	        return true;
	    }
	    bool lr;
	    Node!(T) curr = this.root, prev;
	 
	    if(search(item, curr, prev, lr))
	        return false;
	    prev.link[lr] = new Node!(T)();
	    prev.link[lr].key = item;
	    prev.link[lr].parent = prev;
	    this.count++;
	    return true;
	}
	 
	bool remove(const T item) {
	    bool lr = 1;
	    Node!(T) curr = this.root; 
		Node!(T) prev;
	 
	    if(!search(item, curr, prev, lr))
	        return false;
		if(curr.link[0] is null && curr.link[1] is null) {
			if(prev.link[0] is curr) {
				prev.link[0] = null;
				return true;
			} else if(prev.link[1] is curr) {
				prev.link[1] = null;
				return true;
			} else {
				assert(0, "must be one of them");
			}
		}
		if(curr.link[0] !is null && curr.link[1] is null) {
			if(prev.link[0] is curr) {
				prev.link[0] = curr.link[0];
				prev.link[0].parent = prev;
				return true;
			} else if(prev.link[1] is curr) {
				prev.link[1] = curr.link[0];
				prev.link[1].parent = prev;
				return true;
			} else {
				assert(0, "must be one of them");
			}
		}
		if(curr.link[0] is null && curr.link[1] !is null) {
			if(prev.link[0] is curr) {
				prev.link[0] = curr.link[1];
				prev.link[0].parent = prev;
				return true;
			} else if(prev.link[1] is curr) {
				prev.link[1] = curr.link[1];
				prev.link[1].parent = prev;
				return true;
			} else {
				assert(0, "must be one of them");
			}
		}
		if(curr.link[0] !is null && curr.link[1] !is null) {
			Node!(T) nCur = curr.link[1];
			while(nCur.link[0] !is null) {
				nCur = nCur.link[0];
			}
			if(prev.link[0] is curr) {
				prev.link[0] = nCur;
				prev.link[0].link[0] = curr.link[0];
				prev.link[0].link[1] = curr.link[1];
				prev.link[0].link[0].parent = prev.link[0];
				prev.link[0].link[1].parent = prev.link[0];
			} else if(prev.link[1] is curr) {
				prev.link[1] = nCur;
				prev.link[1].link[0] = curr.link[0];
				prev.link[1].link[1] = curr.link[1];
				prev.link[1].link[0].parent = prev.link[1];
				prev.link[1].link[1].parent = prev.link[1];
			}
			nCur = nCur.parent;
			nCur.link[0] = null;
			return true;
		}
		assert(0, "should be one of the cases");
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
	 
	T min() {
	    return minmax(root, 0).key;
	}
	 
	T max() {
	    return minmax(root, 1).key;
	}
	 
	size_t getSize() const {
	    return count;
	}
	 
	int height() const {
	    return height(root);
	}
	
	bool validate() const {
		return this.root.validate(true);
	}

	void print() const {
		this.root.print();
	}
}

void main() {
	int[] lots = [2811, 1089, 3909, 3593, 1980, 2863, 676, 258, 2499, 3147, 3321, 3532, 3009,
	1526, 2474, 1609, 518, 1451, 796, 2147, 56, 414, 3740, 2476, 3297, 487, 1397,
	973, 2287, 2516, 543, 3784, 916, 2642, 312, 1130, 756, 210, 170, 3510, 987];
	BinarySearchTree!(int) a = new BinarySearchTree!(int)();
	foreach(idx, it; lots) {
		a.insert(it);
		assert(a.validate());
		foreach(jt; lots[0..idx+1]) {
			assert(a.search(jt) !is null);
		}
	}
	writeln("insert done");
	foreach(idx, it; lots) {
		a.remove(it);
		assert(a.validate());
		foreach(jt; lots[0..idx+1]) {
			assert(a.search(jt) is null);
		}
	}
	writeln("bst test done");
}
