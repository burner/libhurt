module hurt.util.slog;

import hurt.io.stdio;
import hurt.string.formatter;
import hurt.string.stringbuffer;
import hurt.util.array;

import core.vararg;

private string cropFileName(string filename) {
	size_t idx = rfind!(char)(filename, '/');
	if(idx < filename.length) {
		return filename[idx+1 .. $];
	} else {
		return filename;
	}
}

unittest {
	assert("crop" == cropFileName("hello/crop"), cropFileName("hello/crop"));
	assert("" == cropFileName("hello/"), cropFileName("hello/"));
}

version(NOLOG) {
	public void log(string File = __FILE__, int Line = __LINE__)(bool need) {
		return;
	}

	public void log(string File = __FILE__, int Line = __LINE__)(bool need,
			string format, lazy ...) {
		return;
	}

	public void log(string File = __FILE__, int Line = __LINE__)() {
		return;
	}

	public void log(string File = __FILE__, int Line = __LINE__)
			(string format, ...) {
		return;
	}
} else {
	public void log(string File = __FILE__, int Line = __LINE__)(bool need) {
		if(!need) {
			return;
		}
		printfln("%s:%d ", cropFileName(File), Line);
	}
	
	public void log(string File = __FILE__, int Line = __LINE__)
			(bool need, string format, lazy ...) {
		if(!need) {
			return;
		}
		printf("%s:%d ", cropFileName(File), Line);
		printfln(format, _arguments, _argptr);
	}

	public void log(string File = __FILE__, int Line = __LINE__)() {
		printfln("%s:%d ", cropFileName(File), Line);
	}
	
	public void log(string File = __FILE__, int Line = __LINE__)
			(string format, ...) {
		printf("%s:%d ", cropFileName(File), Line);
		printfln(format, _arguments, _argptr);
	}
}

version(NOWARN) {
	public void warn(string File = __FILE__, int Line = __LINE__)(bool need) {
		return;
	}

	public void warn(string File = __FILE__, int Line = __LINE__)
			(bool need, string format, lazy ...) {
		return;
	}

	public void warn(string File = __FILE__, int Line = __LINE__)() {
		return;
	}

	public void warn(string File = __FILE__, int Line = __LINE__)
			(string format, ...) {
		return;
	}
} else {
	public void warn(string File = __FILE__, int Line = __LINE__)(bool need) {
		if(!need) {
			return;
		}
		printfln("%s:%d WARNING", cropFileName(File), Line);
	}

	public void warn(string File = __FILE__, int Line = __LINE__)
			(bool need, string format, lazy ...) {
		if(!need) {
			return;
		}
		printf("%s:%d WARN ", cropFileName(File), Line);
		printfln(format, _arguments, _argptr);
	}

	public void warn(string File = __FILE__, int Line = __LINE__)() {
		printfln("%s:%d WARN", cropFileName(File), Line);
	}

	public void warn(string File = __FILE__, int Line = __LINE__)
			(string format, ...) {
		printf("%s:%d WARN ", cropFileName(File), Line);
		printfln(format, _arguments, _argptr);
	}
}
