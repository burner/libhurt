import hurt.io.stdio;
import hurt.string.stringbuffer;
import hurt.string.formatter;

extern(C) char* getLine();
extern(C) void freeCLine(char* line);

string readLine() {
	StringBuffer!(char) sb = new StringBuffer!(char)(128);
	char* tmp = getLine();
	if(tmp is null) {
		throw new Exception(format("%s:%d c function getLine failed", __FILE__, __LINE__));
	}

	for(char *it = tmp; *it != '\0'; it++) {
		sb.pushBack(*it);
	}
	freeCLine(tmp);
	sb.popBack();
	return sb.getString();
}

void main() {
	string line = readLine();
	println(line);
}
