module hurt.conv.tointeger;

import hurt.conv.convutil;
import hurt.conv.conv;
import hurt.conv.chartonumeric;
import hurt.exception.valuerangeexception;
import hurt.math.mathutil;

import std.stdio;
//import std.conv;

public pure T hexStrToInt(T=int,S=char)(immutable(S)[] str) {
	return conv!(long,T)(toLong!(S)(str));
}

public pure T stringToInt(T,S)(immutable(S)[] str, int multi = 10) 
		if(is(S == char) || is(S == wchar) || is(S == dchar)) {
	if(multi == 16) {
		return conv!(long,T)(toLong!(S)(str));
	}
	T ret = 0;
	T mul = 1;	
	T tmp;
	bool neg = false;
		
	foreach_reverse(S it; str) {
		// ignore underscores
		if(it == '_') 
			continue;

		// panic if char isn't a digit
		if(!isDigit(it)) {
			if(it == '-') {
				neg = true;
				continue;
			} else if(it == '+') {
				continue;
			} else {
				assert(0, "is not digit nor sign " ~ conv!(S,char)(it));
			}
		}

		// construct the number
		tmp = chartobase10(it) * mul;	
		ret += tmp;
		mul *= multi;
	}
	if(neg)
		return -ret;
	else
		return ret;
}

public pure long toLong(T)(immutable(T)[] digits, uint radix=0) {
	size_t len;
	
	auto x = parse(digits, radix, &len);
	if(len < digits.length) {
		throw new Exception ("Integer.toLong :: invalid literal");
	}
	return x;
}

public pure long parse(T, U=uint)(immutable(T)[] digits, U radix=0, size_t* ate=null) {
	return parse!(T)(digits, radix, ate);
}

public pure long parse(T)(T[] digits, uint radix=0, size_t* ate=null) {
	bool sign;

	auto eaten = trim(digits, sign, radix);
	auto value = convert(digits[eaten..$], radix, ate);

	// check *ate > 0 to make sure we don't parse "-" as 0.
	if(ate && *ate > 0) {
		*ate += eaten;
	}

	return cast(long) (sign ? -value : value);
}

public pure ulong convert(T, U=uint)(immutable(T)[] digits, U radix=10, size_t* ate=null) {
	return convert!(T)(digits, radix, ate);
}

public pure ulong convert(T)(immutable(T)[] digits, uint radix=10, size_t* ate=null) {
	uint  eaten;
	ulong value;
	T[] run = digits.dup;

	foreach(c; run) {
		if(c >= '0' && c <= '9') {
		} else {
			if(c >= 'a' && c <= 'z') {
				c -= 39;
			} else {
				if(c >= 'A' && c <= 'Z') {
					c -= 7;
				} else {
					break;
				}
			}
		}

		if((c -= '0') < radix) {
			value = value * radix + c;
			++eaten;
		} else {
			break;
		}
	}

	if(ate) {
		*ate = eaten;
	}

	return value;
}

public pure size_t trim(T, U=uint)(immutable(T)[] digits, ref bool sign, ref U radix) {
	return trim!(T)(digits, sign, radix);
}

public pure size_t trim(T)(immutable(T)[] digits, ref bool sign, ref uint radix) {
	size_t idx = 0;
	radix = 10;
	bool nBreak = false;
	foreach(T c; digits) {
		if(c == '-') {
			sign = true;
		} else if(c == '+') {
			sign = false;
		} else if(c == ' ' || c == '\t') {
		} else if(c == 'x' || c == 'X') {
			radix = 16;
			nBreak = true;
		} else if(c == 'b' || c == 'B') {
			radix = 2;
			nBreak = true;
		} else if(c == 'o' || c == 'O') {
			radix = 8;
			nBreak = true;
		}
		idx++;
		if(nBreak) {
			break;
		}
	}
	return idx;
}

unittest {
	assert(stringToInt!(int)("100") == 100);
	assert(stringToInt!(int)("589") == 589);
	assert(stringToInt!(int)("-100") == -100);
	assert(stringToInt!(int)("-589") == -589);
	assert(stringToInt!(int)("10",8) == 8);
	assert(stringToInt!(int)("12",8) == 10);
	assert(stringToInt!(int)("22",8) == 18);
}

public pure uint longToUint(long from) {
	if(from < 0) {
		throw new ValueRangeException("long value " ~ conv!(long,string)(from) 
			~ " doesn't fit into uint");
	} else if(from > uint.max) {
		throw new ValueRangeException("long value " ~ conv!(long,string)(from) 
			~ " doesn't fit into uint");
	} else {
		return cast(uint)from;
	}
}

public pure int longToInt(long from) {
	if(from < int.min) {
		throw new ValueRangeException("long value " ~ conv!(long,string)(from) 
			~ " doesn't fit into uint");
	} else if(from > int.max) {
		throw new ValueRangeException("long value " ~ conv!(long,string)(from) 
			~ " doesn't fit into uint");
	} else {
		return cast(int)from;
	}
}

public pure uint ulongToUint(ulong from) {
	if(from > uint.max) {
		throw new ValueRangeException("long value " ~ conv!(long,string)(from) 
			~ " doesn't fit into uint");
	} else {
		return cast(uint)from;
	}
}

private S getMin(S)() {
	static if(isFloat!(S)) {
		return S.min_normal;
	} else {
		return S.min;
	}
}

public pure S tToS(T,S)(T t, string file = __FILE__, int line = __LINE__) 
		if(isNumeric!(T) && isNumeric!(S)) {
	if(smaller!(T,S)(t,getMin!(S))) {
		throw new ValueRangeException(file ~ ":" 
			~ conv!(int,string)(line) ~ " " ~ conv!(T,string)(t) ~ 
			" doesn't fit, value is to small for " ~
			conv!(S,string)(getMin!(S)));
	} else if(bigger!(T,S)(t,S.max)) {
		throw new ValueRangeException(file ~ ":" 
			~ conv!(int,string)(line) ~ " " ~ conv!(T,string)(t) ~ 
			" doesn't fit, value is to big for " ~ conv!(S,string)(S.max));
	} else {
		return cast(S)t;
	}
}

unittest {
	assert(0 == tToS!(int,long)(0));
	assert(0 == tToS!(short,long)(0));
	assert(0 == tToS!(byte,long)(0));
	assert(0 == tToS!(long,long)(0));
	assert(0 == tToS!(uint,long)(0U));
	assert(0 == tToS!(ushort,long)(0U));
	assert(0 == tToS!(ubyte,long)(0U));
	assert(0 == tToS!(ulong,long)(0U));
	assert(0 == tToS!(int,int)(0));
	assert(0 == tToS!(short,int)(0));
	assert(0 == tToS!(byte,int)(0));
	assert(0 == tToS!(long,int)(0));
	assert(0 == tToS!(uint,int)(0U));
	assert(0 == tToS!(ushort,int)(0U));
	assert(0 == tToS!(ubyte,int)(0U));
	assert(0 == tToS!(ulong,int)(0U));
	assert(0 == tToS!(int,short)(0));
	assert(0 == tToS!(short,short)(0));
	assert(0 == tToS!(byte,short)(0));
	assert(0 == tToS!(long,short)(0));
	assert(0 == tToS!(uint,short)(0U));
	assert(0 == tToS!(ushort,short)(0U));
	assert(0 == tToS!(ubyte,short)(0U));
	assert(0 == tToS!(ulong,short)(0U));
	assert(0 == tToS!(int,byte)(0));
	assert(0 == tToS!(short,byte)(0));
	assert(0 == tToS!(byte,byte)(0));
	assert(0 == tToS!(long,byte)(0));
	assert(0 == tToS!(uint,byte)(0U));
	assert(0 == tToS!(ushort,byte)(0U));
	assert(0 == tToS!(ubyte,byte)(0U));
	assert(0 == tToS!(ulong,byte)(0U));
	assert(0U == tToS!(int,ulong)(0));
	assert(0U == tToS!(short,ulong)(0));
	assert(0U == tToS!(byte,ulong)(0));
	assert(0U == tToS!(long,ulong)(0));
	assert(0U == tToS!(uint,ulong)(0U));
	assert(0U == tToS!(ushort,ulong)(0U));
	assert(0U == tToS!(ubyte,ulong)(0U));
	assert(0U == tToS!(ulong,ulong)(0U));
	assert(0U == tToS!(int,uint)(0));
	assert(0U == tToS!(short,uint)(0));
	assert(0U == tToS!(byte,uint)(0));
	assert(0U == tToS!(long,uint)(0));
	assert(0U == tToS!(uint,uint)(0U));
	assert(0U == tToS!(ushort,uint)(0U));
	assert(0U == tToS!(ubyte,uint)(0U));
	assert(0U == tToS!(ulong,uint)(0U));
	assert(0U == tToS!(int,ushort)(0));
	assert(0U == tToS!(short,ushort)(0));
	assert(0U == tToS!(byte,ushort)(0));
	assert(0U == tToS!(long,ushort)(0));
	assert(0U == tToS!(uint,ushort)(0U));
	assert(0U == tToS!(ushort,ushort)(0U));
	assert(0U == tToS!(ubyte,ushort)(0U));
	assert(0U == tToS!(ulong,ushort)(0U));
	assert(0U == tToS!(int,ubyte)(0));
	assert(0U == tToS!(short,ubyte)(0));
	assert(0U == tToS!(byte,ubyte)(0));
	assert(0U == tToS!(long,ubyte)(0));
	assert(0U == tToS!(uint,ubyte)(0U));
	assert(0U == tToS!(ushort,ubyte)(0U));
	assert(0U == tToS!(ubyte,ubyte)(0U));
	assert(0U == tToS!(ulong,ubyte)(0U));
}
