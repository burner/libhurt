module vector;

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

	public T append(T toAdd) {
		if(this.index == this.data[$].length -1) {
			this.incrsArrySz();
			this.data[this.data.length-1] = new T[this.partSize];
			this.curPos = 0;
		}
		this.data[this.index/this.partSize][this.index % this.partSize] = toAdd;
		curPos++;
		index++;
		return toAdd;
	}

	public T get(uint index) {
		assert(this.partSize * (this.data.length-1) + (curPos) > index);
		return this.data[index / this.partSize][index % this.partSize];
	}

	public T insert(in uint idx, T toAdd) {
	//	assert(idx < (this.partSize * (this.data.length-1) + curPos), 
		assert(idx < this.index, "use append to insert a Element at the end idx = " 
			~ conv!(uint,string)(idx) ~ " curPos = "
			~ conv!(uint,string)(this.partSize * (this.data.length-1) + curPos));
		if( (curPos) == this.data[this.data.length-1].length) {
			this.incrsArrySz();
			curPos = 0;
		}	
		//uint upIdx = this.partSize * (this.data.length-1) + curPos - 0;
		//uint lowIdx = this.partSize * (this.data.length-1) + curPos - 1;
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
		curPos++;
		this.index++;
		return toAdd;
	}

	public T remove(in uint idx) {
		assert(idx < (this.partSize * (this.data.length-1) + curPos), 
			"the given index is out of bound idx = " 
			~ conv!(uint,string)(idx) ~ " curPos = "
			~ conv!(uint,string)(this.partSize * (this.data.length-1) + curPos));
		T ret = this.get(idx);
		uint upIdx = this.partSize * (this.data.length-1) + curPos - 0;
		uint lowIdx = this.partSize * (this.data.length-1) + curPos - 1;
		do {
			this.data[lowIdx / this.partSize][lowIdx % this.partSize] = 
				this.data[upIdx / this.partSize][upIdx % this.partSize];
			upIdx--;
			lowIdx--;
		} while(lowIdx > idx);
		this.data[lowIdx / this.partSize][lowIdx % this.partSize] = 
			this.data[upIdx / this.partSize][upIdx % this.partSize];

		if(this.curPos == 0) {
			this.curPos = this.partSize;
		}
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
}
