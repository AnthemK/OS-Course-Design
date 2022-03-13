; ==========================================
; pmtest5.asm
; 编译方法：nasm pmtest5.asm -o pmtest5.com
;程序的大致执行过程是：保护模式下进入16b的代码段，ring=0，初始化相关段描述符、门描述符、ldt描述符、数据段描述符、堆栈段描述符、ldt中的描述符、ring 3的代码段描述符TSS描述符；
;加载gdt，通过长jmp，进入保护模式，进入32b的代码段，ring =0：初始化数据段、堆栈段、视频段的选择子寄存器；显示一个字符串；load TSS；
;利用retf指令，从ring 0转移到ring 3的代码段：在代码段中显示‘3’，然后通过调用门进入ring 0的代码段：打印字母C，然后通过jmp跳转到局部代码段：打印字母‘L’；程序回到ring 3，成为循环。
; ==========================================

%include	"pm.inc"	; 常量, 宏, 以及一些说明

org	0100h
	jmp	LABEL_BEGIN     ;LABEL_BEGIN 程序代码运行时的入口处，是在实模式下，不需要选择子

[SECTION .gdt]
; GDT
;                                         段基址,         段界限     , 属性
LABEL_GDT:		Descriptor	       0,                   0, 0			; 空描述符
LABEL_DESC_NORMAL:	Descriptor	       0,              0ffffh, DA_DRW			; Normal 描述符
LABEL_DESC_CODE32:	Descriptor	       0,    SegCode32Len - 1, DA_C + DA_32		; 非一致代码段, 32;程序段描述符的基地址首先置位0，以后还要重置为32位程序段物理首地址
LABEL_DESC_CODE16:	Descriptor	       0,              0ffffh, DA_C			; 非一致代码段, 16
LABEL_DESC_CODE_DEST:	Descriptor	       0,  SegCodeDestLen - 1, DA_C + DA_32		; 非一致代码段, 32;实际基址在s16实模式中
LABEL_DESC_CODE_RING3:	Descriptor	       0, SegCodeRing3Len - 1, DA_C + DA_32 + DA_DPL3	; 非一致代码段, 32
LABEL_DESC_DATA:	Descriptor	       0,	  DataLen - 1, DA_DRW			; Data
LABEL_DESC_STACK:	Descriptor	       0,          TopOfStack, DA_DRWA + DA_32		; Stack, 32 位
LABEL_DESC_STACK3:	Descriptor	       0,         TopOfStack3, DA_DRWA + DA_32 + DA_DPL3; Stack, 32 位，ring3
LABEL_DESC_LDT:		Descriptor	       0,          LDTLen - 1, DA_LDT			; LDT
LABEL_DESC_TSS:		Descriptor	       0,          TSSLen - 1, DA_386TSS		; TSS
LABEL_DESC_VIDEO:	Descriptor	 0B8000h,              0ffffh, DA_DRW + DA_DPL3		; 显存首地址,这个32位程序段的物理首地址是在实模式下计算得到的.;为了能在ring 3中读写显存，我们改变了显存段的特权级别

; 门                                            目标选择子,       偏移, DCount, 属性
LABEL_CALL_GATE_TEST:	Gate		  SelectorCodeDest,          0,      0, DA_386CGate + DA_DPL3  ;门描述符的特权级别也是ring 3，不然没法访问；Gate为宏，与Descriptor类似
; GDT 结束

GdtLen		equ	$ - LABEL_GDT	; GDT长度
GdtPtr		dw	GdtLen - 1	; GDT界限,长度都是实际长度减一;定义了一个Gdtptr的数据结构，低16位dw部分为位段界限，高32位为0，一共48位，高32位以后还要重置
		dd	0		; GDT基地址，段基地址，这里之所以没有直接制定，是因为还没有确定保护模式下gdt的基地址;0，1为低16位，高32位是从2开始，所以GdtPtr+2。高32位应该放GDT的物理地址

; GDT 选择子
SelectorNormal		equ	LABEL_DESC_NORMAL	- LABEL_GDT					;这个选择子跳转到下面的实模式代码段
SelectorCode32		equ	LABEL_DESC_CODE32	- LABEL_GDT					;这个选择子跳转到下面的32位保护模式代码段。因为selector选择子是用在保护模式下的， 即使是32位的保护模式
SelectorCode16		equ	LABEL_DESC_CODE16	- LABEL_GDT                 ;这个选择子跳转到下面的16位保护模式代码段。因为selector选择子是用在保护模式下的， 即使是16位的保护模式
SelectorCodeDest	equ	LABEL_DESC_CODE_DEST	- LABEL_GDT	            ;这个选择子跳转到下面的ring0级代码段
SelectorCodeRing3	equ	LABEL_DESC_CODE_RING3	- LABEL_GDT + SA_RPL3   ;这个选择子跳转到下面的ring3级代码段
SelectorData		equ	LABEL_DESC_DATA		- LABEL_GDT					;这个选择子跳转到下面的数据段
SelectorStack		equ	LABEL_DESC_STACK	- LABEL_GDT					;这个选择子跳转到下面的堆栈段(ring0级)
SelectorStack3		equ	LABEL_DESC_STACK3	- LABEL_GDT + SA_RPL3       ;这个选择子跳转到下面的堆栈段(ring3级)
SelectorLDT		equ	LABEL_DESC_LDT		- LABEL_GDT						;LDT选择子跳转到下面的描述符表
SelectorTSS		equ	LABEL_DESC_TSS		- LABEL_GDT		                ;这个选择子跳转到下面的初始化任务状态堆栈段
SelectorVideo		equ	LABEL_DESC_VIDEO	- LABEL_GDT					;视频选择子跳转到下面的显存首地址

SelectorCallGateTest	equ	LABEL_CALL_GATE_TEST	- LABEL_GDT + SA_RPL3     ;这个选择子跳转到调用门特权级变换的代码段
; END of [SECTION .gdt]

;section和段之间没有必然的联系，一般我们习惯将一个section放在一个段里面，不过这是用户习惯，不是语法要求——我们可以把两个section放在段里面。
;mov ax，cs在这里，实模式下offset一般不等于0，保护模式下，这一句的偏移一般是0.

[SECTION .data1]	 ; 数据段
ALIGN	32           ;align是一个让数据对齐的宏。通常align的对象是1、4、8等。这里的align 32是没有意义的，因为本来就是只有32b的地址总线宽度。
[BITS	32]          ;'BITS'指令指定NASM产生的代码是被设计运行在16位模式的处理器上还是运行在32位模式的处理器上,BITS 32即指代码运行在32位模式的处理器上
LABEL_DATA:                                         ;数据段
SPValueInRealMode	dw	0                           ;用来保存实模式下sp，并在跳回实模式前重新赋值给sp
; 字符串
PMMessage:		db	"In Protect Mode now. ^-^", 0	; 进入保护模式后显示此字符串,
               
OffsetPMMessage		equ	PMMessage - $$              ;$:当前行被汇编之后的地址，是实际的线性地址,$$:一个section的开始地方被汇编以后的地址，也是实际的线性地址,pmmessage:偏移地址（相对段的首地址）
                                                    ;最后段基地显然在初始化段描述符的时候悄然发生了变化（都采用了base*16+offset，而offset是不同的）。
													;“pmmessage-$$”的真实含义，pmmessage和$$都表示实模式下相对与段基地址的offset；但后来随着段基地址的漂移，
													;$$变成了首地址，所以pmmessage对应于保护模式下的偏移自然也就发生了变化，需要减去$$对应的地址才行。
StrTest:		db	"ABCDEFGHIJKLMNOPQRSTUVWXYZ", 0 ;解释同上
OffsetStrTest		equ	StrTest - $$
DataLen			equ	$ - LABEL_DATA                  ;数据段长度
; END of [SECTION .data1]


; 全局堆栈段
[SECTION .gs]
ALIGN	32         ;align是一个让数据对齐的宏。通常align的对象是1、4、8等。这里的align 32是没有意义的，因为本来就是只有32b的地址总线宽度。
[BITS	32]        ;32位模式的机器运行
LABEL_STACK:       ;定义LABEL_STACK
	times 512 db 0
TopOfStack	equ	$ - LABEL_STACK - 1  ;堆栈段的大小
; END of [SECTION .gs]             //内层ring0级堆栈段


; 堆栈段ring3
[SECTION .s3]
ALIGN	32          ;align是一个让数据对齐的宏。通常align的对象是1、4、8等。这里的align 32是没有意义的，因为本来就是只有32b的地址总线宽度。
[BITS	32]         ;32位模式的机器运行
LABEL_STACK3:       ;定义LABEL_STACK3
	times 512 db 0
TopOfStack3	equ	$ - LABEL_STACK3 - 1  ;外层ring3级堆栈段的大小
; END of [SECTION .s3]            //外层ring3级堆栈段


; TSS ---------------------------------------------------------------------------------------------
;初始化任务状态堆栈段(TSS)
[SECTION .tss]          ;求得各段的大小
ALIGN	32              ;align是一个让数据对齐的宏。通常align的对象是1、4、8等。这里的align 32是没有意义的，因为本来就是只有32b的地址总线宽度。
[BITS	32]             ;32位模式的机器运行
LABEL_TSS:              ;定义LABEL_TSS
		DD	0			; Back
		DD	TopOfStack		; 0 级堆栈   //内层ring0级堆栈放入TSS中
		DD	SelectorStack		; 
		DD	0			; 1 级堆栈
		DD	0			; 
		DD	0			; 2 级堆栈
		DD	0			;               //TSS中最高只能放入Ring2级堆栈，ring3级堆栈不需要放入
		DD	0			; CR3
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
		DD	0			; LDT
		DW	0			; 调试陷阱标志
		DW	$ - LABEL_TSS + 2	; I/O位图基址
		DB	0ffh			; I/O位图结束标志
TSSLen		equ	$ - LABEL_TSS   ;求得段的大小
; TSS ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


[SECTION .s16]          ;实模式，这个段不需要选择子的，因为它是在实模式下。在这里要初始化段描述符的段基址。这是一个16位代码段 这个程序修改了gdt中的一些值 然后执行跳转到第三个section
[BITS	16]             ;32位模式的机器运行 
LABEL_BEGIN:            ;实模式下的代码
	mov	ax, cs          
	mov	ds, ax          
	mov	es, ax
	mov	ss, ax          ;这个ds es ss等于cs,表示代码段和数据段在同一片内存上，只是偏移量不一样。
                        ;看到段寄存器就应该想象成街道号，看到偏移量就应该想象成门牌号,只有两者组合起来才能形成真正的物理地址。
					    ;如果代码中只出现偏移量，实际上也是和操作系统所默认的这个偏移量的段寄存器（只是代码没有显式给出而已）一起组成物理地址，
					    ;（如ip它默认的段寄存器就是cs），代码也可以显式给出段寄存器和偏移量，这个时候的段寄存器就不一定是这个偏移量所默认的段寄存器。
	mov	sp, 0100h       ;堆栈指针指向0100h

	mov	[LABEL_GO_BACK_TO_REAL+3], ax  ;为回到实模式的这个跳转指令指定正确的段地址，LABEL_GO_BACK_TO_REAL+3恰好就是Segment的地址，而紧接着的mov ax，cs指令执行之前ax的值已经是实模式下的cs
	                                   ;所以它将把cs保存到Segment的位置，等到[SECTION .s16code]中jmp指令执行时不是jmp  0:LABEL_REAL_ENTRY,而变成了jmp cs_real_mode:LABEL_REAL_ENTRY    
	mov	[SPValueInRealMode], sp        ;将SPValueInRealMode压入堆栈段

	; 初始化 16 位代码段描述符
	mov	ax, cs                         
	movzx	eax, ax                    ;将cs寄存器中的数据传入eax寄存器中
	shl	eax, 4                         ;左移4位
	add	eax, LABEL_SEG_CODE16          ;数据相加
	mov	word [LABEL_DESC_CODE16 + 2], ax  
	shr	eax, 16                        ;右移16位
	mov	byte [LABEL_DESC_CODE16 + 4], al
	mov	byte [LABEL_DESC_CODE16 + 7], ah  ;将数据依次放入16位代码段中，初始化 16 位代码段描述符

	; 初始化 32 位代码段描述符
	;我们可以在实模式下通过 段寄存器×16 ＋ 偏移量 得到物理地址，那么，我们就可以将这个物理地址放到段描述符中，以供保护模式下使用，因为保护模式下只能通过段选择子 ＋ 偏移量
	xor	eax, eax
	mov	ax, cs
	shl	eax, 4                             
	add	eax, LABEL_SEG_CODE32
	mov	word [LABEL_DESC_CODE32 + 2], ax       ;物理地址的ax放在段基址 2，3
	shr	eax, 16
	mov	byte [LABEL_DESC_CODE32 + 4], al
	mov	byte [LABEL_DESC_CODE32 + 7], ah

	; 初始化测试调用门的代码段描述符
	xor	eax, eax
	mov	ax, cs
	shl	eax, 4
	add	eax, LABEL_SEG_CODE_DEST               ;调用门的代码段
	mov	word [LABEL_DESC_CODE_DEST + 2], ax
	shr	eax, 16
	mov	byte [LABEL_DESC_CODE_DEST + 4], al
	mov	byte [LABEL_DESC_CODE_DEST + 7], ah

	; 初始化数据段描述符
	xor	eax, eax
	mov	ax, ds
	shl	eax, 4
	add	eax, LABEL_DATA
	mov	word [LABEL_DESC_DATA + 2], ax
	shr	eax, 16
	mov	byte [LABEL_DESC_DATA + 4], al
	mov	byte [LABEL_DESC_DATA + 7], ah

	; 初始化堆栈段描述符(ring0)
	xor	eax, eax
	mov	ax, ds
	shl	eax, 4
	add	eax, LABEL_STACK
	mov	word [LABEL_DESC_STACK + 2], ax
	shr	eax, 16
	mov	byte [LABEL_DESC_STACK + 4], al
	mov	byte [LABEL_DESC_STACK + 7], ah

	; 初始化堆栈段描述符(ring3)
	xor	eax, eax
	mov	ax, ds
	shl	eax, 4
	add	eax, LABEL_STACK3
	mov	word [LABEL_DESC_STACK3 + 2], ax
	shr	eax, 16
	mov	byte [LABEL_DESC_STACK3 + 4], al
	mov	byte [LABEL_DESC_STACK3 + 7], ah

	; 初始化 LDT 在 GDT 中的描述符,LABEL_LDT为LDT的定义地址
	xor	eax, eax
	mov	ax, ds
	shl	eax, 4
	add	eax, LABEL_LDT
	mov	word [LABEL_DESC_LDT + 2], ax
	shr	eax, 16
	mov	byte [LABEL_DESC_LDT + 4], al
	mov	byte [LABEL_DESC_LDT + 7], ah

	; 初始化 LDT 中的描述符,LABEL_CODE_A才是真正的LDT代码
	xor	eax, eax
	mov	ax, ds
	shl	eax, 4
	add	eax, LABEL_CODE_A
	mov	word [LABEL_LDT_DESC_CODEA + 2], ax
	shr	eax, 16
	mov	byte [LABEL_LDT_DESC_CODEA + 4], al
	mov	byte [LABEL_LDT_DESC_CODEA + 7], ah

	; 初始化Ring3描述符
	xor	eax, eax
	mov	ax, ds
	shl	eax, 4
	add	eax, LABEL_CODE_RING3
	mov	word [LABEL_DESC_CODE_RING3 + 2], ax
	shr	eax, 16
	mov	byte [LABEL_DESC_CODE_RING3 + 4], al
	mov	byte [LABEL_DESC_CODE_RING3 + 7], ah

	; 初始化 TSS 描述符
	xor	eax, eax
	mov	ax, ds
	shl	eax, 4
	add	eax, LABEL_TSS
	mov	word [LABEL_DESC_TSS + 2], ax
	shr	eax, 16
	mov	byte [LABEL_DESC_TSS + 4], al
	mov	byte [LABEL_DESC_TSS + 7], ah

	; 为加载 GDTR 作准备
	xor	eax, eax
	mov	ax, ds              ;GDT的段地址为数据寄存器DS
	shl	eax, 4
	add	eax, LABEL_GDT		; eax <- gdt 基地址
	mov	dword [GdtPtr + 2], eax	; [GdtPtr + 2] <- gdt 基地址,dword 表示是双字所以为32位，eax也是32位

	; 加载 GDTR
	
	lgdt	[GdtPtr]        ;加载到gdtr,因为现在段描述符表在内存中，我们必须要让CPU知道段描述符 表在哪个位置通过使用lgdtr就可以将源加载到gdtr寄存器中

	; 关中断
	cli

	; 打开地址线A20
	in	al, 92h
	or	al, 00000010b
	out	92h, al

	; 准备切换到保护模式,设置PE为1
	mov	eax, cr0           ;将寄存器cr0中的数据转移到eax寄存器中
	or	eax, 1             ;进行逻辑或操作，将eax寄存器置1
	mov	cr0, eax           ;现在已经处在保护模式分段机制下，所以寻址必须使用段选择子：偏移量来寻址

	; 真正进入保护模式
	jmp	dword SelectorCode32:0	; 执行这一句会把 SelectorCode32 装入 cs, 并跳转到 Code32Selector:0 处；因为此时偏移量位32位，所以必须dword告诉编译器，不然，编译器将编译成16位

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

LABEL_REAL_ENTRY:		; 从保护模式跳回到实模式就到了这里
	mov	ax, cs
	mov	ds, ax
	mov	es, ax
	mov	ss, ax                      ;这个ds es ss等于cs,表示代码段和数据段在同一片内存上，只是偏移量不一样。

	mov	sp, [SPValueInRealMode]     ;指针调到了堆栈中  返回到实模式

	in	al, 92h		; ┓
	and	al, 11111101b	; ┣ 关闭 A20 地址线
	out	92h, al		; ┛

	sti			; 开中断

	mov	ax, 4c00h	; ┓
	int	21h		; ┛回到 DOS
; END of [SECTION .s16]                    //返回到实模式下完成回到DOS的功能


[SECTION .s32]; 32 位代码段的保护模式，由实模式跳入,需要选择子SelectorCode32
[BITS	32]   ;32位模式的机器运行

LABEL_SEG_CODE32:        ;定义LABEL_SEG_CODE32
	mov	ax, SelectorData
	mov	ds, ax			; 数据段选择子
	mov	ax, SelectorVideo
	mov	gs, ax			; 视频段选择子,gs指向显存

	mov	ax, SelectorStack
	mov	ss, ax			; 堆栈段选择子     //ss esp 指向内层ring0堆栈

	mov	esp, TopOfStack ;确定堆栈段的大小


	; 下面显示一个字符串
	mov	ah, 0Ch			; 0000: 黑底    1100: 红字
	xor	esi, esi                ;将esi寄存器置空
	xor	edi, edi                ;将edi寄存器置空
	mov	esi, OffsetPMMessage	; 源数据偏移
	mov	edi, (80 * 10 + 0) * 2	; 目的数据偏移。屏幕第 10 行, 第 0 列。
	cld                         ; 告诉字符串向前移动
.1:
	lodsb                       ;将字符串中的si指针所指向的一个字节装入al中
	test	al, al              
	jz	.2                      ;判断al是否为空  为空跳转到2
	mov	[gs:edi], ax            ;不为空显示当前字符
	add	edi, 2                  ;edi加二  
	jmp	.1
.2:	; 显示完毕

	call	DispReturn          ;回车 换行

	; Load TSS
	mov	ax, SelectorTSS         ;ltr 是ring0级指令，只能运行在ring0级代码段中。在ring0中需要手动加载tss实现堆栈切换。在call中是系统自动调用tss切换的
	ltr	ax	; 在任务内发生特权级变换时要切换堆栈，而内层堆栈的指针存放在当前任务的TSS中，所以要设置任务状态段寄存器 TR。

	push	SelectorStack3      ;执行retf指令时系统会调用选择子(ring3级)
	push	TopOfStack3         ;执行retf指令时系统会自动在第四步切换到ring3级的这个堆栈
	push	SelectorCodeRing3   ;retf 时，需要检查该选择子得rpl，看是否需要变换特权级
	push	0                   ;特权转换使用retf使用之前，压入ss，sp，cs，ip 到内层Ring0堆栈  push 0 表示ip为0.    0为偏移量
	retf				; Ring0 -> Ring3，历史性转移！将打印数字 '3'。本来ret（retf）是和call配合使用的指令，用来返回断点。
	                    ;这里单独使用，可以理解为“从[SECTION .32]返回[SECTION .ring3]”，用来从高特权级跳转到低特权级。跳转过程：
						;step1:检查被调用者堆栈中保存的CS中的RPL（对应代码push SelectorCodeRing3），以判断返回时是否要变换特权级。
						;此时发现当前特权级为0，转到特权级为3的代码段，发生了特权级变化（高-->低）。
						;step2:加载被调用者堆栈上的cs和eip（SelectorCodeRing3和0）。此时，就返回断点了——在本程序中cs和eip已经指向[SECTION .ring3]段了。
						;step3:此retf不含参数，不用增加esp跳过参数。当前堆栈是被调用者([SECTION .s32])堆栈。
						;step4:加载被调用者([SECTION .s32)堆栈中的ss和esp，切换到调用者([SECTION .ring3])堆栈。此时，被调用者([SECTION .s32)堆栈中的ss和esp被丢弃，但由于等会儿还要从
						;低特权级转换回高特权级，故需要将“0级堆栈的SelectorStack和TopOfStack”提前放入TSS。此时，当前堆栈从被调用者([SECTION .s32])堆栈变成了调用者([SECTION .ring3)堆栈了。
						;step5:此retf不含参数，不用增加esp跳过参数。当前堆栈是调用者([SECTION .ring3)堆栈。
						;step6:检查ds、es、fs、gs的值，如果其中哪一个寄存器指向的段的DPL小于CPL（此规则不适用于一致代码段），那么一个空描述符被加载到该寄存器。此时这几个寄存器都被置空描述符了

; ------------------------------------------------------------------------
DispReturn:             ;打印一个回车,return表示回车
	push	eax
	push	ebx
	mov	eax, edi
	mov	bl, 160
	div	bl
	and	eax, 0FFh
	inc	eax
	mov	bl, 160
	mul	bl
	mov	edi, eax
	pop	ebx
	pop	eax

	ret
; DispReturn 结束---------------------------------------------------------

SegCode32Len	equ	$ - LABEL_SEG_CODE32       ;计算32位代码段的大小
; END of [SECTION .s32]


[SECTION .sdest]; 调用门目标段，[SECTION .sdest]段是非一致32位段，而且DPL=0，并且当前CPL=0。而此后用到的“DPL”和“选择子中的RPL”都为0，均在最高特权级上跳转，不需要设计权限检查了
[BITS	32]

LABEL_SEG_CODE_DEST:    ;ring0级代码段
	mov	ax, SelectorVideo
	mov	gs, ax			; 视频段选择子(目的)

	mov	edi, (80 * 12 + 0) * 2	; 屏幕第 12 行, 第 0 列。
	mov	ah, 0Ch			; 0000: 黑底    1100: 红字
	mov	al, 'C'         ;将字符‘C’放入al寄存器中
	mov	[gs:edi], ax    ;不为空显示当前字符

	; Load LDT
	mov	ax, SelectorLDT ;将LDT选择子置入ax寄存器中
	lldt	ax          ;加载局部描述符

	jmp	SelectorLDTCodeA:0	; 跳入LDT定义的局部段，进入局部任务，将打印字母 'L'。

	retf                   ;通过retf，完成从Ring0-->Ring3的跳转，即高特权级跳转到低特权级,跳转到最后的"jmp $"

SegCodeDestLen	equ	$ - LABEL_SEG_CODE_DEST   ;计算调用门目标段的大小
; END of [SECTION .sdest]


; 16 位代码段. 由 32 位代码段跳入, 跳出后到实模式
[SECTION .s16code]
ALIGN	32
[BITS	16]
LABEL_SEG_CODE16:
	; 跳回实模式:
	mov	ax, SelectorNormal  
	mov	ds, ax
	mov	es, ax
	mov	fs, ax
	mov	gs, ax
	mov	ss, ax               ;通过符合实模式段属性，段界限的选择子SelectorNormal，对各个寄存器的高速缓存重新赋值，使之符合实模式的状态

	mov	eax, cr0
	and	al, 11111110b
	mov	cr0, eax             ;置cr0末位为0

LABEL_GO_BACK_TO_REAL:
	jmp	0:LABEL_REAL_ENTRY	; 段地址会在程序开始处被设置成正确的值,通过实模式下的跳转，完成对CS的赋值

Code16Len	equ	$ - LABEL_SEG_CODE16    ;对上句应由LABEL_REAL_ENTRY这个门牌号，推测到那个街道号LABEL_BEGIN。

; END of [SECTION .s16code]             //大量运用[section .!!!]来间隔代码，通过选择子完成各section之间的跳转。


; LDT
[SECTION .ldt]
ALIGN	32
LABEL_LDT:
;                                         段基址       段界限     ,   属性
LABEL_LDT_DESC_CODEA:	Descriptor	       0,     CodeALen - 1,   DA_C + DA_32	; Code, 32 位

LDTLen		equ	$ - LABEL_LDT           ;计算LDT的大小

; LDT 选择子
SelectorLDTCodeA	equ	LABEL_LDT_DESC_CODEA	- LABEL_LDT + SA_TIL
; END of [SECTION .ldt]


; CodeA (LDT, 32 位代码段)
[SECTION .la]
ALIGN	32
[BITS	32]
LABEL_CODE_A:
	mov	ax, SelectorVideo
	mov	gs, ax			; 视频段选择子(目的)

	mov	edi, (80 * 13 + 0) * 2	; 屏幕第 13 行, 第 0 列。
	mov	ah, 0Ch			; 0000: 黑底    1100: 红字
	mov	al, 'L'
	mov	[gs:edi], ax    ;不为空显示当前字符'L'

	
	jmp	SelectorCode16:0 ; 准备经由16位代码段跳回实模式
CodeALen	equ	$ - LABEL_CODE_A       ；;计算CodeA (LDT, 32 位代码段)的大小
; END of [SECTION .la]


; CodeRing3
[SECTION .ring3]
ALIGN	32
[BITS	32]
LABEL_CODE_RING3:       ;ring3级代码段
	mov	ax, SelectorVideo
	mov	gs, ax			; 视频段选择子(目的)

	mov	edi, (80 * 14 + 0) * 2	; 屏幕第 14 行, 第 0 列。
	mov	ah, 0Ch			; 0000: 黑底    1100: 红字
	mov	al, '3'
	mov	[gs:edi], ax    ;不为空显示当前字符'3'

	call	SelectorCallGateTest:0	; 使用call调用门实现特权转换，实现从ring3---->ring0，这个跳转是通过调用门从低到高特权级。
	                                ;跳转过程: step1:指示调用门的选择子的RPL<=门描述符DPL & 当前代码段的CPL<=门描述符的DPL。此时,在[SECTION .ring3]中。
									;因为[SECTION .ring3]是非一致代码段，故在从[SECTION .s32]跳转到该段时，已经设置CPL=3  即是说，此时CPL=3。
                                    ;call SelectorCallGateTest:0调用调用门，由SelectorCallGateTest	equ	LABEL_CALL_GATE_TEST	- LABEL_GDT + SA_RPL3）可知，调用门的RPL为3。
									;即是说，此时RPL=3。又调用门的DPL=3。 由上面三段的描述有： CPL<=调用门DPL & RPL<=调用门DPL。故可以访问到调用门中的目标段选择子了^_^
                                    ;step2:   CPL>=DPL，RPL不作检查（因为RPL总被清0）现在，CPL=3； 目标段[SECTION .sdest]的DPL=0，且为非一致代码段。
									;故CPL>=DPL(RPL不作检查)，满足特权级检查，跳转到[SECTION .sdest].
									;step3:跳转后，CPL被修改为0(原来为3)因为CPL=目标段[SECTION .sdest]的DPL(=0)，因此，跳转到[SECTION .sdest]后CPL=0 
    jmp $									
SegCodeRing3Len	equ	$ - LABEL_CODE_RING3   ;因为处在3级的代码中，调用门也要设置为3级，通过调用门可以跳掉0级代码
; END of [SECTION .ring3]
