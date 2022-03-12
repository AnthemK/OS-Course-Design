##################################################
# Makefile of pmtestx.asm (x=[1,2,3...])
##################################################

SRC:=mywork.asm
BIN:=$(subst .asm,.com,$(SRC))

.PHONY : everything

everything : $(BIN)
	sudo mount -o loop pm.img /mnt/floppy/       # 进行挂载
	sudo cp $(BIN) /mnt/floppy/a.com -v   # 复制之后的名字统一为a.com
	sudo umount /mnt/floppy/

$(BIN) : $(SRC)
	nasm $< -o $@          # 使用nasm编译为.com文件
clean :
	rm $(BIN)    # 注意pm.img中现在没有格式化
