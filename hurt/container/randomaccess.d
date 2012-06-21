module hurt.container.randomaccess;

interface RandomAccess(T) {
	public T opIndex(size_t idx);
	public const(T) opIndex(size_t idx) const;
	public T[] values();
	public size_t getSize() const;
}
