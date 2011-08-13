module hurt.io.ioflags;

import std.conv;

enum FileFlags {
	O_ACCMODE =	 00000003,
	O_RDONLY  =  00000000,
	O_WRONLY  =  00000001,
	O_RDWR	  =  00000002,
	O_CREAT	  =  std.conv.octal!100,	/* not fcntl */
	O_EXCL	  =  std.conv.octal!200,	/* not fcntl */
	O_NOCTTY  =  std.conv.octal!400,	/* not fcntl */
	O_TRUNC	  =  std.conv.octal!1000,	/* not fcntl */
	O_APPEND  =  std.conv.octal!2000,
	O_NONBLOCK = std.conv.octal!4000,
	O_DSYNC	  =  std.conv.octal!10000,	/* used to be O_SYNC, see below */
	FASYNC	  =  std.conv.octal!20000,	/* fcntl, for BSD compatibility */
	O_DIRECT  =  std.conv.octal!40000,	/* direct disk access hint */
	O_LARGEFILE =std.conv.octal!100000,
	O_DIRECTORY= std.conv.octal!200000,	/* must be a directory */
	O_NOFOLLOW=	 std.conv.octal!400000,	/* don't follow links */
	O_NOATIME =	 std.conv.octal!1000000,
	O_CLOEXEC =	 std.conv.octal!2000000	/* set close_on_exec */
}

enum ModeValues {
	S_IRWXU = 0x700,
	S_IRUSR = 0x400,
	S_IWUSR = 0x200,
	S_IXUSR = 0x100,
	S_IRWXG = 0x070,
	S_IRGRP = 0x040,
	S_IWGRP = 0x020,
	S_IXGRP = 0x010,
	S_IRWXO = 0x007,
	S_IROTH = 0x004,
	S_IWOTH = 0x002,
	S_IXOTH = 0x001
}

enum SeekType {
	SEEK_SET = 0,
	SEEK_CUR = 1,
	SEEK_END = 2
}

pure string errnoToString(const int errno) {
	switch(errno) {
		case 1 : return "Operation not permitted";
		case 2 : return "No such file or directory";
		case 3 : return "No such process";
		case 4 : return "Interrupted system call";
		case 5 : return "I/O error";
		case 6 : return "No such device or address";
		case 7 : return "Argument list too long";
		case 8 : return "Exec format error";
		case 9 : return "Bad file number";
		case 10: return "No child processes";
		case 11: return "Try again";
		case 12: return "Out of memory";
		case 13: return "Permission denied";
		case 14: return "Bad address";
		case 15: return "Block device required";
		case 16: return "Device or resource busy";
		case 17: return "File exists";
		case 18: return "Cross-device link";
		case 19: return "No such device";
		case 20: return "Not a directory";
		case 21: return "Is a directory";
		case 22: return "Invalid argument";
		case 23: return "File table overflow";
		case 24: return "Too many open files";
		case 25: return "Not a typewriter";
		case 26: return "Text file busy";
		case 27: return "File too large";
		case 28: return "No space left on device";
		case 29: return "Illegal seek";
		case 30: return "Read-only file system";
		case 31: return "Too many links";
		case 32: return "Broken pipe";
		case 33: return "Math argument out of domain of func";
		case 34: return "Math result not representable";
		default: return "unknown Errno Number";
	}
}
