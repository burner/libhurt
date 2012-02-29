module hurt.conv.conv;

import hurt.conv.numerictochar;
import hurt.conv.charconv;
import hurt.conv.tointeger;
import hurt.conv.tostring;
import hurt.math.mathutil;
import hurt.string.utf;

import std.stdio;

public pure S conv(T, S)(T t, string file = __FILE__, int line = __LINE__) {
	static if( is(T == string) ) {			// string
		static if( is(S == int) ) {
			return stringToInt!(int,char)(t);	
		} else static if( is(S == ulong) ) {
			return stringToInt!(ulong)(t);
		} else static if( is(S == bool) ) {
			if(t == "true")
				return true;
			if(t == "false")
				return false;
			throw new Exception(t ~ " is not true nor false");
		}
		static if( is(S == dstring) ) {
			return toUTF32(t);
		} else static if( is(S == wstring) ) {
			return toUTF16(t);
		} else static if( is(S == string) ) {
			return t;
		}
	} else static if( is(T == dstring) ) {
		static if( is(S == string) ) {
			return toUTF8(t);
		} else static if( is(S == dstring) ) {
			return t;
		} else static if( isInteger!S() ) {
			return stringToInt!(S,dchar)(t);
		}
	} else static if(isInteger!T() && (is(S == string))) {
		return integerToString!(char,T)(t);
	} else static if(isInteger!T() && (is(S == wstring))) {
		return integerToString!(wchar,T)(t);
	} else static if(isInteger!T() && (is(S == dstring))) {
		return integerToString!(dchar,T)(t);
	} else static if(isInteger!T() && isFloat!S()) {
		return tToS!(T,S)(t);
	} else static if(isFloat!T() && (is(S == string))) {
		return floatToString!(char,T)(t);
	} else static if(isFloat!T() && (is(S == wstring))) {
		return floatToString!(wchar,T)(t);
	} else static if(isFloat!T() && (is(S == dstring))) {
		return floatToString!(dchar,T)(t);
	} else static if(isFloat!T() && isInteger!S()) {
		return tToS!(T,S)(t, file, line);
	} else static if(isInteger!T() && isInteger!S()) {	// integer to integer
		return tToS!(T,S)(t, file, line);
	} else static if( is(T == int) ) {		// int
		static if( is(S == char) ) {
			return byteToChar!(char)(t);
		}
	} else static if( is(T == dchar) ) {	// dchar
		static if( is(S == char) ) {
			return dcharToChar(t);
		} else static if( is(S == string) ) {
			char[4] tmp;
			return toUTF8(tmp, t).idup;
		} else static if( is(S == dstring) ) {
			//return ""d ~ t;
			dchar[1] tmp;
			tmp[0] = t;
			return toUTF32(tmp);
		}
	} else static if( is(T == wchar) ) {	// wchar
		static if( is(S == string) ) {
			wchar[1] tmp;
			tmp[0] = t;
			return "" ~ toUTF8(tmp);
		}
	} else static if( is(T == char) ) {		// char
		static if( is(S == int) ) {
			return cast(int)t;
		} else static if( is(S == string) ) {
			return "" ~ t;
		} else static if( is(S == dchar) ) {
			return cast(dchar)t;
		}
	} else static if( is(T == ubyte)) {		// ubyte
		static if( is(S == string) ) {
			return integerToString!(char,ubyte)(t);	
		} else static if( is(S == byte) || is(S == ubyte) || is(S == short) || 
				is(S == ushort) || is(S == int) || is(S == uint) || 
				is(S == long) || is(S == ulong)) {
			return tToS!(ubyte,S)(t);	
		}
	} else static if( is(T == bool)) {
		static if( is(S == string) ) {
			if(t)
				return "true";
			else
				return "false";
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
	assert("10" == conv!(long,string)(10));
	assert("10" == conv!(int,string)(10));
	assert("10" == conv!(short,string)(10));
	assert("10" == conv!(byte,string)(10));
	assert("10" == conv!(ulong,string)(10));
	assert("10" == conv!(uint,string)(10));
	assert("10" == conv!(ushort,string)(10));
	assert("10" == conv!(ubyte,string)(10));
	assert("-10" == conv!(long,string)(-10));
	assert("-10" == conv!(int,string)(-10));
	assert("-10" == conv!(short,string)(-10));
	assert("-10" == conv!(byte,string)(-10));
	assert("-10.000000" == conv!(float,string)(-10.000000));
	assert("-10.000000" == conv!(double,string)(-10.000000));
	assert("-10.000000" == conv!(real,string)(-10.000000));
	assert("10.000000" == conv!(float,string)(10.000000));
	assert("10.000000" == conv!(double,string)(10.000000));
	assert("10.000000" == conv!(real,string)(10.000000));
	assert("false" == conv!(bool,string)(false));
	assert("true" == conv!(bool,string)(true));
	assert(42 == conv!(string, int)("42"));
	assert(42 == conv!(string, int)("_4__2__"));
	assert(42 == conv!(string, int)("__4__2__"));
	assert("42" == conv!(int, string)(42));
	assert("-42" == conv!(int, string)(-42));
	assert("55" == conv!(short,string)(55));
	assert("55" == conv!(short,string)(55));
}
