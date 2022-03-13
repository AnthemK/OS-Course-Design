
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                               proc.h
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                                                    Forrest Yu, 2005
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/


typedef struct s_stackframe {	/* proc_ptr points here				↑ Low			*/
	t_32	gs;		/* ┓						│			*/
	t_32	fs;		/* ┃						│			*/
	t_32	es;		/* ┃						│			*/
	t_32	ds;		/* ┃						│			*/
	t_32	edi;		/* ┃						│			*/
	t_32	esi;		/* ┣ pushed by save()				│			*/
	t_32	ebp;		/* ┃						│			*/
	t_32	kernel_esp;	/* <- 'popad' will ignore it			│			*/
	t_32	ebx;		/* ┃						↑栈从高地址往低地址增长*/		
	t_32	edx;		/* ┃						│			*/
	t_32	ecx;		/* ┃						│			*/
	t_32	eax;		/* ┛						│			*/
	t_32	retaddr;	/* return address for assembly code save()	│			*/
	t_32	eip;		/*  ┓						│			*/
	t_32	cs;		/*  ┃						│			*/
	t_32	eflags;		/*  ┣ these are pushed by CPU during interrupt	│			*/
	t_32	esp;		/*  ┃						│			*/
	t_32	ss;		/*  ┛						┷High			*/
}STACK_FRAME;


typedef struct s_proc {
	STACK_FRAME			regs;			/* process' registers saved in stack frame */

	t_16				ldt_sel;		/* selector in gdt giving ldt base and limit*/
	DESCRIPTOR			ldts[LDT_SIZE];		/* local descriptors for code and data */
								/* 2 is LDT_SIZE - avoid include protect.h */
	t_32				pid;			/* process id passed in from MM */
	char				p_name[16];		/* name of the process */
}PROCESS;


/* Number of tasks */
#define NR_TASKS	1

/* stacks of tasks */
#define STACK_SIZE_TESTA	0x8000

#define STACK_SIZE_TOTAL	STACK_SIZE_TESTA

