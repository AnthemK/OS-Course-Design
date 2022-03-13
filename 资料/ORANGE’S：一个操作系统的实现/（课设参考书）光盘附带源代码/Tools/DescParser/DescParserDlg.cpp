// DescParserDlg.cpp : implementation file
//

#include "stdafx.h"
#include "DescParser.h"
#include "DescParserDlg.h"

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
// CDescParserDlg dialog

CDescParserDlg::CDescParserDlg(CWnd* pParent /*=NULL*/)
	: CDialog(CDescParserDlg::IDD, pParent)
{
	//{{AFX_DATA_INIT(CDescParserDlg)
		// NOTE: the ClassWizard will add member initialization here
	//}}AFX_DATA_INIT
	// Note that LoadIcon does not require a subsequent DestroyIcon in Win32
	m_hIcon = AfxGetApp()->LoadIcon(IDR_MAINFRAME);
}

void CDescParserDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CDescParserDlg)
		// NOTE: the ClassWizard will add DDX and DDV calls here
	//}}AFX_DATA_MAP
}

BEGIN_MESSAGE_MAP(CDescParserDlg, CDialog)
	//{{AFX_MSG_MAP(CDescParserDlg)
	ON_WM_SYSCOMMAND()
	ON_WM_PAINT()
	ON_WM_QUERYDRAGICON()
	ON_BN_CLICKED(IDC_BUTTON_START, OnButtonStart)
	ON_BN_CLICKED(IDC_BUTTON_HELP, OnButtonHelp)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CDescParserDlg message handlers

BOOL CDescParserDlg::OnInitDialog()
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
	
	//::SetWindowText(::GetDlgItem(this->m_hWnd, IDC_EDIT_DESCRIPTOR), "07ff00009a0000c0");
	//::SetWindowText(::GetDlgItem(this->m_hWnd, IDC_EDIT_DESCRIPTOR), "ff070000009AC000");
	::SetWindowText(::GetDlgItem(this->m_hWnd, IDC_EDIT_DESCRIPTOR), "ff 07 00 00,00 9A C0 00");
	
	
	return TRUE;  // return TRUE  unless you set the focus to a control
}

void CDescParserDlg::OnSysCommand(UINT nID, LPARAM lParam)
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

void CDescParserDlg::OnPaint() 
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
HCURSOR CDescParserDlg::OnQueryDragIcon()
{
	return (HCURSOR) m_hIcon;
}

const int TEXT_LEN = 512;

void CDescParserDlg::OnButtonStart() 
{
	char szDescType[][TEXT_LEN] = {
		"数据段 - 只读",
		"数据段 - 只读、已访问",
		"数据段 - 读/写",
		"数据段 - 读/写、已访问",
		"数据段 - 只读、向下扩展",
		"数据段 - 只读、向下扩展、已访问",
		"数据段 - 读/写、向下扩展",
		"代码段 - 读/写、向下扩展、已访问",
		"代码段 - 只执行",
		"代码段 - 只执行、已访问",
		"代码段 - 执行/读",
		"代码段 - 执行/读、已访问",
		"代码段 - 只执行、一致码段",
		"代码段 - 只执行、一致码段、已访问",
		"代码段 - 执行/读、一致码段",
		"代码段 - 执行/读、一致码段、已访问"
	};
	
	char szGateType[][TEXT_LEN] = {
		"系统段/门 - <未定义>",
		"系统段/门 - 可用286TSS",
		"系统段/门 - LDT",
		"系统段/门 - 忙的286TSS",
		"系统段/门 - 286调用门",
		"系统段/门 - 任务门",
		"系统段/门 - 286中断门",
		"系统段/门 - 286陷阱门",
		"系统段/门 - 未定义",
		"系统段/门 - 可用386TSS",
		"系统段/门 - <未定义>",
		"系统段/门 - 忙的386TSS",
		"系统段/门 - 386调用门",
		"系统段/门 - <未定义>",
		"系统段/门 - 386中断门",
		"系统段/门 - 386陷阱门"
			
	};

	char szDT[][TEXT_LEN] = {
		"系统段描述符或门",
		"存储段描述符"
			
	};
	
	char szG[][TEXT_LEN] = {
		"界限粒度为字节",
		"界限粒度为4K字节"
			
	};

	char szText[TEXT_LEN];
	::GetWindowText(::GetDlgItem(this->m_hWnd, IDC_EDIT_DESCRIPTOR), szText, TEXT_LEN);

	// set other bytes of the string '0'
	::memset(szText + ::strlen(szText), '0', TEXT_LEN - ::strlen(szText));

	int iDesc[8];
	int iHigh;
	int iLow;

	int j = 0;
	for(int i=0;i<8;i++){
		while (!(((szText[j] >= '0') && (szText[j] <= '9')) ||
			((::toupper(szText[j]) >= 'A') && (::toupper(szText[j]) <= 'F')))
			) {
			j++;
		}// jump over invalid char
		iHigh	= szText[j+0] >= ::toupper('a') ? ::toupper(szText[j+0]) - 'A' + 10 : szText[j+0] - '0';
		iLow	= szText[j+1] >= ::toupper('a') ? ::toupper(szText[j+1]) - 'A' + 10 : szText[j+1] - '0';
		iDesc[i] = iHigh * 0x10 + iLow;
		j += 2;
	}

	char szOutput[TEXT_LEN];

	int iBase	= iDesc[2] + (iDesc[3] << 8) + (iDesc[4] << 16) + (iDesc[7] << 24);
	int iLimit	= iDesc[0] + (iDesc[1] << 8) + (iDesc[6] & 0xF);
	int iType	= iDesc[5] & 0xF;
	int iG		= (iDesc[6] >> 7) & 1;
	int iD		= (iDesc[6] >> 6) & 1;
	int iAVL	= (iDesc[6] >> 4) & 1;
	int iP		= (iDesc[5] >> 7) & 1;
	int iDPL	= (iDesc[5] >> 5) & 3;
	int iDT		= (iDesc[5] >> 4) & 1;

	// Type
	char szType[TEXT_LEN];
	::strcpy(szType, iDT ? szDescType[iType] : szGateType[iType]);

	// Limit
	if (iG) {
		iLimit *= 4 * 1024;
	}
	
	::sprintf(szOutput, "\r\n\r\n\
		------------------Output-------------------\r\n\r\n\r\n\
		Base:\t0x%X\r\n\r\n\r\n\
		Limit:\t0x%X\r\n\r\n\r\n\
		Type:\t%s\r\n\r\n\r\n\
		DPL:\t%x\r\n\r\n\r\n\
		G:\t%x\t%s\r\n\r\n\r\n\
		D:\t%x\r\n\r\n\r\n\
		AVL:\t%x\r\n\r\n\r\n\
		P:\t%x\r\n\r\n\r\n\
		DT:\t%x\t%s\r\n\r\n\r\n\
		--------------------END--------------------", 
		iBase, iLimit, szType, iDPL, iG, szG[iG], iD, iAVL, iP, iDT, szDT[iDT]);

	//::MessageBox(this->m_hWnd, szOutput, szText, MB_OK);

	::SetWindowText(::GetDlgItem(this->m_hWnd, IDC_EDIT_OUTPUT), szOutput);

}

void CDescParserDlg::OnButtonHelp() 
{
	::SetWindowText(::GetDlgItem(this->m_hWnd, IDC_EDIT_OUTPUT),
		"\r\n\r\n\
		-------------------Help--------------------\r\n\r\n\r\n\
		All unrecognizable characters will be ignored.\r\n\r\n\r\n\
		So all of them should be OK:\r\n\r\n\r\n\r\n\
		[Low bits --> High bits]\r\n\r\n\r\n\r\n\
		ff070000009AC000\r\n\r\n\r\n\
		ff 07 00 00 00 9A C0 00\r\n\r\n\r\n\
		ff 07 00 00,00 9A C0 00\r\n\r\n\r\n\
		ff,07 00 00,00 9A C0 00\r\n\r\n\r\n\
		ff 070000;00 9A C0,00\r\n\r\n\r\n\
		--------------------END--------------------");
}

void CDescParserDlg::OnOK()
{
	this->OnButtonStart();
}
