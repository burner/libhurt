module hurt.string.stringutil;

import hurt.io.stdio;
import hurt.exception.exception;

import core.vararg; 
import core.stdc.stdio; 
import core.stdc.stdlib;
import core.stdc.string/*, std.algorithm*/;

/*********************************
 * Convert array of chars $(D s[]) to a C-style 0-terminated string.
 * $(D s[]) must not contain embedded 0's. If $(D s) is $(D null) or
 * empty, a string containing only $(D '\0') is returned.
 */
immutable(char)* toStringz(const(char)[] s)
in
{
    // The assert below contradicts the unittests!
    //assert(memchr(s.ptr, 0, s.length) == null,
    //text(s.length, ": `", s, "'"));
}
out (result)
{
    if (result)
    {
        auto slen = s.length;
        while (slen > 0 && s[slen-1] == 0) --slen;
        assert(strlen(result) == slen);
        assert(memcmp(result, s.ptr, slen) == 0);
    }
}
body
{
    /+ Unfortunately, this isn't reliable.
     We could make this work if string literals are put
     in read-only memory and we test if s[] is pointing into
     that.

     /* Peek past end of s[], if it's 0, no conversion necessary.
     * Note that the compiler will put a 0 past the end of static
     * strings, and the storage allocator will put a 0 past the end
     * of newly allocated char[]'s.
     */
     char* p = &s[0] + s.length;
     if (*p == 0)
     return s;
     +/

    // Need to make a copy
    auto copy = new char[s.length + 1];
    copy[0..s.length] = s;
    copy[s.length] = 0;

    return assumeUnique(copy).ptr;
}

/// Ditto
immutable(char)* toStringz(string s)
{
    if (s.length == 0) return "".ptr;
    /* Peek past end of s[], if it's 0, no conversion necessary.
     * Note that the compiler will put a 0 past the end of static
     * strings, and the storage allocator will put a 0 past the end
     * of newly allocated char[]'s.
     */
    immutable p = s.ptr + s.length;
    // Is p dereferenceable? A simple test: if the p points to an
    // address multiple of 4, then conservatively assume the pointer
    // might be pointing to a new block of memory, which might be
    // unreadable. Otherwise, it's definitely pointing to valid
    // memory.
    if ((cast(size_t) p & 3) && *p == 0)
        return s.ptr;
    return toStringz(cast(const char[]) s);
}

unittest
{
    debug(string) printf("string.toStringz.unittest\n");

    auto p = toStringz("foo");
    assert(strlen(p) == 3);
    const(char) foo[] = "abbzxyzzy";
    p = toStringz(foo[3..5]);
    assert(strlen(p) == 2);

    string test = "";
    p = toStringz(test);
    assert(*p == 0);

    test = "\0";
    p = toStringz(test);
    assert(*p == 0);

    test = "foo\0";
    p = toStringz(test);
    assert(p[0] == 'f' && p[1] == 'o' && p[2] == 'o' && p[3] == 0);
}

public bool cmp(T)(immutable(T)[] str1, immutable(T)[] str2) 
		if(isChar!(T)()) {
	if(str1 is null || str2 is null) {
		println(__LINE__);
		return false;
	}

	if(str1.length != str2.length) {
		println(__LINE__);
		return false;
	}

	foreach(idx, it; str1) {
		if(str2[idx] != it) {
			println(__LINE__, idx);
			return false;
		}
	}
	return true;
}

public pure bool isChar(T)() {
	static if(is(T == char) || is(T == wchar) || is(T == dchar)) {
		return true;
	} else {
		return false;
	}
}

@safe
public pure bool isString(T)() {
	static if(is(T == immutable(char)[]) || is(T == immutable(wchar)[]) || 
			is(T == immutable(dchar)[]) || 
			is(T : const(dchar[])) || is(T : const(wchar[])) || 
			is(T : const(char[]))) {
		return true;
	} else {
		return false;
	}
}

/** Trim blanks and tabs from the beginning and end of a str. */
public pure final immutable(T)[] trim(T)(immutable(T)[] str) {
	uint low = 0;
	while(str[low] == ' ' || str[low] == '\t')
		low++;

	version(X86) {
		uint high = str.length-1;
	}
	version(X86_64) {
		ulong high = str.length-1;
	}
	while(str[high] == ' ' || str[high] == '\t')
		high--;

	return str[low..high+1].idup;	
}

public pure int hashCode(T)(immutable(T)[] str) {
	int h = 0;
	int off = 0;

	for (int i = 0; i < str.length; i++) {
		h = 31 * h + str[ off++ ];
	}
	return h;
}

public pure T toLowerCase(T)(T ch) 
		if(is(T == char) || is(T == wchar) || is(T == dchar)) {
	return cast(T)(ch + 32);
}

public pure T toUpperCase(T)(T ch) 
		if(is(T == char) || is(T == wchar) || is(T == dchar)) {
	return cast(T)(ch - 32);
}

public pure bool isLetter(T)(T ch) 
		if(is(T == char) || is(T == wchar) || is(T == dchar)) {
	static if(is(T == char)) {
		if( (ch > 64 && ch < 91) || (ch > 96 && ch < 123) ) {
			return true;
		} else {
			return false;
		}
	}
}

public pure bool isTitleCase(wchar ch) {
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
public pure T toTitleCase(T)(T ch)
		if(is(T == char) || is(T == wchar) || is(T == dchar)) {
	if(ch > 64 && ch < 91)
		return ch;
	else if(ch > 96 && ch < 173)
		return cast(T)(ch - 32);
	
	assert(0, "not a printable character");
}

public pure T isDigit(T)(T ch)
		if(is(T == char) || is(T == wchar) || is(T == dchar)) {
	return ch >= '0' && ch <= '9';
}
