module hurt.exception.ioexception;

import hurt.conv.conv;

public class IOException : Exception {
	public this(string str, string file = __FILE__, int line = __LINE__) {
		super(file ~ ":" ~ conv!(int,string)(line) ~ " IOException: "
			~ str);
	}
}
