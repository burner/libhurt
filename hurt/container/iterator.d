module hurt.container.iterator;

interface Iterator(T) {
	public void opUnary(string s)() if(s == "++");

	public void opUnary(string s)() if(s == "--");

	public T opUnary(string s)() if(s == "*");

	public bool isValid() const;

	public bool opEquals(Object o);
}

interface Iterable(T) {
	int opApply(int delegate(ref size_t,ref T) dg);
	int opApply(int delegate(ref T) dg);
	size_t getSize();
}
