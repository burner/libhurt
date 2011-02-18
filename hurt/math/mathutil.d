module hurt.math.mathutil;

public pure T max(T)(T t, T s) 
		if(is(T : byte) || is(T : float)) {
	if(is(T : byte)) {
		return t > s ? t : s;
	} else static if(is(T : float)) {
		return t > s ? t : s;
	} 
}

public pure T min(T)(T t, T s) 
		if(is(T : byte) || is(T : float)) {
	if(is(T : byte)) {
		return t < s ? t : s;
	} else static if(is(T : float)) {
		return t < s ? t : s;
	} 
}
