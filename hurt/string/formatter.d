module hurt.string.formatter;

import hurt.conv.conv;
import hurt.conv.tostring;
import hurt.util.array;
import hurt.string.stringutil;
import hurt.exception.formaterror;

import core.vararg;

import std.stdio;

public immutable(S)[] format(T,S)(immutable(T)[] form, ...)
		if((is(T == char) || is(T == wchar) || is(T == dchar)) &&
		(is(S == char) || is(S == wchar) || is(S == dchar))) {
	size_t argPtr = 0;
	size_t ptr = 0;
	size_t vaTypePtr = 0;
	T[] ret = new T[32];
	for(size_t idx; idx < form.length; idx++) {
		// no special treatment till you find a % character
		if(form[idx] != '%') {
			appendWithIdx!(T)(ret, ptr++, form[idx]);
			continue;
		} else if((idx > 0 && form[idx] == '%') 
				|| (idx == 0 && form[idx] == '%')) {
			bool padding0 = false;
			int padding = 0;
			int base = 10;
			int precision = 0;
			int leftPad = 0;
			bool ptrToUInt = false;
			bool title = false;
			bool altForm = false;
			bool alwaysSign = false;
			bool leftAlign = false;
			bool intToSChar = false;
			bool intToUChar = false;
			bool intToSInt = false;
			bool intToUInt = false;
			bool kInterleaf = false;
			int width = 0;
			while(idx < form.length && form[idx] != ' ' && form[idx] != '\t' 
					&& form[idx] != '\n') {
				switch(form[idx]) {
					case '0': // pad with 0 instead of blanks
						padding0 = true;		
						break;
					case '1': .. case '9': { // size of padding
						size_t lowIdx = idx;
						while(idx < form.length 
								&& isDigit!(T)(form[idx])) {
							idx++;
						}
						leftPad = conv!(immutable(T)[],int)(form[lowIdx..idx]);
						break;
					}
					case '+': // allways place sign of number
						alwaysSign = true;	
						break;
					case '-': // left align the output
						leftAlign = true;	
						break;
					case '#': // alternative coding
						altForm = true;
						break;
					case '*': {
						idx++;
						if(idx < form.length && form[idx] == '*') {
							//TODO pop next arguemnt as precision
							break;
						}
					}
					case '.': {
						idx++;
						if(idx < form.length && form[idx] == '*') {
							//TODO pop next arguemnt as precision
							break;
						}
						size_t lowIdx = idx;
						while(idx < form.length 
								&& isDigit!(T)(form[idx])) {
							idx++;
						}
						precision = conv!(immutable(T)[],int)(form[lowIdx..idx]);
						break;
					}
					case 'h': // integer to char, uchar, short or ushort
						if(idx+2 < form.length && form[idx+1] == 'h' 
								&& form[idx+2] == 'n') {
							intToSChar = true;
							idx+=2;
						} if(idx+1 < form.length && form[idx+1] == 'h') {
							intToUChar = true;
							idx++;
						} if(idx+1 < form.length && form[idx+1] == 'n') {
							ptrToUInt = true;
							idx++;
						} else {
							intToSInt = true;
							idx++;
						}
					case 'l': // to cent
						if(idx+1 < form.length && form[idx+1] == 'n') {
							assert(0, "long to cent not yet implemented");
						} else if(idx+2 < form.length && form[idx+1] == 's') {
							assert(0, "long to ucent not yet implemented");

						}
					case 'L': // to long double aka real
						if(idx+1 < form.length && form[idx+1] == 'a') {
							idx++;
						} else if(idx+1 < form.length && form[idx+1] == 'A') {
							idx++;

						} else if(idx+1 < form.length && form[idx+1] == 'e') {
							idx++;
						} else if(idx+1 < form.length && form[idx+1] == 'E') {
							idx++;
						} else if(idx+1 < form.length && form[idx+1] == 'f') {
							idx++;
						} else if(idx+1 < form.length && form[idx+1] == 'F') {
							idx++;

						} else if(idx+1 < form.length && form[idx+1] == 'g') {
							idx++;
						} else if(idx+1 < form.length && form[idx+1] == 'G') {
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
					case 'x': // unsigned integer as hex 
						goto case 'd';
					case 'X': // unsigned integer as hex 
						title = true;
						goto case 'd';
					case 'o': // unsigned integer as octal
						base = 8;
					case 'u': // unsigned integer as decimal
					case 'i': // unsigned integer
					case 'd': {// signed integer
						debug writeln(__FILE__,__LINE__,": integer");
						immutable(T)[] tmp;
						if(_arguments[argPtr] == typeid(int)) {
							int value = va_arg!(int)(_argptr);
							debug writeln(__FILE__,__LINE__,": ", value, alwaysSign);
							tmp = integerToString!(char,int)(value, base, alwaysSign, title);
							debug writeln(__FILE__,__LINE__,": ", tmp);
						} else if(_arguments[argPtr] == typeid(uint)) {
							uint value = va_arg!(uint)(_argptr);
							debug writeln(__FILE__,__LINE__,": ", value, alwaysSign);
							tmp = integerToString!(char,uint)(value, base, alwaysSign, title);
							debug writeln(__FILE__,__LINE__,": ", tmp);
						} else if(_arguments[argPtr] == typeid(ubyte)) {
							ubyte value = va_arg!(ubyte)(_argptr);
							debug writeln(__FILE__,__LINE__,": ", value, alwaysSign);
							tmp = integerToString!(char,ubyte)(value, base, alwaysSign, title);
							debug writeln(__FILE__,__LINE__,": ", tmp);
						} else if(_arguments[argPtr] == typeid(byte)) {
							byte value = va_arg!(byte)(_argptr);
							debug writeln(__FILE__,__LINE__,": ", value, alwaysSign);
							tmp = integerToString!(char,byte)(value, base, alwaysSign, title);
							debug writeln(__FILE__,__LINE__,": ", tmp);
						} else if(_arguments[argPtr] == typeid(ushort)) {
							ushort value = va_arg!(ushort)(_argptr);
							debug writeln(__FILE__,__LINE__,": ", value, alwaysSign);
							tmp = integerToString!(char,ushort)(value, base, alwaysSign, title);
							debug writeln(__FILE__,__LINE__,": ", tmp);
						} else if(_arguments[argPtr] == typeid(short)) {
							short value = va_arg!(short)(_argptr);
							debug writeln(__FILE__,__LINE__,": ", value, alwaysSign);
							tmp = integerToString!(char,short)(value, base, alwaysSign, title);
							debug writeln(__FILE__,__LINE__,": ", tmp);
						} else if(_arguments[argPtr] == typeid(ulong)) {
							ulong value = va_arg!(ulong)(_argptr);
							debug writeln(__FILE__,__LINE__,": ", value, alwaysSign);
							tmp = integerToString!(char,ulong)(value, base, alwaysSign, title);
							debug writeln(__FILE__,__LINE__,": ", tmp);
						} else if(_arguments[argPtr] == typeid(long)) {
							long value = va_arg!(long)(_argptr);
							debug writeln(__FILE__,__LINE__,": ", value, alwaysSign);
							tmp = integerToString!(char,long)(value, base, alwaysSign, title);
							debug writeln(__FILE__,__LINE__,": ", tmp);
						} else {
							throw new FormatError("an int was expected but value was a " 
								~ (_arguments[argPtr].toString()));
						}

						foreach(jt; tmp) 
							appendWithIdx!(T)(ret, ptr++, jt);
						
						break;
					}
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
					default:
						break;
				}
				idx++;
			}
		}

	}
	return ret[0..ptr].idup;
}

unittest {
	assert("hello" == format!(char,char)("hello"));
	assert("hello5" == format!(char,char)("hello%d", 5), format!(char,char)("hello%d", 5));
	assert("hello+5" == format!(char,char)("hello%+d", 5), format!(char,char)("hello%+d", 5));
	assert("hello+5" == format!(char,char)("hello%+o", 5), format!(char,char)("hello%+o", 5));
	assert("hello10" == format!(char,char)("hello%o", 8), format!(char,char)("hello%o", 8));
	assert("hello 10" == format!(char,char)("hello %o", 8), format!(char,char)("hello %o", 8));
	writeln(format!(char,char)("hello%d", 5));
	writeln(format!(char,char)("hello%+d", 5));
	writeln(format!(char,char)("hello %o", 8));
}
