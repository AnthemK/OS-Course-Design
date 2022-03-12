%include "pm.inc"
org 0100h

PageDirBase1		equ	200000h	; ҳĿ¼��ʼ��ַ:	2M
PageTblBase1		equ	201000h	; ҳ��ʼ��ַ:		2M +  4K
PageDirBase2		equ	210000h	; ҳĿ¼��ʼ��ַ:	2M + 64K
PageTblBase2		equ	211000h	; ҳ��ʼ��ַ:		2M + 64K + 4K

jmp LABEL_BEGIN


[SECTION  .gdt]		;GDT
LABEL_GDT:			Descriptor 0, 0, 0		;empty descriptor
LABEL_DESC_NORMAL:	Descriptor 0, 0ffffh, DA_DRW	; ���������θı����� ,���ݶ�read��write
LABEL_DESC_CODE16:	Descriptor 0, 0ffffh, DA_C		; ����cs�ı�����, 16, code
LABEL_DESC_CODE32:	Descriptor 0, SegCode32Len - 1, DA_C + DA_32	; codeD, 32
LABEL_DESC_VIDEO:	Descriptor 0B8000h, 0ffffh, DA_DRW + DA_DPL3   ;�Դ�,���ݶ�read��write, ring3
LABEL_DESC_DATA:	Descriptor 0, DataLen - 1, DA_DRW	;���ݶ�read��write
LABEL_DESC_STACK:	Descriptor 0, TopOfStack02, DA_DRWA + DA_32	; Stack, 32 λ��ʹ��esp ,���ݶ�read��write��access
LABEL_DESC_TSS1:	Descriptor 0, TSSLen1 - 1, DA_386TSS + DA_DPL3; TSS1
LABEL_DESC_LDT1:	Descriptor 0, LDTLen1 - 1, DA_LDT + DA_DPL3;LDT1
LABEL_DESC_TSS2:	Descriptor 0, TSSLen2 - 1, DA_386TSS + DA_DPL3; TSS2
LABEL_DESC_LDT2:	Descriptor 0, LDTLen2 - 1, DA_LDT + DA_DPL3;LDT2
LABEL_DESC_FLAT_RW:	Descriptor 0, 0fffffh, DA_DRW | DA_LIMIT_4K	; 0 ~ 4G�����ݶΣ����ڳ�ʼ��ҳ��
; end of gdt

GdtLen		equ	$ - LABEL_GDT	
GdtPtr		dw	GdtLen	;limit GDT
			dd	0		;base GDT

;GDT selector
SelectorNormal		equ	LABEL_DESC_NORMAL - LABEL_GDT
SelectorCode16		equ	LABEL_DESC_CODE16 - LABEL_GDT
SelectorCode32		equ	LABEL_DESC_CODE32 - LABEL_GDT
SelectorVideo		equ	LABEL_DESC_VIDEO - LABEL_GDT		
SelectorData		equ LABEL_DESC_DATA - LABEL_GDT
SelectorStack		equ	LABEL_DESC_STACK - LABEL_GDT
SelectorTSS1		equ	LABEL_DESC_TSS1 - LABEL_GDT + SA_RPL3
SelectorLDT1		equ	LABEL_DESC_LDT1 - LABEL_GDT + SA_RPL3
SelectorTSS2		equ	LABEL_DESC_TSS2 - LABEL_GDT + SA_RPL3
SelectorLDT2		equ	LABEL_DESC_LDT2 - LABEL_GDT + SA_RPL3
SelectorFlatRW		equ	LABEL_DESC_FLAT_RW	- LABEL_GDT
; end of section  .gdt

[SECTION .data1]	 ;���ݶ�
ALIGN	32
[BITS	32]
LABEL_DATA:
SPValueInRealMode	dw	0	

_szPMMessage:			db	"In Protect Mode now. ^-^", 0Ah, 0Ah, 0	; ���뱣��ģʽ����ʾ���ַ���
_szMemChkTitle:			db	"BaseAddrL BaseAddrH LengthLow LengthHigh   Type", 0Ah, 0	; ���뱣��ģʽ����ʾ���ַ���
_szRAMSize			db	"RAM size:", 0
_szReturn			db	0Ah, 0
; ����
_dwMCRNumber:			dd	0	; Memory Check Result
_dwDispPos:			dd	(80 * 6 + 0) * 2	;ȷ�����λ�� ��Ļ�� 6 ��, �� 0 ��
_dwMemSize:			dd	0
_ARDStruct:			; Address Range Descriptor Structure
	_dwBaseAddrLow:		dd	0
	_dwBaseAddrHigh:	dd	0
	_dwLengthLow:		dd	0
	_dwLengthHigh:		dd	0
	_dwType:			dd	0
_MemChkBuf:	times	256	db	0

_PageTableNumber		dd	0	;�����ظ�����ҳ������


_SavedIDTR:			dd	0	; ���ڱ��� IDTR
					dd	0
_SavedIMREG:		db	0	; �ж����μĴ���ֵ
;***********************************************
_seltss				dd	0	; ����ѡ��
;***********************************************

szPMMessage		equ	_szPMMessage - $$
szMemChkTitle		equ	_szMemChkTitle - $$
szRAMSize		equ	_szRAMSize - $$
szReturn		equ	_szReturn - $$
dwMCRNumber		equ	_dwMCRNumber - $$
dwDispPos		equ	_dwDispPos - $$
dwMemSize		equ	_dwMemSize - $$
ARDStruct		equ	_ARDStruct - $$
	dwBaseAddrLow	equ	_dwBaseAddrLow - $$
	dwBaseAddrHigh	equ	_dwBaseAddrHigh - $$
	dwLengthLow	equ	_dwLengthLow - $$
	dwLengthHigh	equ	_dwLengthHigh - $$
	dwType		equ	_dwType - $$
MemChkBuf		equ	_MemChkBuf - $$
PageTableNumber		equ	_PageTableNumber - $$
SavedIDTR		equ	_SavedIDTR - $$
SavedIMREG		equ	_SavedIMREG - $$
seltss			equ _seltss-$$

DataLen			equ	$ - LABEL_DATA
; end of [section .data1]


[SECTION .idt]; IDT
ALIGN	32
[BITS	32]
LABEL_IDT:
%rep 32
			Gate	SelectorCode32, UserIntHandler,      0, DA_386IGate
%endrep
.020h:			Gate	SelectorCode32,    ClockHandler,      0, DA_386IGate
%rep 95
			Gate	SelectorCode32, UserIntHandler,      0, DA_386IGate
%endrep
.080h:			Gate	SelectorCode32,  UserIntHandler,      0, DA_386IGate

IdtLen		equ	$ - LABEL_IDT
IdtPtr		dw	IdtLen - 1	; �ν���
			dd	0		; ����ַ
; END of [SECTION .idt]


[SECTION .gs]	;32ring 0 ��ջ
ALIGN	32
[BITS	32]
LABEL_STACK:
	times 256 db 0
TopOfStack	equ	$ - LABEL_STACK - 1
	times 256 db 0
TopOfStack01	equ	$ - LABEL_STACK - 1
	times 256 db 0
TopOfStack02	equ	$ - LABEL_STACK - 1
; end of [section .gs]


; TSS ---------------------------------------------------------------------------------------------
[SECTION .tss1]		;Ϊ�˴ӵ���Ȩ���������Ȩ��,����ʱҪ��֤�Ĵ���Ϊ�Ϸ�ֵ
ALIGN	32
[BITS	32]
LABEL_TSS1:
		DD	0			; Back
		DD	TopOfStack01	; 0 ����ջ
		DD	SelectorStack	; 
		DD	0			; 1 ����ջ
		DD	0			; 
		DD	0			; 2 ����ջ
		DD	0			; 
		DD	PageDirBase1	; CR3�����Զ�����
		DD	0			; EIP
		DD	0			; EFLAGS
		DD	0			; EAX
		DD	0			; ECX
		DD	0			; EDX
		DD	0			; EBX
		DD	0			; ESP
		DD	0			; EBP
		DD	0			; ESI
		DD	0			; EDI
		DD	0			; ES
		DD	0			; CS
		DD	0			; SS
		DD	0			; DS
		DD	0			; FS
		DD	0			; GS
		DD	SelectorLDT1	; LDT �����Զ�����
		DW	0			; ���������־
		DW	$ - LABEL_TSS1 + 2	; I/Oλͼ��ַ
		DB	0ffh			; I/Oλͼ������־
TSSLen1		equ	$ - LABEL_TSS1

[SECTION .tss2]		;Ϊ�˴ӵ���Ȩ���������Ȩ��
ALIGN	32
[BITS	32]
LABEL_TSS2:
		DD	0			; Back
		DD	TopOfStack02	; 0 ����ջ
		DD	SelectorStack	; 
		DD	0			; 1 ����ջ
		DD	0			; 
		DD	0			; 2 ����ջ
		DD	0			; 
		DD	PageDirBase1	; CR3
		DD	0			; EIP
		DD	0x200		; EFLAGS		;�����ж�
		DD	0			; EAX
		DD	0			; ECX
		DD	0			; EDX
		DD	0			; EBX
		DD	TopOfStack2		; ESP
		DD	0			; EBP
		DD	0			; ESI
		DD	0			; EDI
		DD	0			; ES
		DD	SelectorLDTCodeB	; CS
		DD	SelectorStack2	; SS
		DD	0			; DS
		DD	0			; FS
		DD	0			; GS
		DD	SelectorLDT2	; LDT
		DW	0			; ���������־
		DW	$ - LABEL_TSS2 + 2	; I/Oλͼ��ַ
		DB	0ffh			; I/Oλͼ������־

TSSLen2		equ	$ - LABEL_TSS2
; TSS ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


[SECTION  .s16]
[BITS  16]
Getadd:		;eax = ax*4+ebx
	movzx	eax, ax
	shl	eax, 4
	add	eax, ebx
	ret

Getbase:	;[bx] = eax
	mov	word [bx + 2], ax
	shr eax, 16
	mov byte [bx + 4], al
	mov byte [bx + 7], ah
	ret

LABEL_BEGIN:
	mov ax, cs
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov sp, 0100h	;ǰ100hΪջ�ռ�

	mov	[LABEL_GO_BACK_TO_REAL + 3], ax	;ָ����ֵ
	mov	[SPValueInRealMode], sp			;ջ������

	; �õ��ڴ���Ϣ
	mov	ebx, 0
	mov	di, _MemChkBuf
.loop:
	mov	eax, 0E820h
	mov	ecx, 20
	mov	edx, 0534D4150h
	int	15h
	jc	LABEL_MEM_CHK_FAIL
	add	di, 20
	inc	dword [_dwMCRNumber]
	cmp	ebx, 0
	jne	.loop
	jmp	LABEL_MEM_CHK_OK
LABEL_MEM_CHK_FAIL:
	mov	dword [_dwMCRNumber], 0
LABEL_MEM_CHK_OK:

	;initalize gbt
	; base of code16
	mov	ax, cs
	mov	ebx, LABEL_SEG_CODE16
	call	Getadd		; eax = cs:LABEL_SEG_CODE16
	mov	bx, LABEL_DESC_CODE16
	call	Getbase		;��ֵbase

	;base of code32
	mov ax, cs
	mov	ebx, LABEL_SEG_CODE32
	call	Getadd		; eax = cs:LABEL_SEG_CODE32
	mov	bx, LABEL_DESC_CODE32
	call	Getbase		;��ֵbase

	; base of data
	mov ax, ds
	mov	ebx, LABEL_DATA
	call	Getadd		; eax = ds:LABEL_DATA
	mov	bx, LABEL_DESC_DATA
	call	Getbase		;��ֵbase

	; base of stack
	mov ax, ds
	mov	ebx, LABEL_STACK
	call	Getadd		; eax = ds:LABEL_STACK
	mov	bx, LABEL_DESC_STACK
	call	Getbase		;��ֵbase

	; base of TSS1
	mov ax, ds
	mov	ebx, LABEL_TSS1
	call	Getadd		; eax = ds:LABEL_TSS1
	mov	bx, LABEL_DESC_TSS1
	call	Getbase		;��ֵbase

	; base of stack1
	mov ax, ds
	mov	ebx, LABEL_STACK1
	call	Getadd		; eax = ds:LABEL_STACK1
	mov	bx, LABEL_DESC_STACK1
	call	Getbase		;��ֵbase

	; base of ldt1 seg
	mov ax, ds
	mov	ebx, LABEL_LDT1
	call	Getadd		; eax = ds:LABEL_LDT1
	mov	bx, LABEL_DESC_LDT1
	call	Getbase		;��ֵbase

	; base of ldt1 code
	mov ax, ds
	mov	ebx, LABEL_CODE_A
	call	Getadd		; eax = ds:LABEL_CODE_A
	mov	bx, LABEL_LDT_DESC_CODEA
	call	Getbase		;��ֵbase

	; base of TSS2
	mov ax, ds
	mov	ebx, LABEL_TSS2
	call	Getadd		; eax = ds:LABEL_TSS2
	mov	bx, LABEL_DESC_TSS2
	call	Getbase		;��ֵbase

	; base of stack2
	mov ax, ds
	mov	ebx, LABEL_STACK2
	call	Getadd		; eax = ds:LABEL_STACK2
	mov	bx, LABEL_DESC_STACK2
	call	Getbase		;��ֵbase

	; base of ldt2 seg
	mov ax, ds
	mov	ebx, LABEL_LDT2
	call	Getadd		; eax = ds:LABEL_LDT2
	mov	bx, LABEL_DESC_LDT2
	call	Getbase		;��ֵbase

	; base of ldt2 code
	mov ax, ds
	mov	ebx, LABEL_CODE_B
	call	Getadd		; eax = ds:LABEL_CODE_B
	mov	bx, LABEL_LDT_DESC_CODEB
	call	Getbase		;��ֵbase
	

	;prepare
	mov ax, ds
	mov	ebx, LABEL_GDT
	call	Getadd		;base of gdt  eax = ds:LABEL_GDT
	mov dword [GdtPtr + 2], eax		;	[GdtPtr + 2] = eax

	; Ϊ���� IDTR ��׼��
	mov ax, ds
	mov	ebx, LABEL_IDT
	call	Getadd		;base of idt
	mov	dword [IdtPtr + 2], eax	; [IdtPtr + 2] <- idt ����ַ

	; ���� IDTR
	sidt	[_SavedIDTR]

	; �����ж����μĴ���(IMREG)ֵ
	in	al, 21h
	mov	[_SavedIMREG], al

	lidt	[IdtPtr]	; ���� IDTR

	lgdt	[GdtPtr]	;1 load gdt
	cli					;2 ���ж�
	in	al, 92h
	or	al, 00000010b
	out	92h, al			;3 �򿪵�ַ��
	mov	eax, cr0
	or	eax, 1
	mov	cr0, eax		;4 cr0
	jmp dword SelectorCode32:0	;5 ����protect

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;return here
LABEL_REAL_ENTRY:		; �ӱ���ģʽ���ص�ʵģʽ�͵�������
	mov	ax, cs
	mov	ds, ax
	mov	es, ax
	mov	ss, ax
	mov	sp, [SPValueInRealMode]		;�ָ�ջ
	
	lidt	[_SavedIDTR]	; �ָ� IDTR ��ԭֵ

	in	al, 92h		
	and	al, 11111101b	 
	out	92h, al			; 2 �رյ�ַ��
	sti					; 3 ���ж�
	mov	ax, 4c00h
	int	21h			; �˳�
; end of section  .s16]

[SECTION  .s32]
[BITS  32]
LABEL_SEG_CODE32:
	mov	ax, SelectorData
	mov	ds, ax			; ds : data
	mov	ax, SelectorData
	mov	es, ax
	mov ax, SelectorVideo
	mov gs, ax			; gs : video
	mov	ax, SelectorStack
	mov	ss, ax			; ss : stack
	mov	esp, TopOfStack	; esp : top

	;ʵ�ֹ���
	; ������ʾһ���ַ���
	push	szPMMessage
	call	DispStr
	add	esp, 4

	push	szMemChkTitle
	call	DispStr
	add	esp, 4
	call	DispMemSize		; ��ʾ�ڴ���Ϣ

	call	GetMemSize
	
	mov	eax, PageTblBase1
	mov	ebx, PageDirBase1
	call	InitPaging	;��ʼ��ҳ��1

	mov	eax, PageTblBase2
	mov	ebx, PageDirBase2
	call	InitPaging	;��ʼ��ҳ��2
	
	call	StartPage	;������ҳ
	;call	SelectorCallGateTest:10	; ������	ƫ��ֵ��Ӱ�����
	;call	SelectorCodeDest:0

	; Load LDT
	mov	ax, SelectorLDT1
	lldt	ax

	; Load TSS1
	mov	ax, SelectorTSS1
	ltr	ax	; �������ڷ�����Ȩ���任ʱҪ�л���ջ
;***********************************************
	call	Init8259A
	sti
;***********************************************
	;mov	ax, SelectorNormal
	;mov	es, ax			;��֤�Ϸ���

	push	SelectorStack1
	push	TopOfStack1
	push	SelectorLDTCodeA
	push	0
	retf				; Ring0 -> Ring3	����ʱ�μĴ�������Ҫ�Ϸ�

	call	SetRealmode8259A
	jmp	SelectorCode16:0		;��ʱ����

;***********************************************
	; Init8259A ---------------------------------------------------------------------------------------------
Init8259A:
	mov	al, 011h
	out	020h, al	; ��8259, ICW1.
	call	io_delay

	out	0A0h, al	; ��8259, ICW1.
	call	io_delay

	mov	al, 020h	; IRQ0 ��Ӧ�ж����� 0x20
	out	021h, al	; ��8259, ICW2.
	call	io_delay

	mov	al, 028h	; IRQ8 ��Ӧ�ж����� 0x28
	out	0A1h, al	; ��8259, ICW2.
	call	io_delay

	mov	al, 004h	; IR2 ��Ӧ��8259
	out	021h, al	; ��8259, ICW3.
	call	io_delay

	mov	al, 002h	; ��Ӧ��8259�� IR2
	out	0A1h, al	; ��8259, ICW3.
	call	io_delay

	mov	al, 001h
	out	021h, al	; ��8259, ICW4.
	call	io_delay

	out	0A1h, al	; ��8259, ICW4.
	call	io_delay

	mov	al, 11111110b	; ����������ʱ���ж�
	;mov	al, 11111111b	; ������8259�����ж�
	out	021h, al	; ��8259, OCW1.
	call	io_delay

	mov	al, 11111111b	; ���δ�8259�����ж�
	out	0A1h, al	; ��8259, OCW1.
	call	io_delay

	ret
; Init8259A ---------------------------------------------------------------------------------------------


; SetRealmode8259A ---------------------------------------------------------------------------------------------
SetRealmode8259A:
	mov	ax, SelectorData
	mov	fs, ax

	mov	al, 017h
	out	020h, al	; ��8259, ICW1.
	call	io_delay

	mov	al, 008h	; IRQ0 ��Ӧ�ж����� 0x8
	out	021h, al	; ��8259, ICW2.
	call	io_delay

	mov	al, 001h
	out	021h, al	; ��8259, ICW4.
	call	io_delay

	mov	al, [fs:SavedIMREG]	; ���ָ��ж����μĴ���(IMREG)��ԭֵ
	out	021h, al		; ��
	call	io_delay

	ret
; SetRealmode8259A ---------------------------------------------------------------------------------------------

io_delay:
	nop
	nop
	nop
	nop
	ret


; int handler ---------------------------------------------------------------
_ClockHandler:
ClockHandler	equ	_ClockHandler - $$
	push	eax
	push	ecx		;save
	mov	ax, SelectorData
	mov	ds, ax
	mov	ecx, [ds:seltss]
	inc	ecx
	mov	[ds:seltss], ecx
	mov	al, 20h
	out	20h, al				; ���� EOI

	test	ecx, 1
	jnz MRSUDisplay	
HUSTDisplay:
	
	sti				;
	jmp	SelectorTSS1:0	; ����ֲ�����HUST��
	jmp	Final

MRSUDisplay:
	
	sti				;
	jmp	SelectorTSS2:0	; ����ֲ�����MRSU

Final:
	
	pop	ecx
	pop	eax
	iretd

_UserIntHandler:
UserIntHandler	equ	_UserIntHandler - $$
	mov	ah, 0Ch				; 0000: �ڵ�    1100: ����
	mov	al, 'I'
	mov	[gs:((80 * 0 + 70) * 2)], ax	; ��Ļ�� 0 ��, �� 70 �С�
	iretd
; ---------------------------------------------------------------------------

;***********************************************
; ������ҳ���� --------------------------------------------------------------
GetMemSize:
	; �����ڴ��С����Ӧ��ʼ������PDE�Լ�����ҳ��
	xor	edx, edx
	mov	eax, [dwMemSize]
	mov	ebx, 400000h	; 400000h = 4M = 4096 * 1024, һ��ҳ���Ӧ���ڴ��С
	div	ebx
	mov	ecx, eax	; ��ʱ ecx Ϊҳ��ĸ�����Ҳ�� PDE Ӧ�õĸ���
	test	edx, edx
	jz	.no_remainder
	inc	ecx		; ���������Ϊ 0 ��������һ��ҳ��
.no_remainder:
	mov	[PageTableNumber], ecx	; �ݴ�ҳ�����	
	ret

InitPaging:
	; Ϊ�򻯴���, �������Ե�ַ��Ӧ��ȵ������ַ. ���Ҳ������ڴ�ն�.
	push	eax
	or	eax, PG_P  | PG_USU | PG_RWW
	push	eax
	push	ebx
	; ���ȳ�ʼ��ҳĿ¼
	mov	ax, SelectorFlatRW
	mov	es, ax
	pop	edi			; edi = PageDirBase
	pop	eax			; eax = PageTblBase | PG_P  | PG_USU | PG_RWW
	mov	ecx, [PageTableNumber]
	
.1:
	stosd
	add	eax, 4096		; Ϊ�˼�, ����ҳ�����ڴ�����������.
	loop	.1

	; �ٳ�ʼ������ҳ��
	mov	eax, [PageTableNumber]	; ҳ�����
	mov	ebx, 1024		; ÿ��ҳ�� 1024 �� PTE
	mul	ebx
	mov	ecx, eax		; PTE���� = ҳ����� * 1024
	pop	edi				;edi = PageTblBase
	xor	eax, eax
	mov	eax, PG_P  | PG_USU | PG_RWW
.2:
	stosd
	add	eax, 4096		; ÿһҳָ�� 4K �Ŀռ�
	loop	.2
	ret

StartPage:	
	mov	eax, PageDirBase1
	mov	cr3, eax
	mov	eax, cr0
	or	eax, 80000000h
	mov	cr0, eax
	jmp	short done
done:
	nop
	ret
; ��ҳ����������� ----------------------------------------------------------

;��ʾ�ڴ���Ϣ----------------------------------------------------------------
DispMemSize:
	push	esi
	push	edi
	push	ecx

	mov	esi, MemChkBuf
	mov	ecx, [dwMCRNumber]	;for(int i=0;i<[MCRNumber];i++) // ÿ�εõ�һ��ARDS(Address Range Descriptor Structure)�ṹ
.loop:					;{
	mov	edx, 5			;	for(int j=0;j<5;j++)	// ÿ�εõ�һ��ARDS�еĳ�Ա����5����Ա
	mov	edi, ARDStruct		;	{			// ������ʾ��BaseAddrLow��BaseAddrHigh��LengthLow��LengthHigh��Type
.1:					;
	push	dword [esi]		;
	call	DispInt			;		DispInt(MemChkBuf[j*4]); // ��ʾһ����Ա
	pop	eax			;
	stosd				;		ARDStruct[j*4] = MemChkBuf[j*4];
	add	esi, 4			;
	dec	edx			;
	cmp	edx, 0			;
	jnz	.1			;	}
	call	DispReturn		;	printf("\n");
	cmp	dword [dwType], 1	;	if(Type == AddressRangeMemory) // AddressRangeMemory : 1, AddressRangeReserved : 2
	jne	.2			;	{
	mov	eax, [dwBaseAddrLow]	;
	add	eax, [dwLengthLow]	;
	cmp	eax, [dwMemSize]	;		if(BaseAddrLow + LengthLow > MemSize)
	jb	.2			;
	mov	[dwMemSize], eax	;			MemSize = BaseAddrLow + LengthLow;
.2:					;	}
	loop	.loop			;}
					;
	call	DispReturn		;printf("\n");
	push	szRAMSize		;
	call	DispStr			;printf("RAM size:");
	add	esp, 4			;
					;
	push	dword [dwMemSize]	;
	call	DispInt			;DispInt(MemSize);
	add	esp, 4			;

	pop	ecx
	pop	edi
	pop	esi
	ret
;--------------------------------------------------------------------------------------
%include	"lib.inc"	; �⺯��
SegCode32Len		equ	$ - LABEL_SEG_CODE32
; end of section  [SECTION  .s32]

[SECTION  .s16code]		;32 back to 16
ALIGN	32				;16 ����ģʽ
[BITS	16]
LABEL_SEG_CODE16:

	;dbg
	;mov ax, SelectorVideo
	;mov gs, ax
	;mov	edi, (80 * 11 + 0) * 2	;10row, 0 col, һ���ֽڵ����ռ��λ
	;mov ah, 0Ch		;��ʽ
	;mov al, 'P'		;����
	;mov	[gs:edi], ax

	mov	ax, SelectorNormal
	mov	ds, ax
	mov	es, ax
	mov	fs, ax
	mov	gs, ax
	mov	ss, ax

	mov	eax, cr0
	and	eax, 7fffffffh		;close page,�˳�����ģʽҪ�رշ�ҳ
	and	al, 11111110b
	mov	cr0, eax		;1 �˳�protect

LABEL_GO_BACK_TO_REAL:
	jmp 0:LABEL_REAL_ENTRY	;����ֵ

Code16Len	equ	$ - LABEL_SEG_CODE16
; end of [section .s16code]


[SECTION  .ldt1]	; LDT1
ALIGN	32
LABEL_LDT1:
LABEL_LDT_DESC_CODEA:	Descriptor 0, CodeALen - 1, DA_C + DA_32 + DA_DPL3	; Code, 32
LABEL_DESC_STACK1:	Descriptor 0, TopOfStack1, DA_DRWA + DA_32 + DA_DPL3; Stack, 32 λ ,ring3
; end of gdt

LDTLen1		equ	$ - LABEL_LDT1

; LDT1 selector
SelectorLDTCodeA	equ	LABEL_LDT_DESC_CODEA - LABEL_LDT1 + SA_TIL + SA_RPL3	;��ldtѡ��
SelectorStack1		equ	LABEL_DESC_STACK1 - LABEL_LDT1 + SA_TIL + SA_RPL3
; end of [section  .ldt1]

[SECTION .s1]; ��ջ��1
ALIGN	32
[BITS	32]
LABEL_STACK1:
	times 512 db 0
TopOfStack1	equ	$ - LABEL_STACK1 - 1
; END of [SECTION .s1]

[SECTION  .la]	; CodeA  LDT, 32 
ALIGN	32
[BITS	32]
LABEL_CODE_A:
	mov	ax, SelectorVideo
	mov	gs, ax	
	mov	ah, 0Ch	
show1:
	mov	al, 'H'
	mov	[gs:((80 * 17 + 0) * 2)], ax	; ��Ļ�� 17 ��, �� 0 �С�
	mov	al, 'U'
	mov	[gs:((80 * 17 + 1) * 2)], ax	; ��Ļ�� 17 ��, �� 1 �С�
	mov	al, 'S'
	mov	[gs:((80 * 17 + 2) * 2)], ax	; ��Ļ�� 17 ��, �� 2 �С�
	mov	al, 'T'
	mov	[gs:((80 * 17 + 3) * 2)], ax	; ��Ļ�� 17 ��, �� 3 �С�

	jmp	show1
	jmp	SelectorCode16:0		;��ʱ����

CodeALen	equ	$ - LABEL_CODE_A
; end of [section  .la]


[SECTION  .ldt2]	; LDT2
ALIGN	32
LABEL_LDT2:
LABEL_LDT_DESC_CODEB:	Descriptor 0, CodeBLen - 1, DA_C + DA_32 + DA_DPL3	; Code, 32
LABEL_DESC_STACK2:	Descriptor 0, TopOfStack2, DA_DRWA + DA_32 + DA_DPL3; Stack, 32 λ ,ring3
; end of gdt

LDTLen2		equ	$ - LABEL_LDT2

; LDT2 selector
SelectorLDTCodeB	equ	LABEL_LDT_DESC_CODEB - LABEL_LDT2 + SA_TIL + SA_RPL3	;��ldtѡ��
SelectorStack2		equ	LABEL_DESC_STACK2 - LABEL_LDT2 + SA_TIL + SA_RPL3; Stack, 32 λ ,ring3
; end of [section  .ldt2]

[SECTION .s2]; ��ջ��2
ALIGN	32
[BITS	32]
LABEL_STACK2:
	times 512 db 0
TopOfStack2	equ	$ - LABEL_STACK2 - 1
; END of [SECTION .s1]

[SECTION  .lb]	; CodeB  LDT, 32 
ALIGN	32
[BITS	32]
LABEL_CODE_B:
	mov	ax, SelectorVideo
	mov	gs, ax	
	mov	ah, 0Ch	
show2:
	mov	al, 'I'
	mov	[gs:((80 * 17 + 0) * 2)], ax	; ��Ļ�� 17 ��, �� 0 �С�
	mov	al, 'S'
	mov	[gs:((80 * 17 + 1) * 2)], ax	; ��Ļ�� 17 ��, �� 1 �С�
	mov	al, '1'
	mov	[gs:((80 * 17 + 2) * 2)], ax	; ��Ļ�� 17 ��, �� 2 �С�
	mov	al, '9'
	mov	[gs:((80 * 17 + 3) * 2)], ax	; ��Ļ�� 17 ��, �� 3 �С�

	jmp	show2
	jmp	SelectorCode16:0		;��ʱ����

CodeBLen	equ	$ - LABEL_CODE_B
; end of [section  .lb]
