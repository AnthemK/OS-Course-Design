// DescParser.h : main header file for the DESCPARSER application
//

#if !defined(AFX_DESCPARSER_H__015C52E2_3971_47B0_8722_D8E923591DF4__INCLUDED_)
#define AFX_DESCPARSER_H__015C52E2_3971_47B0_8722_D8E923591DF4__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#ifndef __AFXWIN_H__
	#error include 'stdafx.h' before including this file for PCH
#endif

#include "resource.h"		// main symbols

/////////////////////////////////////////////////////////////////////////////
// CDescParserApp:
// See DescParser.cpp for the implementation of this class
//

class CDescParserApp : public CWinApp
{
public:
	CDescParserApp();

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CDescParserApp)
	public:
	virtual BOOL InitInstance();
	//}}AFX_VIRTUAL

// Implementation

	//{{AFX_MSG(CDescParserApp)
		// NOTE - the ClassWizard will add and remove member functions here.
		//    DO NOT EDIT what you see in these blocks of generated code !
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};


/////////////////////////////////////////////////////////////////////////////

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_DESCPARSER_H__015C52E2_3971_47B0_8722_D8E923591DF4__INCLUDED_)
