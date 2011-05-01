module rbtree;

import std.stdio;

extern(C) long getTicks();

int rand(int low = 0, int up = int.max) {
	immutable M = 2147483647;
	immutable A = 16807;
	static int seed = 1;

	seed = A * ( seed % (M/A) ) - (M%A) * ( seed / (M/A) );
	if(seed <= 0)
		seed += M;

	return (seed + low) % up;
}

 
class RBTree(T) {
	class Iterator(T) {
		Node!(T) current;
		Node!(T) treeRoot;
		
		this(Node!(T) root, bool begin) {
			this.current = root;
			this.treeRoot = root;
			if(begin) {
				this.begin();
			} else {
				this.end();
			}
		}
	
		void begin() {
			while(this.current.link[0] !is null) {
				this.current = this.current.link[0];
			}
		}

		void end() {
			while(this.current.link[1] !is null) {
				this.current = this.current.link[1];
			}
		}

		void opUnary(string s)() if(s == "++") {
			Node!(T) y;
			if(null !is (y = this.current.link[1])) {
				while(y.link[0] !is null) {
					y = y.link[0];
				}
				this.current = y;
			} else {
				y = this.current.par;
				while(y !is null && this.current is y.link[1]) {
					this.current = y;
					y = y.par;
				}
				this.current = y;
			}
		}	

		void opUnary(string s)() if(s == "--") {
			Node!(T) y;
			if(null !is (y = this.current.link[0])) {
				while(y.link[1] !is null) {
					y = y.link[1];
				}
				this.current = y;
			} else {
				y = this.current.par;
				while(y !is null && this.current is y.link[0]) {
					this.current = y;
					y = y.par;
				}
				this.current = y;
			}
		}	
	
		T opUnary(string s)() if(s == "*") {
			return this.current.data;
		}
	
		bool isValid() const {
			return current !is null;
		}
	}
	
	class Node(T) {
		bool red;
		T data;
		Node!(T) par;
		Node!(T) link[2];
	
		this(T data, Node!(T) parent) {
			this.data = data;
			this.red = true;
			this.par = parent;
			this.link[0] = null;	
			this.link[1] = null;	
		}
	
		this() {
			this.red = false;
			this.link[0] = null;	
			this.link[1] = null;	
		}
	}
	static bool isRed(Node!(T) tt) {
		return tt !is null && tt.red;
	}

	Node!(T) root;

	Node!(T) singleRot(Node!(T) root, bool dir) {
		Node!(T) save = root.link[!dir];

		root.link[!dir] = save.link[dir];
		if(root.link[!dir] !is null) {
			root.link[!dir].par = root;
		}
		save.link[dir] = root;
		if(save.link[dir] !is null) {
			save.link[dir].par = save;
		}
		//root.par = save;

		root.red = true;
		save.red = false;

		return save;
	}

	Node!(T) doubleRot(Node!(T) root, bool dir) {
		root.link[!dir] = singleRot(root.link[!dir], !dir);
		root.link[!dir].par = root;
		return singleRot(root, dir);
	}

	Node!(T) insertRecursive(Node!(T) root, T data, Node!(T) parent) {
		if(root is null) {
			root = new Node!(T)(data, parent);
		} else if(data != root.data) {
			bool dir = root.data < data;
			root.link[dir] = insertRecursive(root.link[dir], data, root);
			if(root.link[dir] !is null) {
				root.link[dir].par = root;
			}
			/* Hey, let's rebalance here! */
			if(isRed(root.link[dir])) {
				if(isRed(root.link[!dir])) {
					/* Case 1 */
					root.red = 1;
					root.link[0].red = false;
					root.link[1].red = false;
				} else {
					/* Cases 2 & 3 */
					if(isRed(root.link[dir].link[dir])) {
						root = singleRot(root, !dir);
						root.par = parent;
					} else if(isRed(root.link[dir].link[!dir])) {
						root = doubleRot(root, !dir);
						root.par = parent;
					}
				}
			}
		}
		return root;
	}

	bool insert(T data) {
		this.root = this.insertRecursive(this.root, data, null);
		this.root.par = null;
		this.root.red = false;
		return true;
	}

	Node!(T) removeRecursive(Node!(T) root, T data, ref bool done) {
		if(root is null) {
			done = true;
		} else {
			bool dir;

			if(root.data == data) {
				if(root.link[0] is null || root.link[1] is null) {
					Node!(T) save = root.link[root.link[0] is null];

					/* Case 0 */
					if(isRed(root))
						done = true;
					else if(isRed(save)) {
						save.red = 0;
						done = true;
					}
					return save;
				} else {
					Node!(T) heir = root.link[0];

					while(heir.link[1] !is null)
						heir = heir.link[1];

					root.data = heir.data;
					data = heir.data;
				}
			}

			dir = root.data < data;
			root.link[dir] = removeRecursive(root.link[dir], data, done);
			if(root.link[dir] !is null) {
				root.link[dir].par = root;
			}

			if(!done) {
				root = removeBalance(root, dir, done);
			}
		}
		return root;
	}

	int remove(T data) {
		bool done = false;

		this.root = removeRecursive(this.root, data, done);
		if(this.root !is null) {
			this.root.red = 0;
			this.root.par = null;
		}

		return 1;
	}

	Node!(T) removeBalance(Node!(T) root, bool dir, ref bool done) {
		Node!(T) p = root;
		Node!(T) s = root.link[!dir];

		/* Case reduction, remove red sibling */
		if(isRed(s)) {
			root = singleRot(root, dir);
			s = p.link[!dir];
		}

		if(s !is null) {
			if(!isRed(s.link[0]) && !isRed(s.link[1])) {
				if(isRed(p))
					done = true;
				p.red = false;
				s.red = true;
			} else {
				bool save = p.red;
				bool new_root = (root == p);

				if(isRed(s.link[!dir]))
					p = singleRot(p, dir);
				else
					p = doubleRot(p, dir);

				p.red = save;
				p.link[0].red = false;
				p.link[1].red = false;

				if(new_root)
					root = p;
				else {
					root.link[dir] = p;
					root.link[dir].par = root;
				}

				done = true;
			}
		}

		return root;
	}

	Node!(T) find(T data) {
		Node!(T) it = this.root;
		while(it !is null) {
			if(it.data == data) {
				return it;
			} else {
				bool dir = it.data < data;
				it = it.link[dir];
			}
		}
		return null;
	}

	void inOrder() {
		Node!(T) stack[256];
		size_t sPtr = 0;
		Node!(T) current = this.root;
		while(sPtr > 0 || current) {
			if(current) {
				stack[sPtr++] = current;
				current = current.link[0];
			} else {
				current = stack[--sPtr];
				writeln(current.data);
				current = current.link[1];
			}
		}
	}

	Iterator!(T) begin() {
		return new Iterator!(T)(this.root);
	}

	int validate() {
		return rbAssert(this.root, null);
	}

	int rbAssert(Node!(T) root, Node!(T) parent) {
		if(root is null)
			return 1;
		else {
			if(parent !is null && root.par !is parent) {
				writeln("Parent not correct ", parent.data, " ",root.data);
			}
			Node!(T) ln = root.link[false];
			Node!(T) rn = root.link[true];

			/* Consecutive red links */
			if(isRed(root)) {
				if(isRed(ln) || isRed(rn)) {
					writeln("Red violation");
					return 0;
				}
			}

			int lh, rh;
			lh = rbAssert(ln, root);
			rh = rbAssert(rn, root);

			/* Invalid binary search tree */
			if((ln !is null && ln.data >= root.data)
					||(rn !is null && rn.data <= root.data)) {
				writeln("Binary tree violation");
				return 0;
			}

			/* Black height mismatch */
			if(lh != 0 && rh != 0 && lh != rh ) {
				writeln("Black violation");
				return 0;
			}

			/* Only count black links */
			if(lh != 0 && rh != 0)
				return isRed(root) ? lh : lh + 1;
			else
				return 0;
		}
	}
}

unittest {
	RBTree!(int) rbt2 = new RBTree!(int)();
	int times = 20;
	int[] rn = new int[times];
	foreach(ref it; rn) {
		it = rand(5, times*2);
	}

	long st = getTicks();
	for(int i = 0; i < times; i++) {
		int tmp = rn[i];
		rbt2.insert(tmp);
	}
	//rbt2.inOrder();
	RBTree!(int).Iterator!(int) it = rbt2.begin(true);
	while(it.isValid()) {
		writeln("hello ", *it);
		it++;
	}
	RBTree!(int).Iterator!(int) it = rbt2.begin(false);
	while(it.isValid()) {
		writeln("hello ", *it);
		it--;
	}
		
	writeln("bottom up insert ", getTicks()-st);
	st = getTicks();
	for(int i = 0; i < times; i++) {
		rbt2.remove(rn[i]);
		//rbt2.validate();
	}
	writeln("bottom up remove ", getTicks()-st);
}

void main() {
	writeln("rbtree unittest passed");
	return;
}
