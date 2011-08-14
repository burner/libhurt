module hurt.io.file;

import hurt.io.ioflags;

public extern(C) long writeC(int fd, const void *buf, size_t count);
public extern(C) int openC(const char* name, uint flags, uint modevalues);
public extern(C) int fsyncC(int fd);
public extern(C) int closeC(int fd);
public extern(C) int getFdSize(int fd);
public extern(C) int seekC(int fd, ulong offset, int st);
public extern(C) int readC(int fd, void *buf, const long count);
public extern(C) int getErrno();

bool exists(string filename) {
	int fd = open(filename, FileFlags.O_RDONLY, ModeValues.S_IRWXU);
	int err = getErrno();
	bool ex = true;
	if(err == 2)
		ex = false;
	else
		close(fd);

	return ex;
}

long write(const int fd, void[] buf) {
	return writeC(fd, buf.ptr, buf.length);
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
