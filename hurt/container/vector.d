module vector;
//import tango.io.Stdout;
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
		Vector.incrsArrySz(this.data);
		this.data[this.data.length-1] = new T[this.partSize];
	}

	public T append(T toAdd) {
		if(curPos == this.data[this.data.length-1].length) {
			Vector.incrsArrySz(this.data);
			this.curPos = 0;
			this.data[this.data.length-1] = new T[this.partSize];
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
		for(int i = (this.data.length-1) * this.partSize + this.curPos-1; i-- && result is 0;) {
			result = dg(this.data[i / this.partSize][i % this.partSize]);
		}
		return result;
	}

	private static void incrsArrySz(ref T[][] arr, uint growSize = 1) {
		assert(growSize > 0 && arr.length > growSize, "Invalid growSize");	
		arr.length = arr.length+growSize;
	}

	public uint getSize() const {
		return this.curPos-1;
	}
}
