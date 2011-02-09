module hurt.conv.tostring;

import hurt.conv.numerictochar;

public pure immutable(T)[] intToString(T)(int src) {
	T[16] tmp;
	uint tmpptr = 0;
	bool sign = false;
	if(src < 0) {
		src = -src;
		sign = true;
		static if(is(T == char)) {
			tmp[tmpptr++] = '-';
		} else static if(is(T == wchar)) {
			tmp[tmpptr++] = '\u002D'; // yes 002D means -
		} else static if(is(T == dchar)) {
			tmp[tmpptr++] = '\U0000002D'; // yes 0000002D means -
		} else {
			assert(0, "invalid case");
		}
	}
	byte toConv;
	while(src) {
		toConv = cast(byte)(src % 10);	
		tmp[tmpptr++] = byteToCharBase10!(char)(toConv);
		src /= 10;
	}
	if(sign) {
		tmp[1..tmpptr].reverse;
		return tmp[0..tmpptr].idup;
	} else 
		return tmp[0..tmpptr].reverse.idup;
}

public pure string shortToString(short src) {
	char[8] tmp;
	uint tmpptr = 0;
	bool sign = false;
	if(src < 0) {
		src = -src;
		sign = true;
		tmp[tmpptr++] = '-';
	}
	byte toConv;
	while(src) {
		toConv = cast(byte)(src % 10);	
		tmp[tmpptr++] = byteToCharBase10!(char)(toConv);
		src /= 10;
	}
	if(sign) {
		tmp[1..tmpptr].reverse;
		return tmp[0..tmpptr].idup;
	} else 
		return tmp[0..tmpptr].reverse.idup;
}
