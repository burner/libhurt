module isr;

interface ISRNode(T) {
	T getData();
} 

interface ISR(T) {
	bool insert(T data);
	bool remove(T data);
	ISRNode!(T) search(const T data);
}

