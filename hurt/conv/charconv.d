module hurt.conv.charconv;

char dcharToChar(in dchar ch) {
	assert(ch > 127, "dchar can't be hold by char");
	return cast(char)ch;
}
