	org	07c00h			; ���߱�����������ص�7c00��
	mov	ax, cs
	mov	ds, ax
	mov	es, ax
	call	DispStr			; ������ʾ�ַ�������
	jmp	$			; ����ѭ��
DispStr:
	mov	ax, BootMessage
	mov	bp, ax			; ES:BP = ����ַ
	mov	cx, 16			; CX = ������
	mov	ax, 01301h		; AH = 13,  AL = 01h
	mov	bx, 000ch		; ҳ��Ϊ0(BH = 0) �ڵ׺���(BL = 0Ch,����)
	mov	dl, 0
	int	10h			; 10h ���ж�
	ret
BootMessage:		db	"Hello, OS world!"
times 	510-($-$$)	db	0	; ���ʣ�µĿռ䣬ʹ���ɵĶ����ƴ���ǡ��Ϊ512�ֽ�
dw 	0xaa55				; ������־
