#include<stdio.h>
#include<stdlib.h>
#include<sys/types.h>
#include<fcntl.h>
#include<unistd.h>

#define BUFFER_SIZE 32
char inputBuf[32], outputBuf[32];
int main(){
	int fd, m, n;
	fd = open("/dev/FIFOWithBlock", O_RDWR|O_NONBLOCK);//没有阻塞
	if(fd < 0){
		printf("open /dev/FIFOWithBlock failed\n");
		exit(-1);
	}
	while(1){
		//sleep(1);   //这是为了在ps时看到他正在运行，虽然会产生很多重复的Read a empty Buffer信息
		m = read(fd, outputBuf, 1 * sizeof(char));
		if(m < 0 || outputBuf[0]<0){
			if(m<0) puts("Read a empty Buffer");
			else puts("Read Failed");
			continue;
		
		}
		else{
			printf("read —> char = %c (ASCII：%d) \n", outputBuf[0], outputBuf[0]);
		}
	}
	close(fd);
	return 0;
}
