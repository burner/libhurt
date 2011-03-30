import hurt.util.array;

void main() {
	uint[] z;
	append(z, 6u);
	assert(z[0] == 6u);
	append(z, 9u);
	assert(z[1] == 9u);
}
