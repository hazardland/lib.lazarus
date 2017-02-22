unit LibWinNT;

interface

uses FileUtil, _Strings;

function UserName: string;
function UserHomeDir: string;
function UserDataDir: string;
function UserLocalDir: string;
function ExePath: string;
function ExeDir: string;

implementation

function UserHomeDir: string;
begin
    Result := GetAppConfigDirUTF8(false);
    Result := Before ('\AppData\', Result)+'\';
end;

function UserDataDir: string;
begin
    Result := GetAppConfigDirUTF8(false);
    Result := Before ('\AppData\', Result)+'\AppData\';
end;

function UserLocalDir: string;
begin
	Result := UserHomeDir+'AppData\Local\';
    //Result := 'C:\Users\biohazard\AppData\Local\ConEmu\';
end;

function UserName: string;
begin
    Result := GetAppConfigDirUTF8(false);
    Result := AfterLast ('\', Before('\AppData\', Result));
end;

function ExePath: string;
begin
	Result := GetCurrentDirUTF8 + '\' + BetweenLast('\','\',GetAppConfigDirUTF8(false)) + '.exe';
end;

function ExeDir: string;
begin
	Result := GetCurrentDirUTF8;
end;

end.
