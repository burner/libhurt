module hurt.util.array;

import hurt.conv.conv;
import hurt.string.formatter;
import hurt.exception.nullexception;
import hurt.exception.outofrangeexception;

pure void arrayCopy(T)(T[] src, in size_t sOffset, T[] drain, in size_t dOffset, 
		in size_t number) {
	if(src is null)
		throw new NullException("Source is null");
	if(drain is null)
		throw new NullException("Drain is null");
	if(sOffset + number > src.length) {
		throw new OutOfRangeException("With this offset " 
			~ conv!(size_t, string)(sOffset) ~ " and this number "
			~ conv!(size_t, string)(number) ~ 
				" and Out of Bound Error will occur " 
			~ "because the src array is to short. The array length is " 
			~ conv!(size_t,string)(src.length));
	} else  if(dOffset + number > drain.length) {
		throw new OutOfRangeException("With this offset " 
			~ conv!(size_t, string)(dOffset) ~ " and this number "
			~ conv!(size_t, string)(number) ~ 
				" and Out of Bound Error will occur " 
			~ "because the drain array is to short. The array length is " 
			~ conv!(size_t,string)(drain.length));
	}
	
	for(size_t idx = 0; idx < number; idx++) {
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

unittest {
	uint[] z;
	append(z, 6u);
	assert(z[0] == 6u);
	append(z, 9u);
	assert(z[1] == 9u);
}

pure size_t appendWithIdx(T)(ref T[] arr, size_t idx, T[] toAppend, 
		size_t gRate = 2) {
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

pure T[] appendWithIdx(T)(ref T[] arr, size_t idx, immutable(T) toAppend, 
		size_t gRate = 2) {
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

size_t rfind(T)(in T[] arr, in T toSearch) {
	foreach_reverse(idx, it; arr) {
		if(it == toSearch) {
			return idx;
		}
	}
	return arr.length;
}

size_t findArr(T)(in T[] arr, immutable(T)[] toSearch, size_t i = 0) {
	if(toSearch is null || toSearch.length == 0) {
		return arr.length;
	}
	//outer: foreach(size_t idx, T it; arr) {
	outer: for(size_t idx = i; idx < arr.length; idx++) {
		T it = arr[idx];
		if(idx + toSearch.length > arr.length) {
			return arr.length;
		} else if(it == toSearch[0]) {
			for(size_t jdx = 0; jdx < toSearch.length; jdx++) {
				if(arr[idx+jdx] != toSearch[jdx]) {
					continue outer;
				}
			}
			return idx;
		}
	}
	return arr.length;
}

unittest {
	assert(findArr!(char)("Hello", "ll") == 2, 
		format("%d != %d",findArr!(char)("Hello", "ll") , 2));
	assert(findArr!(char)("Hello", "Helloo") == 5, 
		format("%d != %d",findArr!(char)("Hello", "Helloo") , 5));
	assert(findArr!(char)("Hello", "lo") == 3,
		format("%d != %d",findArr!(char)("Hello", "lo") , 3));
	assert(findArr!(char)("Hello", "o") == 4,
		format("%d != %d",findArr!(char)("Hello", "o") , 4));
	assert(findArr!(char)("Hello", "oll") == 5,
		format("%d != %d",findArr!(char)("Hello", "oll") , 5));
	assert(findArr!(char)("Hello", "zzz") == 5,
		format("%d != %d",findArr!(char)("Hello", "zzz") , 5));
	assert(findArr!(char)("Hello", "") == 5,
		format("%d != %d",findArr!(char)("Hello", "") , 5));
	assert(findArr!(char)("Hello", null) == 5,
		format("%d != %d",findArr!(char)("Hello", null) , 5));
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

unittest {
	int[] a = [1,2,3,4];
	int[] b = [1,2,3,4];
	int[] c = [1,5,3,4];
	int[] d = [1,5,3,4,6];
	int[] e = [1,4,3,2];
	assert(compare(a,b));
	assert(!compare(a,c));
	assert(!compare(a,d));
	assert(compare(a,e));
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
