import std.stdio;

interface Data {
	int toHash() const;
}

class Node(T) {
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
	        if(item == curr.data)
		    return true;
	        lr = (item > curr.data);
	        prev = curr;
	        curr = curr.link[lr];
	    }
	    return false;
	}

	T inOrder(Node!(T) ptr) const {
	    bool lr = true;
	    Node!(T) prev = ptr;
	 
	    ptr = ptr.link[1];
	    while (ptr.link[0] !is null) {
	        prev = ptr;
	        ptr = ptr.link[lr = false];
	    }
	    prev.link[lr] = ptr.link[true];
	    return ptr.data;
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
	 
	bool remove(const T item) {
		bool lr = 1;
    	Node!(T) curr = this.root, prev;
 
    	if(!search(item, curr, prev, lr))
    		return false;
		int s = subNode(curr);
    	switch(s) {
    		case 0:
    		case 1:
    		case 2:
    			if(curr is root) {
    				this.root = curr.link[(s > 1)];
    			} else {
    				prev.link[lr] = curr.link[(s > 1)];
					prev.link[lr].parent = prev;
				}
    			break;
    		case 3:
    		    curr.data = this.inOrder(curr);
				break;
			default:
				assert(0);
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
	 
	T min() {
	    return minmax(root, 0).data;
	}
	 
	T max() {
	    return minmax(root, 1).data;
	}
	 
	size_t getSize() const {
	    return count;
	}
	 
	int height() const {
	    return height(root);
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

void main() {
	BinarySearchTree!(int) b = new BinarySearchTree!(int)();
	b.insert(5);
	assert(b.validate());
	assert(b.search(5));
	assert(b.validate());
	assert(b.remove(5));
	assert(b.validate());
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
	foreach_reverse(idx, it; lots) {
		a.remove(it);
		assert(a.validate());
		foreach(jt; lots[0..idx+1]) {
			assert(a.search(jt) is null);
		}
	}
	writeln("bst test done");
}
