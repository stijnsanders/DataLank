unit MDACVer_TLB;

// ************************************************************************ //
// WARNING                                                                    
// -------                                                                    
// The types declared in this file were generated from data read from a       
// Type Library. If this type library is explicitly or indirectly (via        
// another type library referring to this type library) re-imported, or the   
// 'Refresh' command of the Type Library Editor activated while editing the   
// Type Library, the contents of this file will be regenerated and all        
// manual modifications will be lost.                                         
// ************************************************************************ //

// PASTLWTR : $Revision:   1.130.1.0.1.0.1.6  $
// File generated on 23/03/2017 11:57:49 from Type Library described below.

// ************************************************************************  //
// Type Lib: C:\Windows\system32\odbcconf.dll (1)
// LIBID: {54AF9343-1923-11D3-9CA4-00C04F72C514}
// LCID: 0
// Helpfile: 
// DepndLst: 
//   (1) v2.0 stdole, (C:\Windows\SysWOW64\stdole2.tlb)
//   (2) v4.0 StdVCL, (C:\Windows\SysWOW64\stdvcl40.dll)
// Errors:
//   Hint: Member 'String' of 'IVersion' changed to 'String_'
// ************************************************************************ //
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers. 
{$WARN SYMBOL_PLATFORM OFF}
{$WRITEABLECONST ON}
{$VARPROPSETTER ON}
interface

uses Windows, ActiveX, Classes, Graphics, OleServer, StdVCL, Variants;
  

// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:        
//   Type Libraries     : LIBID_xxxx                                      
//   CoClasses          : CLASS_xxxx                                      
//   DISPInterfaces     : DIID_xxxx                                       
//   Non-DISP interfaces: IID_xxxx                                        
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  MDACVerMajorVersion = 2;
  MDACVerMinorVersion = 50;

  LIBID_MDACVer: TGUID = '{54AF9343-1923-11D3-9CA4-00C04F72C514}';

  IID_IVersion: TGUID = '{54AF934F-1923-11D3-9CA4-00C04F72C514}';
  CLASS_Version: TGUID = '{54AF9350-1923-11D3-9CA4-00C04F72C514}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  IVersion = interface;
  IVersionDisp = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  Version = IVersion;


// *********************************************************************//
// Interface: IVersion
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {54AF934F-1923-11D3-9CA4-00C04F72C514}
// *********************************************************************//
  IVersion = interface(IDispatch)
    ['{54AF934F-1923-11D3-9CA4-00C04F72C514}']
    function Get_Major: OleVariant; safecall;
    function Get_Minor: OleVariant; safecall;
    function Get_Build: OleVariant; safecall;
    function Get_Qfe: OleVariant; safecall;
    function Get_String_: OleVariant; safecall;
    property Major: OleVariant read Get_Major;
    property Minor: OleVariant read Get_Minor;
    property Build: OleVariant read Get_Build;
    property Qfe: OleVariant read Get_Qfe;
    property String_: OleVariant read Get_String_;
  end;

// *********************************************************************//
// DispIntf:  IVersionDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {54AF934F-1923-11D3-9CA4-00C04F72C514}
// *********************************************************************//
  IVersionDisp = dispinterface
    ['{54AF934F-1923-11D3-9CA4-00C04F72C514}']
    property Major: OleVariant readonly dispid 1;
    property Minor: OleVariant readonly dispid 2;
    property Build: OleVariant readonly dispid 3;
    property Qfe: OleVariant readonly dispid 4;
    property String_: OleVariant readonly dispid 5;
  end;

// *********************************************************************//
// The Class CoVersion provides a Create and CreateRemote method to          
// create instances of the default interface IVersion exposed by              
// the CoClass Version. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoVersion = class
    class function Create: IVersion;
    class function CreateRemote(const MachineName: string): IVersion;
  end;

implementation

uses ComObj;

class function CoVersion.Create: IVersion;
begin
  Result := CreateComObject(CLASS_Version) as IVersion;
end;

class function CoVersion.CreateRemote(const MachineName: string): IVersion;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_Version) as IVersion;
end;

end.
