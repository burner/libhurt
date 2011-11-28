module hurt.util.pair;

struct Pair(T,S) {
	T first;
	S second;

	this(T first, S second) {
		this.first = first;
		this.second = second;
	}
}
