
//	Name           Size Alignment   Purpose
//	====           ==== =========   =======
//	Elf32_Addr      4       4       Unsigned program address
//	Elf32_Half      2       2       Unsigned medium integer
//	Elf32_Off       4       4       Unsigned file offset
//	Elf32_Sword     4       4       Signed large integer
//	Elf32_Word      4       4       Unsigned large integer
//	unsigned char   1       1       Unsigned small integer
	typedef	DWORD	Elf32_Addr;
	typedef	WORD	Elf32_Half;
	typedef	DWORD	Elf32_Off;
	typedef	DWORD	Elf32_Sword;
	typedef	DWORD	Elf32_Word;

#define EI_NIDENT       16

	// ELF header
	typedef struct {
		unsigned char       e_ident[EI_NIDENT];
		Elf32_Half          e_type;
					//	e_type
					//
					//	�ó�Աȷ����object�����͡�
					//
					//	Name        Value  Meaning
					//	====        =====  =======
					//	ET_NONE         0  No file type
					//	ET_REL          1  Relocatable file
					//	ET_EXEC         2  Executable file
					//	ET_DYN          3  Shared object file
					//	ET_CORE         4  Core file
					//	ET_LOPROC  0xff00  Processor-specific
					//	ET_HIPROC  0xffff  Processor-specific

		Elf32_Half          e_machine;
					//	e_machine
					//			
					//	�ó�Ա����ָ�������иó�����Ҫ����ϵ�ṹ��
					//
					//	Name      Value  Meaning
					//	====      =====  =======
					//	EM_NONE       0  No machine
					//	EM_M32        1  AT&T WE 32100
					//	EM_SPARC      2  SPARC
					//	EM_386        3  Intel 80386
					//	EM_68K        4  Motorola 68000
					//	EM_88K        5  Motorola 88000
					//	EM_860        7  Intel 80860
					//	EM_MIPS       8  MIPS RS3000
			
		Elf32_Word          e_version;
					//	e_version
					//
					//	�����Աȷ��object�ļ��İ汾��
					//
					//	Name         Value  Meaning
					//	====         =====  =======
					//	EV_NONE          0  Invalid version
					//	EV_CURRENT       1  Current version
			
		Elf32_Addr          e_entry;
					//	�ó�Ա��ϵͳ��һ��������Ƶ������ַ�������������̡�
					//	�����ļ�û����ι�������ڵ㣬�ó�Ա�ͱ���Ϊ 0��

		Elf32_Off           e_phoff;
					//	�ó�Ա�����ų���ͷ��program header table�����ļ��е�ƫ����(���ֽڼ���)��
					//	������ļ�û�г���ͷ��ĵĻ����ó�Ա�ͱ���Ϊ 0��

		Elf32_Off           e_shoff;
					//	�ó�Ա������sectionͷ��section header table�����ļ��е�ƫ����(���ֽڼ���)��
					//	������ļ�û��sectionͷ��ĵĻ����ó�Ա�ͱ���Ϊ0��

		Elf32_Word          e_flags;
					//	�ó�Ա����������ļ����ض���������־��
					//	flag������������EF_<machine>_<flag>�����»�����Ϣ��Machine Information�����ֵ�flag�Ķ��塣

		Elf32_Half          e_ehsize;
					//	�ó�Ա������ELFͷ��С(���ֽڼ���)��

		Elf32_Half          e_phentsize;
					//	�ó�Ա���������ļ��ĳ���ͷ��program header table����һ����ڵĴ�С
					//	(���ֽڼ���)�����е���ڶ���ͬ���Ĵ�С��

		Elf32_Half          e_phnum;
					//	�ó�Ա�������ڳ���ͷ������ڵĸ�����
					//	��ˣ�e_phentsize��e_phnum�ĳ˻����Ǳ�Ĵ�С(���ֽڼ���).
					//	����û�г���ͷ��program header table����e_phnum����Ϊ0��

		Elf32_Half          e_shentsize;
					//	�ó�Ա������sectionͷ�Ĵ�С(���ֽڼ���)��
					//	һ��sectionͷ����sectionͷ��(section header table)��һ����ڣ�
					//	���е���ڶ���ͬ���Ĵ�С��

		Elf32_Half          e_shnum;
					//	�ó�Ա��������section header table�е������Ŀ��
					//	��ˣ�e_shentsize��e_shnum�ĳ˻�����sectionͷ��Ĵ�С(���ֽڼ���)��
					//	�����ļ�û��sectionͷ��e_shnumֵΪ0��

		Elf32_Half          e_shstrndx;
					//	�ó�Ա�����Ÿ�section�����ַ��������ڵ�sectionͷ��(section header table)������
					//	�����ļ���û��section�����ַ����ñ���ֵΪSHN_UNDEF��
					//	����ϸ����Ϣ �����桰Sections�����ַ�����(��String Table��) ��

	} Elf32_Ehdr;

	char sz_desc_e_type[][128] = {	"No file type",
									"Relocatable file",
									"Executable file",
									"Shared object file",
									"Core file"
									};

	char sz_desc_e_machine[][128] = {"No mach", "AT&T", "SPARC", "80386", "Motorola 68", "Motorola 88", "Unknown", "8086", "MIPS"};
	
	char sz_desc_e_entry[] = "Entry point.";


	// Program Header		
	typedef struct {
		Elf32_Word p_type;
					//	Name             Value
					//	====             =====
					//	PT_NULL              0
					//	PT_LOAD              1
					//	PT_DYNAMIC           2
					//	PT_INTERP            3
					//	PT_NOTE              4
					//	PT_SHLIB             5
					//	PT_PHDR              6
					//	PT_LOPROC   0x70000000
					//	PT_HIPROC   0x7fffffff

		Elf32_Off  p_offset;
					//	�ó�Ա�����˸öε�פ��λ��������ļ���ʼ����ƫ�ơ�

		Elf32_Addr p_vaddr;
					//	�ó�Ա�����˸ö����ڴ��е����ֽڵ�ַ��

		Elf32_Addr p_paddr;
		
		Elf32_Word p_filesz;
					//	�ļ�ӳ���иöε��ֽ������������� 0 ��

		Elf32_Word p_memsz;
					//	�ڴ�ӳ���иöε��ֽ������������� 0 ��

		Elf32_Word p_flags;

		Elf32_Word p_align;
					//	�ó�Ա�����˸ö����ڴ���ļ�������ֵ��
					//	0 �� 1 ��ʾ����Ҫ���С����� p_align ����Ϊ���� 2 ���ݣ�
					//	���� p_vaddr Ӧ������ p_offset ģ p_align ��


	} Elf32_Phdr;
	
	
	char sz_desc_p_type[][128] = {"PT_NULL", "PT_LOAD", "PT_DYNAMIC", "PT_INTERP", "PT_NOTE", "PT_SHLIB", "PT_PHDR"};

	// Section Header
	typedef struct {
		Elf32_Word sh_name;
					//	�ó�Աָ�������section�����֡�
					//	����ֵ��section��ͷ�ַ���section��������[�����µġ�String Table��], ��NULL���ַ�������

		Elf32_Word sh_type;
					//	Section Types, sh_type
					//	---------------------------
					//	Name                 Value    Description
					//	====                 =====    ===========
					//	SHT_NULL				 0    ��ֵ������sectionͷ����Ч�ģ���û����ص�section��
					//	SHT_PROGBITS			 1    ��section���汻�������˵�һЩ��Ϣ�����ĸ�ʽ������ȡ���ڳ�����
					//	SHT_SYMTAB				 2    ��sections������һ�����ű�symbol table����
					//	SHT_STRTAB				 3    ��section������һ���ַ�����
					//	SHT_RELA				 4    ��section�����ž�����ȷ�������ض�λ��ڡ�
					//	SHT_HASH				 5    �ñ�ű�����һ����ŵĹ�ϣ(hash)��
					//	SHT_DYNAMIC				 6    ��section�����Ŷ�̬���ӵ���Ϣ��
					//	SHT_NOTE				 7    ��section������������һЩ��־�ļ�����Ϣ��
					//	SHT_NOBITS				 8    �����͵�section���ļ��в�ռ�ռ䣬��������SHT_PROGBITS��
					//	SHT_REL					 9    ��section�������ض�λ����ڡ�
					//	SHT_SHLIB				10    ��section���ͱ���������û��ָ��������������͵�section�ĳ����ǲ�����ABI�ġ�
					//	SHT_DYNSYM				11    ��sections������һ�����ű�symbol table����
					//	SHT_LOPROC		0x70000000    ���ⷶΧ֮���ֵΪ�ض����������Ᵽ���ġ�
					//	SHT_HIPROC		0x7fffffff    ���ⷶΧ֮���ֵΪ�ض����������Ᵽ���ġ�
					//	SHT_LOUSER		0x80000000    �ñ���ΪӦ�ó�������������Χ����С�߽硣
					//	SHT_HIUSER		0xffffffff    �ñ���ΪӦ�ó�������������Χ�����߽硣

			
		Elf32_Word sh_flags;
					//	Section Attribute Flags, sh_flags
					//	-----------------------------------		
					//	Name                Value    Description
					//	====                =====    ===========
					//	SHF_WRITE             0x1    ��section�������ڽ���ִ�й����пɱ�д�����ݡ�
					//	SHF_ALLOC             0x2    ��section�ڽ���ִ�й�����ռ�����ڴ档
					//	SHF_EXECINSTR         0x4    ��section�����˿�ִ�еĻ���ָ�
					//	SHF_MASKPROC   0xf0000000    ���еİ������������е�λΪ�ض��������Ᵽ���ġ�

		Elf32_Addr sh_addr;
					//	�����section�������ڽ��̵��ڴ�ӳ��ռ���ó�Ա������һ����section���ڴ��е�λ�á����򣬸ñ���Ϊ0��

		Elf32_Off  sh_offset;
					//	�ó�Ա���������˸�section���ֽ�ƫ����(���ļ���ʼ����)��

		Elf32_Word sh_size;
					//	�ó�Ա������section���ֽڴ�С��

		Elf32_Word sh_link;
					//	�ó�Ա������һ��section��ͷ����������ӣ����Ľ���������section�����͡�
					//	������Ϣ�μ���"sh_link and sh_info Interpretation"

		Elf32_Word sh_info;
					//	�ó�Ա�����Ŷ������Ϣ�����Ľ���������section�����͡�

					//	sh_link and sh_info Interpretation

					//	-------------------------------------------------------------------------------
					//	sh_type        sh_link                          sh_info
					//	=======        =======                          =======
					//	SHT_DYNAMIC    The section header index of      0
					//	               the string table used by
					//	               entries in the section.
					//	-------------------------------------------------------------------------------
					//	SHT_HASH       The section header index of      0
					//	               the symbol table to which the
					//	               hash table applies.
					//	-------------------------------------------------------------------------------
					//	SHT_REL        The section header index of      The section header index of
					//	SHT_RELA       the associated symbol table.     the section to which the
					//	                                                relocation applies.
					//	-------------------------------------------------------------------------------
					//	SHT_SYMTAB     The section header index of      One greater than the symbol
					//	-------------------------------------------------------------------------------
					//	SHT_DYNSYM     the associated string table.     table index of the last local
					//	               symbol (binding STB_LOCAL).
					//	-------------------------------------------------------------------------------
					//	other          SHN_UNDEF                        0
					//	-------------------------------------------------------------------------------
			

		Elf32_Word sh_addralign;
					//	һЩsections�е�ַ�����Լ����

		Elf32_Word sh_entsize;
					//	һЩsections������һ�Ź̶���С��ڵı�������ű�
					//	��������һ��section��˵���ó�Ա������ÿ����ڵ��ֽڴ�С��
					//	�����sectionû�б�����һ�Ź̶���С��ڵı��ó�Ա��Ϊ0��
	} Elf32_Shdr;
	
	
	char sz_desc_sh_type[][128] = {	"SHT_NULL", "SHT_PROGBITS", "SHT_SYMTAB", "SHT_STRTAB",
									"SHT_RELA", "SHT_HASH", "SHT_DYNAMIC", "SHT_NOTE",
									"SHT_NOBITS", "SHT_REL", "SHT_SHLIB", "SHT_DYNSYM"};	
	char sz_desc_sh_flags[][128] = {"Unknown", "SHF_WRITE", "SHF_ALLOC", "SHF_WRITE & SHF_ALLOC", "SHF_EXECINSTR",
									"SHF_WRITE & SHF_ALLOC", "SHF_ALLOC & SHF_EXECINSTR",
									"SHF_WRITE & SHF_ALLOC & SHF_EXECINSTR"};
	
	char sz_desc_sh_addr[] = "Position in Mem.";
	
	char sz_desc_sh_offset[] = "Position in file.";