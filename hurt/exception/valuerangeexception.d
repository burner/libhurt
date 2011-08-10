module hurt.exception.valuerangeexception;

import hurt.conv.conv;

public class ValueRangeException : Exception {
	public this(string str, string file = __FILE__, int line = __LINE__) {
		super(file ~ ":" ~ conv!(int,string)(line) ~ " Value Range Exception: "
			~ str);
	}
}
