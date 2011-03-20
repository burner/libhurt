module hurt.conv.conv;

import hurt.conv.numerictochar;
import hurt.conv.charconv;
import hurt.conv.tointeger;
import hurt.conv.tostring;

public pure S conv(T, S)(T t) {
	// from string to S
	static if( is(T == string) ) {
		// string to int
		static if( is(S == int) ) {
			return stringToInt(t);	
		// string to dstring
		} static if( is(S == dstring) ) {

		}

	// form long to S
	} else static if( is(T == ulong) ) {
		static if( is(S == uint) ) {
			return ulongToUint(t);
		}
	} else static if( is(T == long) ) {
		static if( is(S == uint) ) {
			return longToUint(t);
		} else static if( is(S == string) ) {
			return integerToString!(char,long)(t);
		} else static if( is(S == int) ) {
			return longToInt(t);
		}

	// from int to S
	} else static if( is(T == int) ) {
		static if( is(S == char) ) {
			return byteToCharBase10!(char)(t);
		} else static if( is(S == string) ) {
			return integerToString!(char,int)(t);
		}
	} else static if( is(T == uint) ) {
		static if( is(S == string) ) {
			return integerToString!(char,int)(t);
		}
	} else static if( is(T == short) ) {
		static if( is(S == string) ) {
			return integerToString!(char,short)(t);	
		}
	} else static if( is(T == dchar) ) {
		static if( is(S == char) ) {
			return dcharToChar(t);
		}
	} else static if( is(T == char) ) {
		static if( is(S == int) ) {
			return cast(int)t;
		}
	} else {
		return null;
	}
}
