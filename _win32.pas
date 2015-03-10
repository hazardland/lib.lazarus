unit _Win32;

interface

uses Windows, SysUtils, Winsock, Classes, Strings, registry;

procedure DesktopEnable;
procedure DesktopDisable;
procedure TaskbarDisable;
procedure TaskbarEnable;

procedure TaskbarHide;
procedure TaskbarShow;
procedure WindowsMinimize;

procedure ShutdownForce;
procedure RestartForce;
procedure ShutDown;
procedure Restart;

function ScreenSet(Width, Height: integer): longint;
function ComputerName: string;

function UserName: string;

function Ip: string;

function RegistryRead (Root:HKEY; Key, Name: string): string;
function RegistryWrite (Root:HKEY; Key, Name, Value: String): Boolean;

implementation


procedure DesktopEnable;
begin
  EnableWindow(FindWindowEx(FindWindow('Progman', nil), 0,
    'ShellDll_DefView', nil), False);
end;

procedure DesktopDisable;
begin
  EnableWindow(FindWindowEx(FindWindow('Progman', nil), 0,
    'ShellDll_DefView', nil), True);
end;

procedure TaskbarDisable;
begin
  EnableWindow(FindWindow('Shell_TrayWnd', nil), False);
end;

procedure TaskbarEnable;
begin
  EnableWindow(FindWindow('Shell_TrayWnd', nil), True);
end;

function Ip: string;
type
  TaPInAddr = array [0..10] of PInAddr;
  PaPInAddr = ^TaPInAddr;
var
  phe: PHostEnt;
  pptr: PaPInAddr;
  Buffer: array [0..63] of char;
  I: integer;
  GInitData: TWSADATA;

begin
  WSAStartup($101, GInitData);
  Result := '';
  GetHostName(Buffer, SizeOf(Buffer));
  phe := GetHostByName(buffer);
  if phe = nil then
    Exit;
  pptr := PaPInAddr(Phe^.h_addr_list);
  I := 0;
  while pptr^[I] <> nil do
  begin
    Result := StrPas(inet_ntoa(pptr^[I]^));
    Inc(I);
  end;
  WSACleanup;
end;

procedure TaskbarHide;
var
  wndClass: array[0..50] of char;
  wndHandle: THandle;
begin
  StrPCopy(@wndClass[0], 'Shell_TrayWnd');
  wndHandle := FindWindow(@wndClass[0], nil);
  ShowWindow(wndHandle, SW_HIDE);
end;

procedure TaskbarShow;
var
  wndClass: array[0..50] of char;
  wndHandle: THandle;
begin
  StrPCopy(@wndClass[0], 'Shell_TrayWnd');
  wndHandle := FindWindow(@wndClass[0], nil);
  ShowWindow(wndHandle, SW_SHOW);
end;

procedure WindowsMinimize;
begin
  Keybd_event(VK_LWIN, 0, 0, 0);
  Keybd_event(byte('M'), 0, 0, 0);
  Keybd_event(byte('M'), 0, KEYEVENTF_KEYUP, 0);
  Keybd_event(VK_LWIN, 0, KEYEVENTF_KEYUP, 0);
end;

function PrivilegeSet(sPrivilegeName: string; bEnabled: boolean): boolean;
var
  TPPrev, TP: TTokenPrivileges;
  Token: THandle;
  dwRetLen: DWord;
begin
  Result := False;
  OpenProcessToken(
    GetCurrentProcess,
    TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY,
    Token);
  TP.PrivilegeCount := 1;
  if (LookupPrivilegeValue(nil, PChar(sPrivilegeName),
    TP.Privileges[0].LUID)) then
  begin
    if (bEnabled) then
    begin
      TP.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;
    end
    else
    begin
      TP.Privileges[0].Attributes :=
        0;
    end;
    dwRetLen := 0;
    Result := AdjustTokenPrivileges(Token, False,
      TP, SizeOf(TPPrev), TPPrev,
      dwRetLen);
  end;
  CloseHandle(Token);
end;



// iFlags:

//  one of the following must be
//  specified

//   EWX_LOGOFF
//   EWX_REBOOT
//   EWX_SHUTDOWN

//  following attributes may be
//  combined with above flags

//   EWX_POWEROFF
//   EWX_FORCE    : terminate processes

function Exit(iFlags: integer): boolean;
begin
  Result := True;
  if (PrivilegeSet('SeShutdownPrivilege', True)) then
  begin
    if (not ExitWindowsEx(iFlags, 0)) then
    begin
      // handle errors...
      Result := False;
    end;
    PrivilegeSet('SeShutdownPrivilege', False);
  end
  else
  begin
    // handle errors...
    Result := False;
  end;
end;


procedure ShutdownForce;
begin
  Exit(EWX_SHUTDOWN + EWX_FORCE + EWX_POWEROFF);
end;

procedure RestartForce;
begin
  Exit(EWX_REBOOT + EWX_FORCE);
end;

procedure Shutdown;
begin
  Exit(EWX_SHUTDOWN + EWX_POWEROFF);
end;

procedure Restart;
begin
  Exit(EWX_REBOOT);
end;



function UserName: string;
const
  cnMaxLen = 254;
var
  sUserName: string;
  dwUserNameLen: DWord;
begin
  dwUserNameLen := cnMaxLen - 1;
  SetLength(sUserName, cnMaxLen);
  GetUserName(PChar(sUserName), dwUserNameLen);
  SetLength(sUserName, dwUserNameLen);
  Result := sUserName;
  if dwUserNameLen = cnMaxLen - 1 then
    Result := '';
end;

function ComputerName: string;
const
  cnMaxLen = 254;
var
  sUserName: string;
  dwUserNameLen: DWord;
begin
  dwUserNameLen := cnMaxLen - 1;
  SetLength(sUserName, cnMaxLen);
  GetComputerName(PChar(sUserName), dwUserNameLen);
  SetLength(sUserName, dwUserNameLen);
  Result := sUserName;
  if dwUserNameLen = cnMaxLen - 1 then
    Result := '';
end;


function ScreenSet(Width, Height: integer): longint;
var
  DeviceMode: TDeviceMode;
begin
  with DeviceMode do
  begin
    dmSize := SizeOf(TDeviceMode);
    dmPelsWidth := Width;
    dmPelsHeight := Height;
    dmFields := DM_PELSWIDTH or DM_PELSHEIGHT;
  end;
  Result := ChangeDisplaySettings(DeviceMode, CDS_UPDATEREGISTRY);
end;

function RegistryRead(Root:HKEY; Key, Name: string): string;
var
  Registry: TRegistry;
begin
  Registry := TRegistry.Create;
  Registry.RootKey := Root;
  if (Registry.OpenKeyReadOnly(Key)) then
  begin
       Result := Registry.ReadString(Name);
  end;
  Registry.Free;
end;

function RegistryWrite (Root:HKEY; Key, Name, Value: String): Boolean;
var
  Registry: TRegistry;
begin

  Result := False;
  Registry := TRegistry.Create;
  Registry.RootKey := Root;
  if not (Registry.KeyExists(Key)) then
  begin
     WriteLn(Key+' does not exist');
     Registry.CreateKey(Key);
  end;
  if (Registry.OpenKey(Key,True)) then
  begin
       //Try
          Registry.WriteString(Name,Value);
          Registry.CloseKey;
          Result := True;
          WriteLn('Writing registry '+Key);
       //finally
       //end;
  end;
  Registry.Free;
end;

end.

