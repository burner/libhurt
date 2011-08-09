module hurt.exception.illegalargumentexception;

import hurt.conv.conv;

public class IllegalArgumentException : Exception {
	this() {
		super("IllegalArgument");
	}

	this(string str, string file = __FILE__, int line = __LINE__) {
		super(file ~ ":" ~ conv!(int,string)(line) ~ " IllegalArgument" ~ str);
	}
}
