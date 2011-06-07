module hurt.io.inputstream;

import hurt.io.file;
import hurt.io.ioflags;

import hurt.conv.conv;
import hurt.container.vector;
import hurt.string.stringbuffer;

import std.stdio;

class InputStream {
	int fd;
	enum BOM {
		UTF8,
		UTF16,
		UTF32
	}
	
	BOM encoding;
	Vector!(ubyte) buf;
	StringBuffer!(char) sbchar;

	this(string fileName) {
		this.fd = open(fileName, FileFlags.O_RDONLY, 0);
		int error = getErrno();
		assert(error == 0, errnoToString(error));
		acquireBOM();
	}

	void acquireBOM() {
		seek(this.fd, 0,SeekType.SEEK_SET);	
		ubyte[] readb = new ubyte[4];
		long rcnt = read(fd, cast(byte[])readb, 4);
		if(readb[0] == 0xEF && readb[1] == 0xBB && readb[2] == 0xBF) {
			this.encoding = BOM.UTF8;
		} else if((readb[0] == 255 && readb[1] == 254 && readb[2] == 0 && readb[3] == 0)
				||(readb[3] == 0xFF && readb[2] == 0xFE && readb[1] == 0 && readb[1] == 0)) {
			this.encoding = BOM.UTF32;
		} else if((readb[0] == 0xFE && readb[1] == 0xFF)
				|| (readb[1] == 0xFE && readb[0] == 0xFF)){
			this.encoding = BOM.UTF16;
		} else {
			this.encoding = BOM.UTF8;
		}
	}

	string getBOM() const {
		if(this.encoding == BOM.UTF16) {
			return "UTF16";
		} else if(this.encoding == BOM.UTF32) {
			return "UTF32";
		} else {
			return "UTF8";
		}
	}

	string readLine() {
		ubyte[128] tmp;
		sbchar.clear();
		long rcnt = read(fd, cast(byte[])tmp, 128);
		if(!this.buf.empty()) {
			size_t bre = -1;
			foreach(idx, it; this.buf) {
				sbchar.pushBack(it);
				if(it == '\n') {
					bre = idx;	
				}
			}	
		}
		return null;
	}

	~this() {
		this.close();
	}

	void close() {
		hurt.io.file.close(fd);
	}
}
