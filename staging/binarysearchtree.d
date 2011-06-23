import std.stdio;

class Node(T) {
    // By value storage of the data
    T data;
 
    // Combine the two branches into an array to optimize the logic
    Node!(T) link[2];
	Node!(T) parent;
 
    // Null the branches so we don't have to do it in the implementation
    this(T data) {
		this.data = data;
		this.parent = null;
        // Left branch
        this.link[0] = null;
 
        // Right branch
        this.link[1] = null;
    }

/*	bool validate(bool root, const Node!(T) par = null) const {
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

	*/
	void print() const {
		writeln(data);
		if(this.link[0] !is null) {
			this.link[0].print();
		}
		if(this.link[1] !is null) {
			this.link[1].print();
		}
	}
	/*
	public override int toHash() const {
		return this.key;
	}*/
}

class BinarySearchTree(T) {
	private Node!(T) root;
	
	void insert(T data) {
		if(this.root is null) {
			this.root = new Node!(T)(data);
			return;
		}
		Node!(T) node = this.search(data);
		if(node is null) {
			node = new Node!(T)(data);
		}
	}

	Node!(T) search(T data) {
		Node!(T) node = this.root;
		while(node !is null) {
			if(data < node.data) {
				node = node.link[0];
			} else if(node.data < data) {
				node = node.link[1];
			} else {
				break;
			}
		}
		return node;
	}

	void remove(ref Node!(T) node) {
		if(node is null)
			return;
		Node!(T) old = node;
		if(node.link[0] is null) {
			node = node.link[1];
			old = null;
		} else if(node.link[1] is null) {
			node = node.link[0];
			old = null;
		} else {
			Node!(T) pred = node.link[0];
			while(pred.link[1] !is null) {
				pred = pred.link[1];
			}
			swap(pred, node);
			remove(pred);
		}
	}

	void print() const {
		this.root.print();
	}

	private void swap(Node!(T) a, Node!(T) b) {
		T tmp = a.data;
		a.data = b.data;
		b.data = tmp;
	}
}

void main() {
	auto a = new BinarySearchTree!(int)();
	a.insert(1);
	assert(a.search(1));
	Node!(int) af = a.search(1);
	assert(af is a.root);
	a.remove(af);
	assert(af is null);
	int[] lots = [2811, 1089, 3909, 3593, 1980, 2863, 676, 258, 2499, 3147, 3321, 3532, 3009,
	1526, 2474, 1609, 518, 1451, 796, 2147, 56, 414, 3740, 2476, 3297, 487, 1397,
	973, 2287, 2516, 543, 3784, 916, 2642, 312, 1130, 756, 210, 170, 3510, 987];
	BinarySearchTree!(int) b = new BinarySearchTree!(int)();
	foreach(idx, it; lots) {
		writeln(__LINE__, " ",it);
		b.insert(it);
		b.print();
		foreach(jt; lots[0..idx]) {
			assert(b.search(jt) !is null);
		}
	}
}
