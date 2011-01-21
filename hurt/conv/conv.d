module hurt.conv.conv;

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
	} else {
		return null;
	}
}
