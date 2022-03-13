// KrnlCheckerDlg.h : header file
//

#if !defined(AFX_KRNLCHECKERDLG_H__92CD1E47_6D68_4ECC_A1EB_32BFED9AC63C__INCLUDED_)
#define AFX_KRNLCHECKERDLG_H__92CD1E47_6D68_4ECC_A1EB_32BFED9AC63C__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

/////////////////////////////////////////////////////////////////////////////
// CKrnlCheckerDlg dialog

class CKrnlCheckerDlg : public CDialog
{
// Construction
public:
	CKrnlCheckerDlg(CWnd* pParent = NULL);	// standard constructor

// Dialog Data
	//{{AFX_DATA(CKrnlCheckerDlg)
	enum { IDD = IDD_KRNLCHECKER_DIALOG };
		// NOTE: the ClassWizard will add data members here
	//}}AFX_DATA

	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CKrnlCheckerDlg)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);	// DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:
	HICON m_hIcon;

	// Generated message map functions
	//{{AFX_MSG(CKrnlCheckerDlg)
	virtual BOOL OnInitDialog();
	afx_msg void OnSysCommand(UINT nID, LPARAM lParam);
	afx_msg void OnPaint();
	afx_msg HCURSOR OnQueryDragIcon();
	afx_msg void OnBtnGetFilename();
	afx_msg void OnBtnCheck();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_KRNLCHECKERDLG_H__92CD1E47_6D68_4ECC_A1EB_32BFED9AC63C__INCLUDED_)
