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
