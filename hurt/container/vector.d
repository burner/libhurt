module hurt.container.vector;

import hurt.conv.conv;

import std.stdio;

class Vector(T) {
	private T data[][];
	private uint partSize;
	private uint curPos;
	private uint index;

	public this() {
		this(10);
	}

	public this(uint partSize) {
		assert(partSize > 0);
		this.partSize = partSize;
		this.curPos = 0;
		this.index = 0;
		this.incrsArrySz();
		this.data[this.data.length-1] = new T[this.partSize];
	}

	public this(Vector!(T) old) {
		this(old.getPartSize());
		for(uint i = 0; i < old.getSize(); i++) {
			this.append(old.get(i));
		}
	}

	public uint getPartSize() const {
		return this.partSize;
	}

	public T append(T toAdd) {
		if(this.index % this.partSize == 0) {
			this.incrsArrySz();
			this.data[this.data.length-1] = new T[this.partSize];
			this.curPos = 0;
		}
		this.data[this.index/this.partSize][this.index % this.partSize] = toAdd;
		index++;
		return toAdd;
	}

	public T popBack() {
		if(this.index == 0) {
			assert(0, "can't remove a item from an empty stack");
		} else {
			return this.data[(this.index-1) / this.partSize][(this.index-1) % this.partSize];
		}
	}

	public T get(uint idx) {
		assert(this.partSize * (this.data.length-1) + (curPos) > idx);
		return this.data[idx / this.partSize][idx % this.partSize];
	}

	public Vector!(T) insert(in uint idx, T toAdd) {
	//	assert(idx < (this.partSize * (this.data.length-1) + curPos), 
		assert(idx < this.index, "use append to insert a Element at the end idx = " 
			~ conv!(uint,string)(idx) ~ " curPos = "
			~ conv!(uint,string)(this.index));
		if(this.index % this.partSize == 0) {
			this.incrsArrySz();
		}	

		uint upIdx = this.index;
		uint lowIdx = this.index-1;
		do {
			this.data[upIdx / this.partSize][upIdx % this.partSize] =
				this.data[lowIdx / this.partSize][lowIdx % this.partSize];
			upIdx--;
			lowIdx--;
		} while(lowIdx > idx);
		this.data[upIdx / this.partSize][upIdx % this.partSize] =
			this.data[lowIdx / this.partSize][lowIdx % this.partSize];
		
		this.data[lowIdx / this.partSize][lowIdx % this.partSize] = toAdd;
		this.index++;
		return this;
	}

	public T remove(in uint idx) {
		assert(idx < (this.partSize * (this.data.length-1) + curPos), 
			"the given index is out of bound idx = " 
			~ conv!(uint,string)(idx) ~ " curPos = "
			~ conv!(uint,string)(this.partSize * (this.data.length-1) + curPos));
		T tmp;
		uint upIdx = idx + 1;
		uint lowIdx = idx;
		T ret = this.data[lowIdx / this.partSize][lowIdx % this.partSize];
		while(lowIdx != this.index) {
			this.data[lowIdx / this.partSize][lowIdx % this.partSize] =
				this.data[upIdx / this.partSize][upIdx % this.partSize];
			upIdx++;
			lowIdx++;
		}
		this.index--;
		return tmp;		
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
			if(value == this.data[offset / this.partSize][offset % this.partSize]) {
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
			result = dg(this.data[i / this.partSize][i % this.partSize]);
		}
		return result;
	}

	private void incrsArrySz() {
		this.data.length = this.data.length+1;
		this.data[$-1] = new T[this.partSize];
	}

	public uint getSize() const {
		return this.index;
	}

	public void setSize(uint newSize) {
		if(newSize <= this.index) {
			this.index = newSize;	
		} else {
			while(newSize <= (this.partSize * this.data.length)) {
				this.incrsArrySz();
			}
		}
	}

	public Vector!(T) clone() {
		return new Vector!(T)(this);
	}

	public T[] elements() {
		T[] ret = new T[this.index-1];
		for(uint i = 0; i < this.index; i++) {
			ret[i] = this.get(i);
		}
		return ret;
	}
}
