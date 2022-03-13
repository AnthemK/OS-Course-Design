// KrnlCheckerDlg.cpp : implementation file
//

#include "stdafx.h"
#include "KrnlChecker.h"
#include "KrnlCheckerDlg.h"

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
// CKrnlCheckerDlg dialog

CKrnlCheckerDlg::CKrnlCheckerDlg(CWnd* pParent /*=NULL*/)
	: CDialog(CKrnlCheckerDlg::IDD, pParent)
{
	//{{AFX_DATA_INIT(CKrnlCheckerDlg)
		// NOTE: the ClassWizard will add member initialization here
	//}}AFX_DATA_INIT
	// Note that LoadIcon does not require a subsequent DestroyIcon in Win32
	m_hIcon = AfxGetApp()->LoadIcon(IDR_MAINFRAME);
}

void CKrnlCheckerDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CKrnlCheckerDlg)
		// NOTE: the ClassWizard will add DDX and DDV calls here
	//}}AFX_DATA_MAP
}

BEGIN_MESSAGE_MAP(CKrnlCheckerDlg, CDialog)
	//{{AFX_MSG_MAP(CKrnlCheckerDlg)
	ON_WM_SYSCOMMAND()
	ON_WM_PAINT()
	ON_WM_QUERYDRAGICON()
	ON_BN_CLICKED(IDC_BTN_GET_FILENAME, OnBtnGetFilename)
	ON_BN_CLICKED(IDC_BTN_CHECK, OnBtnCheck)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CKrnlCheckerDlg message handlers

BOOL CKrnlCheckerDlg::OnInitDialog()
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

void CKrnlCheckerDlg::OnSysCommand(UINT nID, LPARAM lParam)
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

void CKrnlCheckerDlg::OnPaint() 
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
HCURSOR CKrnlCheckerDlg::OnQueryDragIcon()
{
	return (HCURSOR) m_hIcon;
}

//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////

#include ".\\ELF\\elf.h"

char	g_szFile[MAX_PATH] = "*.*";	// buffer for file name

void CKrnlCheckerDlg::OnBtnGetFilename() 
{
	OPENFILENAME ofn;		// common dialog box structure
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


void CheckELF(unsigned char * pData, char * pOutBuf)
{
	strcat(pOutBuf, "\r\n\t   (1M = 10 0000h = 1,048,576)\r\n\r\n");
	strcat(pOutBuf, "\t   30000h ~    80000h <--- Available for Tinix Kernel\r\n\r\n");
	//strcat(pOutBuf, "------------------------------------------\r\n\r\n");
	
	char tmp[128];
	
	Elf32_Ehdr * pELFHdr = (Elf32_Ehdr *)pData;
	
	Elf32_Phdr * pPHdr = (Elf32_Phdr *)(pData + pELFHdr->e_phoff);
	sprintf(tmp, "\t%8Xh", pPHdr->p_vaddr);
	strcat(pOutBuf, tmp);
	strcat(pOutBuf, " ~ ");
	pPHdr += pELFHdr->e_phnum - 1;
	sprintf(tmp, "%8Xh", pPHdr->p_vaddr + pPHdr->p_memsz);
	strcat(pOutBuf, tmp);
	strcat(pOutBuf, " <--- Current Kernel");
	
	//	for(int i=0;i<pELFHdr->e_phnum;i++,pPHdr++){
	//		sprintf(tmp, "%Xh", pPHdr->p_vaddr);
	//		strcat(pOutBuf, tmp);
	//		strcat(pOutBuf, "-->");
	//		sprintf(tmp, "%Xh", pPHdr->p_vaddr + pPHdr->p_memsz);
	//		strcat(pOutBuf, tmp);
	//		strcat(pOutBuf, "; ");
	//	}
}

void CKrnlCheckerDlg::OnBtnCheck() 
{
	const int FILE_BUF_SIZE = 64 * 1024;
	
	unsigned char uchData[FILE_BUF_SIZE];
	
	this->GetDlgItem(IDC_EDIT_FILENAME)->GetWindowText(g_szFile, MAX_PATH);
	
	
	HANDLE hf = ::CreateFile(g_szFile,
		GENERIC_READ,
		0,
		NULL,
		OPEN_EXISTING,
		FILE_ATTRIBUTE_NORMAL,
		NULL);
	DWORD dwFileSizeHigh = 0;
	DWORD dwFilesize = ::GetFileSize(hf, &dwFileSizeHigh);
	if (dwFilesize <= 0) {
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
		::sprintf(szError, "文件读取错误!\n错误代码: %d", iErr);
		::MessageBox(m_hWnd, szError, "Error", MB_OK);
		return;
	}
	::CloseHandle(hf);
	
	char szOutBuf[128] = "";
	::CheckELF(uchData, szOutBuf);
	
	::SetWindowText(::GetDlgItem(this->m_hWnd, IDC_EDIT_OUTPUT), szOutBuf);
}
