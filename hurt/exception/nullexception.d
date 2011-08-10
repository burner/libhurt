module hurt.exception.nullexception;

import hurt.conv.conv;

class NullException : Exception {
	public this(string str, string file = __FILE__, int line = __LINE__) {
		super(file ~ ":" ~ conv!(int,string)(line) ~ " Null Exception: " ~ str);
	}
}
