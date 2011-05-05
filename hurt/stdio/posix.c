#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdio.h>

int writeC(int fd, const void *buf, size_t count) {
	return write(fd, buf, count);
}

int fsyncC(int fd) {
	return fsyncC(fd);
}

int openC(const char *name, unsigned int flags, unsigned int mode) {
	int f = open(name, flags, mode);
	return f;
}

int closeC(const int fd) {
	return close(fd);
}

long getFdSize(const int fd) {
	struct stat s;
	int i = fstat(fd, &s);
	return s.st_size;
}
