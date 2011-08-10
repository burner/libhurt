module hurt.exception.outofrangeexception;

import hurt.conv.conv;

public class OutOfRangeException : Exception {
	public this(string str, string file = __FILE__, int line = __LINE__) {
		super(file ~ ":" ~ conv!(int,string)(line) ~ " Out of Range: " ~ str);
	}
}
