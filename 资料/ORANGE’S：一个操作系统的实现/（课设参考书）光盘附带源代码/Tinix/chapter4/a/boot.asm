
;%define	_BOOT_DEBUG_	; �� Boot Sector ʱһ��������ע�͵�!�����д򿪺��� nasm Boot.asm -o Boot.com ����һ��.COM�ļ����ڵ���

%ifdef	_BOOT_DEBUG_
	org  0100h			; ����״̬, ���� .COM �ļ�, �ɵ���
%else
	org  07c00h			; Boot ״̬, Bios ���� Boot Sector ���ص� 0:7C00 ������ʼִ��
%endif

	jmp short LABEL_START		; Start to boot.
	nop				; ��� nop ������

	; ������ FAT12 ���̵�ͷ
	BS_OEMName	DB 'ForrestY'	; OEM String, ���� 8 ���ֽ�
	BPB_BytsPerSec	DW 512		; ÿ�����ֽ���
	BPB_SecPerClus	DB 1		; ÿ�ض�������
	BPB_RsvdSecCnt	DW 1		; Boot ��¼ռ�ö�������
	BPB_NumFATs	DB 2		; ���ж��� FAT ��
	BPB_RootEntCnt	DW 224		; ��Ŀ¼�ļ������ֵ
	BPB_TotSec16	DW 2880		; �߼���������
	BPB_Media	DB 0xF0		; ý��������
	BPB_FATSz16	DW 9		; ÿFAT������
	BPB_SecPerTrk	DW 18		; ÿ�ŵ�������
	BPB_NumHeads	DW 2		; ��ͷ��(����)
	BPB_HiddSec	DD 0		; ����������
	BPB_TotSec32	DD 0		; ��� wTotalSectorCount �� 0 �����ֵ��¼������
	BS_DrvNum	DB 0		; �ж� 13 ����������
	BS_Reserved1	DB 0		; δʹ��
	BS_BootSig	DB 29h		; ��չ������� (29h)
	BS_VolID	DD 0		; �����к�
	BS_VolLab	DB 'Tinix0.01  '; ���, ���� 11 ���ֽ�
	BS_FileSysType	DB 'FAT12   '	; �ļ�ϵͳ����, ���� 8���ֽ�  

LABEL_START:	
	mov	ax, cs
	mov	ds, ax
	mov	es, ax
	Call	DispStr			; ������ʾ�ַ�������
	jmp	$			; ����ѭ��
DispStr:
	mov	ax, BootMessage
	mov	bp, ax			; ES:BP = ����ַ
	mov	cx, 16			; CX = ������
	mov	ax, 01301h		; AH = 13,  AL = 01h
	mov	bx, 000ch		; ҳ��Ϊ0(BH = 0) �ڵ׺���(BL = 0Ch,����)
	mov	dl, 0
	int	10h			; int 10h
	ret
BootMessage:		db	"Hello, OS world!"
times 	510-($-$$)	db	0	; ���ʣ�µĿռ䣬ʹ���ɵĶ����ƴ���ǡ��Ϊ512�ֽ�
dw 	0xaa55				; ������־
