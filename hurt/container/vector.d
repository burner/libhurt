module vector;

import hurt.conv.conv;

import std.stdio;

class Vector(T) {
	private T data[][];
	private uint partSize;
	private uint curPos;

	public this() {
		this(10);
	}

	public this(uint partSize) {
		assert(partSize > 0);
		this.partSize = partSize;
		this.curPos = 0;
		this.incrsArrySz();
		this.data[this.data.length-1] = new T[this.partSize];
	}

	public T append(T toAdd) {
		if(curPos == this.data[this.data.length-1].length) {
			this.incrsArrySz();
			this.data[this.data.length-1] = new T[this.partSize];
			this.curPos = 0;
		}
		this.data[this.data.length-1][curPos] = toAdd;
		curPos++;
		return toAdd;
	}

	public T opIndexAssign(T toAdd, uint index) {
		return toAdd;
	}	

	public T get(uint index) {
		assert(this.partSize * (this.data.length-1) + (curPos) > index);
		return this.data[index / this.partSize][index % this.partSize];
	}

	public T insert(in uint idx, T toAdd) {
		assert(idx < (this.partSize * (this.data.length-1) + curPos), 
			"use append to insert a Element at the end idx = " 
			~ conv!(uint,string)(idx) ~ " curPos = "
			~ conv!(uint,string)(this.partSize * (this.data.length-1) + curPos));
		if( (curPos) == this.data[this.data.length-1].length) {
			this.incrsArrySz();
			curPos = 0;
		}	
		uint upIdx = this.partSize * (this.data.length-1) + curPos - 0;
		uint lowIdx = this.partSize * (this.data.length-1) + curPos - 1;
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
		return toAdd;
	}

	public T opIndex(uint index) {
		return this.get(index);
	}

	public T[] opSlice(uint low, uint high) {
		assert(low < high, "low index is bigger than high index");
		assert(high < (this.data.length-1) * this.partSize + this.curPos,
			 "high is out of index");

		T[] ret = new T[(this.data.length-1) * this.partSize + this.curPos-1];
		for(uint idx = 0; idx <= high; idx++) {
			ret[idx] = this.get(idx+low);
		}
		return ret;
	}

	int opApply(int delegate(ref T value) dg) {
		int result;
		uint up = (this.data.length-1) * this.partSize + this.curPos;
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
		return (this.data.length-1) * this.partSize + this.curPos;
	}
}
