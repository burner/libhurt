module hurt.string.formatter;

import hurt.string.stringutil;

public pure immutable(T)[] format(T,S)(immutable(S)[] format, ...) 
		if((is(T == char) || is(T == wchar) || is(T == dchar)) &&
		(is(S == char) || is(S == wchar) || is(S == dchar))) {
	size_t ptr = 0;
	size_t vaTypePtr = 0;
	T[] ret = new T[32];
	for(size_t idx; idx < format.length; idx++) {
		// no special treatment till you find a % character
		if(format[idx] != '%') {
			appendWithIdx(ret, ptr++, format[idx]);
		} else if((idx > 0 && format[idx] == '%') 
				|| (idx == 0 && format[idx] == '%')) {
			bool padding0 = false;
			int padding = 0;
			bool altForm = false;
			bool alwaysSign = false;
			bool leftAlign = false;
			int precision = 0;
			bool intToSChar = false;
			bool intToUChar = false;
			bool intToSInt = false;
			bool intToUInt = false;
			bool kInterleaf = false;
			int width = 0;
			while(idx < format.length && format[idx] != ' ') {
				switch(format[idx]) {
					case '0':
						padding0 = true;		
						break;
					case '1': .. case '9': {
						size_t lowIdx = idx;
						while(idx < format.length 
								&& isDigit!(T)(format[idx])) {
							idx++;
						}
						leftPad = conv!(immutable(T)[],size_t)(format[lowIdx..idx]);
						break;
					}
					case '+':
						alwaysSign = true;	
						break;
					case '-':
						leftAlign = true;	
						break;
					case '#':
						altForm = true;
						break;
					case '*': {
						idx++;
						if(idx < format.length && format[idx] == '*') {
							//TODO pop next arguemnt as precision
							break;
						}
						size_t lowIdx = idx;
						while(idx < format.length 
								&& isDigit!(T)(format[idx])) {
							idx++;
						}
						width = conv!(immutable(T)[],size_t)(format[lowIdx..idx]);
						break;
					}
					case '.': {
						idx++;
						if(idx < format.length && format[idx] == '*') {
							//TODO pop next arguemnt as precision
							break;
						}
						size_t lowIdx = idx;
						while(idx < format.length 
								&& isDigit!(T)(format[idx])) {
							idx++;
						}
						precision = conv!(immutable(T)[],size_t)(format[lowIdx..idx]);
						break;
					}
					case 'h': // integer to char, uchar, short or ushort
						if(idx+2 < format.length && format[idx+1] == 'h' 
								&& format[idx+2] == 'n') {
							intToSChar = true;
							idx+=2;
						} if(idx+1 < format.length && format[idx+1] == 'h') {
							intToUChar = true;
							idx++;
						} if(idx+1 < format.length && format[idx+1] == 'n') {
							ptrToUInt = true;
							idx++;
						} else {
							intToSInt = true;
							idx++;
						}
					case 'l': // to cent
						if(idx+1 < format.lenght && format[idx+1] == 'n') {
							assert(0, "long to cent not yet implemented");
						} else if(idx+2 < format.lenght && format[idx+1] == 's') {
							assert(0, "long to ucent not yet implemented");

						}
					case 'L': // to long double aka real
						if(idx+1 < format.lenght && format[idx+1] == 'a') {
							idx++;
						} else if(idx+1 < format.lenght && format[idx+1] == 'A') {
							idx++;

						} else if(idx+1 < format.lenght && format[idx+1] == 'e') {
							idx++;
						} else if(idx+1 < format.lenght && format[idx+1] == 'E') {
							idx++;
						} else if(idx+1 < format.lenght && format[idx+1] == 'f') {
							idx++;
						} else if(idx+1 < format.lenght && format[idx+1] == 'F') {
							idx++;

						} else if(idx+1 < format.lenght && format[idx+1] == 'g') {
							idx++;
						} else if(idx+1 < format.lenght && format[idx+1] == 'G') {
							idx++;
						}
					case 'j': // int to int.max or uint.max
						break;
					case 'z': // int to size_t.max or ssize_t 
						break;
					case 't': // int to ptrdiff_t
						break;
					case '\'': // thousand interleaf
						kInterleaf = true;
					case 'd': // signed integer
						break;
					case 'i': // unsigned integer
						break;
					case 'o': // unsigned integer as octal
						break;
					case 'u': // unsigned integer as decimal
						break;
					case 'x': // unsigned integer as hex 
						break;
					case 'X': // unsigned integer as hex 
						break;
					case 's': // string
						break;
					case 'e': // double as exponent 1.4e44
						break;
					case 'E': // double as exponent 1.4E44
						break;
					case 'f': // double as decimal
						break;
					case 'F': // double as decimal
						break;
					case 'P': // print pointer adress as hex
						break;
					case 'c': // print int as c. %c, 'a' prints a
						break;
					case 'a': // double to hexadecimal
						break;
					case 'A': // double to hexadecimal capital letter
						break;
				}
				i++;
			}	
			
		}

	}
	return ret[0..ptr].idup;

}
