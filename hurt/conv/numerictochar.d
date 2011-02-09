module hurt.conv.numerictochar;

public pure T byteToCharBase10(T)(byte src) 
		if(is(T == char) || is(T == wchar) || is(T == dchar)) {
	static if(is(T == char)) {
		switch(src) {
			case 0:
				return '0';
			case 1:
				return '1';
			case 2:
				return '2';
			case 3:
				return '3';
			case 4:
				return '4';
			case 5:
				return '5';
			case 6:
				return '6';
			case 7:
				return '7';
			case 8:
				return '8';
			case 9:
				return '9';
			default:
				assert(0, "Invalid input");
		}
	} else static if(is(T == wchar)) {
		switch(src) {
			case 0:
				return '\u0030';
			case 1:
				return '\u0031';
			case 2:
				return '\u0032';
			case 3:
				return '\u0033';
			case 4:
				return '\u0034';
			case 5:
				return '\u0035';
			case 6:
				return '\u0036';
			case 7:
				return '\u0037';
			case 8:
				return '\u0038';
			case 9:
				return '\u0039';
			default:
				assert(0, "Invalid input");
		}
	} else static if(is(T == dchar)) {
		switch(src) {
			case 0:
				return '\U00000030';
			case 1:
				return '\U00000031';
			case 2:
				return '\U00000032';
			case 3:
				return '\U00000033';
			case 4:
				return '\U00000034';
			case 5:
				return '\U00000035';
			case 6:
				return '\U00000036';
			case 7:
				return '\U00000037';
			case 8:
				return '\U00000038';
			case 9:
				return '\U00000039';
			default:
				assert(0, "Invalid input");
		}
	}
}
