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
	assert(0 == conv!(int,long)(0));
	assert(0 == conv!(short,long)(0));
	assert(0 == conv!(byte,long)(0));
	assert(0 == conv!(long,long)(0));
	assert(0 == conv!(uint,long)(0U));
	assert(0 == conv!(ushort,long)(0U));
	assert(0 == conv!(ubyte,long)(0U));
	assert(0 == conv!(ulong,long)(0U));
	assert(0 == conv!(int,int)(0));
	assert(0 == conv!(short,int)(0));
	assert(0 == conv!(byte,int)(0));
	assert(0 == conv!(long,int)(0));
	assert(0 == conv!(uint,int)(0U));
	assert(0 == conv!(ushort,int)(0U));
	assert(0 == conv!(ubyte,int)(0U));
	assert(0 == conv!(ulong,int)(0U));
	assert(0 == conv!(int,short)(0));
	assert(0 == conv!(short,short)(0));
	assert(0 == conv!(byte,short)(0));
	assert(0 == conv!(long,short)(0));
	assert(0 == conv!(uint,short)(0U));
	assert(0 == conv!(ushort,short)(0U));
	assert(0 == conv!(ubyte,short)(0U));
	assert(0 == conv!(ulong,short)(0U));
	assert(0 == conv!(int,byte)(0));
	assert(0 == conv!(short,byte)(0));
	assert(0 == conv!(byte,byte)(0));
	assert(0 == conv!(long,byte)(0));
	assert(0 == conv!(uint,byte)(0U));
	assert(0 == conv!(ushort,byte)(0U));
	assert(0 == conv!(ubyte,byte)(0U));
	assert(0 == conv!(ulong,byte)(0U));
	assert(0U == conv!(int,ulong)(0));
	assert(0U == conv!(short,ulong)(0));
	assert(0U == conv!(byte,ulong)(0));
	assert(0U == conv!(long,ulong)(0));
	assert(0U == conv!(uint,ulong)(0U));
	assert(0U == conv!(ushort,ulong)(0U));
	assert(0U == conv!(ubyte,ulong)(0U));
	assert(0U == conv!(ulong,ulong)(0U));
	assert(0U == conv!(int,uint)(0));
	assert(0U == conv!(short,uint)(0));
	assert(0U == conv!(byte,uint)(0));
	assert(0U == conv!(long,uint)(0));
	assert(0U == conv!(uint,uint)(0U));
	assert(0U == conv!(ushort,uint)(0U));
	assert(0U == conv!(ubyte,uint)(0U));
	assert(0U == conv!(ulong,uint)(0U));
	assert(0U == conv!(int,ushort)(0));
	assert(0U == conv!(short,ushort)(0));
	assert(0U == conv!(byte,ushort)(0));
	assert(0U == conv!(long,ushort)(0));
	assert(0U == conv!(uint,ushort)(0U));
	assert(0U == conv!(ushort,ushort)(0U));
	assert(0U == conv!(ubyte,ushort)(0U));
	assert(0U == conv!(ulong,ushort)(0U));
	assert(0U == conv!(int,ubyte)(0));
	assert(0U == conv!(short,ubyte)(0));
	assert(0U == conv!(byte,ubyte)(0));
	assert(0U == conv!(long,ubyte)(0));
	assert(0U == conv!(uint,ubyte)(0U));
	assert(0U == conv!(ushort,ubyte)(0U));
	assert(0U == conv!(ubyte,ubyte)(0U));
	assert(0U == conv!(ulong,ubyte)(0U));
}
