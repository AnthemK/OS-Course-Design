// ELFParserDlg.h : header file
//

#if !defined(AFX_ELFPARSERDLG_H__611A1174_D7F4_4071_9487_C176130066AB__INCLUDED_)
#define AFX_ELFPARSERDLG_H__611A1174_D7F4_4071_9487_C176130066AB__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

/////////////////////////////////////////////////////////////////////////////
// CELFParserDlg dialog

class CELFParserDlg : public CDialog
{
// Construction
public:
	CELFParserDlg(CWnd* pParent = NULL);	// standard constructor

// Dialog Data
	//{{AFX_DATA(CELFParserDlg)
	enum { IDD = IDD_ELFPARSER_DIALOG };
		// NOTE: the ClassWizard will add data members here
	//}}AFX_DATA

	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CELFParserDlg)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);	// DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:
	HICON m_hIcon;

	// Generated message map functions
	//{{AFX_MSG(CELFParserDlg)
	virtual BOOL OnInitDialog();
	afx_msg void OnSysCommand(UINT nID, LPARAM lParam);
	afx_msg void OnPaint();
	afx_msg HCURSOR OnQueryDragIcon();
	afx_msg void OnBtnGetFilename();
	afx_msg void OnBtnBegin();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_ELFPARSERDLG_H__611A1174_D7F4_4071_9487_C176130066AB__INCLUDED_)
