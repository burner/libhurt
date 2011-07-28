module hurt.conv.conv;

import hurt.conv.numerictochar;
import hurt.conv.charconv;
import hurt.conv.tointeger;
import hurt.conv.tostring;

import std.stdio;

public pure S conv(T, S)(T t) {
	static if( is(T == string) ) {			// string
		static if( is(S == int) ) {
			return stringToInt!(int)(t);	
		} else static if( is(S == ulong) ) {
			return stringToInt!(ulong)(t);
		} static if( is(S == dstring) ) {

		} static if( is(S == string) ) {
			return t;
		}
	} else static if( is(T == ulong) ) {	// ulong
		static if( is(S == string) ) {
			return integerToString!(char,ulong)(t);
		} else static if( is(S == byte) || is(S == ubyte) || is(S == short) || 
				is(S == ushort) || is(S == int) || is(S == uint) || 
				is(S == long) || is(S == ulong)) {
			return tToS!(S,T)(t);	
		}
	} else static if( is(T == long) ) {		// long
		static if( is(S == string) ) {
			return integerToString!(char,long)(t);
		} else static if( is(S == byte) || is(S == ubyte) || is(S == short) || 
				is(S == ushort) || is(S == int) || is(S == uint) || 
				is(S == long) || is(S == ulong)) {
			return tToS!(S,T)(t);	
		}
	} else static if( is(T == int) ) {		// int
		static if( is(S == char) ) {
			return byteToChar!(char)(t);
		} else static if( is(S == string) ) {
			return integerToString!(char,int)(t);
		} else static if( is(S == byte) || is(S == ubyte) || is(S == short) || 
				is(S == ushort) || is(S == int) || is(S == uint) || 
				is(S == long) || is(S == ulong)) {
			return tToS!(S,T)(t);	
		}
	} else static if( is(T == uint) ) {		// uint
		static if( is(S == string) ) {
			return integerToString!(char,int)(t);
		}
	} else static if( is(T == short) ) {	// short
		static if( is(S == string) ) {
			return integerToString!(char,short)(t);	
		} else static if( is(S == byte) || is(S == ubyte) || is(S == short) || 
				is(S == ushort) || is(S == int) || is(S == uint) || 
				is(S == long) || is(S == ulong)) {
			return tToS!(S,T)(t);	
		}
	} else static if( is(T == byte) ) {		// byte
		static if( is(S == string) ) {
			return integerToString!(char,byte)(t);	
		} else static if( is(S == byte) || is(S == ubyte) || is(S == short) || 
				is(S == ushort) || is(S == int) || is(S == uint) || 
				is(S == long) || is(S == ulong)) {
			return tToS!(byte,S)(t);	
		}
	} else static if( is(T == dchar) ) {	// dchar
		static if( is(S == char) ) {
			return dcharToChar(t);
		}
	} else static if( is(T == char) ) {		// char
		static if( is(S == int) ) {
			return cast(int)t;
		}
	} else static if( is(T == ubyte)) {		// ubyte
		static if( is(S == string) ) {
			return integerToString!(char,ubyte)(t);	
		} else static if( is(S == byte) || is(S == ubyte) || is(S == short) || 
				is(S == ushort) || is(S == int) || is(S == uint) || 
				is(S == long) || is(S == ulong)) {
			return tToS!(ubyte,S)(t);	
		}
	} else {
		return null;
	}	
}


unittest {
	assert(0 == conv!(byte,int)(0));
	assert(0 == conv!(byte,short)(0));
	assert(0 == conv!(byte,byte)(0));
	assert(0 == conv!(byte,ubyte)(0));
	assert(0 == conv!(int,int)(0));
	assert(0 == conv!(int,short)(0));
	assert(0 == conv!(int,byte)(0));
	assert(0 == conv!(int,ubyte)(0));
	assert(0 == conv!(short,int)(0));
	assert(0 == conv!(short,short)(0));
	assert(0 == conv!(short,byte)(0));
	assert(0 == conv!(short,ubyte)(0));
	assert(0 == conv!(long,int)(0L));
	assert(0 == conv!(long,short)(0UL));
	assert(0 == conv!(long,byte)(0UL));
	assert(0 == conv!(long,ubyte)(0UL));
	assert(0 == conv!(ulong,int)(0UL));
	assert(0 == conv!(ulong,short)(0UL));
	assert(0 == conv!(ulong,byte)(0UL));
	assert(0 == conv!(ulong,ubyte)(0UL));
}
