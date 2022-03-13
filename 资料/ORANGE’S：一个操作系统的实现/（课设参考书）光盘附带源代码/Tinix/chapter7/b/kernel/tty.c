
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                               tty.c
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                                                    Forrest Yu, 2005
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

#include "type.h"
#include "const.h"
#include "protect.h"
#include "proto.h"
#include "string.h"
#include "proc.h"
#include "global.h"
#include "keyboard.h"


/*======================================================================*
                           task_tty
 *======================================================================*/
PUBLIC void task_tty()
{
	while (1) {/* forever. yes, forever, there's something which is some kind of forever... */
		keyboard_read();
	}
}


/*======================================================================*
                           in_process
*======================================================================*/
PUBLIC void in_process(t_32 key)
{
	char	output[2] = {'\0', '\0'};

	if (!(key & FLAG_EXT)) {
		output[0] = key & 0xFF;
		disp_str(output);
	}
}

