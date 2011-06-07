module hurt.io.stdio;

import hurt.io.file;
import hurt.string.stringbuffer;
import core.vararg;

private static StringBuffer!(char) buf;

static this() {
	hurt.io.stdio.buf = new StringBuffer!(char)(32);	
}

public size_t print(...) {
	return 0;
}
