module hurt.util.util;

import core.vararg; 
import core.stdc.stdio; 
import core.stdc.stdlib;
import core.stdc.string/*, std.algorithm*/;

import hurt.exception.exception;

pure uint bswap(uint v) {
	// XxxxxxxxXxxxxxxxXxxxxxxx11111111 -> 11111111XxxxxxxxXxxxxxxxXxxxxxxxx
	uint one = (v << 24);
	// XxxxxxxxXxxxxxxx11111111Xxxxxxxx-> Xxxxxxxx11111111XxxxxxxxXxxxxxxxx
	uint two = ((v >> 8) << 24) >> 8;
	// Xxxxxxxx11111111XxxxxxxxXxxxxxxx-> XxxxxxxxXxxxxxxx11111111Xxxxxxxxx
	uint three = ((v >> 16) << 24) >> 16;
	// 11111111XxxxxxxxXxxxxxxxXxxxxxxx-> XxxxxxxxXxxxxxxxXxxxxxxxx11111111
	uint four = (v >> 24);
	return one | two | three | four;
}

unittest {	
	assert(0b0001_1111_0011_1111_0111_1111_1111_1111 == 
		bswap(0b1111_1111_0111_1111_0011_1111_0001_1111));
}

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
