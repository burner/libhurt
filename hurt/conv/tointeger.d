module hurt.conv.tointeger;

import hurt.conv.convutil;
import hurt.conv.conv;
import hurt.conv.chartonumeric;
import hurt.exception.valuerangeexception;
import hurt.math.mathutil;

public pure T stringToInt(T)(in string str) {
	T ret = 0;
	T mul = 1;	
	T tmp;
		
	foreach_reverse(it; str) {
		// ignore underscores
		if(it == '_') continue;

		// panic if char isn't a digit
		if(!isDigit(it)) {
			assert(0, "is not digit");
		}

		// construct the number
		tmp = chartobase10(it) * mul;	
		ret += tmp;
		mul *= 10;
	}
	return ret;
}

public pure uint longToUint(long from) {
	if(from < 0) {
		throw new ValueRangeException("long value " ~ conv!(long,string)(from) ~ 
			" doesn't fit into uint");
	} else if(from > uint.max) {
		throw new ValueRangeException("long value " ~ conv!(long,string)(from) ~ 
			" doesn't fit into uint");
	} else {
		return cast(uint)from;
	}
}

public pure int longToInt(long from) {
	if(from < int.min) {
		throw new ValueRangeException("long value " ~ conv!(long,string)(from) ~ 
			" doesn't fit into uint");
	} else if(from > int.max) {
		throw new ValueRangeException("long value " ~ conv!(long,string)(from) ~ 
			" doesn't fit into uint");
	} else {
		return cast(int)from;
	}
}

public pure int ulongToUint(ulong from) {
	if(from > uint.max) {
		throw new ValueRangeException("long value " ~ conv!(long,string)(from) ~ 
			" doesn't fit into uint");
	} else {
		return cast(uint)from;
	}
}

public pure S tToS(T,S)(T t) if(isNumeric!(T) && isNumeric!(S)()) {
	if(smaller!(T,S)(t,S.min)) {
		throw new ValueRangeException(__FILE__ ~ ":" 
			~ conv!(int,string)(__LINE__) ~ " " ~ conv!(T,string)(t) ~ 
			" doesn't fit, value is to small for " ~ conv!(S,string)(S.min));
	} else if(bigger!(T,S)(t,S.max)) {
		throw new ValueRangeException(__FILE__ ~ ":" 
			~ conv!(int,string)(__LINE__) ~ " " ~ conv!(T,string)(t) ~ 
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
	assert(0 == tToS!(int,ulong)(0));
	assert(0 == tToS!(short,ulong)(0));
	assert(0 == tToS!(byte,ulong)(0));
	assert(0 == tToS!(long,ulong)(0));
	assert(0 == tToS!(uint,ulong)(0U));
	assert(0 == tToS!(ushort,ulong)(0U));
	assert(0 == tToS!(ubyte,ulong)(0U));
	assert(0 == tToS!(ulong,ulong)(0U));
	assert(0 == tToS!(int,uint)(0));
	assert(0 == tToS!(short,uint)(0));
	assert(0 == tToS!(byte,uint)(0));
	assert(0 == tToS!(long,uint)(0));
	assert(0 == tToS!(uint,uint)(0U));
	assert(0 == tToS!(ushort,uint)(0U));
	assert(0 == tToS!(ubyte,uint)(0U));
	assert(0 == tToS!(ulong,uint)(0U));
	assert(0 == tToS!(int,ushort)(0));
	assert(0 == tToS!(short,ushort)(0));
	assert(0 == tToS!(byte,ushort)(0));
	assert(0 == tToS!(long,ushort)(0));
	assert(0 == tToS!(uint,ushort)(0U));
	assert(0 == tToS!(ushort,ushort)(0U));
	assert(0 == tToS!(ubyte,ushort)(0U));
	assert(0 == tToS!(ulong,ushort)(0U));
	assert(0 == tToS!(int,ubyte)(0));
	assert(0 == tToS!(short,ubyte)(0));
	assert(0 == tToS!(byte,ubyte)(0));
	assert(0 == tToS!(long,ubyte)(0));
	assert(0 == tToS!(uint,ubyte)(0U));
	assert(0 == tToS!(ushort,ubyte)(0U));
	assert(0 == tToS!(ubyte,ubyte)(0U));
	assert(0 == tToS!(ulong,ubyte)(0U));
}
