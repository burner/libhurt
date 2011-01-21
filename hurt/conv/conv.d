module hurt.conv.conv;

import hurt.conv.tointeger;

S conv(T, S)(T t) {
	// from string to S
	static if( is(T == string) ) {
		// string to int
		static if( is(S == int) ) {
			return stringToInt(t);	
		}
	} else {
		return null;
	}
}
