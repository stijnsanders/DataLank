unit DataLankProtocol;

{
DataLankProtocol only serves as a guide to describe what the interface
to the TDataConnection and TQueryResult object should be.
Don't include it in a project (unless you need a quick-fix to determine
if a project has correct syntax.)
Don't override from TDataConnection or TQueryResult.

Create a DataLank.pas unit with code like this to patch through to an
implementation of your selection.

  unit DataLink;

  interface

  uses SomeDBTools;

  type
    TDataConnection = TSomeDBConnection;
    TQueryResult = TSomeDBCommand;

  implementations

  end.

See
  https://github.com/stijnsanders/DataLank
for a list of implementations.

}

interface

type
  TDataConnection=class(TObject)
  public
    constructor Create(const ConnectionInfo: WideString);
    destructor Destroy override;

    function Execute(const SQL: WideString;
      const Values: array of Variant): integer;
    function Insert(const TableName: WideString;
      const Values: array of Variant): integer;
  end;

  TQueryResult=class(TObject)
  private
    FFirstLoad:boolean;
    function GetValue(Idx:OleVariant):OleVariant;
    function IsEof:boolean;
  public
    constructor Create(Connection: TDataConnection; const SQL: WideString;
      const Values: array of Variant);
    destructor Destroy; override;
    function Read:boolean;
    property Fields[Idx:OleVariant]:OleVariant read GetValue; default;
    property EOF: boolean read IsEof;
    function GetInt(Idx:OleVariant):integer;
    function GetStr(Idx:OleVariant):WideString;
    function GetDate(Idx:OleVariant):TDateTime;
    function IsNull(Idx:OleVariant):boolean;
  end;

implementation

{ TDataConnection }

constructor TDataConnection.Create(const ConnectionInfo: WideString);
begin
  inherited Create;
  //create connection data
  //open connection
end;

destructor TDataConnection.Destroy;
begin
  //close connection
  //free connection data
  inherited;
end;

function TDataConnection.Insert(const TableName: WideString;
  const Values: array of Variant): integer;
begin
  //insert record
  //catch primary key and/or auto-number
end;

function TDataConnection.Execute(const SQL: WideString;
  const Values: array of Variant): integer;
begin
  //prepare command and parameters
  //execute SQL
end;
{ TQueryResult }

constructor TQueryResult.Create(Connection: TDataConnection;
  const SQL: WideString; const Values: array of Variant);
begin
  inherited Create;
  //prepare command, set parameter values
  //execute and prepare result set
  FFirstRead:=true;
end;

destructor TQueryResult.Destroy;
begin
  //clean-up result set data
  inherited;
end;

function TQueryResult.GetInt(Idx: OleVariant): integer;
begin
  //Result:=
end;

function TQueryResult.GetStr(Idx: OleVariant): WideString;
begin
  //Result:=
end;

function TQueryResult.GetDate(Idx: OleVariant): TDateTime;
begin
  //Result:=VarToDateTime(
end;

function TQueryResult.GetValue(Idx: OleVariant): OleVariant;
begin
  //Result:=
end;

function TQueryResult.IsNull(Idx: OleVariant): boolean;
begin
  //Result:=VarIsNull(
end;

function TQueryResult.IsEof: boolean;
begin
  //Result:=
end;

function TQueryResult.Read: boolean;
begin
  if EOF then Result:=false else
   begin
    if FFirstRead then FFirstRead:=false else ;//Next;
    Result:=not(EOF);
   end;
end;

end.
