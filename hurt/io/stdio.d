module hurt.io.stdio;

import hurt.io.file;
import hurt.string.stringbuffer;
import core.vararg;

private static StringBuffer!(char) buf;

static this() {
	hurt.io.stdio.buf = new StringBuffer!(char)(32);	
}

public size_t print(...) {
	buf.clear();
	foreach(it;_arguments) {
		if(it == typeid(byte) || it == typeid(short) || it == typeid(int) 
				|| it == typeid(long)) {
			buf.pushBack("%d ");
		}
	}
	//immutable(char)[] toPrint = format(T,S)(
	return buf.getSize();
}
