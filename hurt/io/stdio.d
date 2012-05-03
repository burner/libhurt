module hurt.io.stdio;

import hurt.io.file;
import hurt.string.stringbuffer;
import hurt.string.formatter;
import core.vararg;

//import std.stdio;

extern(C) char* getLine();
extern(C) void freeCLine(char* line);
extern(C) int flushCStdout();

public int flushStdout() {
	return flushCStdout();
}

private static StringBuffer!(char) buf;

static this() {
	hurt.io.stdio.buf = new StringBuffer!(char)(32);	
}

public size_t printfln(int line = __LINE__, string file = __FILE__)
		(immutable(char)[] form, ...) {
	string str = formatString!(char,char)(form, _arguments, _argptr);
	str ~= "\n";
	if(str.length == 0)
		return 0;
	return writeC(0, str.ptr, str.length);
}

public size_t printfln(int line = __LINE__, string file = __FILE__)
		(immutable(char)[] form, TypeInfo[] arguments, void* args) {
	string str = formatString!(char,char)(form, arguments, args);
	str ~= "\n";
	if(str.length == 0)
		return 0;
	return writeC(0, str.ptr, str.length);
}

public size_t printf(int line = __LINE__, string file = __FILE__)
		(immutable(char)[] form, ...) {
	string str = formatString!(char,char)(form, _arguments, _argptr);
	if(str.length == 0)
		return 0;
	return writeC(0, str.ptr, str.length);
}

public size_t print(int line = __LINE__, string file = __FILE__)(...) {
	//writeln(buf.getString());
	string str = makeString(_arguments, _argptr);
	if(str.length == 0)
		return 0;
	if(str.length > 1 && str[$-1] == ' ')
		str = str[0..$-1];
	return writeC(0, str.ptr, str.length);
}

public size_t println(int line = __LINE__, string file = __FILE__)(...) {
	//writeln(buf.getString());
	string str = makeString(_arguments, _argptr);	

	if(str.length > 1 && str[$-1] == ' ')
		str = str[0..$-1] ~ "\n";
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

string readLine() {
	StringBuffer!(char) sb = new StringBuffer!(char)(128);
	char* tmp = getLine();
	if(tmp is null) {
		throw new Exception(format("%s:%d c function getLine failed", __FILE__, __LINE__));
	}

	for(char *it = tmp; *it != '\0'; it++) {
		sb.pushBack(*it);
	}
	freeCLine(tmp);
	sb.popBack();
	return sb.getString();
}
