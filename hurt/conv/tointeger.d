module hurt.conv.tointeger;

import hurt.conv.convutil;
import hurt.conv.conv;
import hurt.conv.chartonumeric;
import hurt.exception.valuerangeexception;

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
