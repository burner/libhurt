import hurt.container.stack;

void main() {
	Stack!(int) i = new Stack!(int);
	i.push(44);
	assert(i.top() == 44);
	i.push(45);
	assert(i.pop() == 45);
	assert(i.pop() == 44);
	assert(i.empty());

	class Tmp {
		uint a = 44;
	}

	Stack!(Tmp) j = new Stack!(Tmp)(1, 4);
	j.push(new Tmp());
	j.top().a = 88;
	assert(j.top().a == 88);
	assert(j.getCapazity() == 1);
	j.push(new Tmp());
	assert(j.getCapazity() == 4);
	j.push(new Tmp());
	j.push(new Tmp());
	assert(j.getSize() == 4);
	j.setCapazity(992);
	assert(j.getCapazity() == 992);
	assert(j.getSize() == 4);
	j.setCapazity(33);
	assert(j.getCapazity() == 992);
}
