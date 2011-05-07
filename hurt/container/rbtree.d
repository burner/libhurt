module hurt.container.rbtree;

import hurt.util.random;
import hurt.util.datetime;
import hurt.conv.conv;

import std.stdio;

abstract class Node {
	private bool red;
	private Node par;
	private Node link[2];

	public final bool isRed() const {
		return this.red;
	}

	public final void setRed(bool red) {
		this.red = red;
	}

	public final Node getPar() {
		return this.par;
	}

	public final void setPar(Node par) {
		this.par = par;
	}

	public final Node getLink(bool dir) {
		return this.link[dir];
	}

	public final void setLink(bool dir, Node node) {
		this.link[dir] = node;
	}

	public override int opCmp(Object o);
	public override bool opEquals(Object o);
	public void set(Node);
}
 
class RBTree(T : Node) {
	class Iterator(T) {
		Node current;
		//Node treeRoot;
		
		this(Node root, bool begin) {
			this.current = root;
			//this.treeRoot = root;
			while(this.current.getLink(!begin) !is null) {
				this.current = this.current.getLink(!begin);
			}
		}

		void opUnary(string s)() if(s == "++") {
			Node y;
			if(null !is (y = this.current.getLink(true))) {
				while(y.getLink(false) !is null) {
					y = y.getLink(false);
				}
				this.current = y;
			} else {
				y = this.current.par;
				while(y !is null && this.current is y.getLink(true)) {
					this.current = y;
					y = y.par;
				}
				this.current = y;
			}
		}	

		void opUnary(string s)() if(s == "--") {
			Node y;
			if(null !is (y = this.current.getLink(false))) {
				while(y.getLink(true) !is null) {
					y = y.getLink(true);
				}
				this.current = y;
			} else {
				y = this.current.par;
				while(y !is null && this.current is y.getLink(false)) {
					this.current = y;
					y = y.par;
				}
				this.current = y;
			}
		}	
	
		T opUnary(string s)() if(s == "*") {
			return cast(T)this.current;
		}
	
		bool isValid() const {
			return current !is null;
		}
	}
	
	static bool isRed(const Node tt) {
		return tt !is null && tt.isRed();
	}

	Node root;
	size_t size;

	this() {
		this.size = 0;
		this.root = null;
	}

	size_t getSize() const {
		return this.size;
	}

	Node singleRot(Node root, bool dir) {
		Node save = root.getLink(!dir);

		root.setLink(!dir, save.getLink(dir));
		if(root.getLink(!dir) !is null) {
			root.getLink(!dir).setPar(root);
		}
		save.setLink(dir,root);
		if(save.getLink(dir) !is null) {
			save.getLink(dir).setPar(save);
		}
		root.setRed(true);
		save.setRed(false);

		return save;
	}

	Node doubleRot(Node root, bool dir) {
		root.setLink(!dir, singleRot(root.getLink(!dir), !dir));
		root.getLink(!dir).setPar(root);
		return singleRot(root, dir);
	}

	Node insertRecursive(Node root, Node data, Node parent) {
		if(root is null) {
			//root = new Node(data, parent);
			root = data;
			data.setRed(true);
			root.setPar(parent);
			this.size++;
		} else if(data != root) {
			bool dir = root < data;
			root.setLink(dir, insertRecursive(root.getLink(dir), data, root));
			if(root.getLink(dir) !is null) {
				root.getLink(dir).setPar(root);
			}
			/* Hey, let's rebalance here! */
			if(isRed(root.getLink(dir))) {
				if(isRed(root.getLink(!dir))) {
					/* Case 1 */
					root.setRed(true);
					root.getLink(false).setRed(false);
					root.getLink(true).setRed(false);
				} else {
					/* Cases 2 & 3 */
					if(isRed(root.getLink(dir).getLink(dir))) {
						root = singleRot(root, !dir);
						root.setPar(parent);
					} else if(isRed(root.getLink(dir).getLink(!dir))) {
						root = doubleRot(root, !dir);
						root.setPar(parent);
					}
				}
			}
		}
		return root;
	}

	bool insert(Node data) {
		this.root = this.insertRecursive(this.root, data, null);
		this.root.setPar(null);
		this.root.setRed(false);
		return true;
	}

	Node removeRecursive(Node root, Node data, ref bool done) {
		if(root is null) {
			done = true;
		} else {
			bool dir;

			if(root == data) {
				if(root.getLink(0) is null || root.getLink(1) is null) {
					Node save = root.getLink(root.getLink(0) is null);

					/* Case 0 */
					if(isRed(root))
						done = true;
					else if(isRed(save)) {
						save.setRed(0);
						done = true;
					}
					this.size--;
					return save;
				} else {
					Node heir = root.getLink(0);

					while(heir.getLink(1) !is null)
						heir = heir.getLink(1);

					root.set(heir);
					data.set(heir);
					//root.data = heir.data;
					//data = heir.data;
				}
			}

			dir = root < data;
			root.setLink(dir, removeRecursive(root.getLink(dir), data, done));
			if(root.getLink(dir) !is null) {
				root.getLink(dir).setPar(root);
			}

			if(!done) {
				root = removeBalance(root, dir, done);
			}
		}
		return root;
	}

	int remove(Node data) {
		bool done = false;

		this.root = removeRecursive(this.root, data, done);
		if(this.root !is null) {
			this.root.setRed(0);
			this.root.setPar(null);
		}

		return 1;
	}

	Node removeBalance(Node root, bool dir, ref bool done) {
		Node p = root;
		Node s = root.getLink(!dir);

		/* Case reduction, remove red sibling */
		if(isRed(s)) {
			root = singleRot(root, dir);
			s = p.getLink(!dir);
		}

		if(s !is null) {
			if(!isRed(s.getLink(0)) && !isRed(s.getLink(1))) {
				if(isRed(p))
					done = true;
				p.setRed(false);
				s.setRed(true);
			} else {
				bool save = p.isRed();
				bool new_root = (root == p);

				if(isRed(s.getLink(!dir)))
					p = singleRot(p, dir);
				else
					p = doubleRot(p, dir);

				p.setRed(save);
				p.getLink(0).setRed(false);
				p.getLink(1).setRed(false);

				if(new_root)
					root = p;
				else {
					root.setLink(dir, p);
					root.getLink(dir).setPar(root);
				}

				done = true;
			}
		}

		return root;
	}

	Node find(const Node data) {
		Node it = this.root;
		while(it !is null) {
			if(it == data) {
				return it;
			} else {
				bool dir = it < data;
				it = it.getLink(dir);
			}
		}
		return null;
	}

	public int opApply(scope int delegate(ref Node) dg) {
		Node stack[256];
		size_t sPtr = 0;
		Node current = this.root;
		while(sPtr > 0 || current) {
			if(current) {
				stack[sPtr++] = current;
				current = current.getLink(0);
			} else {
				current = stack[--sPtr];
				if(int r = dg(current)) {
					return r;
				}
				current = current.getLink(1);
			}
		}
		return 0;
	}

	Iterator!(T) begin() {
		return new Iterator!(T)(this.root, true);
	}

	Iterator!(T) end() {
		return new Iterator!(T)(this.root, false);
	}

	int validate() {
		return rbAssert(this.root, null);
	}

	int rbAssert(Node root, Node parent) {
		if(root is null)
			return 1;
		else {
			if(parent !is null && root.getPar() !is parent) {
				writeln("Parent not correct ", parent.toString(), " ",root.toString());
			}
			Node ln = root.getLink(false);
			Node rn = root.getLink(true);

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
			if((ln !is null && ln >= root) ||(rn !is null && rn <= root)) {
				writeln("Binary tree violation");
				return 0;
			}

			/* Black height mismatch */
			if(lh != 0 && rh != 0 && lh != rh ) {
				writeln("Black violation ", lh, " ", rh);
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

class Map(T,S) : Node {
	T key;
	S data;
	
	this(T key, S data) {
		this.key = key;
		this.data = data;
	}

	override bool opEquals(Object o) {
		Map!(T,S) f = cast(Map!(T,S))o;
		return this.key == f.key;
	}

	override void set(Node toSet) {
		Map!(T,S) c = cast(Map!(T,S))toSet;
		this.key = c.key;
		this.data = c.data;
	}

	override int opCmp(Object o) {
		Map!(T,S) f = cast(Map!(T,S))o;
		int fHash = f.key;
		int thisHash = this.key;
		if(thisHash > fHash)
			return 1;
		else if(thisHash < fHash)
			return -1;
		else
			return 0;
	}
}

class ISet : Node {
	int data;
	
	this(int data) {
		this.data = data;
	}

	override bool opEquals(Object o) {
		ISet f = cast(ISet)o;
		return this.data == f.data;
	}

	override void set(Node toSet) {
		ISet c = cast(ISet)toSet;
		this.data = c.data;
	}

	override int opCmp(Object o) {
		ISet f = cast(ISet)o;
		int fHash = f.data;
		int thisHash = this.data;
		if(thisHash > fHash)
			return 1;
		else if(thisHash < fHash)
			return -1;
		else
			return 0;
	}

	override string toString() {
		return conv!(int,string)(this.data);
	}
}

unittest {
	RBTree!(ISet) rbt2 = new RBTree!(ISet)();
	int times = 20;
	int[] rn = new int[times];
	foreach(ref it; rn) {
		it = rand(5, times*2);
	}

	long st = getMilli();
	for(int i = 0; i < times; i++) {
		int tmp = rn[i];
		rbt2.insert(new ISet(tmp));
		rbt2.validate();
	}
	rbt2.validate();
	writeln("bottom up insert ", getMilli()-st);
	foreach(it; rbt2) {
		writeln(it);
	}
	RBTree!(ISet).Iterator!(ISet) it = rbt2.begin();
	size_t count = 0;
	while(it.isValid()) {
		writeln("hello ", *it);
		it++;
		count++;
	}
	assert(count == rbt2.getSize());
	RBTree!(ISet).Iterator!(ISet) jt = rbt2.end();
	while(jt.isValid()) {
		//writeln("hello ", *jt);
		jt--;
	}
		
	st = getMilli();
	for(int i = 0; i < times; i++) {
		rbt2.remove(new ISet(rn[i]));
		rbt2.validate();
	}
	writeln("bottom up remove ", getMilli()-st);
	assert(rbt2.getSize() == 0);

	RBTree!(Map!(int,string)) map = new RBTree!(Map!(int,string));
	map.insert(new Map!(int,string)(44,"fourtyfour"));
	assert(map.find(new Map!(int,string)(44, null)));
}
