unit LibApplication;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil;


function ApplicationConfigPath: String;
function ApplicationConfigFile: String;

implementation

function ApplicationConfigPath: String;
begin
  if not DirectoryExistsUTF8(GetAppConfigDirUTF8(False)) then CreateDirUTF8(GetAppConfigDirUTF8(False));
  Result := GetAppConfigDirUTF8(False);
end;

function ApplicationConfigFile: String;
begin
  if not DirectoryExistsUTF8(GetAppConfigDirUTF8(False)) then CreateDirUTF8(GetAppConfigDirUTF8(False));
  Result := GetAppConfigFileUTF8(False);
end;


end.

