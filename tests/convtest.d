import hurt.conv.conv;

void main() {
	assert(42 == conv!(string, int)("42"));
}
