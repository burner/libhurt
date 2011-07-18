module isr;

//isr stands for insert search remove

enum ISRType {
	RBTree,
	BinarySearchTree,
	HashTable
}

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
	public bool isEmpty() const;
	public size_t getSize() const;
}

abstract class ISRIterator(T) {
	public void opUnary(string s)() if(s == "++") { increment(); }
	public void opUnary(string s)() if(s == "--") { decrement(); }
	public T opUnary(string s)() if(s == "*") { return getData(); }
	public T getData();
	public bool isValid() const;
	public void increment();
	public void decrement();
}