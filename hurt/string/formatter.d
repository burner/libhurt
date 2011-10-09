module hurt.string.formatter;

import hurt.conv.conv;
import hurt.conv.tostring;
import hurt.util.array;
import hurt.string.stringutil;
import hurt.string.stringbuffer;
import hurt.exception.formaterror;
import hurt.exception.illegalargumentexception;

import core.vararg;

import std.stdio;
import hurt.string.utf;

private static StringBuffer!(char) buf;

static this() {
	buf = new StringBuffer!(char)(32);
}

public string makeString(TypeInfo[] arguments, void* args) {
	buf.clear();
	foreach(it;arguments) {
		if(it == typeid(char) || it == typeid(wchar) 
				|| it == typeid(dchar)) {
			buf.pushBack("%c ");
		} else if(it == typeid(ubyte) || it == typeid(ushort) 
				|| it == typeid(uint) || it == typeid(ulong)) {
			buf.pushBack("%u ");
		} else if(it == typeid(byte) || it == typeid(short) 
				|| it == typeid(int) || it == typeid(long)) {
			buf.pushBack("%d ");
		} else if(it == typeid(float) || it == typeid(double)
				|| it == typeid(real)) {
			buf.pushBack("%.5f ");
		} else if(it == typeid(immutable(char)[]) || 
				it == typeid(immutable(wchar)[]) || 
				it == typeid(immutable(dchar)[])) {
			buf.pushBack("%s ");
		} else if(it == typeid(bool)) {
			buf.pushBack("%b ");
		} else {
			//writeln(45, it);
			buf.pushBack("%a ");
		}
	}
	return formatString!(char,char)(buf.getString(), arguments, args);
}

public immutable(S)[] format(T = char,S = char)(immutable(T)[] form, ...) {
	return formatString!(T,S)(form, _arguments, _argptr);
}

public immutable(S)[] formatString(T,S)(immutable(T)[] form, 
		TypeInfo[] arguments, void* arg)
		if((is(T == char) || is(T == wchar) || is(T == dchar)) &&
		(is(S == char) || is(S == wchar) || is(S == dchar))) {
	//writeln(_arguments);
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
			bool expCap = false;
			bool skipExpCap = false;
			int padding = 0;
			int base = 10;
			int precision = 6;
			int leftPad = 0;
			bool ptrToUInt = false;
			bool title = false;
			bool altForm = false;
			bool alwaysSign = false;
			bool noSignBlank = false;
			bool leftAlign = false;
			bool intToSChar = false;
			bool intToUChar = false;
			bool intToSInt = false;
			bool intToUInt = false;
			bool kInterleaf = false;
			int width = 0;
			parse: while(idx < form.length) {
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
						padding = conv!(immutable(T)[],int)(form[lowIdx..idx]);
						continue;
					}
					case ' ':
						noSignBlank = true;
						break;
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
						if(idx < form.length && form[idx] == '*') {
							if(arguments[argPtr] == typeid(int)) {
								padding = va_arg!(int)(arg);
								argPtr++;
								//debug writeln(__FILE__,__LINE__,": ", 
									//padding, " " , arg);
							} else {
								throw new IllegalArgumentException("Expected 										an int not an " 
									~ arguments[argPtr].toString());
							}
						}
						break;
					}
					case '.': {
						idx++;
						if(idx < form.length && form[idx] == '*') {
							if(arguments[argPtr] == typeid(int)) {
								precision = va_arg!(int)(arg);
								argPtr++;
								//debug writeln(__FILE__,__LINE__,": ", precision, " ", arg);
							} else {
								throw new IllegalArgumentException("Expected 
									an int not an " 
									~ arguments[argPtr].toString());
							}
							break;
						}
						size_t lowIdx = idx;
						while(idx < form.length 
								&& isDigit!(T)(form[idx])) {
							idx++;
						}
						precision = conv!(immutable(T)[],int)(
							form[lowIdx..idx]);
						//debug writeln(__FILE__,__LINE__,": precision ", precision, " ", form[idx]);
						continue;
					}
					case 'h': // integer to char, short or ushort
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
						base = 16;
						goto case 'd';
					case 'X': // unsigned integer as hex 
						title = true;
						base = 16;
						goto case 'd';
					case 'o': // unsigned integer as octal
						base = 8;
					case 'u': // unsigned integer as decimal
					case 'i': // unsigned integer
					case 'd': {// signed integer
						//debug writeln(__FILE__,__LINE__,": integer");
						immutable(T)[] tmp;
						if(arguments[argPtr] == typeid(int) || arguments[argPtr] == typeid(const(int))) {
							int value = va_arg!(int)(arg);
							//debug writeln(__FILE__,__LINE__,": ", value, alwaysSign);
							tmp = integerToString!(T,int)(value, base, 
								alwaysSign, title);
							//debug writeln(__FILE__,__LINE__,": ", tmp);
						} else if(arguments[argPtr] == typeid(uint)) {
							uint value = va_arg!(uint)(arg);
							//debug writeln(__FILE__,__LINE__,": ", value, alwaysSign);
							tmp = integerToString!(T,uint)(value, base, 
								alwaysSign, title);
							//debug writeln(__FILE__,__LINE__,": ", tmp);
						} else if(arguments[argPtr] == typeid(ubyte)) {
							ubyte value = va_arg!(ubyte)(arg);
							//debug writeln(__FILE__,__LINE__,": ", value, alwaysSign);
							tmp = integerToString!(T,ubyte)(value, base, 
								alwaysSign, title);
							//debug writeln(__FILE__,__LINE__,": ", tmp);
						} else if(arguments[argPtr] == typeid(byte)) {
							byte value = va_arg!(byte)(arg);
							//debug writeln(__FILE__,__LINE__,": ", value, alwaysSign);
							tmp = integerToString!(T,byte)(value, base, 
								alwaysSign, title);
							//debug writeln(__FILE__,__LINE__,": ", tmp);
						} else if(arguments[argPtr] == typeid(ushort)) {
							ushort value = va_arg!(ushort)(arg);
							//debug writeln(__FILE__,__LINE__,": ", value, alwaysSign);
							tmp = integerToString!(T,ushort)(value, base, 
								alwaysSign, title);
							//debug writeln(__FILE__,__LINE__,": ", tmp);
						} else if(arguments[argPtr] == typeid(short)) {
							short value = va_arg!(short)(arg);
							//debug writeln(__FILE__,__LINE__,": ", value, alwaysSign);
							tmp = integerToString!(T,short)(value, base, 
								alwaysSign, title);
							//debug writeln(__FILE__,__LINE__,": ", tmp);
						} else if(arguments[argPtr] == typeid(ulong)) {
							ulong value = va_arg!(ulong)(arg);
							//debug writeln(__FILE__,__LINE__,": ", value, alwaysSign);
							tmp = integerToString!(T,ulong)(value, base, 
								alwaysSign, title);
							//debug writeln(__FILE__,__LINE__,": ", tmp);
						} else if(arguments[argPtr] == typeid(const(ulong))) {
							ulong value = va_arg!(ulong)(arg);
							//debug writeln(__FILE__,__LINE__,": ", value, alwaysSign);
							tmp = integerToString!(T,ulong)(value, base, 
								alwaysSign, title);
							//debug writeln(__FILE__,__LINE__,": ", tmp);
						} else if(arguments[argPtr] == typeid(const(long))) {
							long value = va_arg!(long)(arg);
							//debug writeln(__FILE__,__LINE__,": ", value, alwaysSign);
							tmp = integerToString!(T,ulong)(value, base, 
								alwaysSign, title);
							//debug writeln(__FILE__,__LINE__,": ", tmp);
						} else if(arguments[argPtr] == typeid(long)) {
							long value = va_arg!(long)(arg);
							//debug writeln(__FILE__,__LINE__,": ", value, alwaysSign);
							tmp = integerToString!(T,long)(value, base, 
								alwaysSign, title);
							//debug writeln(__FILE__,__LINE__,": ", tmp);
						} else {
							throw new FormatError("an int was expected but 
								value was a " ~ (arguments[argPtr].toString()));
						}
						argPtr++;

						immutable(T) paddingChar = padding0 ? '0' : ' ';
						//debug writeln(__FILE__,__LINE__,": ", padding);
						if(tmp.length < padding && !leftAlign) {
							for(size_t i = 0; i < padding - tmp.length; i++) {
								appendWithIdx!(T)(ret, ptr++, paddingChar);
							}
						}
						bool noSign = false;
						if(altForm && form[idx] == 'x') {
							if(tmp[0] == '-' || tmp[0] == '+') {
								appendWithIdx!(T)(ret, ptr++, tmp[0]);
								noSign = true;
							}
							appendWithIdx!(T)(ret, ptr++, cast(immutable T)'0');
							appendWithIdx!(T)(ret, ptr++, cast(immutable T)'x');
						} else if(altForm && form[idx] == 'X') {
							if(tmp[0] == '-' || tmp[0] == '+') {
								appendWithIdx!(T)(ret, ptr++, tmp[0]);
								noSign = true;
							}
							appendWithIdx!(T)(ret, ptr++, cast(immutable T)'0');
							appendWithIdx!(T)(ret, ptr++, cast(immutable T)'X');
						} else if(altForm && form[idx] == 'o') {
							if(tmp[0] == '-' || tmp[0] == '+') {
								appendWithIdx!(T)(ret, ptr++, tmp[0]);
								noSign = true;
							}
							appendWithIdx!(T)(ret, ptr++, cast(immutable T)'0');
						}
						if(noSign) {
							tmp = tmp[1..$];
						}
						foreach(jt; tmp) 
							appendWithIdx!(T)(ret, ptr++, jt);
						
						if(tmp.length < padding && leftAlign) {
							for(size_t i = 0; i < padding - tmp.length; i++) {
								appendWithIdx!(T)(ret, ptr++, paddingChar);
							}
						}
						break parse;
					}
					case 'b': // string
						if(arguments[argPtr] == typeid(bool)) {
							bool b = va_arg!(bool)(arg);
							immutable(char)[] value = conv!(bool,string)(b);
							assert(value == "true" || value == "false");
							immutable(T) paddingChar = padding0 ? '0' : ' ';
							//debug writeln(__FILE__,__LINE__,": ", padding);
							if(value.length < padding && !leftAlign) {
								for(size_t i = 0; i < padding - value.length; 
										i++) {
									appendWithIdx!(T)(ret, ptr++, paddingChar);
								}
							}
							////debug writeln(__FILE__,__LINE__,": ", value);
							foreach(it; value) {
								appendWithIdx!(T)(ret, ptr++, cast(immutable T)it);
							}
							argPtr++;
						}
						break parse;
					case 's': // string
						if(arguments[argPtr] == typeid(immutable(char)[])) {
							immutable(char)[] value = va_arg!(immutable(char)[])(arg);
							immutable(T) paddingChar = padding0 ? '0' : ' ';
							//debug writeln(__FILE__,__LINE__,": ", padding);
							if(value.length < padding && !leftAlign) {
								for(size_t i = 0; i < padding - value.length; 
										i++) {
									appendWithIdx!(T)(ret, ptr++, paddingChar);
								}
							}
							////debug writeln(__FILE__,__LINE__,": ", value);
							foreach(it; value) {
								appendWithIdx!(T)(ret, ptr++, cast(immutable T)it);
							}
							argPtr++;
						} else if(arguments[argPtr] == 
								typeid(immutable(wchar)[])) {
							immutable(char)[] value = 
								toUTF8(va_arg!(immutable(wchar)[])(arg));
							immutable(T) paddingChar = padding0 ? '0' : ' ';
							//debug writeln(__FILE__,__LINE__,": ", padding);
							if(value.length < padding && !leftAlign) {
								for(size_t i = 0; i < padding - value.length; 
										i++) {
									appendWithIdx!(T)(ret, ptr++, paddingChar);
								}
							}
							////debug writeln(__FILE__,__LINE__,": ", value);
							foreach(it; value) {
								appendWithIdx!(T)(ret, ptr++, cast(immutable T)it);
							}
							argPtr++;
						} else if(arguments[argPtr] == 
								typeid(immutable(dchar)[])) {
							immutable(char)[] value = 
								toUTF8(va_arg!(immutable(dchar)[])(arg));
							immutable(T) paddingChar = padding0 ? '0' : ' ';
							//debug writeln(__FILE__,__LINE__,": ", padding);
							if(value.length < padding && !leftAlign) {
								for(size_t i = 0; i < padding - value.length; 
										i++) {
									appendWithIdx!(T)(ret, ptr++, paddingChar);
								}
							}
							////debug writeln(__FILE__,__LINE__,": ", value);
							foreach(it; value) {
								appendWithIdx!(T)(ret, ptr++, cast(immutable T)it);
							}
							argPtr++;
						}
						break parse;
					case 'e': // double as exponent 1.4e44
						expCap = false;
						skipExpCap = true;
					case 'E': // double as exponent 1.4E44
						//debug writeln(__FILE__,__LINE__,": Exponent ", precision, " ", padding, " ", arguments[argPtr].toString(), arg);
						immutable(T)[] tmp;
						if(!skipExpCap) {
							expCap = true;
						}
						if(arguments[argPtr] == typeid(float)) {
							float value = va_arg!(float)(arg);
							//debug writeln(__FILE__,__LINE__,": ", value," ", precision," ", expCap);
							tmp = floatToExponent!(T,float)(value, precision, alwaysSign, expCap);
							//debug writeln(__FILE__,__LINE__,": ", tmp);
						} else if(arguments[argPtr] == typeid(double)) {
							double value = va_arg!(double)(arg);
							//debug writeln(__FILE__,__LINE__,": ", value," ", precision," ", expCap);
							tmp = floatToExponent!(T,double)(value, precision, alwaysSign, expCap);
							//debug writeln(__FILE__,__LINE__,": ", tmp);
						} else if(arguments[argPtr] == typeid(real)) {
							real value = va_arg!(real)(arg);
							//debug writeln(__FILE__,__LINE__,": ", value," ", precision," ", expCap);
							tmp = floatToExponent!(T,real)(value, precision, alwaysSign, expCap);
							//debug writeln(__FILE__,__LINE__,": ", tmp);
						} else {
							throw new FormatError("an float was expected but value was a " 
								~ (arguments[argPtr].toString()));
						}
						argPtr++;
						immutable(T) paddingChar = padding0 ? '0' : ' ';
						//debug writeln(__FILE__,__LINE__,": ", padding);
						if(tmp.length < padding && !leftAlign) {
							for(size_t i = 0; i < padding - tmp.length; i++) {
								appendWithIdx!(T)(ret, ptr++, paddingChar);
							}
						}
						foreach(jt; tmp) 
							appendWithIdx!(T)(ret, ptr++, jt);

						if(tmp.length < padding && leftAlign) {
							for(size_t i = 0; i < padding - tmp.length; i++) {
								appendWithIdx!(T)(ret, ptr++, paddingChar);
							}
						}
						break parse;
					case 'f': // double as decimal
						//debug writeln(__FILE__,__LINE__,": float ", precision, " ", padding, " ", arguments[argPtr].toString(), arg);
						immutable(T)[] tmp;
						if(arguments[argPtr] == typeid(float)) {
							float value = va_arg!(float)(arg);
							//debug writeln(__FILE__,__LINE__,": ", value," ", precision);
							tmp = floatToString!(T,float)(value, precision, alwaysSign);
							//debug writeln(__FILE__,__LINE__,": ", tmp);
						} else if(arguments[argPtr] == typeid(double)) {
							double value = va_arg!(double)(arg);
							//debug writeln(__FILE__,__LINE__,": ", value," ", precision);
							tmp = floatToString!(T,double)(value, precision, alwaysSign);
							//debug writeln(__FILE__,__LINE__,": ", tmp);
						} else if(arguments[argPtr] == typeid(real)) {
							real value = va_arg!(real)(arg);
							//debug writeln(__FILE__,__LINE__,": ", value," ", precision);
							tmp = floatToString!(T,real)(value, precision, alwaysSign);
							//debug writeln(__FILE__,__LINE__,": ", tmp);
						} else {
							throw new FormatError("an float was expected but value was a " 
								~ (arguments[argPtr].toString()));
						}
						argPtr++;
						immutable(T) paddingChar = padding0 ? '0' : ' ';
						//debug writeln(__FILE__,__LINE__,": ", padding);
						if(tmp.length < padding && !leftAlign) {
							for(size_t i = 0; i < padding - tmp.length; i++) {
								appendWithIdx!(T)(ret, ptr++, paddingChar);
							}
						}
						foreach(jt; tmp) 
							appendWithIdx!(T)(ret, ptr++, jt);

						if(tmp.length < padding && leftAlign) {
							for(size_t i = 0; i < padding - tmp.length; i++) {
								appendWithIdx!(T)(ret, ptr++, paddingChar);
							}
						}
						break parse;
					case 'P': // print pointer adress as hex
						break;
					case 'c': // print int as c. %c, 'a' prints a
						immutable(T)[] tmp = "";
						if(arguments[argPtr] == typeid(char)) {
							char value = va_arg!(char)(arg);
							//debug writeln(__FILE__,__LINE__,": ", value," ", precision);
							tmp ~= value;
						} else if(arguments[argPtr] == typeid(wchar)) {
							wchar value = va_arg!(wchar)(arg);
							//debug writeln(__FILE__,__LINE__,": ", value," ", precision);
							tmp ~= conv!(wchar,string)(value);
						} else if(arguments[argPtr] == typeid(dchar)) {
							dchar value = va_arg!(dchar)(arg);
							//debug writeln(__FILE__,__LINE__,": ", value," ", precision);
							tmp ~= conv!(dchar,string)(value);
						}
						argPtr++;
						immutable(T) paddingChar = padding0 ? '0' : ' ';
						if(tmp.length < padding && !leftAlign) {
							for(size_t i = 0; i < padding - tmp.length; i++) {
								appendWithIdx!(T)(ret, ptr++, paddingChar);
							}
						}
						foreach(jt; tmp) 
							appendWithIdx!(T)(ret, ptr++, jt);

						if(tmp.length < padding && leftAlign) {
							for(size_t i = 0; i < padding - tmp.length; i++) {
								appendWithIdx!(T)(ret, ptr++, paddingChar);
							}
						}
						break parse;
					case 'a': 
						immutable(T)[] tmp;
						Object value;
						//if(is(arguments[argPtr] : Object)) {
							value = va_arg!(Object)(arg);	
							//tmp = value.toString();
							tmp = integerToString!(T,long)(cast(long)&value,16,false,true);	
						/*} else {
							throw new FormatError("A class was expected" 
								~ (arguments[argPtr].toString()));
						}*/
						//writeln(__LINE__, tmp, " ",tmp.length," ", cast(long)&value);
						argPtr++;
						immutable(T) paddingChar = padding0 ? '0' : ' ';
						//debug writeln(__FILE__,__LINE__,": ", padding);
						if(tmp.length < padding && !leftAlign) {
							for(size_t i = 0; i < padding - tmp.length; i++) {
								appendWithIdx!(T)(ret, ptr++, paddingChar);
							}
						}
						foreach(jt; tmp) 
							appendWithIdx!(T)(ret, ptr++, jt);

						if(tmp.length < padding && leftAlign) {
							for(size_t i = 0; i < padding - tmp.length; i++) {
								appendWithIdx!(T)(ret, ptr++, paddingChar);
							}
						}
						break parse;
					default:
						break;
				}
				idx++;
			}
		}

	}
	//writeln(__LINE__," ", ret[0..ptr]);
	return conv!(immutable(T)[],immutable(S)[])(ret[0..ptr].idup);
}

unittest {
	assert("hello" == format!(char,char)("hello"));
	assert("hello5" == format!(char,char)("hello%d", 5), format!(char,char)("hello%d", 5));
	assert("hello  5" == format!(char,char)("hello%*d", 3, 5), format!(char,char)("hello%*d", 3, 5));
	assert("hello+5" == format!(char,char)("hello%+d", 5), format!(char,char)("hello%+d", 5));
	assert("hello+5" == format!(char,char)("hello%+o", 5), format!(char,char)("hello%+o", 5));
	assert("hello+05" == format!(char,char)("hello%#+o", 5), format!(char,char)("hello%#+o", 5));
	assert("hello+5" == format!(char,char)("hello%+X", 5), format!(char,char)("hello%+X", 5));
	assert("hello+5" == format!(char,char)("hello%+x", 5), format!(char,char)("hello%+x", 5));
	assert("hello+A" == format!(char,char)("hello%+X", 10), format!(char,char)("hello%+X", 10));
	assert("hello+a" == format!(char,char)("hello%+x", 10), format!(char,char)("hello%+x", 10));
	assert("hello+0XA" == format!(char,char)("hello%#+X", 10), format!(char,char)("hello%#+X", 10));
	assert("hello+0xa" == format!(char,char)("hello%#+x", 10), format!(char,char)("hello%#+x", 10));
	assert("hello10" == format!(char,char)("hello%o", 8), format!(char,char)("hello%o", 8));
	assert("hello 10" == format!(char,char)("hello %o", 8), format!(char,char)("hello %o", 8));
	assert("hello10.0" == format!(char,char)("hello%.1f", 10.0), format!(char,char)("hello%.1f", 10.0));
	assert("hello 10.00" == format!(char,char)("hello %.2f", 10.0), format!(char,char)("hello %.2f", 10.0));
	assert("hello   10.00" == format!(char,char)("hello %7.2f", 10.0), format!(char,char)("hello %7.2f", 10.0));
	assert("hello 0010.00" == format!(char,char)("hello %07.2f", 10.0), format!(char,char)("hello %07.2f", 10.0));
	assert("hello 10.00  " == format!(char,char)("hello %-7.2f", 10.0), format!(char,char)("hello %-7.2f", 10.0));
	assert("hello 5.000" == format!(char,char)("hello%*.*f", 6, 3, 5.0), format!(char,char)("hello%*.*f", 6, 3, 5.0));
	assert("hello   5.000" == format!(char,char)("hello%*.*f", 8, 3, 5.0), format!(char,char)("hello%*.*f", 8, 3, 5.0));
	assert("hello 5.0e0" == format!(char,char)("hello %.1e", 5.0), format!(char,char)("hello %.1e", 5.0));
	assert("hello 5.0E0" == format!(char,char)("hello %.1E", 5.0), format!(char,char)("hello %.1E", 5.0));
}
