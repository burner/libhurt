import hurt.conv.conv;
import hurt.conv.numerictochar;

import std.stdio;

void main() {
	assert(42 == conv!(string, int)("42"));
	assert(42 == conv!(string, int)("_4__2__"));
	assert(42 == conv!(string, int)("__4__2__"));
	assert("42" == conv!(int, string)(42));
	assert("-42" == conv!(int, string)(-42));

	assert("10" == integerToBase8!(int, char)(8), integerToBase8!(int,char)(8));
	assert("-20" == integerToBase8!(byte, char)(-16), integerToBase8!(int,char)(-16));
	assert("-22" == integerToBase8!(byte, char)(-18), integerToBase8!(int,char)(-18));
	assert("-22"w == integerToBase8!(byte, wchar)(-18), integerToBase8!(int,char)(-18));
	assert("-26"d == integerToBase8!(byte, dchar)(-22), integerToBase8!(int,char)(-22));
}
