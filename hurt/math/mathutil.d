module hurt.math.mathutil;

public pure bool isNumeric(T)() {
	static if(isInteger!T() || isFloat!T()) {
		return true;
	} else {
		return false;
	}
}

public pure bool isInteger(T)() {
	static if(is(T == byte) || is(T == short) || is(T == int) || 
			is(T == long) || is(T == ubyte) || is(T == ushort) || is(T == uint) 
			|| is(T == ulong)) {
		return true;
	} else {
		return false;
	}
}

public pure bool isFloat(T)() {
	static if(is(T == float) || is(T == double) || is(T == real)) {
		return true;
	} else {
		return false;
	}
}

public pure T max(T)(T t, T s) if(isNumeric!(T)()) {
	return t > s ? t : s;
}

public pure T min(T)(T t, T s) if(isNumeric!(T)()) {
	return t < s ? t : s;
}

public pure T abs(T)(T t) if(isNumeric!(T)()) {
	return t < 0 ? -t : t;
}

public pure bool equal(T,S)(T t, S s) if(isNumeric!(T)() && isNumeric!(S)()) {
	if(smaller(t,s))
		return false;
	if(smaller(s,t))
		return false;
	return true;
}

// reads is t smaller than s
public pure bool smaller(T,S)(T t, S s) if(isNumeric!(T)() && isNumeric!(S)()) {
	if(t < 0 && s >= 0) {
		return true;
	} else if(t >= 0 && s < 0) {
		return false;
	} else {
		return t < s;
	}
}

public pure bool bigger(T,S)(T t, S s) if(isNumeric!(T)() && isNumeric!(S)()) {
	if(smaller(t,s))
		return false;
	if(equal(t,s))
		return false;
	return !smaller(s,t);
}

unittest {
	assert(10 == max(10, 9));
	assert(10 == min(10, 11));
	assert(10 == abs(10));
	assert(10 == abs(-10));
	assert(smaller!(byte,ulong)(10,100000000));
	assert(smaller!(uint,ulong)(10u,100000000));
	assert(smaller!(ushort,long)(10,100000000));
	assert(smaller!(short,long)(-10,100000000));
	assert(!smaller!(short,long)(-10,-100000000));
	assert(!smaller!(byte,long)(-10,-100000000));
	assert(!bigger!(byte,ulong)(10,100000000));
	assert(!bigger!(uint,ulong)(10u,100000000));
	assert(!bigger!(ushort,long)(10,100000000));
	assert(!bigger!(short,long)(-10,100000000));
	assert(bigger!(short,long)(-10,-100000000));
	assert(bigger!(byte,long)(-10,-100000000));
	assert(equal!(short,long)(-10,-10));
	assert(equal!(byte,long)(-10,-10));
}
