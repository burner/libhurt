module hurt.conv.conv;

import hurt.conv.numerictochar;
import hurt.conv.charconv;
import hurt.conv.tointeger;
import hurt.conv.tostring;
import hurt.math.mathutil;

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
	} else static if(isInteger!T() && isInteger!S()) {
		return tToS!(T,S)(t);
	} else static if( is(T == ulong) ) {	// ulong
		static if( is(S == string) ) {
			return integerToString!(char,ulong)(t);
		}
	} else static if( is(T == long) ) {		// long
		static if( is(S == string) ) {
			return integerToString!(char,long)(t);
		} 
	} else static if( is(T == int) ) {		// int
		static if( is(S == char) ) {
			return byteToChar!(char)(t);
		} else static if( is(S == string) ) {
			return integerToString!(char,int)(t);
		}
	} else static if( is(T == uint) ) {		// uint
		static if( is(S == string) ) {
			return integerToString!(char,int)(t);
		}
	} else static if( is(T == short) ) {	// short
		static if( is(S == string) ) {
			return integerToString!(char,short)(t);	
		}
	} else static if( is(T == ushort) ) {	// short
		static if( is(S == string) ) {
			return integerToString!(char,ushort)(t);	
		}
	} else static if( is(T == byte) ) {		// byte
		static if( is(S == string) ) {
			return integerToString!(char,byte)(t);	
		}
	} else static if( is(T == dchar) ) {	// dchar
		static if( is(S == char) ) {
			return dcharToChar(t);
		}
	} else static if( is(T == char) ) {		// char
		static if( is(S == int) ) {
			return cast(int)t;
		}
	} else {
		return null;
	}
}

unittest {
	assert(0 == conv!(ulong,int)(0UL));
	assert(0U == conv!(ulong,uint)(0UL));
}
