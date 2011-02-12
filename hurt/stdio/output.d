module hurt.stdio.output;

public void write(T)(immutable(T)[] str) if(is(T == char) || is(T == wchar) 
		|| is(T == dchar)) {

}

public void writeln(T)(immutable(T)[] str) if(is(T == char) || is(T == wchar) 
		|| is(T == dchar)) {

}
