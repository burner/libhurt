module hurt.container.vector;

import hurt.conv.conv;
import hurt.container.dlst;
import hurt.container.iterator;

import std.stdio;

class Vector(T) : Iterable!(T) {
	private T[] data;
	version(X86_64) {
		private long index;
	} else {
		private int index;
	}

	public this() {
		this(10);
	}

	public this(size_t size) {
		this.data = new T[size];
		this.index = -1;
	}

	public this(Vector!(T) old) {
		this.data = new T[old.getSize()-1];
		this.index = -1;
		for(size_t i = 0; i < old.getSize(); i++) {
			this.append(old.get(i));
		}
	}

	public this(DLinkedList!(T) ll) {
		this(ll.getSize());
		foreach(it; ll) 
			this.append(it);
	}

	public Vector!(T) append(T toAdd) {
		if(this.index+1 >= cast(typeof(this.index))this.data.length) {
			this.data.length = this.data.length * 2;
		}
		this.data[++this.index] = toAdd;
		return this;
	}

	public Vector!(T) pushFront(T toAdd) {
		return this.insert(0,toAdd);
	}

	public Vector!(T) pushBack(T toAdd) {
		return this.append(toAdd);
	}

	public T popBack() {
		T ret = this.data[this.index--];
		return ret;
	}

	public T popFront() {
		T ret = this.remove(0);
		return ret;
	}

	public T peekBack() {
		assert(this.index != -1, "vector empty");	
		return this.data[this.index];
	}

	public T get(size_t idx) {
		assert(idx <= this.index, "given index is out of bound");	
		return this.data[idx];
	}

	public Vector!(T) insert(in size_t idx, T toAdd) {
		assert(idx <= this.index, "use append to insert a Element at the 
			end idx = " ~ conv!(size_t,string)(idx) ~ " curPos = "
			~ conv!(typeof(index),string)(this.index));
		this.index++;	
		if(this.index+1 >= cast(typeof(this.index))this.data.length) {
			this.data.length = this.data.length * 2;
		}
		typeof(index) upIdx = this.index;
		typeof(index) lowIdx = this.index-1;
		while(lowIdx >= idx && lowIdx >= 0) {
			this.data[upIdx] = this.data[lowIdx];
			upIdx--;
			lowIdx--;
		}
		this.data[idx] = toAdd;
		return this;
	}

	public T remove(in size_t idx) {
		assert(idx <= this.index, 
			"the given index is out of bound idx = " 
			~ conv!(size_t,string)(idx) ~ " curPos = "
			~ conv!(typeof(this.index),string)(this.index));
		T ret = this.data[idx];
		typeof(this.index) upIdx = idx + 1;
		typeof(this.index) lowIdx = idx;
		while(lowIdx < this.index && lowIdx > 0) {
			this.data[lowIdx] = this.data[upIdx];
			upIdx++;
			lowIdx++;
		}
		this.index--;
		return ret;		
	}

	public T opIndex(size_t idx) {
		return this.get(idx);
	}

	public T set(typeof(index) idx, T value) {
		assert(idx <= this.index, "use append to insert a Element at the 
			end idx = " ~ conv!(size_t,string)(idx) ~ " curPos = "
			~ conv!(typeof(index),string)(this.index));

		this.data[idx] = value;
		return this.data[idx];
	}
	
	public T opIndexAssign(typeof(index) idx, T value) {
		this.set(idx, value);
		return this.data[idx];
	}

	public T[] opSlice(size_t low, size_t high) {
		assert(low < high, "low index is bigger than high index");
		assert(high <= this.index,
			 "high is out of index");

		T[] ret = new T[high-low];
		for(size_t idx = 0; idx <= high; idx++) {
			ret[idx] = this.get(idx+low);
		}
		return ret;
	}

	public typeof(this.index) indexOf(in T value, size_t offset = 0) {
		while(offset <= this.index) {
			if(value == this.data[offset]) {
				return offset;
			}
			offset++;
		}
		return -1;
	}

	public bool contains(T toFind) {
		for(size_t idx = 0; idx < this.index+1; idx++) {
			if(this.get(idx) == toFind)
				return true;
		}
		return false;		
	}

	int opApply(int delegate(ref T value) dg) {
		int result;
		size_t up = this.index+1;
		for(size_t i = 0; i < up && result is 0; i++) {
			result = dg(this.data[i]);
		}
		return result;
	}

	int opApply(int delegate(ref size_t,ref T) dg) {
		int result;
		size_t up = this.index+1;
		for(size_t i = 0; i < up && result is 0; i++) {
			result = dg(i,this.data[i]);
		}
		return result;
	}

	public typeof(this.index) getSize() const {
		return this.index+1;
	}

	public bool empty() const {
		return this.index == -1;
	}

	public size_t capacity() const {
		return this.data.length;
	}

	public void setSize(typeof(this.index) newSize) {
		if(newSize <= this.index) {
			if(newSize < 0) {
				newSize = 0;
				this.index = newSize;	
			}
			this.index = newSize-1;	
		} else {
			this.data.length = newSize;
		}
	}

	public Vector!(T) clone() {
		return new Vector!(T)(this);
	}

	public T[] elements() {
		if(this.index == -1) {
			return null;
		}
		return this.data[0..this.index+1].dup;
	}

	public void clean() {
		this.index = -1;
	}

	public override bool opEquals(Object o) {
		Vector!(T) v = cast(Vector!(T))o;
		if(this.getSize() != v.getSize())
			return false;

		foreach(idx,it;v) {
			if(this[idx] != it)
				return false;
		}
		return true;
	}
}

unittest {
	DLinkedList!(int) ll = new DLinkedList!(int)();
	ll.pushBack(0); ll.pushBack(1); ll.pushBack(2);
	ll.pushBack(3); ll.pushBack(4); ll.pushBack(5);
	Vector!(int) vec = new Vector!(int)(ll);
	assert(vec[0] == 0);
	assert(vec[1] == 1);
	assert(vec[2] == 2);
	assert(vec[3] == 3);
	assert(vec[4] == 4);
	assert(vec[5] == 5);

	size_t idx = 0;
	foreach(it; vec) {
		assert(vec[idx] == it);
		idx++;
	}
	assert(idx == vec.getSize());
	assert([0,1,2,3,4,5] == vec.elements());
	Vector!(int) vec2 = new Vector!(int)(vec);
	assert(vec2 == vec);
	vec2.popFront();
	assert(vec2 != vec);
	foreach(it;[0,1,2,3,4,5])
		assert(vec.contains(it), conv!(int,string)(it));
	vec.remove(5);
	assert(!vec.contains(5));
	foreach(it;[0,1,2,3,4])
		assert(vec.contains(it), conv!(int,string)(it));
	vec.remove(3);
	assert(!vec.contains(3));
	foreach(it;[0,1,2,4])
		assert(vec.contains(it), conv!(int,string)(it));

}
