ifneq ($(KERNELRELEASE),)
  
#kbuildsyntax. dependency relationshsip of files and target modules arelisted here.

#mymodule-objs:= file1.o file2.o

obj-m:= chr_driver.o

else

PWD := $(shell pwd)

KVER:= $(shell uname -r)

KDIR:= /lib/modules/$(KVER)/build

all:

	$(MAKE) -C $(KDIR) M=$(PWD) modules

clean:
	$(MAKE) -C $(KDIR) M=$(PWD) clean

endif
