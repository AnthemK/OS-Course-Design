
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                            proto.h
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                                                    Forrest Yu, 2005
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

/* klib.asm */
PUBLIC void	out_byte(t_port port, t_8 value);
PUBLIC t_8	in_byte(t_port port);
PUBLIC void	disp_str(char * info);
PUBLIC void	disp_color_str(char * info, int color);

/* protect.c */
PUBLIC void	init_prot();
PUBLIC t_32	seg2phys(t_16 seg);
PUBLIC void	disable_irq(int irq);
PUBLIC void	enable_irq(int irq);

/* klib.c */
PUBLIC void	delay(int time);

/* kernel.asm */
void restart();

/* main.c */
void TestA();
void TestB();
void TestC();

/* i8259.c */
PUBLIC void put_irq_handler(int iIRQ, t_pf_irq_handler handler);
PUBLIC void spurious_irq(int irq);

/* clock.c */
PUBLIC void clock_handler(int irq);



/************************************************************************/
/*                        以下是系统调用相关                            */
/************************************************************************/

/* proc.c */
PUBLIC	int	sys_get_ticks();	/* t_sys_call */

/* syscall.asm */
PUBLIC	void	sys_call();		/* t_pf_int_handler */
PUBLIC	int	get_ticks();

