module hurt.util.array;

import hurt.conv.conv;
import hurt.exception.nullexception;
import hurt.exception.outofrangeexception;

pure void arrayCopy(T)(T[] src, in uint sOffset, T[] drain, in uint dOffset, 
		in uint number) {
	if(src is null)
		throw new NullException("Source is null");
	if(drain is null)
		throw new NullException("Drain is null");
	if(sOffset + number > src.length) {
		throw new OutOfRangeException("With this offset " 
			~ conv!(uint, string)(sOffset) ~ " and this number "
			~ conv!(uint, string)(number) ~ " and Out of Bound Error will occur " 
			~ "because the src array is to short. The array length is " 
			~ conv!(uint,string)(src.length));
	} else  if(dOffset + number > drain.length) {
		throw new OutOfRangeException("With this offset " 
			~ conv!(uint, string)(dOffset) ~ " and this number "
			~ conv!(uint, string)(number) ~ " and Out of Bound Error will occur " 
			~ "because the drain array is to short. The array length is " 
			~ conv!(uint,string)(drain.length));
	}
	
	for(uint idx = 0; idx < number; idx++) {
		drain[dOffset + idx] = src[sOffset + idx];
	}
}

pure T[] append(T)(ref T[] arr, T toAppend) {
	if(arr is null) {
		arr = new T[1];
		arr[0] = toAppend;
		return arr;
	}
	arr.length = arr.length + 1;
	arr[$-1] = toAppend;
	return arr;
}

pure size_t appendWithIdx(T)(ref T[] arr, size_t idx, T[] toAppend, size_t gRate = 2) {
	if(arr is null) {
		arr = toAppend.dup;
		return toAppend.length;
	}
	foreach(it; toAppend) {
		if(idx >= arr.length) {
			if(gRate < 2) {
				gRate = 2;
			}
			arr.length =  arr.length * gRate;
		}
		arr[idx++] = it;
	}
	return idx;
}

pure T[] appendWithIdx(T)(ref T[] arr, size_t idx, immutable(T) toAppend, size_t gRate = 2) {
	if(arr is null) {
		arr = new T[1];
		arr[0] = toAppend;
		return arr;
	}
	if(idx >= arr.length) {
		if(gRate < 2) {
			gRate = 2;
		}
		arr.length =  arr.length * gRate;
	}
	arr[idx] = toAppend;
	return arr;
}

/** returns the index of the searched element 
 * if the element is not part of the array the length
 * array is returned. */
size_t find(T)(in T[] arr, in T toSearch) {
	foreach(idx, it; arr) {
		if(it == toSearch) {
			return idx;
		}
	}
	return arr.length;
}

/** compares to arrays. the sorting of the elements
 *  must not be same. */
bool compare(T)(in T[] a, in T[] b) {
	if(a.length != b.length) {
		return false;
	}
	foreach(it; a) {
		if(a.length == find!(T)(b, it)) {
			return false;
		}
	}
	return true;
}

pure T[] remove(T)(T[] arr, in size_t idx) {
	if(idx >= arr.length) {
		throw new OutOfRangeException("idx = " ~ conv!(size_t,string)(idx) 
			~ " this not in range for array with length " 
			~ conv!(size_t,string)(arr.length));
	}

	T[] ret = new T[arr.length-1];
	for(size_t itOld = 0, itNew = 0; itOld < arr.length;) {
		if(itOld != idx) {
			ret[itNew++] = arr[itOld++];
		} else {
			itOld++;
		}
	}
	return ret;
}
