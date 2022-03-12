%include "pm.inc"
org 0100h

PageDirBase1		equ	200000h	; 页目录开始地址:	2M
PageTblBase1		equ	201000h	; 页表开始地址:		2M +  4K
PageDirBase2		equ	210000h	; 页目录开始地址:	2M + 64K
PageTblBase2		equ	211000h	; 页表开始地址:		2M + 64K + 4K

jmp LABEL_BEGIN


[SECTION  .gdt]		;GDT
LABEL_GDT:			Descriptor 0, 0, 0		;empty descriptor
LABEL_DESC_NORMAL:	Descriptor 0, 0ffffh, DA_DRW	; 帮助其他段改变属性 ,数据段read、write
LABEL_DESC_CODE16:	Descriptor 0, 0ffffh, DA_C		; 帮助cs改变属性, 16, code
LABEL_DESC_CODE32:	Descriptor 0, SegCode32Len - 1, DA_C + DA_32	; codeD, 32
LABEL_DESC_VIDEO:	Descriptor 0B8000h, 0ffffh, DA_DRW + DA_DPL3   ;显存,数据段read、write, ring3
LABEL_DESC_DATA:	Descriptor 0, DataLen - 1, DA_DRW	;数据段read、write
LABEL_DESC_STACK:	Descriptor 0, TopOfStack02, DA_DRWA + DA_32	; Stack, 32 位、使用esp ,数据段read、write、access
LABEL_DESC_TSS1:	Descriptor 0, TSSLen1 - 1, DA_386TSS + DA_DPL3; TSS1
LABEL_DESC_LDT1:	Descriptor 0, LDTLen1 - 1, DA_LDT + DA_DPL3;LDT1
LABEL_DESC_TSS2:	Descriptor 0, TSSLen2 - 1, DA_386TSS + DA_DPL3; TSS2
LABEL_DESC_LDT2:	Descriptor 0, LDTLen2 - 1, DA_LDT + DA_DPL3;LDT2
LABEL_DESC_FLAT_RW:	Descriptor 0, 0fffffh, DA_DRW | DA_LIMIT_4K	; 0 ~ 4G，数据段，用于初始化页表
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

[SECTION .data1]	 ;数据段
ALIGN	32
[BITS	32]
LABEL_DATA:
SPValueInRealMode	dw	0	

_szPMMessage:			db	"In Protect Mode now. ^-^", 0Ah, 0Ah, 0	; 进入保护模式后显示此字符串
_szMemChkTitle:			db	"BaseAddrL BaseAddrH LengthLow LengthHigh   Type", 0Ah, 0	; 进入保护模式后显示此字符串
_szRAMSize			db	"RAM size:", 0
_szReturn			db	0Ah, 0
; 变量
_dwMCRNumber:			dd	0	; Memory Check Result
_dwDispPos:			dd	(80 * 6 + 0) * 2	;确定输出位置 屏幕第 6 行, 第 0 列
_dwMemSize:			dd	0
_ARDStruct:			; Address Range Descriptor Structure
	_dwBaseAddrLow:		dd	0
	_dwBaseAddrHigh:	dd	0
	_dwLengthLow:		dd	0
	_dwLengthHigh:		dd	0
	_dwType:			dd	0
_MemChkBuf:	times	256	db	0

_PageTableNumber		dd	0	;不用重复计算页表项数


_SavedIDTR:			dd	0	; 用于保存 IDTR
					dd	0
_SavedIMREG:		db	0	; 中断屏蔽寄存器值
;***********************************************
_seltss				dd	0	; 任务选择
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
IdtPtr		dw	IdtLen - 1	; 段界限
			dd	0		; 基地址
; END of [SECTION .idt]


[SECTION .gs]	;32ring 0 堆栈
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
[SECTION .tss1]		;为了从低特权级进入高特权级,加载时要保证寄存器为合法值
ALIGN	32
[BITS	32]
LABEL_TSS1:
		DD	0			; Back
		DD	TopOfStack01	; 0 级堆栈
		DD	SelectorStack	; 
		DD	0			; 1 级堆栈
		DD	0			; 
		DD	0			; 2 级堆栈
		DD	0			; 
		DD	PageDirBase1	; CR3不会自动填入
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
		DD	SelectorLDT1	; LDT 不会自动填入
		DW	0			; 调试陷阱标志
		DW	$ - LABEL_TSS1 + 2	; I/O位图基址
		DB	0ffh			; I/O位图结束标志
TSSLen1		equ	$ - LABEL_TSS1

[SECTION .tss2]		;为了从低特权级进入高特权级
ALIGN	32
[BITS	32]
LABEL_TSS2:
		DD	0			; Back
		DD	TopOfStack02	; 0 级堆栈
		DD	SelectorStack	; 
		DD	0			; 1 级堆栈
		DD	0			; 
		DD	0			; 2 级堆栈
		DD	0			; 
		DD	PageDirBase1	; CR3
		DD	0			; EIP
		DD	0x200		; EFLAGS		;允许中断
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
		DW	0			; 调试陷阱标志
		DW	$ - LABEL_TSS2 + 2	; I/O位图基址
		DB	0ffh			; I/O位图结束标志

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
	mov sp, 0100h	;前100h为栈空间

	mov	[LABEL_GO_BACK_TO_REAL + 3], ax	;指令填值
	mov	[SPValueInRealMode], sp			;栈顶保存

	; 得到内存信息
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
	call	Getbase		;赋值base

	;base of code32
	mov ax, cs
	mov	ebx, LABEL_SEG_CODE32
	call	Getadd		; eax = cs:LABEL_SEG_CODE32
	mov	bx, LABEL_DESC_CODE32
	call	Getbase		;赋值base

	; base of data
	mov ax, ds
	mov	ebx, LABEL_DATA
	call	Getadd		; eax = ds:LABEL_DATA
	mov	bx, LABEL_DESC_DATA
	call	Getbase		;赋值base

	; base of stack
	mov ax, ds
	mov	ebx, LABEL_STACK
	call	Getadd		; eax = ds:LABEL_STACK
	mov	bx, LABEL_DESC_STACK
	call	Getbase		;赋值base

	; base of TSS1
	mov ax, ds
	mov	ebx, LABEL_TSS1
	call	Getadd		; eax = ds:LABEL_TSS1
	mov	bx, LABEL_DESC_TSS1
	call	Getbase		;赋值base

	; base of stack1
	mov ax, ds
	mov	ebx, LABEL_STACK1
	call	Getadd		; eax = ds:LABEL_STACK1
	mov	bx, LABEL_DESC_STACK1
	call	Getbase		;赋值base

	; base of ldt1 seg
	mov ax, ds
	mov	ebx, LABEL_LDT1
	call	Getadd		; eax = ds:LABEL_LDT1
	mov	bx, LABEL_DESC_LDT1
	call	Getbase		;赋值base

	; base of ldt1 code
	mov ax, ds
	mov	ebx, LABEL_CODE_A
	call	Getadd		; eax = ds:LABEL_CODE_A
	mov	bx, LABEL_LDT_DESC_CODEA
	call	Getbase		;赋值base

	; base of TSS2
	mov ax, ds
	mov	ebx, LABEL_TSS2
	call	Getadd		; eax = ds:LABEL_TSS2
	mov	bx, LABEL_DESC_TSS2
	call	Getbase		;赋值base

	; base of stack2
	mov ax, ds
	mov	ebx, LABEL_STACK2
	call	Getadd		; eax = ds:LABEL_STACK2
	mov	bx, LABEL_DESC_STACK2
	call	Getbase		;赋值base

	; base of ldt2 seg
	mov ax, ds
	mov	ebx, LABEL_LDT2
	call	Getadd		; eax = ds:LABEL_LDT2
	mov	bx, LABEL_DESC_LDT2
	call	Getbase		;赋值base

	; base of ldt2 code
	mov ax, ds
	mov	ebx, LABEL_CODE_B
	call	Getadd		; eax = ds:LABEL_CODE_B
	mov	bx, LABEL_LDT_DESC_CODEB
	call	Getbase		;赋值base
	

	;prepare
	mov ax, ds
	mov	ebx, LABEL_GDT
	call	Getadd		;base of gdt  eax = ds:LABEL_GDT
	mov dword [GdtPtr + 2], eax		;	[GdtPtr + 2] = eax

	; 为加载 IDTR 作准备
	mov ax, ds
	mov	ebx, LABEL_IDT
	call	Getadd		;base of idt
	mov	dword [IdtPtr + 2], eax	; [IdtPtr + 2] <- idt 基地址

	; 保存 IDTR
	sidt	[_SavedIDTR]

	; 保存中断屏蔽寄存器(IMREG)值
	in	al, 21h
	mov	[_SavedIMREG], al

	lidt	[IdtPtr]	; 加载 IDTR

	lgdt	[GdtPtr]	;1 load gdt
	cli					;2 关中断
	in	al, 92h
	or	al, 00000010b
	out	92h, al			;3 打开地址线
	mov	eax, cr0
	or	eax, 1
	mov	cr0, eax		;4 cr0
	jmp dword SelectorCode32:0	;5 进入protect

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;return here
LABEL_REAL_ENTRY:		; 从保护模式跳回到实模式就到了这里
	mov	ax, cs
	mov	ds, ax
	mov	es, ax
	mov	ss, ax
	mov	sp, [SPValueInRealMode]		;恢复栈
	
	lidt	[_SavedIDTR]	; 恢复 IDTR 的原值

	in	al, 92h		
	and	al, 11111101b	 
	out	92h, al			; 2 关闭地址线
	sti					; 3 开中断
	mov	ax, 4c00h
	int	21h			; 退出
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

	;实现功能
	; 下面显示一个字符串
	push	szPMMessage
	call	DispStr
	add	esp, 4

	push	szMemChkTitle
	call	DispStr
	add	esp, 4
	call	DispMemSize		; 显示内存信息

	call	GetMemSize
	
	mov	eax, PageTblBase1
	mov	ebx, PageDirBase1
	call	InitPaging	;初始化页表1

	mov	eax, PageTblBase2
	mov	ebx, PageDirBase2
	call	InitPaging	;初始化页表2
	
	call	StartPage	;开启分页
	;call	SelectorCallGateTest:10	; 调用门	偏移值不影响调用
	;call	SelectorCodeDest:0

	; Load LDT
	mov	ax, SelectorLDT1
	lldt	ax

	; Load TSS1
	mov	ax, SelectorTSS1
	ltr	ax	; 在任务内发生特权级变换时要切换堆栈
;***********************************************
	call	Init8259A
	sti
;***********************************************
	;mov	ax, SelectorNormal
	;mov	es, ax			;保证合法性

	push	SelectorStack1
	push	TopOfStack1
	push	SelectorLDTCodeA
	push	0
	retf				; Ring0 -> Ring3	进入时段寄存器内容要合法

	call	SetRealmode8259A
	jmp	SelectorCode16:0		;暂时到这

;***********************************************
	; Init8259A ---------------------------------------------------------------------------------------------
Init8259A:
	mov	al, 011h
	out	020h, al	; 主8259, ICW1.
	call	io_delay

	out	0A0h, al	; 从8259, ICW1.
	call	io_delay

	mov	al, 020h	; IRQ0 对应中断向量 0x20
	out	021h, al	; 主8259, ICW2.
	call	io_delay

	mov	al, 028h	; IRQ8 对应中断向量 0x28
	out	0A1h, al	; 从8259, ICW2.
	call	io_delay

	mov	al, 004h	; IR2 对应从8259
	out	021h, al	; 主8259, ICW3.
	call	io_delay

	mov	al, 002h	; 对应主8259的 IR2
	out	0A1h, al	; 从8259, ICW3.
	call	io_delay

	mov	al, 001h
	out	021h, al	; 主8259, ICW4.
	call	io_delay

	out	0A1h, al	; 从8259, ICW4.
	call	io_delay

	mov	al, 11111110b	; 仅仅开启定时器中断
	;mov	al, 11111111b	; 屏蔽主8259所有中断
	out	021h, al	; 主8259, OCW1.
	call	io_delay

	mov	al, 11111111b	; 屏蔽从8259所有中断
	out	0A1h, al	; 从8259, OCW1.
	call	io_delay

	ret
; Init8259A ---------------------------------------------------------------------------------------------


; SetRealmode8259A ---------------------------------------------------------------------------------------------
SetRealmode8259A:
	mov	ax, SelectorData
	mov	fs, ax

	mov	al, 017h
	out	020h, al	; 主8259, ICW1.
	call	io_delay

	mov	al, 008h	; IRQ0 对应中断向量 0x8
	out	021h, al	; 主8259, ICW2.
	call	io_delay

	mov	al, 001h
	out	021h, al	; 主8259, ICW4.
	call	io_delay

	mov	al, [fs:SavedIMREG]	; ┓恢复中断屏蔽寄存器(IMREG)的原值
	out	021h, al		; ┛
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
	out	20h, al				; 发送 EOI

	test	ecx, 1
	jnz MRSUDisplay	
HUSTDisplay:
	
	sti				;
	jmp	SelectorTSS1:0	; 跳入局部任务，HUST。
	jmp	Final

MRSUDisplay:
	
	sti				;
	jmp	SelectorTSS2:0	; 跳入局部任务，MRSU

Final:
	
	pop	ecx
	pop	eax
	iretd

_UserIntHandler:
UserIntHandler	equ	_UserIntHandler - $$
	mov	ah, 0Ch				; 0000: 黑底    1100: 红字
	mov	al, 'I'
	mov	[gs:((80 * 0 + 70) * 2)], ax	; 屏幕第 0 行, 第 70 列。
	iretd
; ---------------------------------------------------------------------------

;***********************************************
; 启动分页机制 --------------------------------------------------------------
GetMemSize:
	; 根据内存大小计算应初始化多少PDE以及多少页表
	xor	edx, edx
	mov	eax, [dwMemSize]
	mov	ebx, 400000h	; 400000h = 4M = 4096 * 1024, 一个页表对应的内存大小
	div	ebx
	mov	ecx, eax	; 此时 ecx 为页表的个数，也即 PDE 应该的个数
	test	edx, edx
	jz	.no_remainder
	inc	ecx		; 如果余数不为 0 就需增加一个页表
.no_remainder:
	mov	[PageTableNumber], ecx	; 暂存页表个数	
	ret

InitPaging:
	; 为简化处理, 所有线性地址对应相等的物理地址. 并且不考虑内存空洞.
	push	eax
	or	eax, PG_P  | PG_USU | PG_RWW
	push	eax
	push	ebx
	; 首先初始化页目录
	mov	ax, SelectorFlatRW
	mov	es, ax
	pop	edi			; edi = PageDirBase
	pop	eax			; eax = PageTblBase | PG_P  | PG_USU | PG_RWW
	mov	ecx, [PageTableNumber]
	
.1:
	stosd
	add	eax, 4096		; 为了简化, 所有页表在内存中是连续的.
	loop	.1

	; 再初始化所有页表
	mov	eax, [PageTableNumber]	; 页表个数
	mov	ebx, 1024		; 每个页表 1024 个 PTE
	mul	ebx
	mov	ecx, eax		; PTE个数 = 页表个数 * 1024
	pop	edi				;edi = PageTblBase
	xor	eax, eax
	mov	eax, PG_P  | PG_USU | PG_RWW
.2:
	stosd
	add	eax, 4096		; 每一页指向 4K 的空间
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
; 分页机制启动完毕 ----------------------------------------------------------

;显示内存信息----------------------------------------------------------------
DispMemSize:
	push	esi
	push	edi
	push	ecx

	mov	esi, MemChkBuf
	mov	ecx, [dwMCRNumber]	;for(int i=0;i<[MCRNumber];i++) // 每次得到一个ARDS(Address Range Descriptor Structure)结构
.loop:					;{
	mov	edx, 5			;	for(int j=0;j<5;j++)	// 每次得到一个ARDS中的成员，共5个成员
	mov	edi, ARDStruct		;	{			// 依次显示：BaseAddrLow，BaseAddrHigh，LengthLow，LengthHigh，Type
.1:					;
	push	dword [esi]		;
	call	DispInt			;		DispInt(MemChkBuf[j*4]); // 显示一个成员
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
%include	"lib.inc"	; 库函数
SegCode32Len		equ	$ - LABEL_SEG_CODE32
; end of section  [SECTION  .s32]

[SECTION  .s16code]		;32 back to 16
ALIGN	32				;16 保护模式
[BITS	16]
LABEL_SEG_CODE16:

	;dbg
	;mov ax, SelectorVideo
	;mov gs, ax
	;mov	edi, (80 * 11 + 0) * 2	;10row, 0 col, 一个字节的输出占两位
	;mov ah, 0Ch		;格式
	;mov al, 'P'		;内容
	;mov	[gs:edi], ax

	mov	ax, SelectorNormal
	mov	ds, ax
	mov	es, ax
	mov	fs, ax
	mov	gs, ax
	mov	ss, ax

	mov	eax, cr0
	and	eax, 7fffffffh		;close page,退出保护模式要关闭分页
	and	al, 11111110b
	mov	cr0, eax		;1 退出protect

LABEL_GO_BACK_TO_REAL:
	jmp 0:LABEL_REAL_ENTRY	;待填值

Code16Len	equ	$ - LABEL_SEG_CODE16
; end of [section .s16code]


[SECTION  .ldt1]	; LDT1
ALIGN	32
LABEL_LDT1:
LABEL_LDT_DESC_CODEA:	Descriptor 0, CodeALen - 1, DA_C + DA_32 + DA_DPL3	; Code, 32
LABEL_DESC_STACK1:	Descriptor 0, TopOfStack1, DA_DRWA + DA_32 + DA_DPL3; Stack, 32 位 ,ring3
; end of gdt

LDTLen1		equ	$ - LABEL_LDT1

; LDT1 selector
SelectorLDTCodeA	equ	LABEL_LDT_DESC_CODEA - LABEL_LDT1 + SA_TIL + SA_RPL3	;在ldt选择
SelectorStack1		equ	LABEL_DESC_STACK1 - LABEL_LDT1 + SA_TIL + SA_RPL3
; end of [section  .ldt1]

[SECTION .s1]; 堆栈段1
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
	mov	[gs:((80 * 17 + 0) * 2)], ax	; 屏幕第 17 行, 第 0 列。
	mov	al, 'U'
	mov	[gs:((80 * 17 + 1) * 2)], ax	; 屏幕第 17 行, 第 1 列。
	mov	al, 'S'
	mov	[gs:((80 * 17 + 2) * 2)], ax	; 屏幕第 17 行, 第 2 列。
	mov	al, 'T'
	mov	[gs:((80 * 17 + 3) * 2)], ax	; 屏幕第 17 行, 第 3 列。

	jmp	show1
	jmp	SelectorCode16:0		;暂时到这

CodeALen	equ	$ - LABEL_CODE_A
; end of [section  .la]


[SECTION  .ldt2]	; LDT2
ALIGN	32
LABEL_LDT2:
LABEL_LDT_DESC_CODEB:	Descriptor 0, CodeBLen - 1, DA_C + DA_32 + DA_DPL3	; Code, 32
LABEL_DESC_STACK2:	Descriptor 0, TopOfStack2, DA_DRWA + DA_32 + DA_DPL3; Stack, 32 位 ,ring3
; end of gdt

LDTLen2		equ	$ - LABEL_LDT2

; LDT2 selector
SelectorLDTCodeB	equ	LABEL_LDT_DESC_CODEB - LABEL_LDT2 + SA_TIL + SA_RPL3	;在ldt选择
SelectorStack2		equ	LABEL_DESC_STACK2 - LABEL_LDT2 + SA_TIL + SA_RPL3; Stack, 32 位 ,ring3
; end of [section  .ldt2]

[SECTION .s2]; 堆栈段2
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
	mov	[gs:((80 * 17 + 0) * 2)], ax	; 屏幕第 17 行, 第 0 列。
	mov	al, 'S'
	mov	[gs:((80 * 17 + 1) * 2)], ax	; 屏幕第 17 行, 第 1 列。
	mov	al, '1'
	mov	[gs:((80 * 17 + 2) * 2)], ax	; 屏幕第 17 行, 第 2 列。
	mov	al, '9'
	mov	[gs:((80 * 17 + 3) * 2)], ax	; 屏幕第 17 行, 第 3 列。

	jmp	show2
	jmp	SelectorCode16:0		;暂时到这

CodeBLen	equ	$ - LABEL_CODE_B
; end of [section  .lb]
