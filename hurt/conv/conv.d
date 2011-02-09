module hurt.conv.conv;

import hurt.conv.charconv;
import hurt.conv.tointeger;
import hurt.conv.tostring;

S conv(T, S)(T t) {
	// from string to S
	static if( is(T == string) ) {
		// string to int
		static if( is(S == int) ) {
			return stringToInt(t);	
		}
	// from int to S
	} else static if( is(T == int) ) {
		static if( is(S == string) ) {
			return intToString(t);
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
