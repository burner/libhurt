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
		if((is(T == char) || is(T == wchar) || is(T == dchar)) &&
		(is(S == char) || is(S == wchar) || is(S == dchar))) {
	size_t ptr = 0;
	size_t vaTypePtr = 0;
	T[] ret = new T[32];
	for(size_t idx; idx < format.length; idx++) {
		// no special treatment till you find a % character
		if(format[idx] != '%') {
			appendWithIdx(ret, ptr++, format[idx]);
		} else {
			ParseState formState = ParseState.None;
			
		}

	}
	return ret[0..ptr].idup;

}
