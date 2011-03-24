module hurt.container.vector;

import hurt.conv.conv;

import std.stdio;

class Vector(T) {
	private T[] data;
	private uint index;

	public this() {
		this(10);
	}

	public this(uint size) {
		this.data = new T[size];
		this.index = 0;
	}

	public this(Vector!(T) old) {
		this.data = new T[old.getSize()];
		for(uint i = 0; i < old.getSize(); i++) {
			this.append(old.get(i));
		}
	}

	public Vector!(T) append(T toAdd) {
		if(this.data.length <= this.index) {
			this.data.length = this.data.length * 2;
		}
		this.data[this.index++] = toAdd;
		return this;
	}

	public T popBack() {
		T ret = this.data[--this.index];
		return ret;
	}

	public T get(uint idx) {
		assert(idx <= this.index, "given index is out of bound");	
		return this.data[idx];
	}

	public Vector!(T) insert(in uint idx, T toAdd) {
		assert(idx < this.index, "use append to insert a Element at the end idx = " 
			~ conv!(uint,string)(idx) ~ " curPos = "
			~ conv!(uint,string)(this.index));
		this.index++;	
		if(this.data.length <= this.index) {
			this.data.length = this.data.length * 2;
		}
		long upIdx = this.index;
		long lowIdx = this.index-1;
		while(lowIdx >= idx) {
			this.data[conv!(long,uint)(upIdx)] = this.data[conv!(long,uint)(lowIdx)];
			upIdx--;
			lowIdx--;
		}
		this.data[idx] = toAdd;
		return this;
	}

	public T remove(in uint idx) {
		assert(idx < this.index, 
			"the given index is out of bound idx = " 
			~ conv!(uint,string)(idx) ~ " curPos = "
			~ conv!(uint,string)(this.index));
		T ret = this.data[idx];
		uint upIdx = idx + 1;
		uint lowIdx = idx;
		while(lowIdx != this.index) {
			this.data[lowIdx] = this.data[upIdx];
			upIdx++;
			lowIdx++;
		}
		this.index--;
		return ret;		
	}

	public T opIndex(uint idx) {
		return this.get(idx);
	}

	public T[] opSlice(uint low, uint high) {
		assert(low < high, "low index is bigger than high index");
		assert(high < this.index,
			 "high is out of index");

		T[] ret = new T[high-low];
		for(uint idx = 0; idx <= high; idx++) {
			ret[idx] = this.get(idx+low);
		}
		return ret;
	}

	public uint indexOf(in T value, uint offset = 0) {
		while(offset < this.index) {
			if(value == this.data[offset]) {
				return true;
			}
			offset++;
		}
		return false;
	}

	public bool contains(T toFind) {
		for(uint idx = 0; idx < this.index; idx++) {
			if(this.get(idx) == toFind)
				return true;
		}
		return false;		
	}

	int opApply(int delegate(ref T value) dg) {
		int result;
		//uint up = (this.data.length-1) * this.partSize + this.curPos;
		uint up = this.index;
		for(uint i = 0; i < up && result is 0; i++) {
			result = dg(this.data[i]);
		}
		return result;
	}

	public uint getSize() const {
		return this.index;
	}

	public void setSize(uint newSize) {
		if(newSize < this.index) {
			this.index = newSize;	
		} else {
			this.data.length = newSize;
		}
	}

	public Vector!(T) clone() {
		return new Vector!(T)(this);
	}

	public T[] elements() {
		T[] ret = new T[this.index];
		for(uint i = 0; i < this.index; i++) {
			ret[i] = this.get(i);
		}
		return ret;
	}
}
