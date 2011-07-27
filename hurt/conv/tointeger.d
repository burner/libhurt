module hurt.conv.tointeger;

import hurt.conv.convutil;
import hurt.conv.conv;
import hurt.conv.chartonumeric;
import hurt.exception.valuerangeexception;

import std.stdio;

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

public pure uint ulongToUint(ulong from) {
	if(from > uint.max) {
		throw new ValueRangeException("long value " ~ conv!(long,string)(from) ~ 
			" doesn't fit into uint");
	} else {
		return cast(uint)from;
	}
}

public pure int ulongToInt(ulong from) {
	if(from < int.min) {
		throw new ValueRangeException("long value " ~ conv!(long,string)(from) ~ 
			" doesn't fit into int");
	} else if(from > int.max) {
		throw new ValueRangeException("long value " ~ conv!(long,string)(from) ~ 
			" doesn't fit into int");
	} else {
		return cast(int)from;
	}
}

public pure ushort ulongToUshort(ulong from) {
	if(from > ushort.max) {
		throw new ValueRangeException("long value " ~ conv!(long,string)(from) ~ 
			" doesn't fit into ushort");
	} else {
		return cast(ushort)from;
	}
}

public pure short ulongToShort(ulong from) {
	if(from < short.min) {
		throw new ValueRangeException("long value " ~ conv!(long,string)(from) ~ 
			" doesn't fit into short");
	} else if(from > short.max) {
		throw new ValueRangeException("long value " ~ conv!(long,string)(from) ~ 
			" doesn't fit into short");
	} else {
		return cast(short)from;
	}
}

public pure T tToS(T,S)(S s) {
	if(s < T.min) {
		throw new ValueRangeException(" value " ~ conv!(S,string)(s) ~ 
			" doesn't fit into ");
	} else if(s > T.max) {
		throw new ValueRangeException(" value " ~ conv!(S,string)(s) ~ 
			" doesn't fit into ");
	} else {
		return cast(T)s;
	}
}

unittest {
	assert(0 == tToS!(byte,int)(0L));
	assert(0 == tToS!(byte,short)(0UL));
	assert(0 == tToS!(byte,byte)(0UL));
	assert(0 == tToS!(byte,ubyte)(0UL));
	assert(0 == tToS!(int,int)(0L));
	assert(0 == tToS!(int,short)(0UL));
	assert(0 == tToS!(int,byte)(0UL));
	assert(0 == tToS!(int,ubyte)(0UL));
	assert(0 == tToS!(short,int)(0L));
	assert(0 == tToS!(short,short)(0UL));
	assert(0 == tToS!(short,byte)(0UL));
	assert(0 == tToS!(short,ubyte)(0UL));
	assert(0 == tToS!(long,int)(0L));
	assert(0 == tToS!(long,short)(0UL));
	assert(0 == tToS!(long,byte)(0UL));
	assert(0 == tToS!(long,ubyte)(0UL));
	assert(0 == tToS!(ulong,int)(0UL));
	assert(0 == tToS!(ulong,short)(0UL));
	assert(0 == tToS!(ulong,byte)(0UL));
	assert(0 == tToS!(ulong,ubyte)(0UL));
}
