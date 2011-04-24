module hurt.exception.illegalargumentexception;

public class IllegalArgumentException : Exception {
	this() {
		super("IllegalArgument");
	}
	this(string str) {
		super("IllegalArgument: " ~ str);
	}
}
