module hurt.conv.convutil;

public final bool getSign(in char ch) {
	switch(ch) {
		case '0': .. case '9':
			return true;
		case '+':
			return true;
		case '-':
			return false;
		default:
			assert(0, "invalid fist char");
	}
}

public bool isDigit(in char ch) {
	switch(ch) {
		case '0': .. case '9':
			return true;
		default:
			return false;
	}
}
