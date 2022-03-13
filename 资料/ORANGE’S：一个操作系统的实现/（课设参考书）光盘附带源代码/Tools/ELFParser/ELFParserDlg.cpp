// ELFParserDlg.cpp : implementation file
//

#include "stdafx.h"
#include "ELFParser.h"
#include "ELFParserDlg.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CAboutDlg dialog used for App About

class CAboutDlg : public CDialog
{
public:
	CAboutDlg();

// Dialog Data
	//{{AFX_DATA(CAboutDlg)
	enum { IDD = IDD_ABOUTBOX };
	//}}AFX_DATA

	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CAboutDlg)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:
	//{{AFX_MSG(CAboutDlg)
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

CAboutDlg::CAboutDlg() : CDialog(CAboutDlg::IDD)
{
	//{{AFX_DATA_INIT(CAboutDlg)
	//}}AFX_DATA_INIT
}

void CAboutDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CAboutDlg)
	//}}AFX_DATA_MAP
}

BEGIN_MESSAGE_MAP(CAboutDlg, CDialog)
	//{{AFX_MSG_MAP(CAboutDlg)
		// No message handlers
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CELFParserDlg dialog

CELFParserDlg::CELFParserDlg(CWnd* pParent /*=NULL*/)
	: CDialog(CELFParserDlg::IDD, pParent)
{
	//{{AFX_DATA_INIT(CELFParserDlg)
		// NOTE: the ClassWizard will add member initialization here
	//}}AFX_DATA_INIT
	// Note that LoadIcon does not require a subsequent DestroyIcon in Win32
	m_hIcon = AfxGetApp()->LoadIcon(IDR_MAINFRAME);
}

void CELFParserDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CELFParserDlg)
		// NOTE: the ClassWizard will add DDX and DDV calls here
	//}}AFX_DATA_MAP
}

BEGIN_MESSAGE_MAP(CELFParserDlg, CDialog)
	//{{AFX_MSG_MAP(CELFParserDlg)
	ON_WM_SYSCOMMAND()
	ON_WM_PAINT()
	ON_WM_QUERYDRAGICON()
	ON_BN_CLICKED(IDC_BTN_GET_FILENAME, OnBtnGetFilename)
	ON_BN_CLICKED(IDC_BTN_BEGIN, OnBtnBegin)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CELFParserDlg message handlers

BOOL CELFParserDlg::OnInitDialog()
{
	CDialog::OnInitDialog();

	// Add "About..." menu item to system menu.

	// IDM_ABOUTBOX must be in the system command range.
	ASSERT((IDM_ABOUTBOX & 0xFFF0) == IDM_ABOUTBOX);
	ASSERT(IDM_ABOUTBOX < 0xF000);

	CMenu* pSysMenu = GetSystemMenu(FALSE);
	if (pSysMenu != NULL)
	{
		CString strAboutMenu;
		strAboutMenu.LoadString(IDS_ABOUTBOX);
		if (!strAboutMenu.IsEmpty())
		{
			pSysMenu->AppendMenu(MF_SEPARATOR);
			pSysMenu->AppendMenu(MF_STRING, IDM_ABOUTBOX, strAboutMenu);
		}
	}

	// Set the icon for this dialog.  The framework does this automatically
	//  when the application's main window is not a dialog
	SetIcon(m_hIcon, TRUE);			// Set big icon
	SetIcon(m_hIcon, FALSE);		// Set small icon
	
	// TODO: Add extra initialization here
	
	return TRUE;  // return TRUE  unless you set the focus to a control
}

void CELFParserDlg::OnSysCommand(UINT nID, LPARAM lParam)
{
	if ((nID & 0xFFF0) == IDM_ABOUTBOX)
	{
		CAboutDlg dlgAbout;
		dlgAbout.DoModal();
	}
	else
	{
		CDialog::OnSysCommand(nID, lParam);
	}
}

// If you add a minimize button to your dialog, you will need the code below
//  to draw the icon.  For MFC applications using the document/view model,
//  this is automatically done for you by the framework.

void CELFParserDlg::OnPaint() 
{
	if (IsIconic())
	{
		CPaintDC dc(this); // device context for painting

		SendMessage(WM_ICONERASEBKGND, (WPARAM) dc.GetSafeHdc(), 0);

		// Center icon in client rectangle
		int cxIcon = GetSystemMetrics(SM_CXICON);
		int cyIcon = GetSystemMetrics(SM_CYICON);
		CRect rect;
		GetClientRect(&rect);
		int x = (rect.Width() - cxIcon + 1) / 2;
		int y = (rect.Height() - cyIcon + 1) / 2;

		// Draw the icon
		dc.DrawIcon(x, y, m_hIcon);
	}
	else
	{
		CDialog::OnPaint();
	}
}

// The system calls this to obtain the cursor to display while the user drags
//  the minimized window.
HCURSOR CELFParserDlg::OnQueryDragIcon()
{
	return (HCURSOR) m_hIcon;
}

char	g_szFile[MAX_PATH] = "*.*";	// buffer for file name
char	g_szOutputFile[MAX_PATH] = "a.txt";
CFile	g_fOut;

void CELFParserDlg::OnBtnGetFilename() 
{
	OPENFILENAME ofn;			// common dialog box structure
	HWND hwnd = this->m_hWnd;	// owner window

	// Initialize OPENFILENAME
	ZeroMemory(&ofn, sizeof(OPENFILENAME));
	ofn.lStructSize = sizeof(OPENFILENAME);
	ofn.hwndOwner = hwnd;
	ofn.lpstrFile = g_szFile;
	ofn.nMaxFile = sizeof(g_szFile);
	ofn.lpstrFilter = "ELF files(*.*)\0*.*\0";
	ofn.nFilterIndex = 1;
	ofn.lpstrFileTitle = NULL;
	ofn.nMaxFileTitle = 0;
	ofn.lpstrInitialDir = NULL;
	ofn.lpstrTitle = "打开文件";
	ofn.Flags = OFN_PATHMUSTEXIST | OFN_FILEMUSTEXIST;

	// Display the Open dialog box. 

	if (GetOpenFileName(&ofn)==FALSE){
		return;
	}

	this->GetDlgItem(IDC_EDIT_FILENAME)->SetWindowText(g_szFile);

}

#include ".\\ELF\\elf.h"

void Say( char * pszFormat, ...)
{
	va_list args;
	va_start(args, pszFormat);

	char szTmp[128];
	::vsprintf(szTmp, pszFormat, args);
	g_fOut.Write(szTmp, ::strlen(szTmp));
	
	va_end(args);
}

bool ParseELF(unsigned char * pData)
{
	Elf32_Ehdr * pELFHdr = (Elf32_Ehdr *)pData;

	if (!(	(pELFHdr->e_ident[0] == 0x7F) &&
		(pELFHdr->e_ident[1] == 'E') &&
		(pELFHdr->e_ident[2] == 'L') &&
		(pELFHdr->e_ident[3] == 'F')	)) {
		Say("非 ELF 格式文件或者文件已被破坏。");
		return false;
	}

	Say("\r\n\r\n------------ ELF Header ---------------\r\n");
	Say("e_ident      %10Xh, ", pELFHdr->e_ident[0]);
	Say("\"%c", pELFHdr->e_ident[1]);
	Say("%c", pELFHdr->e_ident[2]);
	Say("%c\", ", pELFHdr->e_ident[3]);
	Say("%xh, ", pELFHdr->e_ident[4]);
	Say("%xh, ", pELFHdr->e_ident[5]);
	Say("%xh, ...\r\n", pELFHdr->e_ident[6]);
	Say("e_type       %10d    %s\r\n", pELFHdr->e_type, pELFHdr->e_type > 4 ? "Processor-specific" : sz_desc_e_type[pELFHdr->e_type]);
	Say("e_machine    %10d    %s\r\n", pELFHdr->e_machine, sz_desc_e_machine[pELFHdr->e_machine]);
	Say("e_version    %10d\r\n", pELFHdr->e_version);
	Say("e_entry      %10X H    %s\r\n", pELFHdr->e_entry, sz_desc_e_entry);
	Say("e_phoff      %10X H\r\n", pELFHdr->e_phoff);
	Say("e_shoff      %10X H\r\n", pELFHdr->e_shoff);
	Say("e_flags      %10d\r\n", pELFHdr->e_flags);
	Say("e_ehsize     %10X H\r\n", pELFHdr->e_ehsize);
	Say("e_phentsize  %10X H\r\n", pELFHdr->e_phentsize);
	Say("e_phnum      %10d\r\n", pELFHdr->e_phnum);
	Say("e_shentsize  %10X H\r\n", pELFHdr->e_shentsize);
	Say("e_shnum      %10X H\r\n", pELFHdr->e_shnum);
	Say("e_shstrndx   %10X H\r\n", pELFHdr->e_shstrndx);

	Elf32_Phdr * pPHdr = (Elf32_Phdr *)(pData + pELFHdr->e_phoff);
	for(int i=0;i<pELFHdr->e_phnum;i++,pPHdr++){
		Say("\r\n------------- Program Header %d -------------\r\n\r\n", i);
		Say("p_type       %10X H    %s\r\n", pPHdr->p_type, pPHdr->p_type > 6 ? "PT_??PROC" : sz_desc_p_type[pPHdr->p_type]);
		Say("p_offset     %10X H\r\n", pPHdr->p_offset);
		Say("p_vaddr      %10X H\r\n", pPHdr->p_vaddr);
		Say("p_paddr      %10X H\r\n", pPHdr->p_paddr);
		Say("p_filesz     %10X H\r\n", pPHdr->p_filesz);
		Say("p_memsz      %10X H\r\n", pPHdr->p_memsz);
		Say("p_flags      %10X H\r\n", pPHdr->p_flags);
		Say("p_align      %10X H\r\n", pPHdr->p_align);
	}
	
	char * pStrTable;	// 用以取得每个 section 的名字
	Elf32_Shdr * pSHdrStrTab = (Elf32_Shdr *)(pData + pELFHdr->e_shoff) + pELFHdr->e_shstrndx;
	pStrTable = (char *)(pData + pSHdrStrTab->sh_offset);
	
	Elf32_Shdr * pSHdr = (Elf32_Shdr *)(pData + pELFHdr->e_shoff);
	for(i=0;i<pELFHdr->e_shnum;i++,pSHdr++){
		Say("\r\n------------- Section Header %d -------------\r\n\r\n", i);
		Say("sh_name      %10X H    %s\r\n", pSHdr->sh_name, pStrTable + pSHdr->sh_name);
		Say("sh_type      %10X H    %s\r\n", pSHdr->sh_type, pSHdr->sh_type > 11 ? "??" : sz_desc_sh_type[pSHdr->sh_type]);
		Say("sh_flags     %10X H    %s\r\n", pSHdr->sh_flags, pSHdr->sh_flags > 7 ? "SHF_MASKPROC" : sz_desc_sh_flags[pSHdr->sh_flags]);
		Say("sh_addr      %10X H    %s\r\n", pSHdr->sh_addr, sz_desc_sh_addr);
		Say("sh_offset    %10X H    %s\r\n", pSHdr->sh_offset, sz_desc_sh_offset);
		Say("sh_size      %10X H\r\n", pSHdr->sh_size);
		Say("sh_link      %10X H\r\n", pSHdr->sh_link);
		Say("sh_info      %10X H\r\n", pSHdr->sh_info);
		Say("sh_addralign %10X H\r\n", pSHdr->sh_addralign);
		Say("sh_entsize   %10X H\r\n", pSHdr->sh_entsize);
	}

	Say("\r\n---------------------------------------\r\n\r\n");

	return true;
}

void CELFParserDlg::OnBtnBegin() 
{
	this->GetDlgItem(IDC_EDIT_FILENAME)->GetWindowText(g_szFile, MAX_PATH);


	const int FILE_BUF_SIZE = 64 * 1024;

	unsigned char uchData[FILE_BUF_SIZE];
	
	HANDLE hf = ::CreateFile(g_szFile,
				GENERIC_READ,
				0,
				NULL,
				OPEN_EXISTING,
				FILE_ATTRIBUTE_NORMAL,
				NULL);
	DWORD dwFileSizeHigh = 0;
	DWORD dwFilesize = ::GetFileSize(hf, &dwFileSizeHigh);
	if ((dwFilesize == INVALID_FILE_SIZE) || (dwFilesize <= 0)) {
		::MessageBox(m_hWnd, "文件错误!", "Error", MB_OK);
		return;
	}
	if (dwFilesize > FILE_BUF_SIZE) {
		::MessageBox(m_hWnd, "文件太大! 本程序处理能力有限.", "Error", MB_OK);
		return;
	}
	DWORD dwRead = 0;
	if (!ReadFile(hf, uchData, dwFilesize, &dwRead, NULL)) {
		int iErr;
		char szError[128];
		iErr = GetLastError();
		::sprintf(szError, "文件读取错误!\r\n错误代码: %d", iErr);
		::MessageBox(m_hWnd, szError, "Error", MB_OK);
		return;
	}
	::CloseHandle(hf);

	::strcpy(g_szOutputFile, g_szFile);
	::strcat(g_szOutputFile, ".txt");
	g_fOut.Open(g_szOutputFile, CFile::modeCreate | CFile::modeWrite);

	Say("\r\n\r\n==================================================================\r\n");
	Say("%s\r\n", g_szFile);
	Say("==================================================================\r\n\r\n");
	
	char szMsgBoxInfo[128];
	char szPathNotepad[128];

	::GetSystemDirectory(szPathNotepad, 128);	// "ExpandEnvironmentStrings" is also OK.
	::strcat(szPathNotepad, "\\notepad.exe");

	if (::ParseELF(uchData)) {
		::strcpy(szMsgBoxInfo, "成功！详细情况在 ");
		::strcat(szMsgBoxInfo, g_szOutputFile);
		::strcat(szMsgBoxInfo, " 中，要现在打开吗？");

		if (::MessageBox(m_hWnd, szMsgBoxInfo, "Finish", MB_YESNO) == IDYES) {
			ShellExecute( 0, "open", szPathNotepad, g_szOutputFile, 0, SW_SHOWNORMAL );
		}
	}
	else {
		::strcpy(szMsgBoxInfo, "发生错误！详细情况在 ");
		::strcat(szMsgBoxInfo, g_szOutputFile);
		::strcat(szMsgBoxInfo, " 中，要现在打开吗？");
		
		if (::MessageBox(m_hWnd, szMsgBoxInfo, "Error", MB_YESNO) == IDYES) {
			ShellExecute( 0, "open", szPathNotepad, g_szOutputFile, 0, SW_SHOWNORMAL );
		}
	}

	g_fOut.Close();

}
