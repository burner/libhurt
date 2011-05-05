import hurt.stdio.file;
import hurt.stdio.ioflags;

void main() {
	int fd = open("testFile.txt", FileFlags.O_CREAT|FileFlags.O_WRONLY, ModeValues.S_IRWXU);
	assert(fd != -1, "file open failed");
	assert(write(fd, "hello file world") != -1, "write failed");
	assert(close(fd) != -1, "close failed");
	//assert(fsync(fd) != -1, "fsync failed");
}
