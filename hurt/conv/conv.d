module hurt.conv.conv;

import hurt.conv.numerictochar;
import hurt.conv.charconv;
import hurt.conv.tointeger;
import hurt.conv.tostring;

S conv(T, S)(T t) {
	// from string to S
	static if( is(T == string) ) {
		// string to int
		static if( is(S == int) ) {
			return stringToInt(t);	
		} static if( is(S == dstring) ) {

		}
	// from int to S
	} else static if( is(T == int) ) {
		static if( is(S == char) ) {
			return byteToCharBase10!(char)(t);
		} else static if( is(S == string) ) {
			return intToString!(char,int)(t);
		}
	} else static if( is(T == uint) ) {
		static if( is(S == string) ) {
			return intToString!(char,int)(t);
		}
	} else static if( is(T == short) ) {
		static if( is(S == string) ) {
			return shortToString(t);	
		}
	} else static if( is(T == dchar) ) {
		static if( is(S == char) ) {
			return dcharToChar(t);
		}
	} else {
		return null;
	}
}
