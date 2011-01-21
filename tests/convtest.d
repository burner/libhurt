import hurt.conv.conv;

import std.stdio;

void main() {
	assert(42 == conv!(string, int)("42"));
	assert(42 == conv!(string, int)("_4__2__"));
	assert(42 == conv!(string, int)("__4__2__"));
	assert("42" == conv!(int, string)(42));
	assert("-42" == conv!(int, string)(-42));
}
