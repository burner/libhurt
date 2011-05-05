import hurt.stdio.file;
import hurt.stdio.ioflags;

import hurt.conv.conv;

void main() {
	int fd = open("testFile.txt", FileFlags.O_CREAT|FileFlags.O_APPEND|FileFlags.O_WRONLY, 0666);
	println(conv!(int,string)(sizeOfFD(fd)));
	assert(fd != -1, "file open failed");
	assert(write(fd, "hello file world") != -1, "write failed");
	println(conv!(int,string)(sizeOfFD(fd)));
	assert(close(fd) != -1, "close failed");
	//assert(fsync(fd) != -1, "fsync failed");
}
