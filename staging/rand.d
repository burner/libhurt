import hurt.util.random.random;
import hurt.io.stdio;

void main() {
	Random rg = new Random();
	for(int i = 0; i < 10; i++) {
		println(rg.next(100));
		println(rg.uniform!(real)());
	}
	return;
}
