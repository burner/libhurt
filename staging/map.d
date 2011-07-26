module hurt.container.map;

import isr;
import rbtree;
import bst;
import hashtable;
import tree;

import hurt.conv.conv;

import std.stdio;
import std.traits, std.typetuple;

class MapItem(T,S) {
	T key;
	S data;

	this() {}

	this(T key, S data) {
		this.key = key;
		this.data = data;
	}

	override bool opEquals(Object o) const {
		MapItem!(T,S) f = cast(MapItem!(T,S))o;
		return this.key == f.key;
	}

	override int opCmp(Object o) const {
		MapItem!(T,S) f = cast(MapItem!(T,S))o;
		if(this.key > f.key)
			return 1;
		else if(this.key < f.key)
			return -1;
		else
			return 0;
	}

	override size_t toHash() const {
		static if(is(T : long) || is(T : int) || is(T : byte) || is(T : char)) {
			return cast(size_t)key;
		} else static if(is(T : long[]) || is(T : int[]) || is(T : byte[])
				|| is(T : char[]) || is(T : immutable(char)[])) {
			size_t ret;
			foreach(it;key) {
				ret = it + (ret << 6) + (ret << 16) - ret;
			}
			return ret;
		} else static if(is(T : Object)) {
			return cast(size_t)key.toHash();
		} else {
			assert(0);
		}
	}

	override string toString() const {
		return "MapItem";
	}

	public T getKey() {
		return this.key;
	}

	public S getData() {
		return this.data;
	}
}

class Map(T,S) {
	private ISR!(MapItem!(T,S)) map;
	private ISRType type;
	private MapItem!(T,S) finder;


	this(ISRType type=ISRType.RBTree) {
		this.type = type;
		this.finder = new MapItem!(T,S)();
		this.makeMap();
	}

	private void makeMap() {
		if(this.type == ISRType.RBTree) {
			this.map = new RBTree!(MapItem!(T,S))();
		} else if(this.type == ISRType.BinarySearchTree) {
			this.map = new BinarySearchTree!(MapItem!(T,S))();
		} else if(this.type == ISRType.HashTable) {
			this.map = new HashTable!(MapItem!(T,S))();
		}
	}

	public size_t getSize() const { return this.map.getSize(); }
	public size_t isEmpty() const { return this.map.isEmpty(); }

	public void clear() {
		this.makeMap();
	}

	public bool contains(T key) {
		return null !is this.find(key);
	}

	public MapItem!(T,S) find(T key) {
		this.finder.key = key;
		ISRNode!(MapItem!(T,S)) jt = this.map.search(this.finder);
		if(jt is null)
			return null;

		return jt.getData();
	}

	public bool insert(T key, S data) {
		MapItem!(T,S) fnd = this.search(key);
		if(fnd !is null) {
			fnd.data = data;
			return false;
		} else {
			this.map.insert(new MapItem!(T,S)(key,data));
			return true;
		}
	}

	public void remove(T key) {
		this.finder.key = key;
		this.map.remove(this.finder);
	}

	public void remove(ISRIterator!(MapItem!(T,S)) it, bool dir = true) {
		if(it.isValid()) {
			MapItem!(T,S) value = *it;
			if(dir)
				it++;
			else
				it--;
			this.remove(value.key);
		}
	}

	ISRIterator!(MapItem!(T,S)) begin() {
		return this.map.begin();
	}

	ISRIterator!(MapItem!(T,S)) end() {
		return this.map.end();
	}

	public override bool opEquals(Object o) {
		Map!(T,S) m = cast(Map!(T,S))o;
		ISRIterator!(MapItem!(T,S)) it = this.begin();
		for(; it.isValid(); it++) {
			MapItem!(T,S) tmp = m.find((*it).key);
			if(tmp is null)
				return false;
			if(tmp.key != (*it).key || tmp.data != (*it).data) {
				//writeln(__LINE__, " ", tmp.key,":",tmp.data, " != ",
				//	(*it).key,":",(*it).data);
				return false;
			}
		}
		return m.getSize() == this.getSize();
	}
}

class Compare {
	private int a;

	this(int a) { this.a = a; }

	override int opCmp(Object o) const {
		Compare c = cast(Compare)o;
		if(this.a > c.a)
			return 1;
		else if(this.a < c.a)
			return -1;
		else
			return 0;
	}

	override bool opEquals(Object o) const {
		Compare c = cast(Compare)o;
		return this.a == c.a;
	}

	override hash_t toHash() const {
		return cast(hash_t)this.a;
	}
}

void main() {
	int[][] lot = [[2811, 1089, 3909, 3593, 1980, 2863, 676, 258, 2499, 3147,
	3321, 3532, 3009, 1526, 2474, 1609, 518, 1451, 796, 2147, 56, 414, 3740,
	2476, 3297, 487, 1397, 973, 2287, 2516, 543, 3784, 916, 2642, 312, 1130,
	756, 210, 170, 3510, 987], [0,1,2,3,4,5,6,7,8,9,10],
	[10,9,8,7,6,5,4,3,2,1,0],[10,9,8,7,6,5,4,3,2,1,0,11],
	[0,1,2,3,4,5,6,7,8,9,10,-1],[11,1,2,3,4,5,6,7,8,0]];

	Map!(string,int)[] sa = new Map!(string,int)[3];
	sa[0] = new Map!(string,int)(ISRType.RBTree);
	sa[1] = new Map!(string,int)(ISRType.BinarySearchTree);
	sa[2] = new Map!(string,int)(ISRType.HashTable);
	sa[0].insert("foo", 1337);
	sa[1].insert("foo", 1337);
	sa[2].insert("foo", 1337);
	assert(sa[0].contains("foo"));
	assert(sa[1].contains("foo"));
	assert(sa[1].contains("foo"));
	assert(sa[0] == sa[1] && sa[1] == sa[2] && sa[0] == sa[2]);
	assert(sa[0].find("foo").data == sa[1].find("foo").data);
	assert(sa[2].find("foo").data == sa[2].find("foo").data);
	assert(sa[0].find("foo").data == sa[2].find("foo").data);
	sa[0].insert("foo", 1338);
	assert(sa[0] != sa[1] && sa[1] == sa[2] && sa[0] != sa[2]);
	sa[1].insert("foo", 1338);
	assert(sa[0] == sa[1] && sa[1] != sa[2] && sa[0] != sa[2]);
	sa[2].insert("foo", 1338);
	assert(sa[0].find("foo").data == sa[1].find("foo").data);
	assert(sa[2].find("foo").data == sa[2].find("foo").data);
	assert(sa[0].find("foo").data == sa[2].find("foo").data);
	sa[0].remove("foo");
	sa[1].remove("foo");
	sa[1].remove("foo");
	assert(!sa[0].contains("foo"));
	assert(!sa[1].contains("foo"));
	assert(!sa[1].contains("foo"));
	Map!(Compare,string) ct = new Map!(Compare,string)(ISRType.HashTable);
	ct.insert(new Compare(44), conv!(int,string)(44));
	assert(ct.contains(new Compare(44)));
	assert((*ct.begin()).key == new Compare(44));
	assert((*ct.begin()).data == "44");
	sa[0].clear(); sa[1].clear(); sa[2].clear();
	for(int j = 0; j < 5; j++) {
		foreach(it;lot) {
			foreach(idx,jt;it) {
				for(int i = 0; i < 3; i++) {
					sa[i].insert(conv!(int,string)(jt), jt);
					assert(sa[i].getSize() == idx+1, 
						conv!(size_t,string)(idx+1) 
						~ " " ~ conv!(size_t,string)(sa[i].getSize()));
					assert(sa[i].contains(conv!(int,string)(jt)), 
						conv!(int,string)(jt));
					sa[i].remove(conv!(int,string)(jt));
					assert(!sa[i].contains(conv!(int,string)(jt)), 
						conv!(int,string)(jt));
					assert(sa[i].getSize() == idx, conv!(size_t,string)(idx) 
						~ " " ~ conv!(size_t,string)(sa[i].getSize()));
					sa[i].insert(conv!(int,string)(jt), jt);
					assert(sa[i].getSize() == idx+1, 
						conv!(size_t,string)(idx+1) 
						~ " " ~ conv!(size_t,string)(sa[i].getSize()));
					assert(sa[i].contains(conv!(int,string)(jt)), 
						conv!(int,string)(jt));
					switch(i) {
						case 0:
							assert(sa[0] != sa[1] && sa[0] != sa[2] && 
								sa[1] == sa[2]);
							break;
						case 1:
							assert(sa[0] == sa[1] && sa[0] != sa[2] && 
								sa[1] != sa[2]);
							break;
						case 2:
							assert(sa[0] == sa[1] && sa[0] == sa[2] && 
								sa[1] == sa[2]);
							break;
						default:
							assert(0);
					}
	
					auto sit = sa[i].begin();
					size_t cnt = 0;
					while(sit.isValid()) {
						assert(sa[i].contains((*sit).key));
						sit++;
						cnt++;
					}
					assert(cnt == sa[i].getSize(), conv!(size_t,string)(cnt) ~
						" " ~ conv!(size_t,string)(sa[i].getSize()));
					sit = sa[i].end();
					cnt = 0;
					while(sit.isValid()) {
						assert(sa[i].contains((*sit).key));
						sit--;
						cnt++;
					}
					assert(cnt == sa[i].getSize(), conv!(size_t,string)(cnt) ~
						" " ~ conv!(size_t,string)(sa[i].getSize()));
				}
			}
			switch(j) {
			case 0:
				sa[0].clear(); sa[1].clear(); sa[2].clear();
				break;
			case 1:
				for(int i = 0; i < 3; i++) {
					foreach(idx,jt;it) {
						sa[i].remove(conv!(int,string)(jt));
						foreach(ht; it[idx+1..$])
							assert(sa[i].contains(conv!(int,string)(ht)));
						foreach(ht; it[0..idx])
							assert(!sa[i].contains(conv!(int,string)(ht)));
					}
				}
				break;
			case 2:
				for(int i = 0; i < 3; i++) {
					foreach_reverse(idx,jt;it) {
						sa[i].remove(conv!(int,string)(jt));
						foreach(ht; it[idx+1..$])
							assert(!sa[i].contains(conv!(int,string)(ht)));
						foreach(ht; it[0..idx])
							assert(sa[i].contains(conv!(int,string)(ht)));
					}
				}
				break;
			case 3: {
				for(int i = 0; i < 3; i++) {
					auto gt = sa[i].begin();
					while(gt.isValid()) {
						sa[i].remove(gt);
					}
				}
				break;
			} case 4: {
				for(int i = 0; i < 3; i++) {
					auto gt = sa[i].end();
					while(gt.isValid()) {
						sa[i].remove(gt, false);
					}
				}
				break;
			}
			default:
				assert(0);
			}
			assert(sa[0] == sa[1] && sa[0] == sa[2] && sa[0] == sa[2]);
			assert(sa[0].getSize() == 0, conv!(int,string)(j) ~ " " ~
				conv!(size_t,string)(sa[0].getSize()));
		}
	
		Map!(int,int)[] sai = new Map!(int,int)[3];
		sai[0] = new Map!(int,int)(ISRType.RBTree);
		sai[1] = new Map!(int,int)(ISRType.BinarySearchTree);
		sai[2] = new Map!(int,int)(ISRType.HashTable);
		foreach(it;lot) {
			foreach(idx,jt;it) {
				for(int i = 0; i < 3; i++) {
					sai[i].insert(jt, jt);
					assert(sai[i].getSize() == idx+1, 
						conv!(size_t,string)(idx+1) 
						~ " " ~ conv!(size_t,string)(sai[i].getSize()));
					assert(sai[i].contains(jt), 
						conv!(int,string)(jt));
					sai[i].remove(jt);
					assert(!sai[i].contains(jt), 
						conv!(int,string)(jt));
					assert(sai[i].getSize() == idx, conv!(size_t,string)(idx) 
						~ " " ~ conv!(size_t,string)(sai[i].getSize()));
					sai[i].insert(jt, jt);
					assert(sai[i].getSize() == idx+1, 
						conv!(size_t,string)(idx+1) 
						~ " " ~ conv!(size_t,string)(sai[i].getSize()));
					assert(sai[i].contains(jt), 
						conv!(int,string)(jt));
					switch(i) {
						case 0:
							assert(sai[0] != sai[1] && sai[0] != sai[2] && 
								sai[1] == sai[2]);
							break;
						case 1:
							assert(sai[0] == sai[1] && sai[0] != sai[2] && 
								sai[1] != sai[2]);
							break;
						case 2:
							assert(sai[0] == sai[1] && sai[0] == sai[2] && 
								sai[1] == sai[2]);
							break;
						default:
							assert(0);
					}
	
					auto sit = sa[i].begin();
					size_t cnt = 0;
					while(sit.isValid()) {
						assert(sa[i].contains((*sit).key));
						sit++;
						cnt++;
					}
					assert(cnt == sa[i].getSize(), conv!(size_t,string)(cnt) ~
						" " ~ conv!(size_t,string)(sa[i].getSize()));
					sit = sa[i].end();
					cnt = 0;
					while(sit.isValid()) {
						assert(sa[i].contains((*sit).key));
						sit--;
						cnt++;
					}
					assert(cnt == sa[i].getSize(), conv!(size_t,string)(cnt) ~
						" " ~ conv!(size_t,string)(sa[i].getSize()));
				}
			}
			switch(j) {
			case 0:
				sai[0].clear(); sai[1].clear(); sai[2].clear();
				break;
			case 1:
				for(int i = 0; i < 3; i++) {
					foreach(idx,jt;it) {
						sai[i].remove(jt);
						foreach(ht; it[idx+1..$])
							assert(sai[i].contains(ht));
						foreach(ht; it[0..idx])
							assert(!sai[i].contains(ht));
					}
				}
				break;
			case 2:
				for(int i = 0; i < 3; i++) {
					foreach_reverse(idx,jt;it) {
						sai[i].remove(jt);
						foreach(ht; it[idx+1..$])
							assert(!sai[i].contains(ht));
						foreach(ht; it[0..idx])
							assert(sai[i].contains(ht));
					}
				}
				break;
			case 3: {
				for(int i = 0; i < 3; i++) {
					auto gt = sai[i].begin();
					while(gt.isValid()) {
						sai[i].remove(gt);
					}
				}
				break;
			}
			case 4: {
				for(int i = 0; i < 3; i++) {
					auto gt = sai[i].end();
					while(gt.isValid()) {
						sai[i].remove(gt, false);
					}
				}
				break;
			}
			default:
				assert(0);
			}
			assert(sai[0] == sai[1] && sai[0] == sai[2] && sai[0] == sai[2]);
			assert(sai[0].getSize() == 0, conv!(int,string)(j) ~ " " ~
				conv!(size_t,string)(sai[0].getSize()));
		}
	
		Map!(Compare,int)[] saj = new Map!(Compare,int)[3];
		saj[0] = new Map!(Compare,int)(ISRType.RBTree);
		saj[1] = new Map!(Compare,int)(ISRType.BinarySearchTree);
		saj[2] = new Map!(Compare,int)(ISRType.HashTable);
		foreach(it;lot) {
			foreach(idx,jt;it) {
				for(int i = 0; i < 3; i++) {
					saj[i].insert(new Compare(jt), jt);
					assert(saj[i].getSize() == idx+1, 
						conv!(size_t,string)(idx+1) 
						~ " " ~ conv!(size_t,string)(saj[i].getSize()));
					assert(saj[i].contains(new Compare(jt)), 
						conv!(int,string)(jt));
					saj[i].remove(new Compare(jt));
					assert(!saj[i].contains(new Compare(jt)), 
						conv!(int,string)(jt));
					assert(saj[i].getSize() == idx, conv!(size_t,string)(idx) 
						~ " " ~ conv!(size_t,string)(saj[i].getSize()));
					saj[i].insert(new Compare(jt), jt);
					assert(saj[i].getSize() == idx+1, 
						conv!(size_t,string)(idx+1) 
						~ " " ~ conv!(size_t,string)(saj[i].getSize()));
					assert(saj[i].contains(new Compare(jt)), 
						conv!(int,string)(jt));
					switch(i) {
						case 0:
							assert(saj[0] != saj[1] && saj[0] != saj[2] && 
								saj[1] == saj[2]);
							break;
						case 1:
							assert(saj[0] == saj[1] && saj[0] != saj[2] && 
								saj[1] != saj[2]);
							break;
						case 2:
							assert(saj[0] == saj[1] && saj[0] == saj[2] && 
								saj[1] == saj[2]);
							break;
						default:
							assert(0);
					}
	
					auto sit = saj[i].begin();
					size_t cnt = 0;
					while(sit.isValid()) {
						assert(saj[i].contains((*sit).key));
						sit++;
						cnt++;
					}
					assert(cnt == saj[i].getSize(), conv!(size_t,string)(cnt) ~
						" " ~ conv!(size_t,string)(saj[i].getSize()));
					sit = saj[i].end();
					cnt = 0;
					while(sit.isValid()) {
						assert(saj[i].contains((*sit).key));
						sit--;
						cnt++;
					}
					assert(cnt == saj[i].getSize(), conv!(size_t,string)(cnt) ~
						" " ~ conv!(size_t,string)(saj[i].getSize()));
				}
			}
			switch(j) {
			case 0:
				saj[0].clear(); saj[1].clear(); saj[2].clear();
				break;
			case 1:
				for(int i = 0; i < 3; i++) {
					foreach(idx,jt;it) {
						saj[i].remove(new Compare(jt));
						foreach(ht; it[idx+1..$])
							assert(saj[i].contains(new Compare(ht)));
						foreach(ht; it[0..idx])
							assert(!saj[i].contains(new Compare(ht)));
					}
				}
				break;
			case 2:
				for(int i = 0; i < 3; i++) {
					foreach_reverse(idx,jt;it) {
						saj[i].remove(new Compare(jt));
						foreach(ht; it[idx+1..$])
							assert(!saj[i].contains(new Compare(ht)));
						foreach(ht; it[0..idx])
							assert(saj[i].contains(new Compare(ht)));
					}
				}
				break;
			case 3: {
				for(int i = 0; i < 3; i++) {
					auto gt = saj[i].begin();
					while(gt.isValid()) {
						saj[i].remove(gt);
					}
				}
				break;
			}
			case 4: {
				for(int i = 0; i < 3; i++) {
					auto gt = saj[i].end();
					while(gt.isValid()) {
						saj[i].remove(gt, false);
					}
				}
				break;
			}
			default:
				assert(0);
			}
			assert(saj[0] == saj[1] && saj[0] == saj[2] && saj[0] == saj[2]);
			assert(saj[0].getSize() == 0, conv!(int,string)(j) ~ " " ~
				conv!(size_t,string)(saj[0].getSize()));
		}
	}
}
