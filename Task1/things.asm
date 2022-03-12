	
	
	; Load LDT1
	mov	ax, SelectorLDT1
	lldt	ax

	; Load TSS1
	mov	ax, SelectorTSS1
	ltr	ax	; 在任务内发生特权级变换时要切换堆栈
	push	SelectorStack1
	push	TopOfStack1
	push	SelectorLDTCode1
	push	0
	retf				; Ring0 -> Ring3	进入时段寄存器内容要合法
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	push	eax
	push	ecx		;save
	;inc	byte [gs:((80 * 0 + 70) * 2)]	; 屏幕第 0 行, 第 70 列。
	mov	ax, SelectorData
	mov	ds, ax
	mov	ecx, [ds:NextTask]
	mov	al, 20h
	out	20h, al		;发送 EOI	
	cmp 	ecx, 0
	jnz	Task2Display
Task1Display:
	mov 	ecx, 1
	sti				;
	jmp	SelectorTSS1:0	; 跳入局部任务，Task1。
	jmp	Final

Task2Display:
	mov 	ecx, 0
	sti				;
	jmp	SelectorTSS2:0	; 跳入局部任务，Task2
Final:
	mov	[ds:NextTask], ecx				; 存回去
	pop	ecx
	pop	eax
	iretd
