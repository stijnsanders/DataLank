unit MyData;
{

  MyData: thin LibMySQL wrapper to connect to a MySQL/MariaDB server.

  https://github.com/stijnsanders/DataLank

ATTENTION:

Include following files in the folder that contains the executable,
or in a folder included in the default DLL search path.
They are provided with the Windows MySQL/MariaDB server install.

  libmysql.dll

}

interface

//debugging: prevent step-into from debugging TQueryResult calls:
{$D-}
{$L-}

uses SysUtils, LibMy;

type
  TMySQLConnection=class(TObject)
  private
    FDB:PMYSQL;
    procedure Exec(const SQL:UTF8String);
  public
    constructor Create(const Host, User, Pwd, SelectDB: UTF8String;
      Port: integer); overload;
    constructor Create(const Parameters: UTF8String); overload;
    destructor Destroy; override;
    procedure BeginTrans;
    procedure CommitTrans;
    procedure RollbackTrans;
    function Execute(const SQL: WideString;
      const Values: array of Variant): integer;
    function Insert(const TableName: WideString;
      const Values: array of Variant;
      const PKFieldName:string=''): integer;
    procedure Update(const TableName: WideString;
      const Values:array of Variant);
    property Handle:PMYSQL read FDB;
  end;

  TMySQLStatement=class(TObject)
  private
    FFirstRead,FFieldNamesListed:boolean;
    FFieldNames:array of string;
    function FieldIdx(const Idx:Variant):integer;
    function GetValue(const Idx:Variant):Variant;
    function IsEof:boolean;
    function GetCount:integer;
  protected
    FDB:PMYSQL;
    FResultSet:PMYSQL_RES;
    FResultRow:MYSQL_ROW;
  public
    constructor Create(Connection: TMySQLConnection; const SQL: WideString;
      const Values: array of Variant);
    destructor Destroy; override;
    procedure Reset;
    procedure NextResults;
    function Read:boolean;
    property Fields[const Idx:Variant]:Variant read GetValue; default;
    property EOF: boolean read IsEof;
    property Count: integer read GetCount;
    function GetInt(const Idx:Variant):integer;
    function GetStr(const Idx:Variant):WideString;
    function GetDate(const Idx:Variant):TDateTime;
    function IsNull(const Idx:Variant):boolean;
  end;

  EMyDataError=class(Exception);
  EQueryResultError=class(Exception);

implementation

uses Variants, VarConv;

{$IF not Declared(UTF8ToWideString)}
function UTF8ToWideString(const s: UTF8String): WideString;
begin
  Result:=UTF8Decode(s);
end;
{$IFEND}

{ TMySQLConnection }

constructor TMySQLConnection.Create(const Host, User, Pwd, SelectDB: UTF8String;
  Port: integer);
begin
  inherited Create;
  FDB:=mysql_init(nil);
  if mysql_real_connect(FDB,PAnsiChar(Host),
    PAnsiChar(User),PAnsiChar(Pwd),PAnsiChar(SelectDB),Port,nil,0)=nil then
    raise EMyDataError.Create(mysql_error(FDB));
end;

constructor TMySQLConnection.Create(const Parameters: UTF8String);
var
  i,j,k,l:integer;
  s,t, Host, User, Pwd, SelectDB: UTF8String;
  Port: integer;
begin
  inherited Create;

  //defaults
  Host:='';
  User:='';
  Pwd:='';
  SelectDB:='';
  Port:=MYSQL_PORT;

  //parse
  i:=1;
  l:=Length(Parameters);
  while (i<=l) do
   begin
    j:=i;
    while (j<=l) and (Parameters[j]<>'=') do inc(j);
    k:=j+1;
    while (k<=l) and (Parameters[k]>' ') do inc(k);
    s:=LowerCase(Copy(Parameters,i,j-i));
    inc(j);
    t:=Copy(Parameters,j,k-j);
    i:=k+1;

    if s='host' then Host:=t
    else if s='user' then User:=t
    else if s='password' then Pwd:=t
    else if s='post' then Port:=StrToInt(t)
    else if s='db' then SelectDB:=t
    else raise EMyDataError.Create('Unknown connection parameter "'+s+'"');

   end;

  //connect
  FDB:=mysql_init(nil);
  if mysql_real_connect(FDB,PAnsiChar(Host),
    PAnsiChar(User),PAnsiChar(Pwd),PAnsiChar(SelectDB),Port,nil,0)=nil then
    raise EMyDataError.Create(mysql_error(FDB));
end;

destructor TMySQLConnection.Destroy;
begin
  if FDB<>nil then
    try
      mysql_close(FDB);
    finally
      FDB:=nil;
    end;
  inherited;
end;

procedure TMySQLConnection.Exec(const SQL: UTF8String);
var
  r:PMYSQL_RES;
begin
  if mysql_real_query(FDB,PAnsiChar(SQL),Length(SQL))<>0 then
    raise EMyDataError.Create(mysql_error(FDB));
  r:=mysql_store_result(FDB);
  if r<>nil then
   begin
    mysql_free_result(r);//raise unexpected result set?µ
    raise EQueryResultError.Create('Exec: unexpected result set');
   end;
end;

procedure TMySQLConnection.BeginTrans;
begin
  //mysql_?
  Exec('begin');
  //TODO: support savepoints
end;

procedure TMySQLConnection.CommitTrans;
begin
  //mysql_commit(FDB);?
  Exec('commit');
end;

procedure TMySQLConnection.RollbackTrans;
begin
  //mysql_rollback(FDB);
  Exec('rollback');
end;

function VarToSQL(const Value:Variant):UTF8String;
begin
  case VarType(Value) of
    varNull,varEmpty:
      Result:='NULL';
    varSmallint,varInteger,varSingle,varDouble,varCurrency,14,
    varShortInt,varByte,varWord,varLongWord,varInt64:
      Result:=UTF8Encode(VarToWideStr(Value));
    varDate:
      Result:=AnsiString(FormatDateTime('"{ts ''"yyyy-mm-dd hh:nn:ss.zzz"''}"',
        VarToDateTime(Value)));
    varString,varOleStr:
      Result:=''''+UTF8Encode(StringReplace(
        VarToStr(Value),'''','\''',[rfReplaceAll]))+'''';//TODO: mysql_real_escape_string
    varBoolean:
      if Value then Result:='1' else Result:='0';
    else raise EMyDataError.Create('Unsupported parameter value type');
  end;
end;

function ParamBind(SQL:UTF8String;const Values:array of Variant):UTF8String;
var
  i,j,k,l,n:integer;
begin
  //TODO: mysql_stmt_prepare
  Result:='';//TODO: TStringStream
  i:=1;
  l:=Length(SQL);
  k:=0;
  n:=Length(Values);
  while i<=l do
   begin
    j:=i;
    while (j<=l) and (SQL[j]<>'?') do inc(j);
    Result:=Result+Copy(SQL,i,j-i);
    i:=j;
    if j<=l then
     begin
      if k>=n then raise EMyDataError.Create('Insufficient parameter values');
      Result:=Result+VarToSQL(Values[k]);
      inc(k);
      inc(i);
     end;
   end;
  if k<n then raise EMyDataError.Create('Superfluous parameter values');
end;

function TMySQLConnection.Execute(const SQL: WideString;
  const Values: array of Variant): integer;
var
  r:PMYSQL_RES;
  s:UTF8String;
begin
  s:=ParamBind(UTF8ToWideString(SQL),Values);
  if mysql_real_query(FDB,PAnsiChar(s),Length(s))<>0 then
    raise EMyDataError.Create(mysql_error(FDB));
  r:=mysql_store_result(FDB);//TODO: switch? mysql_use_result
  if r<>nil then
   begin
    mysql_free_result(r);
    raise EQueryResultError.Create('Execute: unexpected result set');
   end;
  Result:=mysql_affected_rows(FDB);
end;

function TMySQLConnection.Insert(const TableName: WideString;
  const Values: array of Variant; const PKFieldName:string=''): integer;
var
  i,l:integer;
  sql1,sql2:UTF8String;
  r:PMYSQL_RES;
begin
  l:=Length(Values);
  if (l and 1)<>0 then
    raise EQueryResultError.Create('Insert('''+string(TableName)+
      ''') requires an even number of values');

  sql1:='';
  sql2:='';
  i:=1;
  while i<l do
   begin
    if not VarIsNull(Values[i]) then
     begin
      sql1:=sql1+','+UTF8Encode(VarToWideStr(Values[i-1]));
      sql2:=sql2+','+VarToSQL(Values[i]);
     end;
    inc(i,2);
   end;

  sql1[1]:='(';
  sql2[1]:='(';

  sql1:='insert into '+TableName+' '+sql1+') values '+sql2+')';
  if mysql_real_query(FDB,PAnsiChar(sql1),Length(sql1))<>0 then
    raise EMyDataError.Create(mysql_error(FDB));
  r:=mysql_store_result(FDB);//TODO: switch? mysql_use_result
  if r<>nil then
   begin
    mysql_free_result(r);
    raise EQueryResultError.Create('Insert: unexpected result set');
   end;
  if PKFieldName='' then Result:=-1 else Result:=mysql_insert_id(FDB);
end;

procedure TMySQLConnection.Update(const TableName: WideString;
  const Values: array of Variant);
var
  i,l:integer;
  sql:UTF8String;
  r:PMYSQL_RES;
begin
  l:=Length(Values);
  if (l and 1)<>0 then
    raise EQueryResultError.Create('Update('''+string(TableName)+
      ''') requires an even number of values');

  sql:='';
  i:=3;
  while i<l do
   begin
    if not VarIsNull(Values[i]) then
      sql:=sql+','+UTF8Encode(VarToWideStr(Values[i-1]))+
        '='+VarToSQL(Values[i]);
    inc(i,2);
   end;

  sql[1]:=' ';
  sql:='update '+TableName+' set'+sql+
    ' where '+Values[0]+'='+VarToSQL(Values[1]);
  if mysql_real_query(FDB,PAnsiChar(sql),Length(sql))<>0 then
    raise EMyDataError.Create(mysql_error(FDB));
  r:=mysql_store_result(FDB);//TODO: switch? mysql_use_result
  if r<>nil then
   begin
    mysql_free_result(r);
    raise EQueryResultError.Create('Update: unexpected result set');
   end;
end;

{ TMySQLStatement }

constructor TMySQLStatement.Create(Connection: TMySQLConnection;
  const SQL: WideString; const Values: array of Variant);
var
  s:UTF8String;
begin
  inherited Create;
  FDB:=Connection.FDB;
  s:=ParamBind(SQL,Values);
  if mysql_real_query(FDB,PAnsiChar(s),Length(s))<>0 then
    raise EMyDataError.Create(mysql_error(FDB));
  //TODO: switch? mysql_use_result
  FResultSet:=mysql_store_result(FDB);
  if FResultSet=nil then
    raise EQueryResultError.Create('Query did not return a result set');
  FResultRow:=mysql_fetch_row(FResultSet);
  FFirstRead:=true;
  FFieldNamesListed:=false;
end;

destructor TMySQLStatement.Destroy;
begin
  mysql_free_result(FResultSet);
  inherited;
end;

function TMySQLStatement.Read: boolean;
begin
  if (FResultSet=nil) or (FResultRow=nil) then Result:=false else
   begin
    if FFirstRead then FFirstRead:=false else
      FResultRow:=mysql_fetch_row(FResultSet);
    Result:=FResultRow<>nil;
   end;
end;

procedure TMySQLStatement.Reset;
begin
  FFirstRead:=true;
  mysql_row_seek(FResultSet,nil);
end;

function TMySQLStatement.FieldIdx(const Idx: Variant): integer;
var
  i:integer;
  f:PMYSQL_FIELD;
  s:string;
begin
  Result:=-1;//default
  if FResultRow=nil then
    raise EQueryResultError.Create('Reading past EOF');
  if VarIsNumeric(Idx) then Result:=Idx else
   begin
    s:=VarToStr(Idx);
    if FFieldNamesListed then
     begin
      i:=0;
      while (i<FResultSet.field_count) and (CompareText(s,FFieldNames[i])<>0) do
        inc(i);
      Result:=i;
     end
    else
     begin
      SetLength(FFieldNames,FResultSet.field_count);
      FFieldNamesListed:=true;
      i:=0;
      f:=mysql_fetch_field(FResultSet);
      while f<>nil do
       begin
        FFieldNames[i]:=f.name;//org_name?
        if (Result=-1) and (CompareText(s,FFieldNames[i])=0) then
          Result:=i;
        inc(i);
        f:=mysql_fetch_field(FResultSet);
       end;
     end;
   end;
  if (Result<0) or (Result>=FResultSet.field_count) then
    raise EQueryResultError.Create('GetInt: Field not found: '+VarToStr(Idx));
end;

function TMySQLStatement.GetInt(const Idx: Variant): integer;
var
  p:PAnsiChar;
begin
  p:=FResultRow[FieldIdx(Idx)];
  if p=nil then Result:=0 else Result:=StrToInt(p);
end;

function TMySQLStatement.GetStr(const Idx: Variant): WideString;
begin
  Result:=UTF8ToWideString(FResultRow[FieldIdx(Idx)]);
end;

function TMySQLStatement.GetDate(const Idx: Variant): TDateTime;
var
  i,l,f:integer;
  dy,dm,dd,th,tm,ts,tz:word;
  s:UTF8String;
  function Next:word;
  begin
    Result:=0;
    while (i<=l) and (s[i] in ['0'..'9']) do
     begin
      Result:=Result*10+(byte(s[i]) and $F);
      inc(i);
     end;
  end;
begin
  s:=FResultRow[FieldIdx(Idx)];
  if s='' then
    Result:=0 //now?
  else
   begin
    i:=1;
    l:=Length(s);
    dy:=Next;
    inc(i);//'-'
    dm:=Next;
    inc(i);//'-'
    dd:=Next;
    inc(i);//' '
    th:=Next;
    inc(i);//':'
    tm:=Next;
    inc(i);//':'
    ts:=Next;
    inc(i);//'.'
    tz:=0;//Next;//more precision than milliseconds here, encode floating:

    f:=24*60*60;
    Result:=0.0;
    while (i<=l) and (s[i] in ['0'..'9']) do
     begin
      f:=f*10;
      Result:=Result+(byte(s[i]) and $F)/f;
      inc(i);
     end;

    //assert i>l
    Result:=EncodeDate(dy,dm,dd)+EncodeTime(th,tm,ts,tz)+Result;
   end;
end;

function TMySQLStatement.GetValue(const Idx: Variant): Variant;
var
  i:integer;
  p:PAnsiChar;
begin
  i:=FieldIdx(Idx);
  p:=FResultRow[i];
  if p=nil then Result:=Null else
   begin
    VarClear(Result);
    case mysql_fetch_field_direct(FResultSet,i).type_ of
      MYSQL_TYPE_TINY:
       begin
        TVarData(Result).VType:=varByte;
        TVarData(Result).VByte:=StrToInt(p);
       end;
      MYSQL_TYPE_SHORT:
       begin
        TVarData(Result).VType:=varShortInt;
        TVarData(Result).VShortInt:=StrToInt(p);
       end;
      MYSQL_TYPE_LONG,MYSQL_TYPE_INT24:
       begin
        TVarData(Result).VType:=varInteger;
        TVarData(Result).VInteger:=StrToInt(p);
       end;
      MYSQL_TYPE_FLOAT,
      MYSQL_TYPE_DOUBLE,
      MYSQL_TYPE_DECIMAL,
      MYSQL_TYPE_NEWDECIMAL:
       begin
        TVarData(Result).VType:=varDouble;
        TVarData(Result).VDouble:=StrToFloat(p);
       end;
      MYSQL_TYPE_NULL:
        Result:=Null;
      MYSQL_TYPE_TIMESTAMP,//?
      MYSQL_TYPE_DATE,
      MYSQL_TYPE_TIME,
      MYSQL_TYPE_DATETIME,
      MYSQL_TYPE_YEAR,
      MYSQL_TYPE_NEWDATE:
        Result:=GetDate(Idx);//?
      MYSQL_TYPE_LONGLONG:
       begin
        TVarData(Result).VType:=varInt64;
        TVarData(Result).VInt64:=StrToInt64(p);
       end;
      MYSQL_TYPE_VARCHAR,
      MYSQL_TYPE_VAR_STRING,
      MYSQL_TYPE_STRING:
        Result:=UTF8ToWideString(p);
      MYSQL_TYPE_BIT:
        if p='0' then Result:=false else Result:=true;
      //MYSQL_TYPE_ENUM=247,
      //MYSQL_TYPE_SET=248,
      //MYSQL_TYPE_TINY_BLOB=249,
      //MYSQL_TYPE_MEDIUM_BLOB=250,
      //MYSQL_TYPE_LONG_BLOB=251,
      //MYSQL_TYPE_BLOB=252,
      //MYSQL_TYPE_GEOMETRY=255
      else
        //raise?
        Result:=UTF8ToWideString(p);
    end;
  end;
end;

function TMySQLStatement.IsNull(const Idx: Variant): boolean;
begin
  Result:=FResultRow[FieldIdx(Idx)]=nil;
end;

function TMySQLStatement.IsEof: boolean;
begin
  Result:=(FResultSet=nil) or (FResultRow=nil);
end;

function TMySQLStatement.GetCount: integer;
begin
  if FResultSet=nil then Result:=-1 else Result:=FResultSet.row_count;
end;

procedure TMySQLStatement.NextResults;
begin
  //xxxxxxxx
end;

initialization
  //something fixed invalid, see function RefCursor
  mysql_library_init(0,nil,nil);
finalization
  mysql_library_end;
end.
