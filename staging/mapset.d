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
		for(; it.isValid(); it++) {
			ret += (*it).getData().getSize();
		}
		return ret;
	}

	public bool contains(T t, S s) {
		MapItem!(T,Set!(S)) mi = this.map.find(t);
		if(mi !is null) {
			return mi.getData().contains(s);
		} else {
			return false;
		}
	}
}

unittest {
	MapSet!(int,int) ms = new MapSet!(int,int)();
	assert(ms.insert(1,1));
	assert(ms.getSize() == 1);
	assert(ms.getMapSize() == 1);
	assert(ms.getSetSize(1) == 1);
	assert(ms.getSetSize(0) == 0);
	assert(ms.contains(1,1));
	assert(!ms.contains(1,2));
	assert(ms.insert(2,1));
	assert(ms.insert(2,2));
	assert(ms.insert(1,2));
	assert(!ms.insert(1,2));
	assert(ms.remove(1));
	assert(!ms.remove(1));
	assert(ms.remove(2,1));
	assert(!ms.remove(2,1));
}

void main() {
	MapSet!(int,int) ms = new MapSet!(int,int)();
}
