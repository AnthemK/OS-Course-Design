// ELFParser.h : main header file for the ELFPARSER application
//

#if !defined(AFX_ELFPARSER_H__A6C0B0FF_33D0_48B5_AC0A_FB19A5177239__INCLUDED_)
#define AFX_ELFPARSER_H__A6C0B0FF_33D0_48B5_AC0A_FB19A5177239__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#ifndef __AFXWIN_H__
	#error include 'stdafx.h' before including this file for PCH
#endif

#include "resource.h"		// main symbols

/////////////////////////////////////////////////////////////////////////////
// CELFParserApp:
// See ELFParser.cpp for the implementation of this class
//

class CELFParserApp : public CWinApp
{
public:
	CELFParserApp();

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CELFParserApp)
	public:
	virtual BOOL InitInstance();
	//}}AFX_VIRTUAL

// Implementation

	//{{AFX_MSG(CELFParserApp)
		// NOTE - the ClassWizard will add and remove member functions here.
		//    DO NOT EDIT what you see in these blocks of generated code !
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};


/////////////////////////////////////////////////////////////////////////////

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_ELFPARSER_H__A6C0B0FF_33D0_48B5_AC0A_FB19A5177239__INCLUDED_)
