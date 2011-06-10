module hurt.math.mathutil;

public pure T max(T)(T t, T s) 
		if(is(T : byte) || is(T : float)) {
	return t > s ? t : s;
}

public pure T min(T)(T t, T s) 
		if(is(T : byte) || is(T : float)) {
	return t < s ? t : s;
}

public pure T abs(T)(T t) 
		if(is(T : byte) || is(T : float)) {
	return t < 0 ? -t : t;
}

unittest {
	assert(10 == max(10, 9));
	assert(10 == min(10, 11));
	assert(10 == abs(10));
	assert(10 == abs(-10));
}
