module hurt.util.array;

import hurt.conv.conv;
import hurt.exception.outofrangeexception;
import hurt.exception.nullexception;

void arrayCopy(T)(T[] src, in uint sOffset, T[] drain, in uint dOffset, 
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

T[] append(T)(ref T[] arr, T toAppend) {
	if(arr is null) {
		arr = new T[1];
		arr[0] = toAppend;
		return arr;
	}
	arr.length = arr.length + 1;
	arr[$-1] = toAppend;
	return arr;
}
