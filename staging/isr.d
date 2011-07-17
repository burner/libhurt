module isr;

//isr stands for insert search remove

interface ISRNode(T) {
	T getData();
} 

interface ISR(T) {
	public bool insert(T data);
	public bool remove(T data);
	//public bool remove(Iterator!(T) data, bool dir = true);
	public ISRIterator!(T) begin();
	public ISRIterator!(T) end();
	public ISRNode!(T) search(const T data);
}

interface ISRIterator(T) {
	public void opUnary(string s)() if(s == "++");
	public void opUnary(string s)() if(s == "--");
	public T opUnary(string s)() if(s == "*");
	public bool isValid() const;
}
