module hurt.exception.formaterror;

import hurt.conv.conv;

public class FormatError : Exception {
	this(string str, string file = __FILE__, int line = __LINE__) {
		super(file ~ ":" ~ conv!(int,string)(line) ~ " " ~ str);
	}
}
