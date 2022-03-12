
all: readBlock.out readNonBlock.out write.out
readBlock.out: 
	cc -o readBlock.out readBlock.c
readNonBlock.out:
	cc -o readNonBlock.out readNonBlock.c
write.out:
	cc -o write.out write.c
 .PHONY : clean
clean:
	rm -f *.out
