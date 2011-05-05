module hurt.stdio.stdio;
import hurt.stdio.ioflags;

extern(C) long writeC(int fd, const void *buf, size_t count);
extern(C) int openC(const char* name, uint flags, uint modevalues);
extern(C) int fsyncC(int fd);
extern(C) int closeC(int fd);
extern(C) int getFdSize(int fd);

size_t print(const string str) {
	return writeC(0, str.ptr, str.length);	
}

size_t println(string str) {
	str ~= '\n';
	return writeC(0, str.ptr, str.length);	
}

size_t write(const int fd, const string str) {
	return writeC(fd , str.ptr, str.length);	
}

int open(string name, const uint flags, const uint modevalues) {
	name ~= '\0';
	return openC(name.ptr, flags, modevalues);
}

int close(const int fd) {
	return closeC(fd);
}

int fsync(const int fd) {
	return fsyncC(fd);
}

int sizeOfFD(const int fd) {
	return getFdSize(fd);
}

unittest {
	string a = "Hello World";
	//println(a);
	//int fd = open("testFile.text", FileFlags.O_CREAT, ModeValues.S_IRWXU);
	//assert(fd != -1);
}
