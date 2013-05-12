unit _System;

interface

uses Windows, SysUtils, Winsock, Classes;

procedure SystemDesktopEnable;
procedure SystemDesktopDisable;
procedure SystemTaskbarDisable;
procedure SystemTaskbarEnable;

procedure SystemTaskbarHide;
procedure SystemTaskbarShow;
procedure SystemWindowsMinimize;

procedure SystemShutdownForce;
procedure SystemRestartForce;
procedure SystemShutDown;
procedure SystemRestart;

function SystemScreenResolutionSet(Width, Height: integer): longint;
function SystemComputerName: string;
function SystemUserLogin: string;
function SystemIp: string;


implementation


procedure SystemDesktopEnable;
begin
  EnableWindow(FindWindowEx(FindWindow('Progman', nil), 0,
    'ShellDll_DefView', nil), False);
end;

procedure SystemDesktopDisable;
begin
  EnableWindow(FindWindowEx(FindWindow('Progman', nil), 0,
    'ShellDll_DefView', nil), True);
end;

procedure SystemTaskbarDisable;
begin
  EnableWindow(FindWindow('Shell_TrayWnd', nil), False);
end;

procedure SystemTaskbarEnable;
begin
  EnableWindow(FindWindow('Shell_TrayWnd', nil), True);
end;

function SystemIp: string;
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

procedure SystemTaskbarHide;
var
  wndClass: array[0..50] of char;
  wndHandle: THandle;
begin
  StrPCopy(@wndClass[0], 'Shell_TrayWnd');
  wndHandle := FindWindow(@wndClass[0], nil);
  ShowWindow(wndHandle, SW_HIDE);
end;

procedure SystemTaskbarShow;
var
  wndClass: array[0..50] of char;
  wndHandle: THandle;
begin
  StrPCopy(@wndClass[0], 'Shell_TrayWnd');
  wndHandle := FindWindow(@wndClass[0], nil);
  ShowWindow(wndHandle, SW_SHOW);
end;

procedure SystemWindowsMinimize;
begin
  Keybd_event(VK_LWIN, 0, 0, 0);
  Keybd_event(byte('M'), 0, 0, 0);
  Keybd_event(byte('M'), 0, KEYEVENTF_KEYUP, 0);
  Keybd_event(VK_LWIN, 0, KEYEVENTF_KEYUP, 0);
end;

function SystemPrivilegeSet(sPrivilegeName: string; bEnabled: boolean): boolean;
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
      TP.Privileges[0].Attributes :=
        SE_PRIVILEGE_ENABLED;
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

function SystemExit(iFlags: integer): boolean;
begin
  Result := True;
  if (SystemPrivilegeSet('SeShutdownPrivilege', True)) then
  begin
    if (not ExitWindowsEx(iFlags, 0)) then
    begin
      // handle errors...
      Result := False;
    end;
    SystemPrivilegeSet('SeShutdownPrivilege', False);
  end
  else
  begin
    // handle errors...
    Result := False;
  end;
end;


procedure SystemShutdownForce;
begin
  SystemExit(EWX_SHUTDOWN + EWX_FORCE + EWX_POWEROFF);
end;

procedure SystemRestartForce;
begin
  SystemExit(EWX_REBOOT + EWX_FORCE);
end;

procedure SystemShutdown;
begin
  SystemExit(EWX_SHUTDOWN + EWX_POWEROFF);
end;

procedure SystemRestart;
begin
  SystemExit(EWX_REBOOT);
end;



function SystemUserLogin: string;
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

function SystemComputerName: string;
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


function SystemScreenResolutionSet(Width, Height: integer): longint;
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



end.

