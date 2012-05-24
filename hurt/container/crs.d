module hurt.container.crs;

import hurt.exception.outofrangeexception;
import hurt.conv.conv;
import hurt.string.formatter;
version(staging) {
import hurt.io.stdio;
import hurt.time.stopwatch;
}

struct CRS(T) {
	private T[] val;
	private size_t[] colIdx;
	private size_t[] rowPtr;
	private size_t colLength;
	private T nullValue;
	private float ratio = 1.0;

	public pure @safe this(size_t[] colIdx, size_t[] rowPtr, T[] val, 
			T nullValue) {
		assert(colIdx.length == val.length);
		this.val = val;
		this.colIdx = colIdx;
		this.rowPtr = rowPtr;
		this.nullValue = nullValue;
	}

	public pure nothrow @safe this(const T[][] input, 
			T nullvalue) {
		assert(input.length > 0);
		T[] val = new T[input.length * input[0].length];
		size_t valPtr = 0;
		size_t[] col = new size_t[input.length * input[0].length];
		size_t colPtr = 0;
		size_t[] row = new size_t[input.length * input[0].length];
		size_t rowPtr = 0;

		foreach(idx, it; input) {
			row[rowPtr++] = colPtr;
			foreach(jdx, jt; it) {
				if(jt != nullvalue) {
					val[valPtr++] = jt;
					col[colPtr++] = jdx;
				}
			}
		}
		this.val = val[0 .. valPtr]; 
		this.colIdx = col[0 .. colPtr];
		this.rowPtr = row[0 .. rowPtr]; 
		this.colLength = input[0].length;
		this.nullValue = nullValue;

		this.ratio = conv!(size_t,float)(
			this.val.length * 2 + this.rowPtr.length) / 
			conv!(size_t,float)(input.length * input[0].length);
	}

	pure nothrow @safe this(T[] val, size_t[] colIdx, size_t[] rowPtr, 
			size_t colLength) {
		this.val = val;
		this.colIdx = colIdx;
		this.rowPtr = rowPtr;
		this.colLength = colLength;
	}

	private pure nothrow @safe size_t binary_search(size_t key, 
			size_t imin, size_t imax) const {
		while(imax >= imin) {
			size_t imid = (imin + imax) / 2;
			if(colIdx[imid] < key) {
				imin = imid + 1;
			} else if(colIdx[imid] > key) {
				imax = imid - 1;
			} else {
				return imid;
			}
		}
		return size_t.max;
	}

	public pure @safe T opIndex(size_t row, size_t column) const {
		return this.get!(T)(row, column, this.nullValue);
	}

	public pure @safe T get(T)(size_t row, size_t column, T nullValue) 
			const {
		if(row >= rowPtr.length) {
			throw new OutOfRangeException("row " ~ conv!(size_t,string)(row) 
				~ " out of bound");
		}

		if(column >= colLength) {
			throw new OutOfRangeException("column " 
				~ conv!(size_t,string)(column) ~ " out of bound");
		}

		size_t searchEnd = row+1 == rowPtr.length ? colIdx.length-1 : 
			rowPtr[row+1]-1;
		size_t valIdx = binary_search(column, rowPtr[row], searchEnd);

		if(valIdx == size_t.max) {
			return nullValue;
		} else {
			return val[valIdx];
		}
	}

	public pure nothrow @safe void setNullValue(T nullValue) {
		this.nullValue = nullValue;
	}

	public pure nothrow @safe float getRatio() const {
		return this.ratio;
	}

	public pure nothrow @safe size_t getSize() const {
		return this.val.length * 2 + this.rowPtr.length;
	}
}


unittest {
	auto a = [[10, 0, 0, 12, 0],
			  [0, 0, 11, 0, 13],
			  [0, 16, 0, 0, 0],
			  [0, 0, 0, 0, 0],
			  [0, 0, 11, 0, 13]];

	auto r = CRS!(int)(a, 0);
	foreach(idx, it; a) {
		foreach(jdx, jt; it) {
			assert(jt == r.get(idx, jdx, 0), format(
				"a[%d][%d] == %d != r.get(%d, %d, 0) == " ,
				idx, jdx, jt, idx, jdx, r.get(idx, jdx, 0)));
			assert(jt == r[idx, jdx], format(
				"a[%d][%d] == %d != r.get(%d, %d, 0) == " ,
				idx, jdx, jt, idx, jdx, r[idx, jdx]));
		}
	}
}

version(staging) {
void main() {
}
unittest {
	short[][] table = [
	[   1,   1,   2,  -1,   4,   6,   8,   3,  10,  12,  14,  16,  18,  20,  22,  24,  26,  28,  30,  32,  34,  36,  38,   5,  40,  40,  40,  40,  40,  40,  42,  44,  46,  48, 334, 419, 420, 237, 421, 335, 422,  40, 242,  40, 423, 488, 336, 337, 424, 338, 425, 339, 426, 427, 428,  40,  40,  40,  50,  52,  54,  56],
	[   1,   1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1],
	[  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1, 226, 227, 228,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1, 113,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1],
	[  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1, 109, 109,  -1,  -1,  -1,  -1,  -1,  -1, 109, 109, 109, 109, 109, 109,  -1,  -1,  -1,  -1, 109, 109, 109, 109, 109, 109, 109, 109, 109, 109, 109, 109, 109, 109, 109, 109, 109, 109, 109, 109, 109, 109, 109, 109,  -1,  -1,  -1,  -1],
	[  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1],
	[  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  63,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  65,  -1,  67, 240,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1],
	[  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1, 225,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1],
	[  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1, 114,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1],
	[  -1,  -1,  -1,  -1,  -1,  -1, 223,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1, 224,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1],
	[  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  11,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1],
	[  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  13,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1],
	[  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  15,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1],
	[  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1, 221,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1],
	[  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  17,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1],
	[  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1, 219,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1, 220,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1],
	[  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  19,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1],
	[  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  21,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1],
	[  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1, 217,  -1,  -1,  -1,  -1,  -1,  -1, 218,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1]];
	StopWatch sw;
	sw.start();
	auto r = CRS!(short)(table, -1);
	printfln("ratio %f table size %d crs size %d", r.getRatio(),
		table.length * table[0].length, r.getSize());
	foreach(idx, it; table) {
		foreach(jdx, jt; it) {
			assert(jt == r.get(idx, jdx, -1), format(
				"a[%d][%d] == %d != r.get(%d, %d, 0) == " ,
				idx, jdx, jt, idx, jdx, r.get(idx, jdx, 0)));
		}
	}

	printfln("the hole fun took %f seconds", sw.stop());
}

}
