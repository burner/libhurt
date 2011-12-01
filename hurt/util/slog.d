module hurt.util.slog;

import hurt.io.stdio;
import hurt.string.formatter;
import hurt.string.stringbuffer;
import hurt.util.array;

import core.vararg;

private string cropFileName(string filename) {
	size_t idx = rfind!(char)(filename, '/');
	if(idx > filename.length) {
		return filename[idx+1 .. $];
	} else {
		return filename;
	}
}

public void log(string File = __FILE__, int Line = __LINE__)() {
	printfln("%s:%d ", cropFileName(File), Line);
}

public void log(string File = __FILE__, int Line = __LINE__)
		(string format, ...) {
	printf("%s:%d ", cropFileName(File), Line);
	printfln(format, _arguments, _argptr);
}
