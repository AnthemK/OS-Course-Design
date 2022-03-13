// KrnlChecker.h : main header file for the KRNLCHECKER application
//

#if !defined(AFX_KRNLCHECKER_H__EC4D0B96_99DB_4EB6_A78B_2702D76EBA11__INCLUDED_)
#define AFX_KRNLCHECKER_H__EC4D0B96_99DB_4EB6_A78B_2702D76EBA11__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#ifndef __AFXWIN_H__
	#error include 'stdafx.h' before including this file for PCH
#endif

#include "resource.h"		// main symbols

/////////////////////////////////////////////////////////////////////////////
// CKrnlCheckerApp:
// See KrnlChecker.cpp for the implementation of this class
//

class CKrnlCheckerApp : public CWinApp
{
public:
	CKrnlCheckerApp();

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CKrnlCheckerApp)
	public:
	virtual BOOL InitInstance();
	//}}AFX_VIRTUAL

// Implementation

	//{{AFX_MSG(CKrnlCheckerApp)
		// NOTE - the ClassWizard will add and remove member functions here.
		//    DO NOT EDIT what you see in these blocks of generated code !
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};


/////////////////////////////////////////////////////////////////////////////

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_KRNLCHECKER_H__EC4D0B96_99DB_4EB6_A78B_2702D76EBA11__INCLUDED_)
