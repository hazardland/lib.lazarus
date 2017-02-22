unit LibFile;

{$mode delphi}

interface

uses
  Classes, SysUtils, strutils, LazFileUtils;

type TFile = class
  private
  public
   Stream: TFileStream;
   Name: String;
   constructor Assign (Name: String);
   procedure Create;
   procedure Overwrite;
   procedure Open;
   procedure Edit;
   function Read: String;
   procedure Insert (Line: String);
   procedure Write (Line: String);
   function Exists: Boolean;
   destructor Close;
  end;
function FileDate (Path:String): LongInt;

implementation

  procedure TFile.Create;
  begin
     if not DirectoryExists(ExtractFileDir(Self.Name)) then
     begin
       CreateDir(ExtractFileDir(Self.Name));
     end;
     if not Exists then
     begin
       Stream := TFileStream.Create (Self.Name, fmCreate or fmOpenReadWrite);
     end;
  end;

  procedure TFile.Overwrite;
  begin
     DeleteFile (Self.Name);
     Create;
  end;

  constructor TFile.Assign (Name: String);
  begin
     Self.Name := Name;
  end;

  procedure TFile.Edit;
  begin
     Stream := TFileStream.Create (Name, fmOpenReadWrite);
  end;

  procedure TFile.Open;
  begin
     Stream := TFileStream.Create (Name, fmOpenRead);
  end;

  procedure TFile.Insert (Line: String);
  var Buffer: UTF8String;
  begin
     Buffer := UTF8Encode(Line);
     try
        Self.Stream.WriteBuffer (Pointer(Buffer)^, Length(Buffer))
     except
     end;
  end;

  procedure TFile.Write (Line: String);
  var Buffer: UTF8String;
  begin
     Buffer := UTF8Encode(Line);
     Stream.Seek (0, soFromEnd);
     try
        Self.Stream.WriteBuffer (Pointer(Buffer)^, Length(Buffer))
     except
     end;
  end;

  function TFile.Read: String;
  var Buffer: UTF8String;
  begin
     try
        Stream.Position := 0;
        SetLength (Buffer, Stream.Size);
        Stream.ReadBuffer (PChar(Buffer)^, Stream.Size);
        Result := UTF8Decode(Buffer);
     except
     end;
  end;

  function TFile.Exists: Boolean;
  begin
     if FileExists(Name) then
     begin
       Result := True;
     end
     else
     begin
       Result := False;
     end;
  end;

  destructor TFile.Close;
  begin
     Self.Stream.Free;
     inherited Destroy;
  end;

  function FileDate (Path:String): LongInt;
  begin
       Result:=FileAgeUTF8(Path);
  end;

end.

