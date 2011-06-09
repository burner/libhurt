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
		writeln(__LINE__," ", it);
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
		}
	}
	writeln(__LINE__," ", buf.getString());
	return formatString!(char,char)(buf.getString(),arguments, args);
}

unittest {
	println(22,13,5);
	print("\n\n\n\n");
}
