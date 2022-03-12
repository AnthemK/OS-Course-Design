org 07C00h                   ; 告诉编译器程序加载到07C00处
       mov ax, cs
       mov ds, ax
       mov es, ax
       call DispStr                    ; 调用显示字符串例程
       jmp $              ; 无限循环
DispStr:
       mov ax, 0E801h
       int 15h
       mov cx, 400h
       mul cx
       push dx
       push ax
       mov ax, bx
       mov cx, 1000h
       mul cx
       pop bx
       pop cx       ;cx.bx
       add ax, bx
       adc cx, dx   ;cx.ax
       
       push cx
       
       mov cx, 7
       mov [midreg], cx
       call getchar
       mov cx, 6
       mov [midreg], cx
       call getchar   
       mov cx, 5
       mov [midreg], cx
       call getchar
       mov cx, 4
       mov [midreg], cx
       call getchar  
       
       pop ax

       mov cx, 3
       mov [midreg], cx
       call getchar
       mov cx, 2
       mov [midreg], cx
       call getchar   
       mov cx, 1
       mov [midreg], cx
       call getchar
       mov cx, 0
       mov [midreg], cx
       call getchar  
      
       mov ax, BootMessage
       mov bp, ax                    ; es:bp = 串地址
       mov cx, 9                    ; cx = 串长度
       mov ax, 01301h            ; ah = 13, al = 01h
       mov bx, 000Ch              ; 页号为0(bh = 0) 黑底红字 (bl = 0Ch,高亮)
       mov dx, 0
       int 10h                          ; 10h号中断
       ret
getchar:
       mov dx, 0
       mov bx, 10h
       div bx
       mov cx, [midreg]
       mov bx, asciitable
       add bx, dx
       mov dh, [bx]
       mov bx, cx
       add bx, BootMessage
       mov [bx], dh
       ret
BootMessage:
times 8 db '0'
        db 'h'
asciitable:
        db '0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'
midreg:
        dw 0
times 510-($-$$)   db   0            ; 填充剩下的空间，使生成的二进制代码恰好为512字节
dw 0xaa55
