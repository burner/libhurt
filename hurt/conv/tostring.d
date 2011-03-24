module hurt.conv.tostring;

import hurt.conv.numerictochar;

public pure immutable(T)[] integerToString(T,S)(S src)
		if( (is(T == char) || is(T == wchar) || is(T == dchar)) && 
			(is(S == ubyte) || is(S == byte) || is(S == ushort) || 
			 is(S == short) || is(S == uint) || is(S == int) ||
			 is(S == ulong) || is(S == long)) ) {
	T[32] tmp;
	uint tmpptr = 0;
	bool sign = false;
	if(src == 0) 
		return "0";
	if(src < 0) {
		src = -src;
		sign = true;
		static if(is(T == char)) {
			tmp[tmpptr++] = '-';
		} else static if(is(T == wchar)) {
			tmp[tmpptr++] = '\u002D'; // yes 002D means -
		} else static if(is(T == dchar)) {
			tmp[tmpptr++] = '\U0000002D'; // yes 0000002D means -
		}
	}
	byte toConv;
	while(src) {
		toConv = cast(byte)(src % 10);	
		static if(is(T == char)) {
			tmp[tmpptr++] = byteToCharBase10!(char)(toConv);
		} else static if(is(T == wchar)) {
			tmp[tmpptr++] = byteToCharBase10!(wchar)(toConv);
		} else static if(is(T == dchar)) {
			tmp[tmpptr++] = byteToCharBase10!(dchar)(toConv);
		}
		src /= 10;
	}
	if(sign) {
		tmp[1..tmpptr].reverse;
		return tmp[0..tmpptr].idup;
	} else 
		return tmp[0..tmpptr].reverse.idup;
}
