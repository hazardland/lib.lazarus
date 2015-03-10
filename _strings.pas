unit _Strings;

{$mode objfpc}

interface

uses
  Classes, SysUtils, StrUtils, _Arrays;

function Before (This, InThat: String): String;
function After (This, InThat: String): String;
function Between (This, That, InThat: String): String;
function AfterLast (This, InThat: String): String;
function BeforeLast (This, InThat: String): String;
function BetweenLast (This, That, InThat: String): String;
function Explode (Source, Separator: String): TArrayIntegerString;
function Implode (Source: TArrayIntegerString; Separator: String): String;
function StrReplace (const This: array of string; That: string; InThat:String): String; overload;
function StrReplace (const This: array of string; const That: array of string;  InThat:String): String; overload;
function StrReplace (This, That, InThat:String): String; overload;
function NameToCaption (Name: String): String;
function CaptionToName (Caption: String): String;

implementation

function After (This, InThat: String): String;
begin
  if Pos(This,InThat)<>0 then
  begin
    After := Copy (InThat,Pos(This,InThat)+Length(This),Length(InThat)-Length(This));
  end
  else
  begin
    After := '';
  end;
end;

function Before (This, InThat: String): String;
begin
  if Pos(This,InThat)<>0 then
  begin
    Before := Copy (InThat,1,Length(InThat)-Length(This)-Length(After(This,InThat)));
  end
  else
  begin
    Before := '';
  end;
end;

function Between (This, That, InThat: String): String;
begin
  Between := Before (That,After(This,InThat) );
end;

function AfterLast (This, InThat: String): String;
begin
  AfterLast := ReverseString (Before(This,ReverseString(InThat)));
end;

function BeforeLast (This, InThat: String): String;
begin
  BeforeLast := ReverseString (After(This,ReverseString(InThat)));
end;

function BetweenLast (This, That, InThat: String): String;
begin
  BetweenLast := AfterLast (This,BeforeLast(That, InThat) );
end;

function Implode (Source: TArrayIntegerString; Separator: String): String;
begin
  Result := '';
  Source.Reset;
  repeat
    Result := Result + Source.Value + Separator;
  until Source.Foreach;
end;

function Explode (Source, Separator: String): TArrayIntegerString;
var Count: Integer;
begin
  Result := TArrayIntegerString.Create;
  Count := 0;
  repeat
    if (Source<>'') and (Pos(Separator,Source)=0) then
    begin
        Result[Count] := Source;
    end
    else
    begin
        Result[Count] := Before(Separator,Source);
    end;
    Source := After (Separator,Source);
    Count := Count + 1;
  until Source = '';
end;

function StrReplace (const This: array of string; That: string; InThat:String): String; overload;
var I, Count: Integer;
begin
  Count := Length (This);
  for I := 0 to Count - 1 do
  begin
    InThat := StringReplace (InThat, This[I], That, [rfReplaceAll,rfIgnoreCase]);
  end;
  Result := InThat;
end;

function StrReplace (const This: array of string; const That: array of string;  InThat:String): String; overload;
var I, Count: Integer;
begin
  Count := Length (This);
  for I := 0 to Count - 1 do
  begin
    InThat := StringReplace (InThat, This[I], That[I], [rfReplaceAll,rfIgnoreCase]);
  end;
  Result := InThat;
end;

function StrReplace (This, That, InThat:String): String; overload;
begin
  Result := StringReplace (InThat, This, That, [rfReplaceAll,rfIgnoreCase]);
end;

function NameToCaption(Name: String): String;
begin
  Result := AnsiProperCase(StrReplace('_',' ',Name), StdWordDelims);
end;

function CaptionToName(Caption: String): String;
begin
  Result := LowerCase(StrReplace(' ','_',Caption));
end;

end.

