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
    function Insert(const TableName: WideString; const Values: array of Variant;
      const PKFieldName: WideString=''): int64;
    procedure Update(const TableName: WideString; const Values:array of Variant);

    procedure BeginTrans;
    procedure CommitTrans;
    procedure RollbackTrans;
  end;

  TQueryResult=class(TObject)
  private
    FFirstLoad:boolean;
    function GetValue(const Idx:Variant):Variant;
    function IsEof:boolean;
  public
    constructor Create(Connection: TDataConnection; const SQL: WideString;
      const Values: array of Variant);
    destructor Destroy; override;
    function Read:boolean;
    property Fields[Idx:Variant]:Variant read GetValue; default;
    property EOF: boolean read IsEof;
    function GetInt(const Idx:Variant):integer;
    function GetStr(const Idx:Variant):WideString;
    function GetDate(const Idx:Variant):TDateTime;
    function IsNull(const Idx:Variant):boolean;
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

procedure TDataConnection.BeginTrans;
begin
  Execute('BEGIN TRANSACTION',[]);
end;

procedure TDataConnection.CommitTrans;
begin
  Execute('COMMIT TRANSACTION',[]);
end;

procedure TDataConnection.RollbackTrans;
begin
  Execute('ROLLBACK TRANSACTION',[]);
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

function TQueryResult.GetValue(const Idx: Variant): Variant;
begin
  //Result:=
end;

function TQueryResult.GetInt(const Idx: Variant): integer;
begin
  //Result:=
end;

function TQueryResult.GetStr(const Idx: Variant): WideString;
begin
  //Result:=
end;

function TQueryResult.GetDate(const Idx: Variant): TDateTime;
begin
  //Result:=VarToDateTime(
end;

function TQueryResult.IsNull(const Idx: Variant): boolean;
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
