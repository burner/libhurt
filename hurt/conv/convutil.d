module hurt.conv.convutil;

public final pure bool getSign(in char ch) {
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

public final pure bool isDigit(S)(in S ch) {
	switch(ch) {
		case '0': .. case '9':
			return true;
		default:
			return false;
	}
}
