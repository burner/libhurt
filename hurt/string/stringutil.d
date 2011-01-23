module hurt.string.stringutil;

/** Trim blanks and tabs from the beginning and end of a str. */
public final immutable(T)[] trim(T)(immutable(T)[] str) {
	uint low = 0;
	while(str[low] == ' ' || str[low] == '\t')
		low++;

	uint high = str.length-1;
	while(str[high] == ' ' || str[high] == '\t')
		high--;

	return str[low..high+1].idup;	
}
