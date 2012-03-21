module hurt.conv.numerictochar;

import hurt.conv.conv;

public pure T byteToChar(T)(byte src, bool title = false) 
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
			case 10:
				return title ? 'A' : 'a';
			case 11:
				return title ? 'B' : 'b';
			case 12:
				return title ? 'C' : 'c';
			case 13:
				return title ? 'D' : 'd';
			case 14:
				return title ? 'E' : 'e';
			case 15:
				return title ? 'F' : 'f';
			default:
				return 'E';
				/*assert(0, "Invalid input " ~ cast(char)src ~ " " ~ 
					conv!(byte,string)(src));*/
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
			case 10:
				return title ? '\u0041' : '\u0061';
			case 11:
				return title ? '\u0042' : '\u0062';
			case 12:
				return title ? '\u0043' : '\u0063';
			case 13:
				return title ? '\u0044' : '\u0064';
			case 14:
				return title ? '\u0045' : '\u0065';
			case 15:
				return title ? '\u0046' : '\u0066';
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
			case 10:
				return title ? '\U00000041' : '\U00000061';
			case 11:
				return title ? '\U00000042' : '\U00000062';
			case 12:
				return title ? '\U00000043' : '\U00000063';
			case 13:
				return title ? '\U00000044' : '\U00000064';
			case 14:
				return title ? '\U00000045' : '\U00000065';
			case 15:
				return title ? '\U00000046' : '\U00000066';
			default:
				assert(0, "Invalid input");
		}
	}
}
