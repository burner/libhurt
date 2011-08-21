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

public size_t printfln(immutable(char)[] form, ...) {
	string str = formatString!(char,char)(form ~ "\n", _arguments, _argptr);
	if(str.length == 0)
		return 0;
	return writeC(0, str.ptr, str.length);
}

public size_t printf(immutable(char)[] form, ...) {
	string str = formatString!(char,char)(form, _arguments, _argptr);
	if(str.length == 0)
		return 0;
	return writeC(0, str.ptr, str.length);
}

public size_t print(...) {
	//writeln(buf.getString());
	string str = makeString(_arguments, _argptr);
	if(str.length == 0)
		return 0;
	if(str.length > 2 && str[$-1] == ' ')
		str = str[0..$];
	return writeC(0, str.ptr, str.length);
}

public size_t println(...) {
	//writeln(buf.getString());
	string str = makeString(_arguments, _argptr);	
	if(str.length == 0)
		return 0;

	if(str.length > 2 && str[$-1] == ' ')
		str = str[0..$] ~ "\n";
	else
		str ~= '\n';
	return writeC(0, str.ptr, str.length);
}

/*
unittest {
	assert(8 == println(22,13,5));
	assert(12 == println("hello","world"));
	assert(5 == println("\n\n\n\n"));
}*/
