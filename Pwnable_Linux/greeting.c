#include <stdio.h>
int win(){
	puts("You shouldn't be here");
	system("/bin/sh");
}

int main() {
	char buf [64];
	puts("Hi! What's your name?\n");
	gets(buf);
	printf("Nice to meet you %s\n", buf);
	return 0;
}
