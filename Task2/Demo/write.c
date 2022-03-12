#include<stdio.h>
#include<stdlib.h>
#include<sys/types.h>
#include<fcntl.h>
#include <stdlib.h>
#include <time.h>
#include<string.h>
#include<unistd.h>

#define BUFFER_SIZE 32
char inputBuf[32], outputBuf[32];
int main(){
	int fd, m, n;
	char c;
	fd = open("/dev/FIFOWithBlock", O_RDWR); //有阻塞
	if(fd < 0){
		printf("open /dev/FIFOWithBlock failed\n");
		exit(-1);
	}
	inputBuf[1] = '\0';
	srand(time(0));
	while(1){
		printf("input a sentence, input \"random\" to write random ascii string, input \"quit\" to end\n");
		fgets(inputBuf, 32, stdin);
		inputBuf[strlen(inputBuf)-1]=0;
		if(!strcmp(inputBuf,"quit")) break;
		if(!strcmp(inputBuf,"random"))  //进入random模式
		{
			while(1)
			{
				for(int i=0;i<10;++i) inputBuf[i]=33+rand()%94;
				inputBuf[10]=0;
				n = write(fd, inputBuf, strlen(inputBuf)*sizeof(char));
				printf("write done %d words!\n",n);	
				sleep(1);			
			}
		}
		inputBuf[strlen(inputBuf)+1]='\0';
		n = write(fd, inputBuf, strlen(inputBuf)*sizeof(char));
		printf("write done %d words!\n",n);

	}
	close(fd);
	return 0;
}
