module hurt.io.stdio;

import hurt.io.file;
import hurt.string.stringbuffer;
import hurt.string.formatter;
import core.vararg;

import std.stdio;

private static StringBuffer!(char) buf;

static this() {
	hurt.io.stdio.buf = new StringBuffer!(char)(32);	
}

public size_t print(...) {
	//writeln(buf.getString());
	string str = makeString(_arguments, _argptr);
	if(str.length == 0)
		return 0;
	str = str[0..$-1];
	return writeC(0, str.ptr, str.length);
}

public size_t println(...) {
	//writeln(buf.getString());
	string str = makeString(_arguments, _argptr);	
	if(str.length == 0)
		return 0;
	str = str[0..$-1] ~ "\n";
	return writeC(0, str.ptr, str.length);
}

public string makeString(TypeInfo[] arguments, void* args) {
	buf.clear();
	foreach(it;arguments) {
		if(it == typeid(ubyte) || it == typeid(ushort) 
				|| it == typeid(uint) || it == typeid(ulong)) {
			buf.pushBack("%u ");
		} else if(it == typeid(byte) || it == typeid(short) 
				|| it == typeid(int) || it == typeid(long)) {
			buf.pushBack("%d ");
		} else if(it == typeid(float) || it == typeid(double)
				|| it == typeid(real)) {
			buf.pushBack("%.5f ");
		} else if(it == typeid(immutable(char)[]) || it == typeid(immutable(wchar)[])
				|| it == typeid(immutable(dchar)[])) {
			buf.pushBack("%s ");
		} else {
			//writeln(45, it);
			buf.pushBack("%a ");
		}
	}
	return formatString!(char,char)(buf.getString(), arguments, args);
}

unittest {
	assert(8 == println(22,13,5));
	assert(12 == println("hello","world"));
	assert(5 == println("\n\n\n\n"));
}
