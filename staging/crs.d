module hurt.container.crs;

import hurt.exception.outofrangeexception;
import hurt.conv.conv;
import hurt.io.stdio;
import hurt.string.formatter;

struct CRS(T) {
	T[] val;
	size_t[] colIdx;
	size_t[] rowPtr;

	pure nothrow @safe this(T[] val, size_t[] colIdx, size_t[] rowPtr) {
		this.val = val;
		this.colIdx = colIdx;
		this.rowPtr = rowPtr;
	}
}

public pure nothrow @safe CRS!(T) makeCRS(T)(T[][] input, T nullvalue) {
	assert(input.length > 0);
	T[] val = new T[input.length * input[0].length];
	size_t valPtr = 0;
	size_t[] col = new size_t[input.length * input[0].length];
	size_t colPtr = 0;
	size_t[] row = new size_t[input.length * input[0].length];
	size_t rowPtr = 0;

	foreach(size_t idx, T[] it; input) {
		/*foreach(jt; it) {
			debug printf("%d ", jt);
		}
		debug println();*/
		row[rowPtr++] = colPtr;
		foreach(size_t jdx, T jt; it) {
			if(jt != nullvalue) {
				val[valPtr++] = jt;
				col[colPtr++] = jdx;
			}
		}
	}

	return CRS!(T)(val[0 .. valPtr], col[0 .. colPtr],
			row[0 .. rowPtr]);
}

//private pure nothrow @safe size_t binary_search(size_t[] A, size_t key, size_t imin, size_t imax) {
private size_t binary_search(size_t[] A, size_t key, size_t imin, size_t imax) {
	while(imax >= imin) {
		size_t imid = (imin + imax) / 2;
		printfln("%d : %d : %d", imin, imid, imax);
		if(A[imid] < key) {
			imin = imid + 1;
		} else if(A[imid] > key) {
			imax = imid - 1;
		} else {
			return imid;
		}
	}
	printfln("%d %d", imax, imin);
	return size_t.max;
}

public T get(T)(CRS!(T) value, size_t row, size_t column, T nullValue) {
//public pure @safe T get(T)(CRS!(T) value, size_t row, size_t column, T nullValue) {
	if(row >= value.rowPtr.length) {
		throw new OutOfRangeException("row " ~ conv!(size_t,string)(row) ~ " out of bound");
	}

	size_t searchEnd = row+1 == value.rowPtr.length ? value.colIdx.length-1 : value.rowPtr[row+1];
	debug printfln("%d:%d column %d", value.rowPtr[row], searchEnd, column);
	printfln("codIdx length %d", value.colIdx.length);
	size_t valIdx = binary_search(value.colIdx, column, value.rowPtr[row], searchEnd);

	println();
	if(valIdx == size_t.max) {
		return nullValue;
	} else {
		return value.val[valIdx];
	}
}

void main() {
	auto a = [[10, 0, 0, 12, 0],
			  [0, 0, 11, 0, 13],
			  [0, 16, 0, 0, 0],
			  [0, 0, 0, 0, 0],
			  [0, 0, 11, 0, 13]];

	auto r = makeCRS!(int)(a, 0);
	printf("val :");
	foreach(it; r.val) {
		printf("%3d, ", it);
	}
	println();
	printf("col :");
	foreach(it; r.colIdx) {
		printf("%3d, ", it);
	}
	println();
	printf("row :");
	foreach(it; r.rowPtr) {
		printf("%3d, ", it);
	}
	println();
	foreach(idx, it; a) {
		foreach(jdx, jt; it) {
			assert(jt == r.get(idx, jdx, 0), format(
				"a[%d][%d] == %d != r.get(%d, %d, 0) == " ,
				idx, jdx, jt, idx, jdx, r.get(idx, jdx, 0)));
		}
	}
}

