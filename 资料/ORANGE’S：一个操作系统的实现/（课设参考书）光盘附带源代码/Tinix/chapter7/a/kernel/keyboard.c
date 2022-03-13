
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                            keyboard.c
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
#include "keymap.h"

PRIVATE	KB_INPUT	kb_in;

/*======================================================================*
                            keyboard_handler
 *======================================================================*/
PUBLIC void keyboard_handler(int irq)
{
	t_8 scan_code = in_byte(KB_DATA);

	if (kb_in.count < KB_IN_BYTES) {
		*(kb_in.p_head) = scan_code;
		kb_in.p_head++;
		if (kb_in.p_head == kb_in.buf + KB_IN_BYTES) {
			kb_in.p_head = kb_in.buf;
		}
		kb_in.count++;
	}
}


/*======================================================================*
                           init_keyboard
*======================================================================*/
PUBLIC void init_keyboard()
{
	kb_in.count = 0;
	kb_in.p_head = kb_in.p_tail = kb_in.buf;

	put_irq_handler(KEYBOARD_IRQ, keyboard_handler);	/* �趨�����жϴ������ */
	enable_irq(KEYBOARD_IRQ);				/* �������ж� */
}


/*======================================================================*
                           keyboard_read
*======================================================================*/
PUBLIC void keyboard_read()
{
	t_8	scan_code;
	char	output[2];
	t_bool	make;	/* TRUE : make  */
			/* FALSE: break */

	memset(output, 0, 2);

	if(kb_in.count > 0){
		disable_int();
		scan_code = *(kb_in.p_tail);
		kb_in.p_tail++;
		if (kb_in.p_tail == kb_in.buf + KB_IN_BYTES) {
			kb_in.p_tail = kb_in.buf;
		}
		kb_in.count--;
		enable_int();

		/* ���濪ʼ����ɨ���� */
		if (scan_code == 0xE1) {
			/* ��ʱ�����κβ��� */
		}
		else if (scan_code == 0xE0) {
			/* ��ʱ�����κβ��� */
		}
		else {	/* ���洦��ɴ�ӡ�ַ� */
			
			/* �����ж�Make Code ���� Break Code */
			make = (scan_code & FLAG_BREAK ? FALSE : TRUE);

			/* �����Make Code �ʹ�ӡ���� Break Code �������� */
			if(make){
				output[0] = keymap[(scan_code & 0x7F) * MAP_COLS];
				disp_str(output);
			}
		}
	}
}


