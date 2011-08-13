module hurt.io.inputstream;

import hurt.io.file;
import hurt.io.ioflags;
import hurt.io.stdio;

import hurt.conv.conv;
import hurt.conv.tostring;
import hurt.container.vector;
import hurt.string.stringbuffer;

import hurt.io.stdio;
import std.stdio;
import hurt.io.stream;


void main() {
	Stream st = new hurt.io.stream.File("utf8");
	string ln =  cast(string)st.readLine();
	writeln(ln);
}
