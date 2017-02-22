unit LibWince;

{$mode objfpc}

interface

uses
  Classes, SysUtils;

const
  NLED_COUNT_INFO_ID	= 0;
  NLED_SUPPORTS_INFO_ID	= 1;
  NLED_SETTINGS_INFO_ID	= 2;

type
  TNLED_COUNT_INFO = record
    cLeds: DWORD;
  end;

  TNLED_SETTINGS_INFO = record
    LedNum: DWORD;                 // LED number, 0 is first LED
    OffOnBlink: Integer;           // 0 = off, 1 = on, 2 = blink
    TotalCycleTime: DWORD;         // total cycle time of a blink in microseconds
    OnTime: DWORD;                 // on time of a cycle in microseconds
    OffTime: DWORD;                // off time of a cycle in microseconds
    MetaCycleOn: Integer;          // number of on blink cycles
    MetaCycleOff: Integer;         // number of off blink cycles
   end;

  function NLedGetDeviceInfo(nID:Integer; var pOutput): WordBool;
   stdcall; external 'coredll.dll' name 'NLedGetDeviceInfo';
  function NLedSetDevice(nID: Integer; var pOutput): WordBool;
   stdcall; external 'coredll.dll' name 'NLedSetDevice';

procedure WinceVibratorOn;
procedure WinceVibratorOff;

implementation
procedure WinceVibratorOn;
var
  Countnfo: TNLED_COUNT_INFO;
  Info:TNLED_SETTINGS_INFO;
begin
  NLedGetDeviceInfo(NLED_COUNT_INFO_ID, Countnfo);
  Info.LedNum := Countnfo.cLeds -1;
  Info.OffOnBlink := 1;
  NLedSetDevice(NLED_SETTINGS_INFO_ID, Info);
end;

procedure WinceVibratorOff;
var
  Countnfo: TNLED_COUNT_INFO;
  Info:TNLED_SETTINGS_INFO;
begin
  NLedGetDeviceInfo(NLED_COUNT_INFO_ID, Countnfo);
  Info.LedNum := Countnfo.cLeds -1;
  Info.OffOnBlink := 0;
  NLedSetDevice(NLED_SETTINGS_INFO_ID, Info);
end;
end.

