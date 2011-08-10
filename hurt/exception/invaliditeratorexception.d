module hurt.exception.invaliditeratorexception;

import hurt.conv.conv;

public class InvalidIteratorException : Exception {
	public this(string str, string file = __FILE__, int line = __LINE__) {
		super(file ~ ":" ~ conv!(int,string)(line) ~ " Invalid Iterator " 
			~ str);
	}
}
