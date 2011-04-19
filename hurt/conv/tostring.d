module hurt.conv.tostring;

import hurt.conv.numerictochar;

import std.stdio;

public pure immutable(T)[] integerToString(T,S)(S src, int base = 10, bool sign = false, bool title = false)
		if( (is(T == char) || is(T == wchar) || is(T == dchar)) && 
			(is(S == ubyte) || is(S == byte) || is(S == ushort) || 
			 is(S == short) || is(S == uint) || is(S == int) ||
			 is(S == ulong) || is(S == long)) ) {

	if(base > 16) { // only till base 16 aka hex
		return null;
	}
	T[64] tmp;
	uint tmpptr = 0;
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
	} else if(sign) {
		static if(is(T == char)) {
			tmp[tmpptr++] = '+';
		} else static if(is(T == wchar)) {
			tmp[tmpptr++] = '\u002B'; // yes 002D means -
		} else static if(is(T == dchar)) {
			tmp[tmpptr++] = '\U0000002B'; // yes 0000002D means -
		}
	}
	byte toConv;
	while(src) {
		toConv = cast(byte)(src % base);	
		tmp[tmpptr++] = byteToChar!(T)(toConv, title);
		src /= base;
	}
	if(sign) {
		tmp[1..tmpptr].reverse;
		return tmp[0..tmpptr].idup;
	} else {
		return tmp[0..tmpptr].reverse.idup;
	}
}
