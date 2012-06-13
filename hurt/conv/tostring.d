module hurt.conv.tostring;

import hurt.conv.numerictochar;
import hurt.math.mathutil;
import hurt.string.formatter;

import std.stdio;

public pure immutable(T)[] integerToString(T,S)(S src, int base = 10, 
		bool sign = false, bool title = false)
		if( (is(T == char) || is(T == wchar) || is(T == dchar)) && 
			isInteger!S() ) {

	if(base > 16) { // only till base 16 aka hex
		return null;
	}
	T[128] tmp;
	uint tmpptr = 0;
	long toProcess;
	if(src == 0) {
		return "0";
	}

	if(src < 0) {
		//src = -src;
		toProcess = -src;
		sign = true;
		static if(is(T == char)) {
			tmp[tmpptr++] = '-';
		} else static if(is(T == wchar)) {
			tmp[tmpptr++] = '\u002D'; // yes 002D means -
		} else static if(is(T == dchar)) {
			tmp[tmpptr++] = '\U0000002D'; // yes 0000002D means -
		}
	} else if(sign) {
		if(src < 0) {
			toProcess = -src;
		} else {
			toProcess = src;
		}
		static if(is(T == char)) {
			tmp[tmpptr++] = '+';
		} else static if(is(T == wchar)) {
			tmp[tmpptr++] = '\u002B'; // yes 002D means -
		} else static if(is(T == dchar)) {
			tmp[tmpptr++] = '\U0000002B'; // yes 0000002D means -
		}
	} else {
		toProcess = src;
	}

	byte toConv;
	while(toProcess) {
		toConv = cast(byte)(toProcess % base);	
		tmp[tmpptr++] = byteToChar!(T)(toConv, title);
		toProcess /= base;
	}
	if(sign) {
		tmp[1..tmpptr].reverse;
		return tmp[0..tmpptr].idup;
	} else {
		T[] r = tmp[0..tmpptr].reverse;
		return r.idup;
	}
}

unittest {
	assert("1010" == integerToString!(char,int)(10,2));
	assert("-1010" == integerToString!(char,int)(-10,2));
	assert("+1010" == integerToString!(char,int)(10,2,true));
	assert("10" == integerToString!(char,int)(10));
	assert("12" == integerToString!(char,int)(10,8));
	assert("-10" == integerToString!(char,int)(-10));
	assert("-12" == integerToString!(char,int)(-10,8));
	assert("+10" == integerToString!(char,int)(10,10,true),
		integerToString!(char,int)(10,10,true));
	assert("+12" == integerToString!(char,int)(10,8,true));
	assert("-10" == integerToString!(char,int)(-10,10,true));
	assert("-12" == integerToString!(char,int)(-10,8,true));
	assert("a" == integerToString!(char,int)(10,16),
		integerToString!(char,int)(10,16));
	assert("-a" == integerToString!(char,int)(-10,16));
	assert("-a" == integerToString!(char,int)(-10,16));
	assert("+a" == integerToString!(char,int)(10,16,true),
		integerToString!(char,int)(10,10,true));
	assert("+a" == integerToString!(char,int)(10,16,true));
	assert("-a" == integerToString!(char,int)(-10,16,true));
	assert("-a" == integerToString!(char,int)(-10,16,true));
	assert("+A" == integerToString!(char,int)(10,16,true,true));
	assert("-A" == integerToString!(char,int)(-10,16,true,true));
	assert("-A" == integerToString!(char,int)(-10,16,true,true));
	assert("+11" == integerToString!(char,int)(17,16,true,true),
		integerToString!(char,int)(17,16,true,true));
	assert("-11" == integerToString!(char,int)(-17,16,true,true));
	assert("-11" == integerToString!(char,int)(-17,16,true,true));
}

public pure immutable(T)[] floatToString(T,S)(S src, int round = 6, 
		bool sign = false)
		if( (is(T == char) || is(T == wchar) || is(T == dchar)) && 
			(is(S == float) || is(S == double) || is(S == real))) {
	long intp;
	long fractp;
	long power = 1;
	int i;
	round++;

	for(i = 0; i < round; i++)
		power *= 10;

	intp = cast(long)src;
	fractp = cast(long)((src - cast(S) intp) * power);
	fractp = fractp < 0 ? -fractp : fractp;
	long toR = fractp % 10;
	fractp += toR;
	fractp /= 10;

	immutable(T)[] dec = integerToString!(T,long)(intp, 10, sign, true);
	immutable(T)[] frac = integerToString!(T,long)(fractp, 10, false, true);
	round--;
	while(frac.length < round) {
		frac = frac ~ "0";
	}
	return dec ~ "." ~ frac;
}

public pure immutable(T)[] floatToExponent(T,S)(S src, int round = 4, 
		bool sign = false, bool big = false)
		if( (is(T == char) || is(T == wchar) || is(T == dchar)) && 
			(is(S == float) || is(S == double) || is(S == real))) {
	int count = 0;
	while(abs(src) >= 10) {
		count++;
		src /= 10;
	}
	immutable(T)[] digits = floatToString!(T,S)(src, round, sign);
	immutable(T)[] expo = integerToString!(T,int)(count);
	return digits ~ (big ? 'E' : 'e') ~ expo;
}

unittest {
	assert("0.00" == floatToString!(char,double)(0.0, 2), 
		floatToString!(char,double)(0.0, 2));
	assert("10.00" == floatToString!(char,double)(10.0, 2), 
		floatToString!(char,double)(10.0, 2));
	assert("1.20" == floatToString!(char,double)(1.2, 2), 
		floatToString!(char,double)(1.2, 2));
	assert("100.2" == floatToString!(char,double)(100.222123, 1), 
		floatToString!(char,double)(100.222123, 1));
	assert("1.200000000" == floatToString!(char,real)(1.2, 9), 
		floatToString!(char,real)(1.2, 9));
	assert("100.2221230" == floatToString!(char,real)(100.222123, 7), 
		floatToString!(char,real)(100.222123, 7));
	assert("-100.2221230" == floatToString!(char,real)(-100.222123, 7), 
		floatToString!(char,real)(-100.222123, 7));
	assert("-100.222121" == floatToString!(char,real)(-100.222121, 6), 
		floatToString!(char,real)(-100.222121, 6));
	assert("-100.222129" == floatToString!(char,real)(-100.222129, 6),
		floatToString!(char,real)(-100.222129, 6));
	assert("100.222130" == floatToString!(char,float)(100.222129, 6),
		floatToString!(char,float)(100.222129, 6));
	assert("+1.20" == floatToString!(char,double)(1.2, 2, true),
		floatToString!(char,double)(1.2, 2, true));
	assert("+100.2" == floatToString!(char,double)(100.222123, 1, true),
		floatToString!(char,double)(100.222123, 1, true));
	assert("+1.200000000" == floatToString!(char,real)(1.2, 9, true),
		floatToString!(char,real)(1.2, 9, true));
	assert("+100.2221230" == floatToString!(char,real)(100.222123, 7, true),
		floatToString!(char,real)(100.222123, 7, true));
	assert("-100.2221230" == floatToString!(char,real)(-100.222123, 7, true),
		floatToString!(char,real)(-100.222123, 7, true));
	assert("-100.222121" == floatToString!(char,real)(-100.222121, 6, true),
		floatToString!(char,real)(-100.222121, 6, true));
	assert("-100.222129" == floatToString!(char,real)(-100.222129, 6, true),
		floatToString!(char,real)(-100.222129, 6, true));
	assert("+100.222130" == floatToString!(char,float)(100.222129, 6, true),
		floatToString!(char,float)(100.222129, 6, true));
	assert("1.0e1" == floatToExponent!(char,float)(10,1,false, false),
		floatToExponent!(char,float)(10,1,false, false));
	assert("-1.0e2" == floatToExponent!(char,float)(-100,1,false, false),
		floatToExponent!(char,float)(-100,1,false, false));
}
