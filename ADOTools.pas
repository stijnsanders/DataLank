unit ADOTools;
{

  ADOTools: thin ADODB wrapper.

  https://github.com/stijnsanders/DataLank

}

interface

uses SysUtils, ADODB_TLB;

type
  TADOLink=class(TObject)
  private
    FConnection:Connection;
  public
    constructor Create(const ConnectionString: WideString);
    destructor Destroy; override;
    function SingleValue(const SQL: WideString;
      const Values: array of Variant): Variant;
    function Execute(const SQL: WideString;
      const Values: array of Variant): integer;
    function Insert(const TableName: WideString; const Values: array of OleVariant;
      const PKFieldName: WideString=''): int64;
    procedure Update(const TableName: WideString; const Values:array of OleVariant);
    property Connection:Connection read FConnection;
  end;

  TADOResult=class(TObject)
  private
    FRecordSet:Recordset;
    FFirstRead:boolean;
    function GetValue(Idx:OleVariant):OleVariant;
    function IsEof:boolean;
  public
    constructor Create(Connection: TADOLink; const SQL: WideString;
      const Values: array of Variant); overload;
    constructor Create(Recordset: Recordset); overload;
    destructor Destroy; override;

    procedure Reset;
    procedure CheckResultSet;//use with multiple resultsets (e.g. when calling stored procedure)
    function Read:boolean;
    property Fields[Idx:OleVariant]:OleVariant read GetValue; default;
    property EOF: boolean read IsEof;
    function GetInt(Idx:OleVariant):integer;
    function GetStr(Idx:OleVariant):WideString;
    function GetDate(Idx:OleVariant):TDateTime;
    function IsNull(Idx:OleVariant):boolean;
    function GetDefault(Idx,Default:OleVariant):OleVariant;
  end;

  EFieldNotFound=class(Exception);
  ESingleValueFailed=class(Exception);

implementation

uses Variants, Classes, ComObj;

procedure CmdParameters(Cmd:Command;const Values:array of Variant);
var
  i:integer;
  vt:TVarType;
begin
  for i:=0 to Length(Values)-1 do
   begin
    vt:=VarType(Values[i]);
    if (vt=varNull) or (vt=varString) or (vt=varOleStr) then
      cmd.Parameters.Append(cmd.CreateParameter('',adVariant,adParamInput,0,Values[i]))
    else
      cmd.Parameters.Append(cmd.CreateParameter('',vt,adParamInput,0,Values[i]));
   end;
end;

function ErrInfo(const QueryName: AnsiString; const Values: array of Variant):AnsiString;
var
  i,l:integer;
begin
  l:=Length(Values);
  Result:='';
  if l>0 then
   begin
    Result:=VarToStr(Values[0]);
    for i:=1 to l-1 do Result:=Result+','+VarToStr(Values[i]);
   end;
  Result:=#13#10'"'+QueryName+'"['+Result+']';
end;

{ TADOResult }

constructor TADOResult.Create(Connection: TADOLink; const SQL: WideString;
  const Values: array of Variant);
var
  cmd:Command;
begin
  inherited Create;
  //FRecordSet:=Session.DbCon.Execute(,v,adCmdText);
  FFirstRead:=true;
  cmd:=CoCommand.Create;
  try
    cmd.CommandType:=adCmdText;
    cmd.CommandText:=SQL;
    cmd.Set_ActiveConnection(Connection.FConnection);
    CmdParameters(cmd,Values);
    FRecordset:=CoRecordset.Create;
    FRecordset.CursorLocation:=adUseClient;
    FRecordset.Open(cmd,EmptyParam,adOpenStatic,adLockReadOnly,0);
  except
    on e:Exception do
     begin
      e.Message:=e.Message+ErrInfo(SQL,Values);
      raise;
     end;
  end;
end;

constructor TADOResult.Create(Recordset: Recordset);
begin
  inherited Create;
  FFirstRead:=true;
  FRecordSet:=Recordset;//Clone?
end;

destructor TADOResult.Destroy;
begin
  //FRecordSet.Close;
  FRecordSet:=nil;
  inherited;
end;

procedure TADOResult.Reset;
begin
  FFirstRead:=true;
  FRecordSet.MoveFirst;
end;

function TADOResult.GetInt(Idx: OleVariant): integer;
var
  v:OleVariant;
begin
  try
    //v:=FRecordSet.Fields[Idx].Value;
    v:=FRecordSet.Collect[idx];
  except
    on e:EOleException do
      if cardinal(e.ErrorCode)=$800A0CC1 then
        raise EFieldNotFound.Create('GetInt: Field not found: '+VarToStr(Idx));
      else
        raise;
  end;
  if VarIsNull(v) then Result:=0 else Result:=v;
end;

function TADOResult.GetStr(Idx: OleVariant): WideString;
begin
  try
    //Result:=VarToWideStr(FRecordSet.Fields[Idx].Value);
    Result:=VarToWideStr(FRecordSet.Collect[Idx]);
  except
    on e:EOleException do
      if cardinal(e.ErrorCode)=$800A0CC1 then
        raise EFieldNotFound.Create('GetStr: Field not found: '+VarToStr(Idx));
      else
        raise;
  end;
end;

function TADOResult.GetDate(Idx: OleVariant): TDateTime;
var
  v:OleVariant;
begin
  try
    //v:=FRecordSet.Fields[Idx].Value;
    v:=FRecordSet.Collect[Idx];
  except
    on e:EOleException do
      if cardinal(e.ErrorCode)=$800A0CC1 then
        raise EFieldNotFound.Create('GetDate: Field not found: '+VarToStr(Idx));
      else
        raise;
  end;
  if VarIsNull(v) then
    Result:=0 //Now?
  else
    Result:=VarToDateTime(v);
end;

function TADOResult.GetValue(Idx: OleVariant): OleVariant;
begin
  try
    //Result:=FRecordSet.Fields[Idx].Value;
    Result:=FRecordSet.Collect[Idx];
  except
    on e:EOleException do
      if cardinal(e.ErrorCode)=$800A0CC1 then
        raise EFieldNotFound.Create('Field not found: '+VarToStr(Idx));
      else
        raise;
  end;
end;

function TADOResult.GetDefault(Idx,Default: OleVariant): OleVariant;
begin
  if FRecordSet.EOF then Result:=Default else Result:=GetValue(Idx);
end;

function TADOResult.IsNull(Idx: OleVariant): boolean;
begin
  try
    //Result:=VarIsNull(FRecordSet.Fields[Idx].Value);
    Result:=VarIsNull(FRecordSet.Collect[Idx]);
  except
    on e:EOleException do
     begin
      if cardinal(e.ErrorCode)=$800A0CC1 then
        raise EFieldNotFound.Create('IsNull: Field not found: '+VarToStr(Idx))
      else
        raise;
      Result:=true;//counter warning
     end;
  end;
end;

function TADOResult.IsEof: boolean;
begin
  Result:=FRecordSet.EOF;
end;

function TADOResult.Read: boolean;
begin
  if (FRecordSet=nil) or FRecordSet.EOF then Result:=false else
   begin
    if FFirstRead then FFirstRead:=false else FRecordSet.MoveNext;
    Result:=not(FRecordSet.EOF);
   end;
end;

procedure TADOResult.CheckResultSet;
var
  v:OleVariant;
begin
  while (FRecordSet<>nil) and (FRecordSet.State=adStateClosed) do
    FRecordSet:=FRecordSet.NextRecordset(v);
  FFirstRead:=true;
end;

{ TADOLink }

constructor TADOLink.Create(const ConnectionString: WideString);
begin
  inherited Create;
  FConnection:=CoConnection.Create;
  FConnection.Open(ConnectionString,'','',0);
end;

destructor TADOLink.Destroy;
begin
  try
    if FConnection<>nil then FConnection.Close;
  except
    //ignore
  end;
  FConnection:=nil;
  inherited;
end;

function TADOLink.SingleValue(const SQL: WideString;
  const Values: array of Variant): Variant;
var
  cmd:Command;
  rs:Recordset;
  v:OleVariant;
begin
  try
    cmd:=CoCommand.Create;
    cmd.CommandType:=adCmdText;
    cmd.CommandText:=SQL;
    cmd.Set_ActiveConnection(FConnection);
    CmdParameters(cmd,Values);
    rs:=cmd.Execute(v,EmptyParam,0);
    if rs.EOF then
      raise ESingleValueFailed.Create('SingleValue did not result a value "'+SQL+'"')
    else
     begin
      Result:=rs.Fields[0].Value;
      rs.MoveNext;
      if not rs.EOF then
        raise ESingleValueFailed.Create('SingleValue resulted in more than one value "'+SQL+'"')
     end;
  except
    on e:Exception do
     begin
      e.Message:=e.Message+ErrInfo(SQL,Values);
      raise;
     end;
  end;
end;

function TADOLink.Execute(const SQL: WideString;
  const Values: array of Variant): integer;
var
  cmd:Command;
  v:OleVariant;
begin
  try
    cmd:=CoCommand.Create;
    cmd.CommandType:=adCmdText;
    cmd.CommandText:=SQL;
    cmd.Set_ActiveConnection(FConnection);
    CmdParameters(cmd,Values);
    cmd.Execute(v,EmptyParam,0);//rs:=
    //while (rs<>nil) and (rs.State=adStateClosed) do rs:=rs.NextRecordset(v);
    Result:=v;
  except
    on e:Exception do
     begin
      e.Message:=e.Message+ErrInfo(SQL,Values);
      raise;
     end;
  end;
end;

function TADOLink.Insert(const TableName: WideString;
  const Values: array of OleVariant; const PKFieldName: WideString=''): int64;
var
  rs:Recordset;
  i,l:integer;
begin
  l:=Length(Values);
  if (l mod 2)<>0 then
    raise Exception.Create('TADOLink.Insert expects pairs of name-value');

  rs:=CoRecordset.Create;
  //TODO: adCmdTable and find PK? first col?
  rs.Open(
    'SELECT * FROM ['+TableName+'] WHERE 0=1',
    FConnection,
    adOpenKeyset,//?
    adLockOptimistic,//adLockPessimistic?
    adCmdText);
  rs.AddNew(EmptyParam,EmptyParam);

  for i:=0 to (l div 2)-1 do
    rs.Fields[Values[i*2]].Value:=Values[i*2+1];

  if PKFieldName='' then
    Result:=rs.Fields[0].Value //assert primary key
  else
    Result:=rs.Fields[PKFieldName].Value;
  rs.Update(EmptyParam,EmptyParam);
  rs:=nil;
end;

procedure TADOLink.Update(const TableName: WideString;
  const Values: array of OleVariant);
var
  cmd:Command;
  rs:Recordset;
  i,l:integer;
  v:OleVariant;
  vt:TVarType;
begin
  l:=Length(Values);
  if (l mod 2)<>0 then
    raise Exception.Create('TADOLink.Insert expects pairs of name-value');

  cmd:=CoCommand.Create;
  cmd.CommandType:=adCmdText;
  cmd.CommandText:='SELECT * FROM ['+TableName+'] WHERE ['+VarToStr(Values[0])+']=?';
  cmd.Set_ActiveConnection(FConnection);
  vt:=VarType(Values[1]);
  if (vt=varNull) or (vt=varString) or (vt=varOleStr) then
    cmd.Parameters.Append(cmd.CreateParameter('',adVariant,adParamInput,0,Values[1]))
  else
    cmd.Parameters.Append(cmd.CreateParameter('',vt,adParamInput,0,Values[1]));


  rs:=CoRecordset.Create;
  //TODO: adCmdTable and find PK? first col?
  rs.Open(
    cmd,
    FConnection,
    adOpenKeyset,//?
    adLockOptimistic,//adLockPessimistic?
    adCmdUnspecified);

  for i:=2 to (l div 2)-1 do
    rs.Fields[Values[i*2]].Value:=Values[i*2+1];

  rs.Update(EmptyParam,EmptyParam);
  rs:=nil;
  cmd:=nil;
end;

end.
