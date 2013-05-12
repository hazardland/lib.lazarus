unit _Arrays;

{$mode objfpc}

interface

uses
  Classes, SysUtils;

type generic TArray <TIndex, TValue> = class
private
  Values: array of TValue;
  Indexes: array of TIndex;
  Ticker: Integer;
  function Key (Index: TIndex): Integer;
  procedure Write (Index: TIndex; Value: TValue);
  function Read (Index: TIndex): TValue;
public
  Position: Integer;
  constructor Create;
  property Items [Index: TIndex]: TValue read Read write Write; default;
  procedure Reset;
  function Index: TIndex;
  function Value: TValue;
  function Foreach: Boolean;
  function Count: Integer;
  procedure Sort;
  procedure Delete (Element: TIndex);
  function Exists (What: TIndex): Boolean;
end;

type
  TArrayIntegerString = specialize TArray <Integer, String>;
  TArrayStringInteger = specialize TArray <String, Integer>;
  TArrayStringString = specialize TArray <String, String>;
  TArrayIntegerInteger = specialize TArray <String, String>;

implementation

constructor TArray.Create;
 begin
   SetLength(Indexes, 0);
   SetLength(Values, 0);
   Position := 0;
   Ticker := 0;
 end;

 function TArray.Foreach: Boolean;
 begin
   if (Ticker<Count) then
   begin
     Result := True;
     Ticker := Ticker + 1;
     Position := Ticker - 1;
   end
   else
   begin
     Result := False;
     Reset;
   end;
 end;

 function TArray.Count: Integer;
 begin
   Result := Length (Indexes)
 end;

 function TArray.Index: TIndex;
 begin
   Result := Indexes[Position];
 end;

 function TArray.Value: TValue;
 begin
   Result:= Values[Position];
 end;

 procedure TArray.Reset;
 begin
   Ticker := 0;
   Position := 0;
 end;

 procedure TArray.Write (Index: TIndex; Value: TValue);
 var Cursor: Integer;
 begin
   Cursor := Key(Index);
   if Cursor=-1 then
   begin
     SetLength (Indexes, Length(Indexes)+1);
     SetLength (Values, Length(Values)+1);
     Cursor := Length(Indexes)-1;
   end;
   Indexes[Cursor] := Index;
   Values[Cursor] := Value;
 end;

 function TArray.Read (Index: TIndex): TValue;
 var Cursor: Integer;
 begin
   Cursor := Key (Index);
   if Cursor=-1 then
   begin
     Result := Null;
   end
   else
   begin
     Result := Values[Cursor];
   end;
 end;

 function TArray.Key (Index: TIndex): Integer;
 var
   Current,Records: Integer;
 begin
   Result := -1;
   Records := Length (Indexes);
   for Current:=0 to Records-1 do
   begin
     if Indexes[Current]=Index then
     begin
       Result := Current;
       break;
     end;
   end;
 end;

 function TArray.Exists (What: TIndex): Boolean;
 var
   Current,Records: Integer;
 begin
   Result := False;
   Records := Length (Indexes);
   for Current:=0 to Records-1 do
   begin
     if Indexes[Current]=What then
     begin
       Result := True;
       break;
     end;
   end;
 end;

 procedure TArray.Sort;
 var
   Current,Records: Integer;
   ValueBuffer: TValue;
   IndexBuffer: TIndex;
 begin
   Records := Length (Indexes);
   ValueBuffer := Values[0];
   for Current:=1 to Records-1 do
   begin
        if (ValueBuffer>Values[Current]) then
        begin
          Values[Current-1]:= Values[Current];
          Values[Current] := ValueBuffer;
          IndexBuffer := Indexes[Current-1];
          Indexes[Current-1] := Indexes[Current];
          Indexes[Current] := IndexBuffer;
        end;
        ValueBuffer := Values[Current];
   end;
 end;

 procedure TArray.Delete (Element: TIndex);
 var
   Current: Integer;
 begin
   Current := Key(Element);
   if Current > High(Indexes) then
   begin
      Exit;
   end;
   if Current < Low(Indexes) then
   begin
      Exit;
   end;
   if Current = High(Indexes) then
   begin
     SetLength(Indexes, Length(Indexes) - 1) ;
     Exit;
   end;
   Finalize(Indexes[Current]) ;
   System.Move(Indexes[Current +1], Indexes[Current],(Length(Indexes) - Current -1) * SizeOf(TIndex) + 1) ;
   SetLength(Indexes, Length(Indexes) - 1);
   if Current > High(Values) then
   begin
      Exit;
   end;
   if Current < Low(Values) then
   begin
      Exit;
   end;
   if Current = High(Values) then
   begin
     SetLength(Values, Length(Values) - 1) ;
     Exit;
   end;
   Finalize(Values[Current]) ;
   System.Move(Values[Current +1], Values[Current],(Length(Values) - Current -1) * SizeOf(TValue) + 1) ;
   SetLength(Values, Length(Values) - 1);
 end;

end.

