module hurt.stdio.stdio;

import hurt.stdio.file;
import hurt.string.stringbuffer;
import core.vararg;

private static StringBuffer!(char) buf;

static this() {
	hurt.stdio.stdio.buf = new StringBuffer!(char)(32);	
}

public size_t print(...) {
	return 0;
}
