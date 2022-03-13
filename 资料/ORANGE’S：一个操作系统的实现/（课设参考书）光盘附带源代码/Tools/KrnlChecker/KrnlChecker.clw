; CLW file contains information for the MFC ClassWizard

[General Info]
Version=1
LastClass=CKrnlCheckerDlg
LastTemplate=CDialog
NewFileInclude1=#include "stdafx.h"
NewFileInclude2=#include "KrnlChecker.h"

ClassCount=4
Class1=CKrnlCheckerApp
Class2=CKrnlCheckerDlg
Class3=CAboutDlg

ResourceCount=3
Resource1=IDD_ABOUTBOX
Resource2=IDR_MAINFRAME
Resource3=IDD_KRNLCHECKER_DIALOG

[CLS:CKrnlCheckerApp]
Type=0
HeaderFile=KrnlChecker.h
ImplementationFile=KrnlChecker.cpp
Filter=N

[CLS:CKrnlCheckerDlg]
Type=0
HeaderFile=KrnlCheckerDlg.h
ImplementationFile=KrnlCheckerDlg.cpp
Filter=D
BaseClass=CDialog
VirtualFilter=dWC

[CLS:CAboutDlg]
Type=0
HeaderFile=KrnlCheckerDlg.h
ImplementationFile=KrnlCheckerDlg.cpp
Filter=D

[DLG:IDD_ABOUTBOX]
Type=1
Class=CAboutDlg
ControlCount=4
Control1=IDC_STATIC,static,1342177283
Control2=IDC_STATIC,static,1342308480
Control3=IDC_STATIC,static,1342308352
Control4=IDOK,button,1342373889

[DLG:IDD_KRNLCHECKER_DIALOG]
Type=1
Class=CKrnlCheckerDlg
ControlCount=4
Control1=IDC_EDIT_FILENAME,edit,1350631552
Control2=IDC_EDIT_OUTPUT,edit,1350631556
Control3=IDC_BTN_GET_FILENAME,button,1342242816
Control4=IDC_BTN_CHECK,button,1342242816

