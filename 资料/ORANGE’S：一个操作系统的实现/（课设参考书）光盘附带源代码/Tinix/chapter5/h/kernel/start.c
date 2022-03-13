
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                            start.c
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                                                    Forrest Yu, 2005
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

#include "type.h"
#include "const.h"
#include "protect.h"

PUBLIC	void*	memcpy(void* pDst, void* pSrc, int iSize);
PUBLIC void	disp_str(char * pszInfo);

PUBLIC	t_8			gdt_ptr[6];	// 0~15:Limit  16~47:Base
PUBLIC	DESCRIPTOR		gdt[GDT_SIZE];


/*======================================================================*
                            cstart
 *======================================================================*/
PUBLIC void cstart()
{
	disp_str("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n-----\"cstart\" begins-----\n");

	// 将 LOADER 中的 GDT 复制到新的 GDT 中
	memcpy(	&gdt,				    // New GDT
		(void*)(*((t_32*)(&gdt_ptr[2]))),   // Base  of Old GDT
		*((t_16*)(&gdt_ptr[0])) + 1	    // Limit of Old GDT
		);
	// gdt_ptr[6] 共 6 个字节：0~15:Limit  16~47:Base。用作 sgdt 以及 lgdt 的参数。
	t_16* p_gdt_limit = (t_16*)(&gdt_ptr[0]);
	t_32* p_gdt_base  = (t_32*)(&gdt_ptr[2]);
	*p_gdt_limit = GDT_SIZE * sizeof(DESCRIPTOR) - 1;
	*p_gdt_base  = (t_32)&gdt;

	disp_str("-----\"cstart\" finished-----\n");
}
