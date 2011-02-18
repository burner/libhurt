module hurt.conv.charconv;

public pure char dcharToChar(in dchar ch) {
	assert(ch > 127, "dchar can't be hold by char");
	return cast(char)ch;
}
