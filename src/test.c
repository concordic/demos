#include <stdio.h>

void print_hello() {
	printf("Hello\n");
}

int add(int x, int y) {
	return x + y;
}

int add_ptr(int* x, int* y) {
	*x = 1;
	*y = 1;
	return *x + *y;
}
