module isr;

//isr stands for insert search remove

interface ISRNode(T) {
	T getData();
} 

interface ISR(T) {
	bool insert(T data);
	bool remove(T data);
	ISRIterator!(T) begin();
	ISRIterator!(T) end();
	ISRNode!(T) search(const T data);
}

interface ISRIterator(T) {
	public void opUnary(string s)() if(s == "++");
	public void opUnary(string s)() if(s == "--");
	public T opUnary(string s)() if(s == "*");
	public bool isValid() const;
}
