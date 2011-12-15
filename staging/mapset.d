module hurt.container.mapset;

import hurt.container.map;
import hurt.container.set;
import hurt.container.isr;

public class MapSet(T,S) {
	// the map
	private Map!(T, Set!(S)) map;

	// the mapping types
	private ISRType mapType;
	private ISRType setType;

	this() {
		this(ISRType.RBTree, ISRType.RBTree);
	}

	this(ISRType mapType, ISRType setType) {
		// save the passed mapping types
		this.mapType = mapType;
		this.setType = setType;

		// make the map
		this.map = new Map!(T,Set!(S))(this.mapType);
	}

	public bool insert(T t, S s) {
		MapItem!(T, Set!(S)) mi = this.map.find(t);
		Set!(S) set;
		// the set doesn't exists
		if(mi is null) {
			// create the set 
			set = new Set!(S)(this.setType);
			// fill it
			set.insert(s);
			// save it in the map
			this.map.insert(t, set);
			return true;
		} else {
			// get the set
			set = mi.getData();
			// to make check if something has been inserted
			size_t setSize = set.getSize();
			// insert the value
			set.insert(s);
			// if a new value has been inserted the size has changed
			return setSize != set.getSize();
		}
	}

	/** Remove a hole set.
	 */
	public bool remove(T t) {
		if(this.map.contains(t)) { // if the map contains it remove it
			this.map.remove(t);
			return true;
		} else { // else nothing else to do
			return false;
		}
	}

	/** Remove a member of a set.
	 */
	public bool remove(T t, S s) {
		// is there a matching map
		MapItem!(T,Set!(S)) m = this.map.find(t);
		if(m !is null) { // remove the symbol
			size_t setSize = m.getData().getSize();
			m.getData().remove(s);
			return setSize != m.getData().getSize();
		} else { // no mapitem no remove
			return false;
		}
	}

	public size_t getMapSize() {
		return this.map.getSize();	
	}

	public size_t getSetSize(T t) {
		MapItem!(T,Set!(S)) mi = this.map.find(t);
		if(mi !is null) {
			return mi.getData().getSize();
		} else {
			return 0u;
		}
	}

	public size_t getSize() {
		size_t ret = 0;
		ISRIterator!(MapItem!(T,Set!(S))) it = this.map.begin();
		for(; it.isValid(); it.increment()) {
			ret += it.getData().getData().getSize();
		}
		return ret;
	}

	/** Check if the set of map t contains s
	 */
	public bool contains(T t, S s) {
		MapItem!(T,Set!(S)) mi = this.map.find(t);
		if(mi !is null) {
			return mi.getData().contains(s);
		} else {
			return false;
		}
	}

	/** Check if any of the maps contains s.
	 */
	public bool containsElement(S s) {
		ISRIterator!(MapItem!(T,Set!(S))) it = this.map.begin();
		for(; it.isValid(); it.increment()) {
			if(it.getData().getData().contains(s)) {
				return true;
			}
		}
		return false;
	}

	/** Check if there is a map by the key of t.
	 */
	public bool containsMapping(T t) {
		MapItem!(T,Set!(S)) it = this.map.find(t);
		return it !is null;
	}

	package Map!(T,Set!(S)) getMap() {
		return this.map;
	}
}

/* If I make this a member of the mapset the compiler complains about
 * Error: template instance hurt.container.isr.ISRIterator!(MapItem).
 * ISRIterator.opUnary!("++") recursive expansion
 */
public bool Equals(T,S)(MapSet!(T,S) ms, MapSet!(T,S) ns) {
	ISRIterator!(MapItem!(T,Set!(S))) it = ns.getMap().begin();
	for(; it.isValid(); it++) {
		ISRIterator!(S) jt = (*it).getData().begin();
		for(; jt.isValid(); jt++) {
			if(!ms.contains((*it).getKey(), *jt)) {
				return false;
			}
		}
	}
	it = ms.getMap().begin();
	for(; it.isValid(); it++) {
		ISRIterator!(S) jt = (*it).getData().begin();
		for(; jt.isValid(); jt++) {
			if(!ns.contains((*it).getKey(), *jt)) {
				return false;
			}
		}
	}
	return true;
}

unittest {
	MapSet!(int,int) ms = new MapSet!(int,int)();
	assert(ms.insert(1,1));
	MapSet!(int,int) ms2 = new MapSet!(int,int)();
	assert(ms2.insert(1,1));
	assert(Equals(ms, ms2));
	assert(ms2.containsElement(1));
	assert(ms.getSize() == 1);
	assert(ms.getMapSize() == 1);
	assert(ms.getSetSize(1) == 1);
	assert(ms.getSetSize(0) == 0);
	assert(ms.contains(1,1));
	assert(!ms.contains(1,2));
	assert(ms.containsElement(1));
	assert(ms.insert(2,1));
	assert(ms.insert(2,2));
	assert(ms.containsElement(2));
	assert(ms.insert(1,2));
	assert(!ms.insert(1,2));
	assert(ms.remove(1));
	assert(!ms.remove(1));
	assert(ms.remove(2,1));
	assert(!ms.remove(2,1));

	int[] rand = [ 123, 3, 1, 44, 2, 24, 54, 23, 67, 77, 34 ];
	int[][] data = new int[][4];
	data[0] = [0,1,2,3,4,5,6,7,8,9];
	data[1] = [0,-1,-2,-3,-4,-5,-6,-7,-8,-9];
	data[2] = [-9,-8,-7,-6,-5,-4,-3,-2,-1,0,1,2,3,4,5,6,7,8,9];
	data[3] = [2811, 1089, 3909, 3593, 1980, 2863, 676, 258, 2499, 3147,
	3321, 3532, 3009, 1526, 2474, 1609, 518, 1451, 796, 2147, 56, 414, 3740,
	2476, 3297, 487, 1397, 973, 2287, 2516, 543, 3784, 916, 2642, 312, 1130,
	756, 210, 170, 3510, 987];

	MapSet!(int,int)[] mss = new MapSet!(int,int)[9];
	mss[0] = new MapSet!(int,int)(ISRType.RBTree, ISRType.RBTree);
	mss[1] = new MapSet!(int,int)(ISRType.RBTree, ISRType.BinarySearchTree);
	mss[2] = new MapSet!(int,int)(ISRType.RBTree, ISRType.HashTable);
	mss[3] = new MapSet!(int,int)(ISRType.BinarySearchTree, ISRType.RBTree);
	mss[4] = new MapSet!(int,int)(ISRType.BinarySearchTree, 
		ISRType.BinarySearchTree);
	mss[5] = new MapSet!(int,int)(ISRType.BinarySearchTree, 
		ISRType.HashTable);
	mss[6] = new MapSet!(int,int)(ISRType.HashTable, ISRType.RBTree);
	mss[7] = new MapSet!(int,int)(ISRType.HashTable, ISRType.BinarySearchTree);
	mss[8] = new MapSet!(int,int)(ISRType.HashTable, ISRType.HashTable);
}

void main() {
	MapSet!(int,int) ms = new MapSet!(int,int)();
}
