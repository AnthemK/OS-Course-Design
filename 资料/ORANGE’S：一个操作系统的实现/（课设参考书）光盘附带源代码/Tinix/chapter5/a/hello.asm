
; �������ӷ���
; (ld �ġ�-s��ѡ����Ϊ��strip all��)
;
; [root@XXX XXX]# nasm -f elf hello.asm -o hello.o
; [root@XXX XXX]# ld -s hello.o -o hello
; [root@XXX XXX]# ./hello
; Hello, world!
; [root@XXX XXX]# 


[section .data]	; �����ڴ�

strHello	db	"Hello, world!", 0Ah
STRLEN		equ	$ - strHello


[section .text]	; �����ڴ�

global _start	; ���Ǳ��뵼�� _start �����ڣ��Ա���������ʶ��

_start:
	mov	edx, STRLEN
	mov	ecx, strHello
	mov	ebx, 1
	mov	eax, 4		; sys_write
	int	0x80		; ϵͳ����
	mov	ebx, 0
	mov	eax, 1		; sys_exit
	int	0x80		; ϵͳ����
