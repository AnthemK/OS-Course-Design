
==========
关于本光盘
==========

\Tinix:	书中所附代码

	其中很多目录中除了包含源代码(*.asm, *.inc, *.c, *.h)外，还有这样一些文件:

	boot.bin	引导扇区(Boot Sector)，可通过 FloppyWriter 写入软盘(或软盘映像)。
	loader.bin	LOADER，直接拷贝至软盘(或软盘映像)根目录。
	kernel.bin	内核(Kernel)，直接拷贝至软盘(或软盘映像)根目录。

	bochsrc.bxrc	Bochs 配置文件，如果系统中安装了 Bochs-2.1.1 可直接双击之运行。其它细节请见书第 2.7 节。
	godbg.bat	调试时可使用此批处理文件。它假设 Bochs-2.1.1 安装在 D:\Program Files\Bochs-2.1.1\ 中。
	TINIX.IMG	软盘映像。可直接通过 Bochs 或者 Virtual PC 运行。

	*.com		可以在 DOS (必须为纯 DOS) 下运行的文件。


\Tools:	一些小工具 (在 VC6 下编译通过)

	DescParser	描述符分析器，输入描述符的值，可以得出起基址、界限、属性等信息。

	ELFParser	ELF 文件分析器，可以列出一个 ELF 文件的 ELF Header、 Program Header、Section Header 等信息。

	FloppyWriter	用以写引导扇区，支持软盘和软盘映像。

	KrnlChecker	用以检查一个 Tinix 内核加载后位置是否正确。

