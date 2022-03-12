; ==========================================
; mywork.asm
; 编译方法：nasm mywork.asm -o mywork.com
; 或者: make
; ==========================================
%include	"pm.inc"	; 常量, 宏, 以及一些说明

PageDirBase0		equ	200000h	; 页目录开始地址:	2M
PageTblBase0		equ	201000h	; 页表开始地址:		2M +  4K
;PageDirBase1		equ	210000h	; 页目录开始地址:	2M + 64K
;PageTblBase1		equ	211000h	; 页表开始地址:		2M + 64K + 4K

org	0100h
jmp	LABEL_BEGIN


[SECTION .gdt]
; GDT
;                                         段基址,       段界限     , 属性
LABEL_GDT:		Descriptor	       0,                 0, 0				; 空描述符
LABEL_DESC_NORMAL:	Descriptor	       0,            0ffffh, DA_DRW			; Normal 描述符,帮助其他段改变属性 ,数据段read、write
LABEL_DESC_CODE32:	Descriptor	       0,  SegCode32Len - 1, DA_CR | DA_32		; 非一致代码段, 32
LABEL_DESC_CODE16:	Descriptor	       0,            0ffffh, DA_C			; 非一致代码段, 16
LABEL_DESC_DATA:	Descriptor	       0,	DataLen - 1, DA_DRW			; Data,数据段read、write
LABEL_DESC_STACK:	Descriptor	       0,        TopOfStack02, DA_DRWA | DA_32			; Stack, 32 位、使用esp ,数据段read、write、access
LABEL_DESC_VIDEO:	Descriptor	 0B8000h,            0ffffh, DA_DRW | DA_DPL3		; 显存首地址
LABEL_DESC_FLAT_RW:    Descriptor		0, 		0fffffh, DA_DRW | DA_LIMIT_4K	; 0 ~ 4G，数据段，用于初始化页表

; Task1 
LABEL_DESC_TSS1:	Descriptor		0,	TSSLen1-1,	DA_386TSS | DA_DPL3
LABEL_DESC_LDT1:	Descriptor		0,	LDT_Len1-1,	DA_LDT | DA_DPL3

; Task2
LABEL_DESC_TSS2:	Descriptor		0,	TSSLen2-1,	DA_386TSS | DA_DPL3
LABEL_DESC_LDT2:	Descriptor		0,	LDT_Len2-1,	DA_LDT | DA_DPL3

; GDT 结束

GdtLen		equ	$ - LABEL_GDT	; GDT长度
GdtPtr		dw	GdtLen - 1	; GDT界限
		dd	0		; GDT基地址

; GDT 选择子
SelectorNormal		equ	LABEL_DESC_NORMAL	- LABEL_GDT
SelectorCode32		equ	LABEL_DESC_CODE32	- LABEL_GDT
SelectorCode16		equ	LABEL_DESC_CODE16	- LABEL_GDT
SelectorData		equ	LABEL_DESC_DATA	- LABEL_GDT
SelectorStack		equ	LABEL_DESC_STACK	- LABEL_GDT
SelectorVideo		equ	LABEL_DESC_VIDEO	- LABEL_GDT
SelectorFlatRW		equ	LABEL_DESC_FLAT_RW	- LABEL_GDT

SelectorTSS1		equ	LABEL_DESC_TSS1 - LABEL_GDT + SA_RPL3
SelectorLDT1		equ	LABEL_DESC_LDT1 - LABEL_GDT + SA_RPL3

SelectorTSS2		equ	LABEL_DESC_TSS2 - LABEL_GDT + SA_RPL3
SelectorLDT2		equ	LABEL_DESC_LDT2 - LABEL_GDT + SA_RPL3

; END of [SECTION .gdt]


[SECTION .data1]	 ; 数据段
ALIGN	32
[BITS	32]
LABEL_DATA:
; 实模式下使用这些符号
; 字符串
_szPMMessage:			db	"In Protect Mode now. ^-^", 0Ah, 0Ah, 0	; 进入保护模式后显示此字符串
_szMemChkTitle:			db	"BaseAddrL BaseAddrH LengthLow LengthHigh   Type", 0Ah, 0	; 进入保护模式后显示此字符串
_szRAMSize			db	"RAM size:", 0
_szReturn			db	0Ah, 0
; 变量
_wSPValueInRealMode		dw	0
_dwMCRNumber:			dd	0	; Memory Check Result
_dwDispPos:			dd	(80 * 6 + 0) * 2	; 屏幕第 6 行, 第 0 列。
_dwMemSize:			dd	0
_ARDStruct:			; Address Range Descriptor Structure
	_dwBaseAddrLow:		dd	0
	_dwBaseAddrHigh:	dd	0
	_dwLengthLow:		dd	0
	_dwLengthHigh:		dd	0
	_dwType:		dd	0
_PageTableNumber		dd	0  

_MemChkBuf:	times	256	db	0

_SavedIDTR:			dd	0	; 用于保存 IDTR
				dd	0
_SavedIMREG:			db	0	; 中断屏蔽寄存器值
_NextTask: 			dd	0	; 下一个将要执行的程序代号

; 保护模式下使用这些符号
szPMMessage		equ	_szPMMessage	- $$
szMemChkTitle		equ	_szMemChkTitle	- $$
szRAMSize		equ	_szRAMSize	- $$
szReturn		equ	_szReturn	- $$
dwDispPos		equ	_dwDispPos	- $$
dwMemSize		equ	_dwMemSize	- $$
dwMCRNumber		equ	_dwMCRNumber	- $$
ARDStruct		equ	_ARDStruct	- $$
	dwBaseAddrLow	equ	_dwBaseAddrLow	- $$
	dwBaseAddrHigh	equ	_dwBaseAddrHigh - $$
	dwLengthLow	equ	_dwLengthLow	- $$
	dwLengthHigh	equ	_dwLengthHigh	- $$
	dwType		equ	_dwType	- $$
MemChkBuf		equ	_MemChkBuf	- $$
PageTableNumber	equ	_PageTableNumber- $$
SavedIDTR		equ	_SavedIDTR	- $$
SavedIMREG		equ	_SavedIMREG	- $$
NextTask		equ	_NextTask	- $$

DataLen			equ	$ - LABEL_DATA
; END of [SECTION .data1]


; 全局堆栈段
[SECTION .gs]      ;ring0下的堆栈段
ALIGN	32
[BITS	32]
LABEL_STACK:
	times 256 db 0
TopOfStack	equ	$ - LABEL_STACK - 1   ;给Code32和中断使用的堆栈
	times 256 db 0
TopOfStack01	equ	$ - LABEL_STACK - 1   ;ring0下程序1的堆栈
	times 256 db 0
TopOfStack02	equ	$ - LABEL_STACK - 1   ;ring0下程序2的堆栈

; END of [SECTION .gs]



; IDT
[SECTION .idt]
ALIGN	32
[BITS	32]
LABEL_IDT:
; 门                                目标选择子,            偏移, DCount, 属性
%rep 32
			Gate	SelectorCode32, UserIntHandler,      0, DA_386IGate
%endrep
.020h:			Gate	SelectorCode32,   ClockHandler,      0, DA_386IGate  ;这个是时钟中断
%rep 95
			Gate	SelectorCode32, UserIntHandler,      0, DA_386IGate
%endrep
.080h:			Gate	SelectorCode32,  UserIntHandler,      0, DA_386IGate

IdtLen		equ	$ - LABEL_IDT
IdtPtr		dw	IdtLen - 1	; 段界限
		dd	0		; 基地址
; END of [SECTION .idt]


[SECTION .s16]
[BITS	16]
LABEL_BEGIN:
	mov	ax, cs
	mov	ds, ax
	mov	es, ax
	mov	ss, ax
	mov	sp, 0100h

	mov	[LABEL_GO_BACK_TO_REAL+3], ax
	mov	[_wSPValueInRealMode], sp

	; 得到内存数
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

	; 初始化 16 位代码段描述符
	mov	ax, cs
	movzx	eax, ax
	shl	eax, 4
	add	eax, LABEL_SEG_CODE16
	mov	word [LABEL_DESC_CODE16 + 2], ax
	shr	eax, 16
	mov	byte [LABEL_DESC_CODE16 + 4], al
	mov	byte [LABEL_DESC_CODE16 + 7], ah

	; 初始化 32 位代码段描述符
	xor	eax, eax
	mov	ax, cs
	shl	eax, 4
	add	eax, LABEL_SEG_CODE32
	mov	word [LABEL_DESC_CODE32 + 2], ax
	shr	eax, 16
	mov	byte [LABEL_DESC_CODE32 + 4], al
	mov	byte [LABEL_DESC_CODE32 + 7], ah

	; 初始化数据段描述符
	xor	eax, eax
	mov	ax, ds
	shl	eax, 4
	add	eax, LABEL_DATA
	mov	word [LABEL_DESC_DATA + 2], ax
	shr	eax, 16
	mov	byte [LABEL_DESC_DATA + 4], al
	mov	byte [LABEL_DESC_DATA + 7], ah

	; 初始化堆栈段描述符
	xor	eax, eax
	mov	ax, ds
	shl	eax, 4
	add	eax, LABEL_STACK
	mov	word [LABEL_DESC_STACK + 2], ax
	shr	eax, 16
	mov	byte [LABEL_DESC_STACK + 4], al
	mov	byte [LABEL_DESC_STACK + 7], ah
	
	
	
	; 初始化 TSS1 段描述符
	xor	eax, eax
	mov	ax, cs
	shl	eax, 4
	add	eax, LABEL_TSS1
	mov	word [LABEL_DESC_TSS1 + 2], ax
	shr	eax, 16
	mov	byte [LABEL_DESC_TSS1 + 4], al
	mov	byte [LABEL_DESC_TSS1 + 7], ah
	
	; 初始化 LDT1 段描述符
	xor	eax, eax
	mov	ax, cs
	shl	eax, 4
	add	eax, LABEL_LDT1
	mov	word [LABEL_DESC_LDT1 + 2], ax
	shr	eax, 16
	mov	byte [LABEL_DESC_LDT1 + 4], al
	mov	byte [LABEL_DESC_LDT1 + 7], ah	
	
	; 初始化 Code1 段描述符
	xor	eax, eax
	mov	ax, cs
	shl	eax, 4
	add	eax, LABEL_CODE1
	mov	word [LABEL_LDT_DESC_CODE1 + 2], ax
	shr	eax, 16
	mov	byte [LABEL_LDT_DESC_CODE1 + 4], al
	mov	byte [LABEL_LDT_DESC_CODE1 + 7], ah
	
	; 初始化 Stack1 段描述符
	xor	eax, eax
	mov	ax, cs
	shl	eax, 4
	add	eax, LABEL_STACK1
	mov	word [LABEL_LDT_DESC_STACK1 + 2], ax
	shr	eax, 16
	mov	byte [LABEL_LDT_DESC_STACK1 + 4], al
	mov	byte [LABEL_LDT_DESC_STACK1 + 7], ah


	; 初始化 TSS2 段描述符
	xor	eax, eax
	mov	ax, cs
	shl	eax, 4
	add	eax, LABEL_TSS2
	mov	word [LABEL_DESC_TSS2 + 2], ax
	shr	eax, 16
	mov	byte [LABEL_DESC_TSS2 + 4], al
	mov	byte [LABEL_DESC_TSS2 + 7], ah
	
	; 初始化 LDT2 段描述符
	xor	eax, eax
	mov	ax, cs
	shl	eax, 4
	add	eax, LABEL_LDT2
	mov	word [LABEL_DESC_LDT2 + 2], ax
	shr	eax, 16
	mov	byte [LABEL_DESC_LDT2 + 4], al
	mov	byte [LABEL_DESC_LDT2 + 7], ah	
	
	; 初始化 Code2 段描述符
	xor	eax, eax
	mov	ax, cs
	shl	eax, 4
	add	eax, LABEL_CODE2
	mov	word [LABEL_LDT_DESC_CODE2 + 2], ax
	shr	eax, 16
	mov	byte [LABEL_LDT_DESC_CODE2 + 4], al
	mov	byte [LABEL_LDT_DESC_CODE2 + 7], ah
	
	; 初始化 Stack2 段描述符
	xor	eax, eax
	mov	ax, cs
	shl	eax, 4
	add	eax, LABEL_STACK2
	mov	word [LABEL_LDT_DESC_STACK2 + 2], ax
	shr	eax, 16
	mov	byte [LABEL_LDT_DESC_STACK2 + 4], al
	mov	byte [LABEL_LDT_DESC_STACK2 + 7], ah


	; 为加载 GDTR 作准备
	xor	eax, eax
	mov	ax, ds
	shl	eax, 4
	add	eax, LABEL_GDT		; eax <- gdt 基地址
	mov	dword [GdtPtr + 2], eax	; [GdtPtr + 2] <- gdt 基地址

	; 为加载 IDTR 作准备
	xor	eax, eax
	mov	ax, ds
	shl	eax, 4
	add	eax, LABEL_IDT		; eax <- idt 基地址
	mov	dword [IdtPtr + 2], eax	; [IdtPtr + 2] <- idt 基地址

	; 保存 IDTR
	sidt	[_SavedIDTR]

	; 保存中断屏蔽寄存器(IMREG)值
	in	al, 21h
	mov	[_SavedIMREG], al
	
	; 加载 GDTR
	lgdt	[GdtPtr]
	
	; 关中断
	cli
	
	; 加载 IDTR
	lidt	[IdtPtr]
	
	; 打开地址线A20
	in	al, 92h
	or	al, 00000010b
	out	92h, al

	; 准备切换到保护模式
	mov	eax, cr0
	or	eax, 1
	mov	cr0, eax

	; 真正进入保护模式
	jmp	dword SelectorCode32:0	; 执行这一句会把 SelectorCode32 装入 cs, 并跳转到 Code32Selector:0  处

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

LABEL_REAL_ENTRY:		; 从保护模式跳回到实模式就到了这里
	mov	ax, cs
	mov	ds, ax
	mov	es, ax
	mov	ss, ax

	mov	sp, [_wSPValueInRealMode]   ;恢复栈基址
	
	lidt	[_SavedIDTR]	; 恢复 IDTR 的原值
	mov	al, [_SavedIMREG]		; ┓恢复中断屏蔽寄存器(IMREG)的原值
	out	21h, al			; ┛
	
	in	al, 92h		; ┓
	and	al, 11111101b	; ┣ 关闭 A20 地址线
	out	92h, al		; ┛

	sti			; 开中断

	mov	ax, 4c00h	; ┓
	int	21h		; ┛回到 DOS
; END of [SECTION .s16]


[SECTION .s32]; 32 位代码段. 由实模式跳入.
[BITS	32]

LABEL_SEG_CODE32:
	mov	ax, SelectorData
	mov	ds, ax			; 数据段选择子
	mov	es, ax
	mov	ax, SelectorVideo
	mov	gs, ax			; 视频段选择子

	mov	ax, SelectorStack
	mov	ss, ax			; 堆栈段选择子

	mov	esp, TopOfStack


	; 下面显示一个字符串
	push	szPMMessage
	call	DispStr
	add	esp, 4

	push	szMemChkTitle
	call	DispStr
	add	esp, 4

	call	DispMemSize		; 显示内存信息
	;call    SetupPaging
	
	
	call	Init8259A
	;int	080h
	sti
	;jmp	$
	
	; Load LDT2
	mov	ax, SelectorLDT2
	lldt	ax

	; Load TSS2
	mov	ax, SelectorTSS2
	ltr	ax	; 在任务内发生特权级变换时要切换堆栈
	push	SelectorLDTStack2
	push	TopOfStack2
	push	SelectorLDTCode2
	push	0
	retf				; Ring0 -> Ring3	进入时段寄存器内容要合法
	jmp $
	call	SetRealmode8259A
	; 到此停止
	jmp	SelectorCode16:0

; 启动分页机制 --------------------------------------------------------------
SetupPaging:
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

	; 为简化处理, 所有线性地址对应相等的物理地址. 并且不考虑内存空洞.

	; 首先初始化页目录
	mov	ax, SelectorFlatRW
	mov	es, ax
	mov	edi, PageDirBase0	; 此段首地址为 PageDirBase0
	xor	eax, eax
	mov	eax, PageTblBase0 | PG_P  | PG_USU | PG_RWW
.1:
	stosd
	add	eax, 4096		; 为了简化, 所有页表在内存中是连续的.
	loop	.1

	; 再初始化所有页表
	mov	eax, [PageTableNumber]	; 页表个数
	mov	ebx, 1024		; 每个页表 1024 个 PTE
	mul	ebx
	mov	ecx, eax		; PTE个数 = 页表个数 * 1024
	mov	edi, PageTblBase0	; 此段首地址为 PageTblBase0
	xor	eax, eax
	mov	eax, PG_P  | PG_USU | PG_RWW
.2:
	stosd
	add	eax, 4096		; 每一页指向 4K 的空间
	loop	.2

	mov	eax, PageDirBase0
	mov	cr3, eax
	mov	eax, cr0
	or	eax, 80000000h
	mov	cr0, eax
	jmp	short .3
.3:
	nop

	ret
; 分页机制启动完毕 ----------------------------------------------------------

; 显示内存信息 --------------------------------------------------------------
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
; ---------------------------------------------------------------------------

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
	push	ecx		;保存中断前的运行现场
	;inc	byte [gs:((80 * 0 + 70) * 2)]	; 屏幕第 0 行, 第 70 列。
	mov	ax, SelectorData
	mov	ds, ax
	mov	ecx, [ds:NextTask]  ;获得下一个要制定的进程代号
	mov	al, 20h
	out	20h, al		;发送 EOI	
	cmp 	ecx, 0
	jnz	Task2Display
Task1Display:
	mov 	ecx, 1
	mov	[ds:NextTask], ecx				; 存回去
	sti				;
	jmp	SelectorTSS1:0	; 跳入局部任务，Task1。
	jmp	Final

Task2Display:
	mov 	ecx, 0
	mov	[ds:NextTask], ecx				; 存回去
	sti				;
	jmp	SelectorTSS2:0	; 跳入局部任务，Task2
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

_SpuriousHandler:
SpuriousHandler	equ	_SpuriousHandler - $$
	mov	ah, 0Ch				; 0000: 黑底    1100: 红字
	mov	al, '!'
	mov	[gs:((80 * 0 + 75) * 2)], ax	; 屏幕第 0 行, 第 75 列。
	jmp	$
	iretd
; ---------------------------------------------------------------------------

%include	"lib.inc"	; 库函数

SegCode32Len	equ	$ - LABEL_SEG_CODE32
; END of [SECTION .s32]


[SECTION  .s16code]		;32位 回到 16位 需要通过这个段的代码
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
; end of [SECTION .s16code]









[SECTION  .ldt1]	; LDT1
ALIGN	32
LABEL_LDT1:		Descriptor 0, 		0, 	0
LABEL_LDT_DESC_CODE1:	Descriptor 0, Code1Len - 1, DA_C + DA_32 + DA_DPL3	; Code, 32
LABEL_LDT_DESC_STACK1:	Descriptor 0, TopOfStack1, DA_DRWA + DA_32 + DA_DPL3; Stack, 32 位 ,ring3
; end of gdt

LDT_Len1		equ	$ - $$

; LDT1 selector
SelectorLDTCode1	equ	LABEL_LDT_DESC_CODE1 - $$ + SA_TIL + SA_RPL3	;在ldt选择
SelectorLDTStack1		equ	LABEL_LDT_DESC_STACK1 - $$ + SA_TIL + SA_RPL3
; end of [section  .ldt1]


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
		DD	PageDirBase0		; CR3不会自动填入
		DD	0			; EIP
		DD	0x200			; EFLAGS
		DD	0			; EAX
		DD	0			; ECX
		DD	0			; EDX
		DD	0			; EBX
		DD	TopOfStack1		; ESP
		DD	0			; EBP
		DD	0			; ESI
		DD	0			; EDI
		DD	0			; ES
		DD	SelectorLDTCode1	; CS
		DD	SelectorLDTStack1	; SS
		DD	0			; DS
		DD	0			; FS
		DD	0			; GS
		DD	SelectorLDT1		; LDT 不会自动填入
		DW	0			; 调试陷阱标志
		DW	$ - LABEL_TSS1 + 2	; I/O位图基址
		DB	0ffh			; I/O位图结束标志
TSSLen1		equ	$ - $$

[SECTION .s1]; 堆栈段1
ALIGN	32
[BITS	32]
LABEL_STACK1:
	times 512 db 0
TopOfStack1	equ	$ - $$ - 1
; END of [SECTION .s1]

[SECTION  .la]	; Code1  LDT, 32 
ALIGN	32
[BITS	32]
LABEL_CODE1:
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

	jmp	show1   ;死循环
	;jmp	SelectorCode16:0		;暂时到这

Code1Len	equ	$ - $$
; end of [section  .la]








[SECTION  .ldt2]	; LDT2
ALIGN	32
LABEL_LDT2:		Descriptor 0, 		0, 	0
LABEL_LDT_DESC_CODE2:	Descriptor 0, Code2Len - 1, DA_C + DA_32 + DA_DPL3	; Code, 32
LABEL_LDT_DESC_STACK2:	Descriptor 0, TopOfStack2, DA_DRWA + DA_32 + DA_DPL3; Stack, 32 位 ,ring3
; end of gdt

LDT_Len2		equ	$ - LABEL_LDT2

; LDT2 selector
SelectorLDTCode2	equ	LABEL_LDT_DESC_CODE2 - $$ + SA_TIL + SA_RPL3	;在ldt选择
SelectorLDTStack2		equ	LABEL_LDT_DESC_STACK2 - $$ + SA_TIL + SA_RPL3
; end of [section  .ldt2]


[SECTION .tss2]		;为了从低特权级进入高特权级,加载时要保证寄存器为合法值
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
		DD	PageDirBase0	; CR3不会自动填入
		DD	0			; EIP
		DD	0x200			; EFLAGS
		DD	0			; EAX
		DD	0			; ECX
		DD	0			; EDX
		DD	0			; EBX
		DD	TopOfStack2		; ESP
		DD	0			; EBP
		DD	0			; ESI
		DD	0			; EDI
		DD	0			; ES
		DD	SelectorLDTCode2	; CS
		DD	SelectorLDTStack2	; SS
		DD	0			; DS
		DD	0			; FS
		DD	0			; GS
		DD	SelectorLDT2		; LDT 不会自动填入
		DW	0			; 调试陷阱标志
		DW	$ - LABEL_TSS2 + 2	; I/O位图基址
		DB	0ffh			; I/O位图结束标志
TSSLen2		equ	$ - $$

[SECTION .s2]; 堆栈段2
ALIGN	32
[BITS	32]
LABEL_STACK2:
	times 512 db 0
TopOfStack2	equ	$ - $$ - 1
; END of [SECTION .s2]

[SECTION  .la]	; Code2  LDT, 32 
ALIGN	32
[BITS	32]
LABEL_CODE2:
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
	;int 020h
	jmp	show2   ;死循环
	;jmp	SelectorCode16:0		;暂时到这

Code2Len	equ	$ - $$
; end of [section  .la]


