; CLW file contains information for the MFC ClassWizard

[General Info]
Version=1
LastClass=CELFParserDlg
LastTemplate=CDialog
NewFileInclude1=#include "stdafx.h"
NewFileInclude2=#include "ELFParser.h"

ClassCount=3
Class1=CELFParserApp
Class2=CELFParserDlg
Class3=CAboutDlg

ResourceCount=3
Resource1=IDD_ABOUTBOX
Resource2=IDR_MAINFRAME
Resource3=IDD_ELFPARSER_DIALOG

[CLS:CELFParserApp]
Type=0
HeaderFile=ELFParser.h
ImplementationFile=ELFParser.cpp
Filter=N

[CLS:CELFParserDlg]
Type=0
HeaderFile=ELFParserDlg.h
ImplementationFile=ELFParserDlg.cpp
Filter=D
BaseClass=CDialog
VirtualFilter=dWC
LastObject=CELFParserDlg

[CLS:CAboutDlg]
Type=0
HeaderFile=ELFParserDlg.h
ImplementationFile=ELFParserDlg.cpp
Filter=D

[DLG:IDD_ABOUTBOX]
Type=1
Class=CAboutDlg
ControlCount=4
Control1=IDC_STATIC,static,1342177283
Control2=IDC_STATIC,static,1342308480
Control3=IDC_STATIC,static,1342308352
Control4=IDOK,button,1342373889

[DLG:IDD_ELFPARSER_DIALOG]
Type=1
Class=CELFParserDlg
ControlCount=3
Control1=IDC_EDIT_FILENAME,edit,1350631552
Control2=IDC_BTN_GET_FILENAME,button,1342242816
Control3=IDC_BTN_BEGIN,button,1342242816

