module bst;

import isr;
import tree;

import hurt.conv.conv;

import std.stdio;
 
class BinarySearchTree(T) : Tree!(T) { 
	private bool search(const T item, ref Node!(T) curr, ref Node!(T) prev , 
			ref bool lr) const {
	    while (curr !is null) {
	        if(item == curr.data)
		    return true;
	        lr = curr.data < item;
	        prev = curr;
	        curr = curr.link[lr];
	    }
	    return false;
	}
	 
	bool insert(T item) {
	    if(this.root is null) {
	        this.root = new Node!(T);
	        this.root.data = item;
	        this.size++;
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
	    this.size++;
	    return true;
	}

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
	 
	bool remove(T item) {
		if(this.root !is null ) {
			Node!(T) p = null, succ;
			Node!(T) it = this.root;
			bool dir;

			while(true) {
				if(it is null )
					return false;
				else if(it.data == item)
					break;

				dir = it.data < item;
				p = it;
				it = it.link[dir];
			}

			if(it.link[0] !is null && it.link[1] !is null ) {
				p = it;
				succ = it.link[1];

				while(succ.link[0] !is null ) {
					p = succ;
					succ = succ.link[0];
				}

				it.data = succ.data;
				bool which = p.link[1] is succ;
				p.link[which] = succ.link[1];
				if(p.link[which] !is null) {
					p.link[which].parent = p;
				}
			} else {
				dir = it.link[0] is null;

				if(p is null) {
					this.root = it.link[dir];
					if(this.root !is null) {
						this.root.parent = null;
					}
				} else {
					bool which = p.link[1] is it;
					p.link[which] = it.link[dir];
					if(p.link[which] !is null) {
						p.link[which].parent = p;
					}
				}
			}
		}

    	size--;
    	return true;
	}
	 
	Node!(T) search(T item) {
	    bool found;
	    Node!(T) curr = root, prev;
	 
	    found = search(item, curr, prev, found);
		if(found) {
			return curr;
		} else {
			return null;
		}
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

bool compare(T)(BinarySearchTree!(T) t, T[T] s) {
	if(t.getSize() != s.length) {
		writeln(__LINE__, " size wrong");
		return false;
	}
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
