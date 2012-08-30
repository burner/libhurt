module hurt.container.rbtree;

import hurt.container.isr;
import hurt.container.tree;

import std.stdio;

import hurt.conv.conv;

class RBTree(T) : Tree!(T) {
	private static isRed(const Node!(T) n) {
		return n !is null && n.red;
	}

	private static singleRotate(Node!(T) node, bool dir) {
		Node!(T) save = node.link[!dir];
		node.link[!dir] = save.link[dir];
		if(node.link[!dir] !is null) {
			node.link[!dir].parent = node;
		}
		save.link[dir] = node;
		if(save.link[dir] !is null) {
			save.link[dir].parent = save;
		}
		node.red = true;
		save.red = false;
		return save;
	}

	private static doubleRotate(Node!(T) node, bool dir) {
		node.link[!dir] = singleRotate(node.link[!dir], !dir);
		if(node.link[!dir] !is null) {
			node.link[!dir].parent = node;	
		}
		return singleRotate(node, dir);
	}

	private static int validate(Node!(T) node, Node!(T) parent) {
		if(node is null) {
			return 1;
		} else {
			if(node.parent !is parent) {
				writeln("parent violation ", node.parent is null, " ",
					parent is null);
			}
			if(node.link[0] !is null)
				if(node.link[0].parent !is node) {
					writeln("parent violation link wrong");

				}
			if(node.link[1] !is null)
				if(node.link[1].parent !is node) {
					writeln("parent violation link wrong");

				}

			Node!(T) ln = node.link[0];
			Node!(T) rn = node.link[1];

			if(isRed(node)) {
				if(isRed(ln) || isRed(rn)) {
					writeln("Red violation");
					return 0;
				}
			}
			int lh = validate(ln, node);
			int rh = validate(rn, node);
			
			if((ln !is null && ln.data >= node.data)
					|| (rn !is null && rn.data <= node.data)) {
				writeln("Binary tree violation");
				return 0;
			}

			if(lh != 0 && rh != 0 && lh != rh) {
				writeln("Black violation ", lh, " ", rh);
				return 0;
			}

			if(lh != 0 && rh != 0)
				return isRed(node) ? lh : lh +1;
			else
				return 0;
		}
	}

	public bool validate() {
		return validate(this.root, null) != 0;	
	}

	public Node!(T) search(T data) {
		return search(this.root, data);
	}

	private Node!(T) search(Node!(T) node ,T data) {
		if(node is null)
			return null;
		else if(node.data == data)
			return node;
		else {
			bool dir = node.data < data;
			return this.search(node.link[dir], data);
		}
	}

	public bool remove(ISRIterator!(T) it, bool dir = true) {
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

	public bool remove(T data) {
		bool done = false;
		bool succes = false;
		this.root = removeR(this.root, data, done, succes);
		if(this.root !is null) {
			this.root.red = false;
			this.root.parent = null;
		}
		if(succes)
			this.size--;
		return succes;
	}

	private static Node!(T) removeR(Node!(T) node, T data, ref bool done, 
			ref bool succes) {
		if(node is null)
			done = true;
		else {
			bool dir;
			if(node.data == data) {
				succes = true;
				if(node.link[0] is null || node.link[1] is null) {
					Node!(T) save = node.link[node.link[0] is null];	

					if(isRed(node)) {
						done = true;
					} else if(isRed(save)) {
						save.red = false;
						done = true;
					}
					return save;
				} else {
					Node!(T) heir = node.link[0];
					while(heir.link[1] !is null)
						heir = heir.link[1];

					node.data = heir.data;
					data = heir.data;
				}
			}
			dir = node.data < data;
			node.link[dir] = removeR(node.link[dir], data, done, succes);
			if(node.link[dir] !is null) {
				node.link[dir].parent = node;
			}

			if(!done)
				node = removeBalance(node, dir, done);
		}
		return node;
	}

	private static removeBalance(Node!(T) node, bool dir, ref bool done) {
		Node!(T) p = node;
		Node!(T) s = node.link[!dir];
		if(isRed(s)) {
			node = singleRotate(node, dir);
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
				bool newRoot = (node == p);
				
				if(isRed(s.link[!dir]))
					p = singleRotate(p, dir);
				else
					p = doubleRotate(p, dir);

				p.red = save;
				p.link[0].red = false;
				p.link[1].red = false;

				if(newRoot)
					node = p;
				else {
					node.link[dir] = p;
					if(node.link[dir] !is null) {
						node.link[dir].parent = node;
					}
				}

				done = true;
			}
		}
		return node;
	}
	
	public bool insert(T data) {
		if(this.root is null) {
			this.root = new Node!(T)(data);
			if(this.root is null) 
				return false;
			this.size++;
		} else {
			scope Node!(T) head = new Node!(T)();
			Node!(T) g, t;
			Node!(T) p, q;
			bool dir = false, last;

			t = head;
			g = p = null;
			q = t.link[1] = this.root;

			while(true) {
				if(q is null) {
					p.link[dir] = q = new Node!(T)(data);
					if(q is null)
						return false;
					else {
						q.parent = p;
						this.size++;
					}
				} else if(isRed(q.link[0]) && isRed(q.link[1])) {
					q.red = true;
					q.link[0].red = false;
					q.link[1].red = false;
					if(q.link[0] !is null) {
						q.link[0].parent = q;
					}
					if(q.link[1] !is null) {
						q.link[1].parent = q;
					}
				}
				if(isRed(q) && isRed(p)) {
					bool dir2 = t.link[1] is g;
					if(q is p.link[last]) {
						t.link[dir2] = singleRotate(g,!last);
						if(t.link[dir2] !is null) {
							t.link[dir2].parent = t;
						}
					} else {
						t.link[dir2] = doubleRotate(g,!last);
						if(t.link[dir2] !is null) {
							t.link[dir2].parent = t;
						}
					}
				}

				if(q.data == data) {
					break;
				}

				last = dir;
				dir = q.data < data;

				if(g !is null)
					t = g;
				g = p;
				p = q;
				q = q.link[dir];
			}
			this.root = head.link[1];
			if(this.root !is null) {
				this.root.parent = null;
			}
		}
		this.root.red = false;				
		return true;
	}
}

bool compare(T)(RBTree!(T) t, T[T] s) {
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
		RBTree!(int) a = new RBTree!(int)();
		int[int] at;
		foreach(idx, it; lots) {
			assert(a.insert(it), conv!(int,string)(it));
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
		RBTree!(int) itT = new RBTree!(int)();
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
		RBTree!(int) itT = new RBTree!(int)();
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
