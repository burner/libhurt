module hurt.stdio.stdio;
import hurt.stdio.ioflags;

extern(C) long writeC(int fd, const void *buf, size_t count);
extern(C) int openC(const char* name, uint flags, uint modevalues);
extern(C) int fsyncC(int fd);
extern(C) int closeC(int fd);
extern(C) int getFdSize(int fd);
extern(C) int seekC(int fd, ulong offset, int st);
extern(C) int readC(int fd, void *buf, const long count);
extern(C) int getErrno();

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

int sync(const int fd) {
	return fsyncC(fd);
}

int sizeOfFD(const int fd) {
	return getFdSize(fd);
}

int seek(int fd, long offset, SeekType st) {
	return seekC(fd, offset, st);	
} 

long read(const int fd, byte[] buf, const long count) {
	return readC(fd, buf.ptr, count);
}
