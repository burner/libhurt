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
			left = this.link[0].validate(false, this);
		}
		if(this.link[1] !is null) {
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
		return a.toHash() > b.toHash();
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
	    Node!(T) curr = this.root, prev;
	 
	    if(!search(item, curr, prev, lr))
	        return false;
		int s = subNode(curr);
		writeln(__LINE__,": ", s);
	    switch(s) {
	    	case 0:
	    	case 1:
	    	case 2:
	    	    if(curr is this.root) {
					writeln(__LINE__);
	    	        this.root = curr.link[(s > 1)];
	    	    } else {
					writeln(__LINE__);
	    	        prev.link[lr] = curr.link[(s > 1)];
					if(prev !is null && prev.link[lr] !is null) {
						prev.link[lr].parent = prev;
					}
				}
	    	    break;
	    	case 3:
	    	    curr.key = inOrder(curr);
			default:
	    }
	    count--;
		writeln(__LINE__);
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
