module rbtree;

import std.stdio;

extern(C) long getTicks();

int rand() {
	immutable M = 2147483647;
	immutable A = 16807;
	
	static int seed = 1;

	seed = A * ( seed % (M/A) ) - (M%A) * ( seed / (M/A) );

	if(seed <= 0)
		seed += M;

	return seed;
}

class Node(T) {
	bool red;
	T data;
	Node!(T) link[2];

	this(T data) {
		this.data = data;
		this.red = true;
		this.link[0] = null;	
		this.link[1] = null;	
	}

	this() {
		this.red = false;
		this.link[0] = null;	
		this.link[1] = null;	
	}
}
 
class RBTree(T) {
	static bool isRed(Node!(T) tt) {
		return tt !is null && tt.red;
	}

	Node!(T) root;

	Node!(T) singleRot(Node!(T) root, bool dir) {
		Node!(T) save = root.link[!dir];

		root.link[!dir] = save.link[dir];
		save.link[dir] = root;

		root.red = true;
		save.red = false;

		return save;
	}

	Node!(T) doubleRot(Node!(T) root, bool dir) {
		root.link[!dir] = singleRot(root.link[!dir], !dir);
		return singleRot(root, dir);
	}

	int insert(T data) {
		if(this.root is null) {
			/* Empty tree case */
			this.root = new Node!(T)(data);
			if(this.root is null)
				return 0;
		} else {
			Node!(T) head = new Node!(T)(); /* False tree root */

			Node!(T) g, t;     /* Grandparent & parent */
			Node!(T) p, q;     /* Iterator & parent */
			bool dir = false, last;

			/* Set up helpers */
			t = head;
			g = p = null;
			q = t.link[1] = this.root;

			/* Search down the tree */
			for(; ;) {
				if(q is null) {
					/* Insert new node at the bottom */
					p.link[dir] = q = new Node!(T)(data);
					if(q is null)
						return 0;
				}
				else if(isRed(q.link[0]) && isRed(q.link[1])) {
					/* Color flip */
					q.red = 1;
					q.link[0].red = 0;
					q.link[1].red = 0;
				}

				/* Fix red violation */
				if(isRed(q) && isRed(p)) {
					int dir2 = t.link[1] == g;

					if(q == p.link[last])
						t.link[dir2] = singleRot(g, !last);
					else
						t.link[dir2] = doubleRot(g, !last);
				}

				/* Stop if found */
				if(q.data == data)
					break;

				last = dir;
				dir = q.data < data;

				/* Update helpers */
				if(g !is null)
					t = g;
				g = p, p = q;
				q = q.link[dir];
			}

			/* Update root */
			this.root = head.link[1];
		}

		/* Make root black */
		this.root.red = 0;

		return 1;
	}

	Node!(T) insertRecursive(Node!(T) root, T data) {
		if(root is null)
			root = new Node!(T)(data);
		else if(data != root.data) {
			bool dir = root.data < data;
			root.link[dir] = insertRecursive(root.link[dir], data);
			/* Hey, let's rebalance here! */
			if(isRed(root.link[dir])) {
				if(isRed(root.link[!dir])) {
					/* Case 1 */
					root.red = 1;
					root.link[0].red = false;
					root.link[1].red = false;
				} else {
					/* Cases 2 & 3 */
					if(isRed(root.link[dir].link[dir]))
						root = singleRot(root, !dir);
					else if(isRed(root.link[dir].link[!dir]))
						root = doubleRot(root, !dir);
				}
			}
		}
		return root;
	}

	bool insertBU(T data) {
		this.root = this.insertRecursive(this.root, data);
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

			if(!done)
				root = removeBalance(root, dir, done);
		}
		return root;
	}

	int removeBU(T data) {
		bool done = false;

		this.root = removeRecursive(this.root, data, done);
		if(this.root !is null)
			this.root.red = 0;

		return 1;
	}


	int remove(int data) {
		if(this.root !is null) {
			Node!(T) head = new Node!(T); /* False this.root */
			Node!(T) q, p, g; /* Helpers */
			Node!(T) f = null;  /* Found item */
			bool dir = true;

			/* Set up helpers */
			q = head;
			g = p = null;
			q.link[1] = this.root;

			/* Search and push a red down */
			while(q.link[dir] !is null) {
				bool last = dir;

				/* Update helpers */
				g = p, p = q;
				q = q.link[dir];
				dir = q.data < data;

				/* Save found node */
				if(q.data == data)
					f = q;

				/* Push the red node down */
				if(!isRed(q) && !isRed(q.link[dir])) {
					if(isRed(q.link[!dir]))
						p = p.link[last] = singleRot(q, dir);
					else if(!isRed(q.link[!dir])) {
						Node!(T) s = p.link[!last];

						if(s !is null) {
							if(!isRed(s.link[!last]) && !isRed(s.link[last])) {
								/* Color flip */
								p.red = 0;
								s.red = 1;
								q.red = 1;
							} else {
								bool dir2 = g.link[1] == p;

								if(isRed(s.link[last]))
									g.link[dir2] = doubleRot(p, last);
								else if(isRed(s.link[!last]))
									g.link[dir2] = singleRot(p, last);

								/* Ensure correct coloring */
								q.red = g.link[dir2].red = 1;
								g.link[dir2].link[0].red = 0;
								g.link[dir2].link[1].red = 0;
							}
						}
					}
				}
			}

			/* Replace and remove if found */
			if(f !is null) {
				f.data = q.data;
				p.link[p.link[1] == q] =
					q.link[q.link[0] is null];
			}

			/* Update root and make it black */
			this.root = head.link[1];
			if(this.root !is null)
				this.root.red = 0;
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
				else
					root.link[dir] = p;

				done = true;
			}
		}

		return root;
	}

	

	int validate() {
		return rbAssert(this.root);
	}

	int rbAssert(Node!(T) root) {
		if(root is null)
			return 1;
		else {
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
			lh = rbAssert(ln);
			rh = rbAssert(rn);

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
	RBTree!(int) rbt1 = new RBTree!(int)();
	int times = 10000;
	int[] rn = new int[times];
	writeln(getTicks());
	
	for(int i = 0; i < times; i++) {
		int tmp = rand();
		rn[i] = tmp;
		rbt1.insert(tmp);
		rbt1.validate();
	}
	writeln(getTicks());

	for(int i = 0; i < times; i++) {
		rbt1.remove(rn[i]);
		rbt1.validate();
	}
}

void main() {
	writeln("rbtree unittest passed");
	return;
}
