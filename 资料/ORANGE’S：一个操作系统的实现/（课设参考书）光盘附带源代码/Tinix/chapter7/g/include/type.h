
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                            type.h
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                                                    Forrest Yu, 2005
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

#ifndef	_TINIX_TYPE_H_
#define	_TINIX_TYPE_H_


typedef	unsigned int		t_32;
typedef	unsigned short		t_16;
typedef	unsigned char		t_8;
typedef	int			t_bool;

typedef	unsigned int		t_port;

typedef char*			va_list;

typedef	void	(*t_pf_int_handler)	();
typedef	void	(*t_pf_task)		();
typedef	void	(*t_pf_irq_handler)	(int irq);

typedef	void*	t_sys_call;


#endif /* _TINIX_TYPE_H_ */
