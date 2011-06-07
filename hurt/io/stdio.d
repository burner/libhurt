module hurt.io.stdio;

import hurt.io.file;
import hurt.string.stringbuffer;
import hurt.string.formatter;
import core.vararg;

private static StringBuffer!(char) buf;

static this() {
	hurt.io.stdio.buf = new StringBuffer!(char)(32);	
}

public size_t print(...) {
	string str = makeString(_arguments, _argptr);	
	return writeC(0, str.ptr, str.length);
}

public size_t println(...) {
	string str = makeString(_arguments, _argptr) ~ "\n";	
	return writeC(0, str.ptr, str.length);
}

public string makeString(TypeInfo[] arguments, void* args) {
	buf.clear();
	foreach(it;arguments) {
		if(it == typeid(byte) || it == typeid(short) || it == typeid(int) 
				|| it == typeid(long)) {
			buf.pushBack("%d ");
		} else if(it == typeid(string)) {
			buf.pushBack("%s ");
		}
	}
	return format!(char,char)(buf.getString(), args);
}

unittest {
	print(22,13,5);
	print("\n\n\n\n");
}
