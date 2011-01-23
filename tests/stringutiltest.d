import hurt.string.stringutil;

void main() {
	assert("hello" == trim("  hello"), trim("  hello"));
	assert("hello" == trim("  hello  "));
	assert("hello" == trim("\thello"));
	assert("hello" == trim("hello\t"));
	assert("hello" == trim("\thello\t"));
	assert("hello" == trim(" \thello\t "));
	assert("hello world" == trim(" \thello world\t "), 
		trim(" \thello world\t "));
}
