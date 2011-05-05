module hurt.stdio.stdio;
import hurt.stdio.ioflags;

extern(C) long writeC(int fd, const void *buf, size_t count);
extern(C) int openC(const char* name, uint flags, uint modevalues);
extern(C) int fsyncC(int fd);

size_t write(const string str) {
	return writeC(0, str.ptr, str.length);	
}

size_t writeln(string str) {
	str ~= '\n';
	return writeC(0, str.ptr, str.length);	
}

int open(string name, const uint flags, const uint modevalues) {
	name ~= '\0';
	return openC(name.ptr, flags, modevalues);
}

unittest {
	string a = "Hello World";
	writeln(a);
	int fd = open("testFile.text", FileFlags.O_CREAT, ModeValues.S_IRWXU);
	assert(fd != -1);
}
