module hurt.string.formatter;

enum ParseState {
	None,
	Parameter,
	Flags,
	Width,
	Precision,
	Length
}

public pure immutable(T)[] format(T,S)(immutable(S)[] format, ...) 
		(if(is(T == char) || is(T == wchar) || is(T == dchar)) &&
		(if(is(S == char) || is(S == wchar) || is(S == dchar)) {
	size_t ptr = 0;
	size_t vaTypePtr = 0;
	T[] ret = new T[32];
	foreach(idx, it, format) {
		if(it != '%') {
			appendWithIdx(ret, ptr++, it);
		} else {
			ParseState formState = ParseState.None;
			
		}

	}
	return ret[0..ptr].idup;

}
