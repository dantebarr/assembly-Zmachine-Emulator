extern void asm_main();

#include <stdio.h>

int hex_ascii_converter();
int divide();
int modulus();
int multiply();
int print_num();

int main()
{
	asm_main();
    return 0;
}

int hex_ascii_converter(int x){
	int a = x;
	if(a < 10){
		a = a + 48;
	}
	else{
		a = a + 55;
	}
	return a;
}

int print_num(int x){
	char buffer[100];
	int n, i;
	n = sprintf(buffer,"%d",x);
	i = n;
	while(n >= 0){
		buffer[i] = buffer[i-1];
		i--;
		if(i == 0) break;
	}

	buffer[0] = (char)n;

	i = (int) buffer;
	return i;
}

int divide(int x, int y){
	return x/y;
}

int modulus(int x, int y){
	return x%y;
}

int multiply(int x, int y){
	return x*y;
}

