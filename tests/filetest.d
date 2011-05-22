import hurt.stdio.file;
import hurt.stdio.ioflags;
import hurt.stdio.inputstream;

import hurt.conv.conv;

void main() {
	int fd = open("testFile.txt", FileFlags.O_CREAT|FileFlags.O_APPEND|FileFlags.O_RDWR, 0666);
	println(conv!(int,string)(sizeOfFD(fd)));
	assert(fd != -1, "file open failed");
	assert(write(fd, "hello file world") != -1, "write failed");
	println(conv!(int,string)(sizeOfFD(fd)));
	//assert(seek(fd, 0L, SeekType.SEEK_SET) != -1);
	println("seek work");
	println(conv!(int,string)(seek(fd, -12L, SeekType.SEEK_CUR)));
	char[] readb = new char[12];
	long rcnt = read(fd, cast(byte[])readb, 12);
	println(conv!(long,string)(rcnt));
	println("Errno value " ~ conv!(long,string)(getErrno()));
	println(readb[0..rcnt].idup);
	assert(close(fd) != -1, "close failed");
	println("close worked");
	println("€");
	InputStream ins = new InputStream("testFile2utf16.txt");
	println("ins bom " ~ ins.getBOM());
	//assert(fsync(fd) != -1, "fsync failed");
}
