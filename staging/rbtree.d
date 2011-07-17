module rbtree;

import isr;
import tree;

import std.stdio;

import hurt.conv.conv;

/*
private class Iterator(T) : ISRIterator!(T) {
	private Node!(T) current;

	this(Node!(T) current) {
		this.current = current;
	}

	void opUnary(string s)() if(s == "++") {
		Node!(T) y;
		if(null !is (y = this.current.link[true])) {
			while(y.link[false] !is null) {
				y = y.link[false];
			}
			this.current = y;
		} else {
			y = this.current.parent;
			while(y !is null && this.current is y.link[true]) {
				this.current = y;
				y = y.parent;
			}
			this.current = y;
		}
	}	

	void opUnary(string s)() if(s == "--") {
		Node!(T) y;
		if(null !is (y = this.current.link[false])) {
			while(y.link[true] !is null) {
				y = y.link[true];
			}
			this.current = y;
		} else {
			y = this.current.parent;
			while(y !is null && this.current is y.link[false]) {
				this.current = y;
				y = y.parent;
			}
			this.current = y;
		}
	}

	bool isValid() const {
		return this.current !is null;
	}

	T opUnary(string s)() if(s == "*") {
		return this.current.data;
	}
}
private class Node(T) : ISRNode!(T) {
	bool red;
	T data;
	Node!(T) link[2];
	Node!(T) parent;

	this() {

	}

	this(T data) {
		this.data = data;
		this.red = true;
	}

	T getData() {
		return this.data;
	}
}
*/

class RBTree(T) : Tree!(T) {
	//private Node!(T) root;
	//private size_t size;

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
/*
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
		//writeln(__LINE__," ",count, " ", be is null, " ", it is null, " ", it.isValid(), " ", *it);
		return it;	
	}

	Iterator!(T) end() {
		Node!(T) end = this.root;
		if(end is null)
			return new Iterator!(T)(null);
		while(end.link[1] !is null)
			end = end.link[1];
		return new Iterator!(T)(end);
	}*/

	private static validate(const Node!(T) node, const Node!(T) parent) {
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

			const Node!(T) ln = node.link[0];
			const Node!(T) rn = node.link[1];

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

	public bool validate() const {
		return validate(this.root, null) != 0;	
	}

/*
	T[] values() {
		if(this.size == 0) {
			return null;
		}
		T[] ret = new T[this.size];
		size_t ptr = 0;
		Iterator!(T) it = this.begin();
		//writeln(__LINE__," ", it.isValid());
		while(it.isValid()) {
			//writeln(ptr, " ", *it);
			ret[ptr++] = *it;
			it++;
		}
		assert(ptr == ret.length, conv!(size_t,string)(ptr) ~ " " ~
			conv!(size_t, string)(ret.length));
		return ret;
	}
	*/

	this() {
		this.root = null;
		this.size = 0;
	}

	public Node!(T) search(const T data) {
		return search(this.root, data);
	}

	private Node!(T) search(Node!(T) node ,const T data) {
		if(node is null)
			return null;
		else if(node.data == data)
			return node;
		else {
			bool dir = node.data < data;
			return this.search(node.link[dir], data);
		}
	}

	/*private static Node!(T) insertR(Node!(T) node, T data) {
		if(node is null) {
			node = new Node!(T)(data);
		} else if(data != node.data) {	
			bool dir = node.data < data;
			node.link[dir] = insertR(node.link[dir], data);	
			if(node.link[dir] !is null)
				node.link[dir].parent = node;

			if(isRed(node.link[dir])) {
				if(isRed(node.link[!dir])) {
					node.red = true;
					node.link[0].red = false;
					node.link[1].red = false;
				} else {
					if(isRed(node.link[dir].link[dir])) {
						node = singleRotate(node, !dir);
					} else if(isRed(node.link[dir].link[!dir])) {
						node = doubleRotate(node, !dir);
					}
				}
			}
		}
		return node;
	}

	bool insert(T data) {
		this.root = insertR(this.root, data);
		if(this.root !is null)
			this.root.parent = null;
		this.root.red = false;
		return true;
	}
*/

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

				if(q.data == data)
					break;

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

	/*public size_t getSize() const {
		return this.size;
	}*/
	
	/*void remove(T data) {
		if(this.root !is null) {
			Node!(T) head = new Node!(T)();
			Node!(T) q, p, g;
			Node!(T) f = null;
			bool dir = true;

			q = head;
			g = p = null;
			q.link[1] = this.root;

			while(q.link[dir] !is null) {
				bool last = dir;
				g = p, p = q;
				q = q.link[dir];
				dir = q.data < data;

				if(q.data == data)
					f = q;

				if(!isRed(q) && !isRed(q.link[dir])) {
					if(isRed(q.link[!dir])) {
						//p = p.link[last] = singleRotate(q, dir);
						p.link[last] = singleRotate(q, dir);
						if(p.link[last] !is null) {
							p.link[last].parent = p;
						}
						Node!(T) oldPar = p.parent;
						p = p.link[last];
						p.parent = oldPar;
					} else if(!isRed(q.link[!dir])) {
						Node!(T) s = p.link[!last];

						if(s !is null) {
							if(!isRed(s.link[!last]) && isRed(s.link[last])) {
								p.red = false;
								s.red = true;
								q.red = true;
							} else {
								int dir2 = g.link[1] == p;
								if(isRed(s.link[last])) {
									g.link[dir2] = doubleRotate(p,last);
									if(g.link[dir2] !is null)
										g.link[dir2].parent = g;
								} else if(isRed(s.link[!last])) {
									g.link[dir2] = singleRotate(p, last);
									if(g.link[dir2] !is null)
										g.link[dir2].parent = g;
								}

								q.red = g.link[dir2].red = 1;
								g.link[dir2].link[0].red = 0;
								g.link[dir2].link[1].red = 0;
							}
						}
					}
				}
			}
			if(f !is null) {
				f.data = q.data;
				bool to = p.link[1] is q;
				//p.link[p.link[1] is q] = q.link[q.link[0] is null];
				p.link[to] = q.link[q.link[0] is null];
				if(p.link[to] !is null)
					p.link[to].parent = p;
			}

			this.root = head.link[1];
			if(this.root !is null) {
				this.root.parent = null;
				this.root.red = false;
			}
		}
	}*/
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
