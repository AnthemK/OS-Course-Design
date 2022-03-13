// DescParserDlg.h : header file
//

#if !defined(AFX_DESCPARSERDLG_H__B651C643_92CA_4CA9_8BE7_D7877C386F26__INCLUDED_)
#define AFX_DESCPARSERDLG_H__B651C643_92CA_4CA9_8BE7_D7877C386F26__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

/////////////////////////////////////////////////////////////////////////////
// CDescParserDlg dialog

class CDescParserDlg : public CDialog
{
// Construction
public:
	CDescParserDlg(CWnd* pParent = NULL);	// standard constructor
	void CDescParserDlg::OnOK();

// Dialog Data
	//{{AFX_DATA(CDescParserDlg)
	enum { IDD = IDD_DESCPARSER_DIALOG };
		// NOTE: the ClassWizard will add data members here
	//}}AFX_DATA

	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CDescParserDlg)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);	// DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:
	HICON m_hIcon;

	// Generated message map functions
	//{{AFX_MSG(CDescParserDlg)
	virtual BOOL OnInitDialog();
	afx_msg void OnSysCommand(UINT nID, LPARAM lParam);
	afx_msg void OnPaint();
	afx_msg HCURSOR OnQueryDragIcon();
	afx_msg void OnButtonStart();
	afx_msg void OnButtonHelp();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_DESCPARSERDLG_H__B651C643_92CA_4CA9_8BE7_D7877C386F26__INCLUDED_)
