module hurt.container.set;

import isr;
import rbtree;
import bst;
import hashtable;
import tree;

import hurt.conv.conv;

import std.stdio;

class Set(T) {
	ISR!(T) map;
	ISRType type;

	this(ISRType type=ISRType.RBTree) {
		this.type = type;
		this.makeMap();
	}

	private void makeMap() {
		if(this.type == ISRType.RBTree) {
			this.map = new RBTree!(T)();
		} else if(this.type == ISRType.BinarySearchTree) {
			this.map = new BinarySearchTree!(T)();
		} else if(this.type == ISRType.HashTable) {
			this.map = new HashTable!(T)();
		}
	}

	public size_t getSize() const { return this.map.getSize(); }
	public size_t isEmpty() const { return this.map.isEmpty(); }

	public bool contains(T data) {
		ISRNode!(T) it = this.map.search(data);	
		return it !is null;
	}

	public bool insert(T data) {
		return this.map.insert(data);
	}

	public bool remove(T data) {
		return this.map.remove(data);
	}

	ISRIterator!(T) begin() {
		return this.map.begin();
	}

	ISRIterator!(T) end() {
		return this.map.end();
	}

	public void clear() {
		this.makeMap();
	}

	public Set!(T) dup() {
		Set!(T) ret = new Set!(T)(this.type);
		ISRIterator!(T) it = this.begin();

		for(;it.isValid(); it++)
			ret.insert(*it);

		return ret;
	}

	public override bool opEquals(Object o) {
		Set!(T) s = cast(Set!(T))o;
		ISRIterator!(T) sit = s.begin();
		while(sit.isValid()) {
			if(!this.contains(*sit))
				return false;
			sit++;
		}
		sit = this.begin();
		while(sit.isValid()) {
			if(!s.contains(*sit))
				return false;
			sit++;
		}
		return this.getSize() == s.getSize();
	}
}

void main() {
	int[][] lot = [[2811, 1089, 3909, 3593, 1980, 2863, 676, 258, 2499, 3147,
	3321, 3532, 3009, 1526, 2474, 1609, 518, 1451, 796, 2147, 56, 414, 3740,
	2476, 3297, 487, 1397, 973, 2287, 2516, 543, 3784, 916, 2642, 312, 1130,
	756, 210, 170, 3510, 987], [0,1,2,3,4,5,6,7,8,9,10],
	[10,9,8,7,6,5,4,3,2,1,0],[10,9,8,7,6,5,4,3,2,1,0,11],
	[0,1,2,3,4,5,6,7,8,9,10,-1],[11,1,2,3,4,5,6,7,8,0]];

	Set!(int)[] sa = new Set!(int)[3];
	sa[0] = new Set!(int)(ISRType.RBTree);
	sa[1] = new Set!(int)(ISRType.BinarySearchTree);
	sa[2] = new Set!(int)(ISRType.HashTable);
	foreach(it;lot) {
		foreach(idx,jt;it) {
			for(int i = 0; i < 3; i++) {
				assert(sa[i].insert(jt), conv!(int,string)(jt));
				assert(sa[i].getSize() == idx+1, conv!(size_t,string)(idx+1) 
					~ " " ~ conv!(size_t,string)(sa[i].getSize()));
				assert(sa[i].contains(jt), conv!(int,string)(jt));
				assert(sa[i].remove(jt), conv!(int,string)(jt));
				assert(!sa[i].contains(jt), conv!(int,string)(jt));
				assert(sa[i].insert(jt), conv!(int,string)(jt));
				sa[i].insert(jt), conv!(int,string)(jt);
				assert(sa[i].remove(jt), conv!(int,string)(jt));
				assert(!sa[i].contains(jt), conv!(int,string)(jt));
				assert(sa[i].insert(jt), conv!(int,string)(jt));
				for(int j = 0; j < idx; j++) {
					assert(sa[i].contains(it[j]));
				}
		
				ISRIterator!(int) sit = sa[i].begin();
				size_t cnt = 0;
				while(sit.isValid()) {
					assert(sa[i].contains(*sit));
					sit++;
					cnt++;
				}
				assert(cnt == sa[i].getSize(), conv!(size_t,string)(cnt) ~
					" " ~ conv!(size_t,string)(sa[i].getSize()));
				sit = sa[i].end();
				cnt = 0;
				while(sit.isValid()) {
					assert(sa[i].contains(*sit));
					sit--;
					cnt++;
				}
				assert(cnt == sa[i].getSize(), conv!(size_t,string)(cnt) ~
					" " ~ conv!(size_t,string)(sa[i].getSize()));
			}
			assert(sa[0] == sa[1]);
			assert(sa[0] == sa[2]);
			assert(sa[1] == sa[2]);
		}
		sa[0].clear();
		sa[1].clear();
		sa[2].clear();
	}
	foreach(it;lot) {
		foreach(idx,jt;it) {
			for(int i = 0; i < 3; i++) {
				sa[i].insert(jt), conv!(int,string)(jt);
				assert(sa[i].contains(jt), conv!(int,string)(jt));
				assert(sa[i].remove(jt), conv!(int,string)(jt));
				assert(!sa[i].contains(jt), conv!(int,string)(jt));
				assert(sa[i].insert(jt), conv!(int,string)(jt));
				sa[i].insert(jt), conv!(int,string)(jt);
				assert(sa[i].remove(jt), conv!(int,string)(jt));
				assert(!sa[i].contains(jt), conv!(int,string)(jt));
				assert(sa[i].insert(jt), conv!(int,string)(jt));
				for(int j = 0; j < idx; j++) {
					assert(sa[i].contains(it[j]));
				}
		
				ISRIterator!(int) sit = sa[i].begin();
				size_t cnt = 0;
				while(sit.isValid()) {
					assert(sa[i].contains(*sit));
					sit++;
					cnt++;
				}
				assert(cnt == sa[i].getSize(), conv!(size_t,string)(cnt) ~
					" " ~ conv!(size_t,string)(sa[i].getSize()));
			}
			assert(sa[0] == sa[1]);
			assert(sa[0] == sa[2]);
			assert(sa[1] == sa[2]);
		}
		foreach(idx,jt;it) {
			for(int i = 0; i < 3; i++) {
				sa[i].remove(jt);
			}
			assert(sa[0] == sa[1]);
			assert(sa[0] == sa[2]);
			assert(sa[1] == sa[2]);
		}
	}
}
