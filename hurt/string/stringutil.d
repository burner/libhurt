module hurt.string.stringutil;

/** Trim blanks and tabs from the beginning and end of a str. */
public final immutable(T)[] trim(T)(immutable(T)[] str) {
	uint low = 0;
	while(str[low] == ' ' || str[low] == '\t')
		low++;

	uint high = str.length-1;
	while(str[high] == ' ' || str[high] == '\t')
		high--;

	return str[low..high+1].idup;	
}

public int hashCode(T)(immutable(T)[] str) {
	int h = 0;
	int off = 0;

	for (int i = 0; i < str.length; i++) {
		h = 31 * h + str[ off++ ];
	}
	return h;
}

public T toLowerCase(T)(T ch) 
		if(is(T == char) || is(T == wchar) || is(T == dchar)) {
	return ch + 32;
}

public T toUpperCase(T)(T ch) 
		if(is(T == char) || is(T == wchar) || is(T == dchar)) {
	return ch - 32;
}

public bool isTitleCase(wchar ch) {
	if(ch == '\u01c5' || ch == '\u01c8' || ch == '\u01cb' || ch == '\u01f2') {
		return true;
	}
	if(ch >= '\u1f88' && ch <= '\u1ffc') {
		// 0x1f88 - 0x1f8f, 0x1f98 - 0x1f9f, 0x1fa8 - 0x1faf
		if(ch > '\u1faf') {
			return ch == '\u1fbc' || ch == '\u1fcc' || ch == '\u1ffc';
		}
		int last = ch & 0xf;
		return last >= 8 && last <= 0xf;
	}
	return false;
}

/** Converts a [w,d]char to Title Case.	TODO check is
 *  
 * @author Robert "BuRnEr" Schadek
 *  
 * @param = the character
 * @template = T must be char,wchar or dchar
 *  
 * @return the TitleCase representation of the given character.
 */
public T toTitleCase(T)(T ch)
		if(is(T == char) || is(T == wchar) || is(T == dchar)) {
	if(ch > 64 && ch < 91)
		return ch;
	else if(ch > 96 && ch < 173)
		return ch - 32;
	
	assert(0, "not a printable character");
}