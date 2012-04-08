module hurt.container.arraybst;

import hurt.container.arraytree;

import hurt.conv.conv;
import hurt.io.stdio;
import hurt.util.slog;
 
class BinarySearchTreeArray(T) : ArrayTree!(T) { 
	private bool search(const T item, ref long curr, ref long prev, 
			ref bool lr) const {
		while(curr != -1) {
			//this.print();
			if(item == this.nodes[curr].data) {
				return true;
			}
			
			lr = this.nodes[curr].data < item;
			prev = curr;
			curr = this.nodes[curr].link[lr];
		}
		if(prev > -1 && this.nodes[prev].data == item) {
			curr = prev;
			return true;
		} else {
			return false;
		}
	}
	 
	bool insert(T item) {
		if(this.root == -1) {
			//this.root = new Node!(T);
			this.root = this.newNode();
			//log("%d", this.root);
			//log("%d", this.root);
			this.nodes[this.root] = Node!(T)(this,item);
			this.size++;
			return true;
		}
		bool lr;
		long curr = this.root; 
		long prev;

		if(this.search(item, curr, prev, lr)) {
			return false;
		}

		this.nodes[prev].link[lr] = this.newNode();
		this.nodes[this.nodes[prev].link[lr]] = Node!(T)(this,item);
		if(prev != -1) {
			this.nodes[this.nodes[prev].link[lr]].parent = prev;
		}
		this.size++;
		return true;
	}

	/*public bool remove(ISRIterator!(T) it, bool dir = true) {
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
	}*/
	 
	bool remove(T item) {
		if(this.root != -1 ) {
			//Node!(T) p = null;
			long p = -1;
			long succ = -1;
			long it = this.root;
			bool dir;

			while(true) {
				if(it == -1) {
					return false;
				} else if(this.nodes[it].data == item) {
					break;
				}

				dir = this.nodes[it].data < item;
				p = it;
				it = this.nodes[it].link[dir];
			}

			if(this.nodes[it].link[0] != -1 && 
				this.nodes[it].link[1] != -1 ) {
				//log();
				p = it;
				succ = this.nodes[it].link[1];

				while(this.nodes[succ].link[0] != -1) {
					p = succ;
					succ = this.nodes[succ].link[0];
				}

				this.nodes[it].data = this.nodes[succ].data;
				bool which = this.nodes[p].link[1] == -1;
				this.nodes[p].link[which] = this.nodes[succ].link[1];
				if(this.nodes[p].link[which] != -1) {
					this.nodes[this.nodes[p].link[which]].parent = p;
				}

				this.releaseNode(succ);
			} else {
				//log();
				dir = this.nodes[it].link[0] == -1;

				if(p == -1) {
					//log("%d %b", it, dir);
					this.root = this.nodes[it].link[dir];
					if(this.root != -1 && this.nodes[this.root].isValid()) {
						this.nodes[this.root].parent = -1;
					}
					this.releaseNode(it);
				} else {
					//log("%d", p);
					bool which = this.nodes[this.nodes[p].link[1]] == 
						this.nodes[it];
					this.nodes[this.nodes[p].link[which]] = 
						this.nodes[this.nodes[it].link[dir]];
					if(this.nodes[this.nodes[p].link[which]].isValid()) {
						this.nodes[this.nodes[p].link[which]].parent = p;
					}
					this.releaseNode(it);
				}
			}
		}

		size--;
		return true;
	}
	 
	Node!(T) search(T item) {
		bool found;
		long curr = this.root; 
		long prev = -1;
	 
		found = search(item, curr, prev, found);
		if(found) {
			return this.nodes[curr];
		} else {
			return Node!(T)(this);
		}
	}

	public void print() const {
		foreach(idx, it; this.nodes) {
			printf("%u:%s,", idx, it.toString());
		}
		printfln("%d %d %d", this.root, this.tail, this.inBetween.getSize());
	}
	
	bool validate() const {
		if(this.root == -1) 
			return true;
		return this.nodes[this.root].validate(true, Node!(T)(this));
	}

	/*void print() const {
		this.nodes[this.root].print();
	}*/
}

/*bool compare(T)(BinarySearchTree!(T) t, T[T] s) {
	if(t.getSize() != s.length) {
		println(__LINE__, "size wrong");
		return false;
	}
	foreach(it; s.values) {
		if(t.search(it) is null) {
			println(__LINE__, "size wrong");
			return false;
		}
	}
	return true;
}*/

version(staging) {
void main() {
	BinarySearchTreeArray!(int) bst = new BinarySearchTreeArray!(int)();
	assert(bst.insert(22));
	assert(bst.validate());
	assert(bst.search(22).isValid());
	assert(!bst.search(23).isValid());
	assert(bst.remove(22));
	assert(bst.validate());
	assert(!bst.search(22).isValid());
	assert(bst.insert(22));
	assert(bst.insert(23));
	assert(bst.validate());
	//bst.print();
	assert(bst.search(22).isValid());
	assert(bst.search(23).isValid());
	assert(bst.remove(22));
	assert(bst.validate());
	assert(!bst.search(22).isValid());
	assert(bst.search(23).isValid());
	//bst.print();
	assert(bst.insert(44));
	assert(bst.validate());
	//bst.print();
}
}

/*unittest {
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
}*/
