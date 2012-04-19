module hurt.util.util;

import hurt.math.mathutil;
import hurt.string.formatter;

pure uint bswap(uint v) {
	// XxxxxxxxXxxxxxxxXxxxxxxx11111111 -> 11111111XxxxxxxxXxxxxxxxXxxxxxxxx
	uint one = (v << 24);
	// XxxxxxxxXxxxxxxx11111111Xxxxxxxx-> Xxxxxxxx11111111XxxxxxxxXxxxxxxxx
	uint two = ((v >> 8) << 24) >> 8;
	// Xxxxxxxx11111111XxxxxxxxXxxxxxxx-> XxxxxxxxXxxxxxxx11111111Xxxxxxxxx
	uint three = ((v >> 16) << 24) >> 16;
	// 11111111XxxxxxxxXxxxxxxxXxxxxxxx-> XxxxxxxxXxxxxxxxXxxxxxxxx11111111
	uint four = (v >> 24);
	return one | two | three | four;
}

unittest {	
	assert(0b0001_1111_0011_1111_0111_1111_1111_1111 == 
		bswap(0b1111_1111_0111_1111_0011_1111_0001_1111));
}

public @safe pure size_t negIdx(T)(const T[] arr, long idx) {
	assert(idx < 0, "Index not negativ");
	assert(abs(idx) <= arr.length);
	return arr.length - abs(idx);
}

unittest {
	int[] a = [1,2,3,4,5];
	assert(a[negIdx(a, -1)] == 5);
	assert(a[negIdx(a, -2)] == 4);
	assert(a[negIdx(a, -3)] == 3);
	assert(a[negIdx(a, -4)] == 2);
	assert(a[negIdx(a, -5)] == 1);
}
