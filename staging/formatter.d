module hurt.string.formatter;

import hurt.io.file;
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

public string makeString(int line = __LINE__, string file = __FILE__)(
		TypeInfo[] arguments, void* args) {
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
	return formatString!(char,char,line,file)(buf.getString(), arguments, args);
}

private bool isTypeOf(T)(TypeInfo given) {
	if(given == typeid(T) || given == typeid(const(T)) || 
			given == typeid(immutable(T))) {
		return true;
	} else {
		return false;
	}
}

private bool convertsTo(T)(TypeInfo given) {
	static if(is(T == char)) {
		return isTypeOf!(char)(given);
	} else static if(is(T == ubyte) || is(T == ushort) || is(T == uint) ||
			is(T == ulong) || is(T == byte) || is(T == short) || 
			is(T == int) || is(T == long)) {
		return isTypeOf!(int)(given) || isTypeOf!(byte)(given) || 
			isTypeOf!(short)(given) || isTypeOf!(long)(given) || 
			isTypeOf!(uint)(given) || isTypeOf!(ubyte)(given) || 
			isTypeOf!(ushort)(given) || isTypeOf!(ulong)(given);
	} else static if(is(T == float) || is(T == double) || is(T == real)) {
		return isTypeOf!(float)(given) || isTypeOf!(double)(given) || 
			isTypeOf!(real)(given);
	} else {
		return false;
	}
}

public immutable(S)[] format(T = char,S = char, int line = __LINE__,
		string file = __FILE__)(immutable(T)[] form, ...) {
	return formatString!(T,S,line,file)(form, _arguments, _argptr);
}

public immutable(S)[] formatString(T = char,S = char, int line = __LINE__,
		string file = __FILE__)(immutable(T)[] form, TypeInfo[] arguments, 
		void* arg)
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
							if(convertsTo!(int)(arguments[argPtr])) {
								if(isTypeOf!(int)(arguments[argPtr])) {
									padding = va_arg!(int)(arg);
								} else if(isTypeOf!(long)(arguments[argPtr])) {
									padding = conv!(long,int)
										(va_arg!(long)(arg));
								} else if(isTypeOf!(byte)(arguments[argPtr])) {
									padding = conv!(byte,int)
										(va_arg!(byte)(arg));
								} else if(isTypeOf!(short)(arguments[argPtr])) {
									padding = conv!(short,int)
										(va_arg!(short)(arg));
								} else if(isTypeOf!(ulong)(arguments[argPtr])) {
									padding = conv!(ulong,int)
										(va_arg!(long)(arg));
								} else if(isTypeOf!(ubyte)(arguments[argPtr])) {
									padding = conv!(ubyte,int)
										(va_arg!(byte)(arg));
								} else if(isTypeOf!(ushort)
										(arguments[argPtr])) {
									padding = conv!(ushort,int)
										(va_arg!(short)(arg));
								}

								argPtr++;
							} else {
								throw new IllegalArgumentException(
									"Expected an int not an " 
									~ arguments[argPtr].toString() ~ 
									": called from " ~ file ~ ":" ~
									conv!(int,string)(line));
							}
						}
						break;
					}
					case '.': {
						idx++;
						if(idx < form.length && form[idx] == '*') {
							if(convertsTo!(int)(arguments[argPtr])) {
								if(isTypeOf!(int)(arguments[argPtr])) {
									precision = va_arg!(int)(arg);
								} else if(isTypeOf!(long)(arguments[argPtr])) {
									precision = conv!(long,int)
										(va_arg!(long)(arg));
								} else if(isTypeOf!(byte)(arguments[argPtr])) {
									precision = conv!(byte,int)
										(va_arg!(byte)(arg));
								} else if(isTypeOf!(short)(arguments[argPtr])) {
									precision = conv!(short,int)
										(va_arg!(short)(arg));
								} else if(isTypeOf!(ulong)(arguments[argPtr])) {
									precision = conv!(ulong,int)
										(va_arg!(long)(arg));
								} else if(isTypeOf!(ubyte)(arguments[argPtr])) {
									precision = conv!(ubyte,int)
										(va_arg!(byte)(arg));
								} else if(isTypeOf!(ushort)
										(arguments[argPtr])) {
									precision = conv!(ushort,int)
										(va_arg!(short)(arg));
								}
								argPtr++;
							} else {
								throw new IllegalArgumentException(
									"Expected an int not an " 
									~ arguments[argPtr].toString() ~ 
									": called from " ~ file ~ ":" ~
									conv!(int,string)(line));
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
						continue;
					case 'l': // to cent
						if(idx+1 < form.length && form[idx+1] == 'n') {
							assert(0, "long to cent not yet implemented");
						} else if(idx+2 < form.length && form[idx+1] == 's') {
							assert(0, "long to ucent not yet implemented");

						}
						continue;
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
						continue;
					case 'j': // int to int.max or uint.max
						break;
					case 'z': // int to size_t.max or ssize_t 
						break;
					case 't': // int to ptrdiff_t
						break;
					case '\'': // thousand interleaf
						kInterleaf = true;
						continue;
					case 'x': // unsigned integer as hex 
						base = 16;
						goto case 'd';
					case 'X': // unsigned integer as hex 
						title = true;
						base = 16;
						goto case 'd';
					case 'o': // unsigned integer as octal
						base = 8;
						goto case 'd';
					case 'u': // unsigned integer as decimal
					case 'i': // unsigned integer
					case 'd': {// signed integer
						immutable(T)[] tmp;
						if(isTypeOf!(int)(arguments[argPtr])) {
							int value = va_arg!(int)(arg);
							tmp = integerToString!(T,int)(value, base, 
								alwaysSign, title);
						} else if(isTypeOf!(uint)(arguments[argPtr])) {
							uint value = va_arg!(uint)(arg);
							tmp = integerToString!(T,uint)(value, base, 
								alwaysSign, title);
						} else if(isTypeOf!(ubyte)(arguments[argPtr])) {
							ubyte value = va_arg!(ubyte)(arg);
							tmp = integerToString!(T,ubyte)(value, base, 
								alwaysSign, title);
						} else if(isTypeOf!(byte)(arguments[argPtr])) {
							byte value = va_arg!(byte)(arg);
							tmp = integerToString!(T,byte)(value, base, 
								alwaysSign, title);
						} else if(isTypeOf!(ubyte)(arguments[argPtr])) {
							ushort value = va_arg!(ushort)(arg);
							tmp = integerToString!(T,ushort)(value, base, 
								alwaysSign, title);
						} else if(isTypeOf!(short)(arguments[argPtr])) {
							short value = va_arg!(short)(arg);
							tmp = integerToString!(T,short)(value, base, 
								alwaysSign, title);
						} else if(isTypeOf!(ulong)(arguments[argPtr])) {
							ulong value = va_arg!(ulong)(arg);
							tmp = integerToString!(T,ulong)(value, base, 
								alwaysSign, title);
						} else if( isTypeOf!(long)(arguments[argPtr])) {
							long value = va_arg!(long)(arg);
							tmp = integerToString!(T,long)(value, base, 
								alwaysSign, title);
						} else {
							throw new FormatError("an integer was expected but "
								~ "value was a " ~ 
								(arguments[argPtr].toString()) ~ 
								": called from " ~ file ~ ":" ~
								conv!(int,string)(line));
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
						if(isTypeOf!(bool)(arguments[argPtr])){
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
							foreach(it; value) {
								appendWithIdx!(T)(ret, ptr++, 
									cast(immutable T)it);
							}
							argPtr++;
						}
						break parse;
					case 's': // string
						if(isTypeOf!(string)(arguments[argPtr])) {
							immutable(char)[] value = va_arg!(immutable(char)[])
								(arg);
							immutable(T) paddingChar = padding0 ? '0' : ' ';
							//debug writeln(__FILE__,__LINE__,": ", value);
							if(value.length < padding && !leftAlign) {
								for(size_t i = 0; i < padding - value.length; 
										i++) {
									appendWithIdx!(T)(ret, ptr++, paddingChar);
								}
							}
							foreach(it; value) {
								appendWithIdx!(T)(ret, ptr++, 
									cast(immutable T)it);
							}
							argPtr++;
						} else if(isTypeOf!(wstring)(arguments[argPtr])) {
							immutable(char)[] value = 
								toUTF8(va_arg!(immutable(wchar)[])(arg));

							immutable(T) paddingChar = padding0 ? '0' : ' ';
							if(value.length < padding && !leftAlign) {
								for(size_t i = 0; i < padding - value.length; 
										i++) {
									appendWithIdx!(T)(ret, ptr++, paddingChar);
								}
							}
							foreach(it; value) {
								appendWithIdx!(T)(ret, ptr++, 
									cast(immutable T)it);
							}
							argPtr++;
						} else if( isTypeOf!(dstring)(arguments[argPtr])) {
							immutable(char)[] value = 
								toUTF8(va_arg!(immutable(dchar)[])(arg));
							immutable(T) paddingChar = padding0 ? '0' : ' ';

							if(value.length < padding && !leftAlign) {
								for(size_t i = 0; i < padding - value.length; 
										i++) {
									appendWithIdx!(T)(ret, ptr++, paddingChar);
								}
							}

							foreach(it; value) {
								appendWithIdx!(T)(ret, ptr++, 
									cast(immutable T)it);
							}
							argPtr++;
						}
						break parse;
					case 'e': // double as exponent 1.4e44
						expCap = false;
						skipExpCap = true;
						goto case 'E';
					case 'E': // double as exponent 1.4E44
						immutable(T)[] tmp;
						if(!skipExpCap) {
							expCap = true;
						}
						if(isTypeOf!(float)(arguments[argPtr])) {
							float value = va_arg!(float)(arg);
							tmp = floatToExponent!(T,float)(value, precision, 
								alwaysSign, expCap);
						} else if(isTypeOf!(double)(arguments[argPtr])) {
							double value = va_arg!(double)(arg);
							tmp = floatToExponent!(T,double)(value, precision, 
								alwaysSign, expCap);
						} else if(isTypeOf!(real)(arguments[argPtr])) {
							real value = va_arg!(real)(arg);
							tmp = floatToExponent!(T,real)(value, precision, 
								alwaysSign, expCap);
						} else {
							throw new FormatError(
								"an float was expected but value was a " 
								~ (arguments[argPtr].toString()) ~ 
								": called from " ~ file ~ ":" ~
								conv!(int,string)(line));
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
					case 'f': // double as decimal
						immutable(T)[] tmp;
						if(isTypeOf!(float)(arguments[argPtr])) {
							float value = va_arg!(float)(arg);
							tmp = floatToString!(T,float)(value, precision, 
								alwaysSign);
						} else if(isTypeOf!(double)(arguments[argPtr])) {
							double value = va_arg!(double)(arg);
							tmp = floatToString!(T,double)(value, precision, 
								alwaysSign);
						} else if(isTypeOf!(real)(arguments[argPtr])) {
							real value = va_arg!(real)(arg);
							tmp = floatToString!(T,real)(value, precision, 
								alwaysSign);
						} else {
							throw new FormatError(
								"an float was expected but value was a " 
								~ (arguments[argPtr].toString()) ~ 
								": called from " ~ file ~ ":" ~
								conv!(int,string)(line));
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
					case 'P': // print pointer adress as hex
						break;
					case 'c': // print int as c. %c, 'a' prints a
						immutable(T)[] tmp = "";
						if(isTypeOf!(char)(arguments[argPtr])) {
							char value = va_arg!(char)(arg);
							tmp ~= value;
						} else if(isTypeOf!(wchar)(arguments[argPtr])){
							wchar value = va_arg!(wchar)(arg);
							tmp ~= conv!(wchar,string)(value);
						} else if(isTypeOf!(dchar)(arguments[argPtr])) {
							dchar value = va_arg!(dchar)(arg);
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
							value = va_arg!(Object)(arg);	
							tmp = integerToString!(T,long)(cast(long)&value,16,
								false,true);	

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
					default:
						break;
				}
				idx++;
			}
		}

	}
	return conv!(immutable(T)[],immutable(S)[])(ret[0..ptr].idup);
}

unittest {
	assert("hello" == format!(char,char)("hello"));
	assert("hello5" == format!(char,char)("hello%d", 5), 
		format!(char,char)("hello%d", 5));
	assert("hello  5" == format!(char,char)("hello%*d", 3, 5), 
		format!(char,char)("hello%*d", 3, 5));
	assert("hello+5" == format!(char,char)("hello%+d", 5),
		format!(char,char)("hello%+d", 5));
	assert("hello+5" == format!(char,char)("hello%+o", 5),
		format!(char,char)("hello%+o", 5));
	assert("hello+05" == format!(char,char)("hello%#+o", 5),
		format!(char,char)("hello%#+o", 5));
	assert("hello+5" == format!(char,char)("hello%+X", 5),
		format!(char,char)("hello%+X", 5));
	assert("hello+5" == format!(char,char)("hello%+x", 5),
		format!(char,char)("hello%+x", 5));
	assert("hello+A" == format!(char,char)("hello%+X", 10),
		format!(char,char)("hello%+X", 10));
	assert("hello+a" == format!(char,char)("hello%+x", 10),
		format!(char,char)("hello%+x", 10));
	assert("hello+0XA" == format!(char,char)("hello%#+X", 10),
		format!(char,char)("hello%#+X", 10));
	assert("hello+0xa" == format!(char,char)("hello%#+x", 10),
		format!(char,char)("hello%#+x", 10));
	assert("hello10" == format!(char,char)("hello%o", 8),
		format!(char,char)("hello%o", 8));
	assert("hello 10" == format!(char,char)("hello %o", 8),
		format!(char,char)("hello %o", 8));
	assert("hello10.0" == format!(char,char)("hello%.1f", 10.0),
		format!(char,char)("hello%.1f", 10.0));
	assert("hello 10.00" == format!(char,char)("hello %.2f", 10.0),
		format!(char,char)("hello %.2f", 10.0));
	assert("hello   10.00" == format!(char,char)("hello %7.2f", 10.0),
		format!(char,char)("hello %7.2f", 10.0));
	assert("hello 0010.00" == format!(char,char)("hello %07.2f", 10.0),
		format!(char,char)("hello %07.2f", 10.0));
	assert("hello 10.00  " == format!(char,char)("hello %-7.2f", 10.0),
		format!(char,char)("hello %-7.2f", 10.0));
	assert("hello 5.000" == format!(char,char)("hello%*.*f", 6, 3, 5.0),
		format!(char,char)("hello%*.*f", 6, 3, 5.0));
	assert("hello   5.000" == format!(char,char)("hello%*.*f", 8, 3, 5.0),
		format!(char,char)("hello%*.*f", 8, 3, 5.0));
	assert("hello 5.0e0" == format!(char,char)("hello %.1e", 5.0),
		format!(char,char)("hello %.1e", 5.0));
	assert("hello 5.0E0" == format!(char,char)("hello %.1E", 5.0),
		format!(char,char)("hello %.1E", 5.0));

	// const
	assert("hello" == format!(char,char)("hello"));
	assert("hello5" == format!(char,char)("hello%d", cast(const)5), 
		format!(char,char)("hello%d", cast(const)5));
	assert("hello  5" == format!(char,char)("hello%*d", cast(const)3, 
		cast(const)5), format!(char,char)("hello%*d", cast(const)3, 
		cast(const)5));
	assert("hello+5" == format!(char,char)("hello%+d", cast(const)5),
		format!(char,char)("hello%+d", cast(const)5));
	assert("hello+5" == format!(char,char)("hello%+o", cast(const)5),
		format!(char,char)("hello%+o", cast(const)5));
	assert("hello+05" == format!(char,char)("hello%#+o", cast(const)5),
		format!(char,char)("hello%#+o", cast(const)5));
	assert("hello+5" == format!(char,char)("hello%+X", cast(const)5),
		format!(char,char)("hello%+X", cast(const)5));
	assert("hello+5" == format!(char,char)("hello%+x", cast(const)5),
		format!(char,char)("hello%+x", cast(const)5));
	assert("hello+A" == format!(char,char)("hello%+X", cast(const)10),
		format!(char,char)("hello%+X", cast(const)10));
	assert("hello+a" == format!(char,char)("hello%+x", cast(const)10),
		format!(char,char)("hello%+x", cast(const)10));
	assert("hello+0XA" == format!(char,char)("hello%#+X", cast(const)10),
		format!(char,char)("hello%#+X", cast(const)10));
	assert("hello+0xa" == format!(char,char)("hello%#+x", cast(const)10),
		format!(char,char)("hello%#+x", cast(const)10));
	assert("hello10" == format!(char,char)("hello%o", cast(const)8),
		format!(char,char)("hello%o", cast(const)8));
	assert("hello 10" == format!(char,char)("hello %o", cast(const)8),
		format!(char,char)("hello %o", cast(const)8));
	assert("hello10.0" == format!(char,char)("hello%.1f", cast(const)10.0),
		format!(char,char)("hello%.1f", cast(const)10.0));
	assert("hello 10.00" == format!(char,char)("hello %.2f", cast(const)10.0),
		format!(char,char)("hello %.2f", cast(const)10.0));
	assert("hello   10.00" == format!(char,char)("hello %7.2f", 
		cast(const)10.0), format!(char,char)("hello %7.2f", cast(const)10.0));
	assert("hello 0010.00" == format!(char,char)("hello %07.2f", 
		cast(const)10.0), format!(char,char)("hello %07.2f", cast(const)10.0));
	assert("hello 10.00  " == format!(char,char)("hello %-7.2f", 
		cast(const)10.0), format!(char,char)("hello %-7.2f", cast(const)10.0));
	assert("hello 5.000" == format!(char,char)("hello%*.*f", cast(const)6, 
		cast(const)3, cast(const)5.0), format!(char,char)("hello%*.*f", 
		cast(const)6, cast(const)3, cast(const)5.0));
	assert("hello   5.000" == format!(char,char)("hello%*.*f", cast(const)8, 
		cast(const)3, cast(const)5.0), format!(char,char)("hello%*.*f", 
		cast(const)8, cast(const)3, cast(const)5.0));
	assert("hello 5.0e0" == format!(char,char)("hello %.1e", cast(const)5.0),
		format!(char,char)("hello %.1e", cast(const)5.0));
	assert("hello 5.0E0" == format!(char,char)("hello %.1E", cast(const)5.0),
		format!(char,char)("hello %.1E", cast(const)5.0));

	assert("hello5" == format!(char,char)("hello%d", cast(const(byte))5), 
		format!(char,char)("hello%d", cast(const(byte))5));
	assert("hello  5" == format!(char,char)("hello%*d", cast(const(byte))3, 
		cast(const(byte))5), format!(char,char)("hello%*d", cast(const(byte))3, 
		cast(const(byte))5));
	assert("hello+5" == format!(char,char)("hello%+d", cast(const(byte))5),
		format!(char,char)("hello%+d", cast(const(byte))5));
	assert("hello+5" == format!(char,char)("hello%+o", cast(const(byte))5),
		format!(char,char)("hello%+o", cast(const(byte))5));
	assert("hello+05" == format!(char,char)("hello%#+o", cast(const(byte))5),
		format!(char,char)("hello%#+o", cast(const(byte))5));
	assert("hello+5" == format!(char,char)("hello%+X", cast(const(byte))5),
		format!(char,char)("hello%+X", cast(const(byte))5));
	assert("hello+5" == format!(char,char)("hello%+x", cast(const(byte))5),
		format!(char,char)("hello%+x", cast(const(byte))5));
	assert("hello+A" == format!(char,char)("hello%+X", cast(const(byte))10),
		format!(char,char)("hello%+X", cast(const(byte))10));
	assert("hello+a" == format!(char,char)("hello%+x", cast(const(byte))10),
		format!(char,char)("hello%+x", cast(const(byte))10));
	assert("hello+0XA" == format!(char,char)("hello%#+X", cast(const(byte))10),
		format!(char,char)("hello%#+X", cast(const(byte))10));
	assert("hello+0xa" == format!(char,char)("hello%#+x", cast(const(byte))10),
		format!(char,char)("hello%#+x", cast(const(byte))10));
	assert("hello10" == format!(char,char)("hello%o", cast(const(byte))8),
		format!(char,char)("hello%o", cast(const(byte))8));
	assert("hello 10" == format!(char,char)("hello %o", cast(const(byte))8),
		format!(char,char)("hello %o", cast(const(byte))8));
}

version(staging) {
void main() {
	//for(int k = 0; k < 8; k++) {
		//for(int i = 0; i < 10; i++) {
			//for(int j = 0; j < 10; j++) {
				//string s = format("%c[%d;%d;%dm", cast(char)0x1B, k, 30+j, 40 + i);
				//string g = format("Hello %d %d %d\n", k, i, j);
				//string s = "^[5;34;42m In color";
				//writeC(0, s.ptr, s.length);
				//writeC(0, g.ptr, g.length);
			//}
		//}
	//}
	string s = format("%c[%d;%d;%dmHello\n", cast(char)0x1B, 1, 31, 49);
	//string g = format("Hello %d %d %d\n", k, i, j);
	writeC(0, s.ptr, s.length);
	s = format("%c[%d;%d;%dmHello\n", cast(char)0x1B, 0, 31, 49);
	writeC(0, s.ptr, s.length);
	//writeC(0, g.ptr, g.length);
	return;
}
}
