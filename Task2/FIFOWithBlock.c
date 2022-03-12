#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/cdev.h>
#include <linux/fs.h>
#include <linux/errno.h>
#include <asm/current.h>
#include <linux/sched.h>
#include <linux/uaccess.h>
#include <asm/atomic.h>
#include <linux/mutex.h>
#include <linux/wait.h>
#include <linux/device.h>
#include <linux/kfifo.h>
#include <linux/miscdevice.h>

#include <linux/slab.h>
#include <linux/gfp.h>
#include <linux/poll.h>

#define DEV_NAME "FIFOWithBlock"
#define BUFFER_SIZE 32
#define MISC_MINOR  114
DEFINE_KFIFO(FIFOBuffer, char, BUFFER_SIZE);
struct _BlockDevice{
	const char *name;
	struct device *device;
	struct miscdevice *miscdev;
	struct mutex reader_mutex,writer_mutex;
	wait_queue_head_t read_queue;
	wait_queue_head_t write_queue;
};

struct _BlockDevice * BlockDevice;
int ret, actual_readed, actul_write;
struct _BlockDevice temp;
// open device
static int FIFOWithBlock_open(struct inode *inode, struct file *filp)
{
	printk(KERN_INFO"Device Opened: %s\n", __func__);
	return 0;
}

// release device
static int FIFOWithBlock_release(struct inode * inode, struct file * filp){
	printk(KERN_INFO "Device Released\n");
	return 0;
}

// read device
static ssize_t FIFOWithBlock_read(struct file *file, char __user *buf, size_t count, loff_t *offset){
	mutex_lock(&(BlockDevice->reader_mutex));  //必须要在进入队列前加锁
	// don't have data to read
	if(kfifo_is_empty(&FIFOBuffer)){	
		if(file->f_flags & O_NONBLOCK)   //非阻塞的系统调用，由于资源限制/不满足条件，导致返回值为EAGAIN
		{
			mutex_unlock(&(BlockDevice->reader_mutex));
			return -EAGAIN;
		}
		// wait until condition is met
		ret = wait_event_interruptible(BlockDevice->read_queue, !kfifo_is_empty(&FIFOBuffer));
	}
	
	// copy read data to user's buffer
	ret = kfifo_to_user(&FIFOBuffer, buf, count, &actual_readed);

	// when queue is not full, call write process to write data
	if(!kfifo_is_full(&FIFOBuffer)){
		wake_up_interruptible(&BlockDevice->write_queue);
	}
	mutex_unlock(&(BlockDevice->reader_mutex));
	return actual_readed;
}

// write device
static ssize_t FIFOWithBlock_write(struct file * file, const char __user *buf, size_t count, loff_t *offset){
	mutex_lock(&(BlockDevice->writer_mutex));   //必须要在进入队列前加锁
	if(kfifo_is_full(&FIFOBuffer)){
		if(file->f_flags & O_NONBLOCK) //非阻塞的系统调用，由于资源限制/不满足条件，导致返回值为EAGAIN
		{
			mutex_unlock(&(BlockDevice->writer_mutex));
			return -EAGAIN;
		}

		ret = wait_event_interruptible(BlockDevice->write_queue, !kfifo_is_full(&FIFOBuffer));
	}
	ret = kfifo_from_user(&FIFOBuffer, buf, count, &actul_write);

	if(!kfifo_is_empty(&FIFOBuffer))
		wake_up_interruptible(&BlockDevice->read_queue);
	mutex_unlock(&(BlockDevice->writer_mutex));
	return actul_write;
}

// file struct
static const struct file_operations fops = {  //用来链接函数
	.owner = THIS_MODULE,
	.open = FIFOWithBlock_open,
	.release = FIFOWithBlock_release,
	.read = FIFOWithBlock_read,
	.write = FIFOWithBlock_write,
};

static struct miscdevice miscDeviceFIFOBlock = {  //用来声明设备
	.minor = MISC_MINOR,
	.name = DEV_NAME,
	.fops = &fops,
};

// init
static int __init FIFOWithBlock_init(void){
	ret = misc_register(&miscDeviceFIFOBlock);
	BlockDevice = &temp;
//	BlockDevice = kmalloc(sizeof(struct _BlockDevice), GFP_KERNEL);
	BlockDevice->miscdev = &miscDeviceFIFOBlock;
	init_waitqueue_head(&BlockDevice->read_queue);
	init_waitqueue_head(&BlockDevice->write_queue);
	mutex_init(&(BlockDevice->reader_mutex)); /*初始化*/
	mutex_init(&(BlockDevice->writer_mutex));
	printk(KERN_INFO"Device installed successfully");
	return 0;
}

// exit
static void  __exit FIFOWithBlock_exit(void){
	misc_deregister(&miscDeviceFIFOBlock);
	BlockDevice=NULL;
	printk(KERN_INFO"Device uninstalled successfully");
	return;
}

module_init(FIFOWithBlock_init);
module_exit(FIFOWithBlock_exit);
MODULE_LICENSE("GPL");
