unit Cassandra;

interface

uses SysUtils, Classes, simpleSock;

type
  TCassandraMessage=class;//forward

  TCassandraWire=class
  private
    FSocket:TTcpSocket;
    FOwnsSocket:boolean;
    procedure InitConnection;
    procedure ClearSocket;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ConnectIPv4(const Host:string;Port:word=9042);
    procedure ConnectIPv6(const Host:string;Port:word=9042);
    procedure ConnectIPv4Secure(const Host:string;Port:word=9142);
    procedure ConnectIPv6Secure(const Host:string;Port:word=9142);
    procedure ConnectRaw(OpenSocket:TTcpSocket;OwnsSocket:boolean=false);

    procedure SendMessage(m:TCassandraMessage);
    function ReceiveMessage(m:TCassandraMessage;ExpectedSize:integer=$10000):integer;
  end;

  ECassandraWireError=class(Exception);
  ECassandraQueryError=class(Exception);
  ECassandraQueryEmpty=class(Exception);
  ECassandraError=class(Exception)
  private
    FErrorCode:integer;
  public
    constructor Create(ErrorCode:integer;const Msg:string);
    property ErrorCode:integer read FErrorCode;
  end;

  TCassandraMessage=class
  private
    FData:array of byte;
    FPosition,FSize:integer;
    procedure CheckPos(x:integer);
    procedure CheckSize(x:integer);
    function GetMemory:pointer;
  public
    constructor Create;
    procedure w1(x:byte);
    procedure w2(x:word);
    procedure w4(x:integer);
    procedure w4u(x:cardinal);
    procedure w8(x:int64);
    procedure ws(const x:UTF8String);
    procedure wl(const x:UTF8String);
    procedure wx(const Data;Length:integer);
    procedure BuildMsg(OpCode:byte;StreamID:word;Flags:byte=0);
    function CloseMsg:integer;
    property Memory:pointer read GetMemory;
    property Position:integer read FPosition write FPosition;
    function ReadMsg(Capacity:integer):pointer;
    procedure OpenMsg(Size:integer);
    function MoreMsg1(TotalSize:integer):pointer;
    procedure MoreMsg2(AddSize:integer);
    function r1:byte;
    function r2:word;
    function r4:integer;
    function r4u:cardinal;
    function r8:int64;
    function rs:UTF8String;
    function rl:UTF8String;
    procedure rx(var Data;Length:integer);
  end;

  TCassandraValueReader=function(Msg:TCassandraMessage;Size:integer):Variant of object;
  TCassandraValueWriter=procedure(Msg:TCassandraMessage;
    const Value:Variant) of object;

  TCassandraQuery=class
  private
    FWire:TCassandraWire;
    FMsg:TCassandraMessage;//TODO: inherit from?
    FColumns:array of record
      KeySpace,Table,Name:UTF8String;
      MsgPos,Size:integer;
      Reader:TCassandraValueReader;
    end;
    FColumnCount,FRowCount,FRowIndex,FRowStart:integer;
    function IsEOF:boolean;
    function GetColumnKeySpace(Idx:integer):UTF8String;
    function GetColumnTable(Idx:integer):UTF8String;
    function GetColumnName(Idx:integer):UTF8String;
    function GetColumnIndex(const Idx:Variant):integer;
    function GetValue(const Idx:Variant):Variant;
  protected
    function GetValueReader(Msg:TCassandraMessage;
      ColumnIndex:integer):TCassandraValueReader; virtual;
  public
    constructor Create(Wire:TCassandraWire);
    destructor Destroy; override;
    procedure Query(const SQL:UTF8String);//;const Parameters:array of Variant);
    //procedure Prepare(const SQL:UTF8String);
    //procedure Perform(...
    function Read:boolean;
    function Value(const KeySpace,Table,Name:UTF8String):Variant;
    function IsNull(const Idx:Variant):boolean;
    function GetInt(const Idx:Variant):integer;
    function GetStr(const Idx:Variant):UTF8String;
    function GetDate(const Idx:Variant):TDateTime;
    property EOF:boolean read IsEOF;
    property ColumnCount:integer read FColumnCount;
    property RowCount:integer read FRowCount;
    property ColumnKeySpace[Idx:integer]:UTF8String read GetColumnKeySpace;
    property ColumnTable[Idx:integer]:UTF8String read GetColumnTable;
    property ColumnName[Idx:integer]:UTF8String read GetColumnName;
    property Fields[const Idx:Variant]:Variant read GetValue; default;
  end;

const
  CassandraWire_Version = 4;
  CassandraWire_HeaderSize = 9;

  CassandraWire_Flag_Compression   =$01;
  CassandraWire_Flag_Tracing       =$02;
  CassandraWire_Flag_CustomPayload =$04;
  CassandraWire_Flag_Warning       =$08;

  CassandraWire_OpCode_Error         =$00;
  CassandraWire_OpCode_StartUp       =$01;
  CassandraWire_OpCode_Ready         =$02;
  CassandraWire_OpCode_Authenticate  =$03;
  CassandraWire_OpCode_Options       =$05;
  CassandraWire_OpCode_Supported     =$06;
  CassandraWire_OpCode_Query         =$07;
  CassandraWire_OpCode_Result        =$08;
  CassandraWire_OpCode_Prepare       =$09;
  CassandraWire_OpCode_Execute       =$0A;
  CassandraWire_OpCode_Register      =$0B;
  CassandraWire_OpCode_Event         =$0C;
  CassandraWire_OpCode_Batch         =$0D;
  CassandraWire_OpCode_AuthChallenge =$0E;
  CassandraWire_OpCode_AuthResponse  =$0F;
  CassandraWire_OpCode_AuthSuccess   =$10;

  CassandraWire_ConsistencyLevel_Any         =$0000;
  CassandraWire_ConsistencyLevel_One         =$0001;
  CassandraWire_ConsistencyLevel_Two         =$0002;
  CassandraWire_ConsistencyLevel_Three       =$0003;
  CassandraWire_ConsistencyLevel_Quorum      =$0004;
  CassandraWire_ConsistencyLevel_All         =$0005;
  CassandraWire_ConsistencyLevel_LocalQuorum =$0006;
  CassandraWire_ConsistencyLevel_EachQuorum  =$0007;
  CassandraWire_ConsistencyLevel_Serial      =$0008;
  CassandraWire_ConsistencyLevel_LocalSerial =$0009;
  CassandraWire_ConsistencyLevel_LocalOne    =$000A;

  CassandraWire_QueryFlag_None                  =$00;
  CassandraWire_QueryFlag_Values                =$01;
  CassandraWire_QueryFlag_SkipMetadata          =$02;
  CassandraWire_QueryFlag_PageSize              =$04;
  CassandraWire_QueryFlag_WithPagingStat        =$08;
  CassandraWire_QueryFlag_WithSerialConsistency =$10;
  CassandraWire_QueryFlag_WithDefaultTimestamp  =$20;
  CassandraWire_QueryFlag_WithNamesForValues    =$40;

  CassandraWire_BatchFlag_WithSerialConsistency =$10;
  CassandraWire_BatchFlag_WithDefaultTimestamp  =$20;
  CassandraWire_BatchFlag_WthNamesForValues     =$40;

  CassandraWire_ResultKind_Void         =$01;
  CassandraWire_ResultKind_Rows         =$02;
  CassandraWire_ResultKind_SetKeyspace  =$03;
  CassandraWire_ResultKind_Prepared     =$04;
  CassandraWire_ResultKind_SchemaChange =$05;

  CassandraWire_ResultRowsFlag_GlobalTablesSpec =$0001;
  CassandraWire_ResultRowsFlag_HasMorePages     =$0002;
  CassandraWire_ResultRowsFlag_NoMetadata       =$0004;

  CassandraWire_FieldType_Custom    =$0000;
  CassandraWire_FieldType_Ascii     =$0001;
  CassandraWire_FieldType_Bigint    =$0002;
  CassandraWire_FieldType_Blob      =$0003;
  CassandraWire_FieldType_Boolean   =$0004;
  CassandraWire_FieldType_Counter   =$0005;
  CassandraWire_FieldType_Decimal   =$0006;
  CassandraWire_FieldType_Double    =$0007;
  CassandraWire_FieldType_Float     =$0008;
  CassandraWire_FieldType_Int       =$0009;
  CassandraWire_FieldType_Timestamp =$000B;
  CassandraWire_FieldType_Uuid      =$000C;
  CassandraWire_FieldType_Varchar   =$000D;
  CassandraWire_FieldType_Varint    =$000E;
  CassandraWire_FieldType_Timeuuid  =$000F;
  CassandraWire_FieldType_Inet      =$0010;
  CassandraWire_FieldType_Date      =$0011;
  CassandraWire_FieldType_Time      =$0012;
  CassandraWire_FieldType_Smallint  =$0013;
  CassandraWire_FieldType_Tinyint   =$0014;
  CassandraWire_FieldType_List      =$0020;
  CassandraWire_FieldType_Map       =$0021;
  CassandraWire_FieldType_Set       =$0022;
  CassandraWire_FieldType_UDT       =$0030;
  CassandraWire_FieldType_Tuple     =$0031;

  CassandraWire_ValueLength_Null = -1;

  CassandraWire_ResultPreparedFlag_GlobalTablesSpec =$0001;

  CassandraWire_Error_ServerError          =$0000;
  CassandraWire_Error_ProtocolError        =$000A;
  CassandraWire_Error_AuthenticationError  =$0100;
  CassandraWire_Error_UnavailableException =$1000;
  CassandraWire_Error_OVerloaded           =$1001;
  CassandraWire_Error_IsBootstrapping      =$1002;
  CassandraWire_Error_TruncateError        =$1003;
  CassandraWire_Error_WriteTimeout         =$1100;
  CassandraWire_Error_ReadTimeout          =$1200;
  CassandraWire_Error_ReadFailure          =$1300;
  CassandraWire_Error_FunctionFailure      =$1400;
  CassandraWire_Error_WriteFailure         =$1500;
  CassandraWire_Error_SyntaxError          =$2000;
  CassandraWire_Error_Unauthorized         =$2100;
  CassandraWire_Error_Invalid              =$2200;
  CassandraWire_Error_ConfigError          =$2300;
  CassandraWire_Error_AlreadyExists        =$2400;
  CassandraWire_Error_Unprepared           =$2500;

implementation

uses Variants, jsonDoc;

{ TCassandraWire }

constructor TCassandraWire.Create;
begin
  inherited Create;
  FSocket:=nil;//see Connect
  FOwnsSocket:=false;//default
end;

destructor TCassandraWire.Destroy;
begin
  ClearSocket;
  inherited;
end;

procedure TCassandraWire.ClearSocket;
begin
  if FOwnsSocket then
    FreeAndNil(FSocket)
  else
    FSocket:=nil;
end;

procedure TCassandraWire.ConnectIPv4(const Host: string; Port: word);
begin
  ClearSocket;
  FOwnsSocket:=true;
  FSocket:=TTcpSocket.Create(AF_INET);
  FSocket.Connect(Host,Port);
  InitConnection;
end;

procedure TCassandraWire.ConnectIPv6(const Host: string; Port: word);
begin
  ClearSocket;
  FOwnsSocket:=true;
  FSocket:=TTcpSocket.Create(AF_INET6);
  FSocket.Connect(Host,Port);
  InitConnection;
end;

procedure TCassandraWire.ConnectIPv4Secure(const Host: string; Port: word);
begin
  ClearSocket;
  FOwnsSocket:=true;
  FSocket:=TTcpSecureSocket.Create(AF_INET);
  FSocket.Connect(Host,Port);
  InitConnection;
end;

procedure TCassandraWire.ConnectIPv6Secure(const Host: string; Port: word);
begin
  ClearSocket;
  FOwnsSocket:=true;
  FSocket:=TTcpSecureSocket.Create(AF_INET6);
  FSocket.Connect(Host,Port);
  InitConnection;
end;

procedure TCassandraWire.ConnectRaw(OpenSocket: TTcpSocket;
  OwnsSocket: boolean);
begin
  ClearSocket;
  FOwnsSocket:=OwnsSocket;
  FSocket:=OpenSocket;
  //assert FSocket.Connected
  InitConnection;
end;

procedure TCassandraWire.InitConnection;
var
  m:TCassandraMessage;
  b:byte;
  w:word;
begin
  m:=TCassandraMessage.Create;
  try
    m.BuildMsg(CassandraWire_OpCode_StartUp,1);
    m.w2(1);//[string map] of options
    m.ws('CQL_VERSION');m.ws('3.0.0');
    //m.ws('COMPRESSION');m.ws();
    //m.ws('NO_COMPACT');m.ws();

    FSocket.SendBuf(m.Memory^,m.CloseMsg);

    m.OpenMsg(FSocket.ReceiveBuf(m.ReadMsg($10000)^,$10000));

    //version
    b:=m.r1;
    if b<>($80 or CassandraWire_Version) then
      raise ECassandraWireError.CreateFmt('Unexpected version response: %d',[b]);
    //flags
    b:=m.r1;
    if b<>0 then
      raise ECassandraWireError.CreateFmt('Unexpected response flags: %.2x',[b]);
    //stream
    w:=m.r2;
    if w<>1 then
      raise ECassandraWireError.CreateFmt('Unexpected stream ID: %d',[w]);//TODO: multi-streams
    //opcode
    b:=m.r1;
    if b<>CassandraWire_OpCode_Ready then
      //if b=CassandraWire_OpCode_Error then ...
      raise ECassandraWireError.CreateFmt('Unexpected response opcode: %d',[b]);

    //TODO: if CassandraWire_OpCode_AuthResponse then ...

    //length
    if m.r4<>0 then
      raise ECassandraWireError.Create('Unexpected response body');

  finally
    m.Free;
  end;
end;

procedure TCassandraWire.SendMessage(m: TCassandraMessage);
var
  i,l:integer;
begin
  l:=m.CloseMsg;
  i:=FSocket.SendBuf(m.Memory^,l);
  if i<>l then
    raise ECassandraWireError.CreateFmt('Failed to send message (%d/%d)',[i,l]);
end;

function TCassandraWire.ReceiveMessage(m: TCassandraMessage;
  ExpectedSize: integer): integer;
begin
  Result:=FSocket.ReceiveBuf(m.ReadMsg(ExpectedSize)^,ExpectedSize);
  m.OpenMsg(Result);
  //TODO: read more when Result<>m...r4
end;

{ TCassandraMessage }

const
  CassandraMessage_GrowStep=$10000;
  CassandraMessage_Max=$40000;//256MB

constructor TCassandraMessage.Create;
begin
  inherited;
  FPosition:=0;
  FSize:=0;//only used with read
  SetLength(FData,CassandraMessage_GrowStep);// > CassandraWire_HeaderSize
end;

procedure TCassandraMessage.BuildMsg(OpCode:byte;StreamID:word;Flags:byte=0);
begin
  FPosition:=0;
  w1(byte(CassandraWire_Version));
  w1(Flags);
  w2(StreamID);
  w1(OpCode);
  //w4();//length: see CloseMsg
  FPosition:=CassandraWire_HeaderSize;
end;

procedure TCassandraMessage.CheckPos(x: integer);
var
  i,l:integer;
begin
  //used for writing
  i:=FPosition+x;
  l:=Length(FData);
  if i>l then
   begin
    while (FPosition+x>l) do inc(l,CassandraMessage_GrowStep);
    SetLength(FData,l);
   end;
end;

procedure TCassandraMessage.CheckSize(x: integer);
begin
  //used for reading
  if FPosition+x>FSize then
    raise ECassandraWireError.Create('Read past end of message.');
end;

function TCassandraMessage.CloseMsg: integer;
var
  l:integer;
  d:array[0..3] of byte absolute l;
begin
  if FPosition<CassandraWire_HeaderSize then
    raise ECassandraWireError.Create('Message not correctly prepared.');
  l:=FPosition-CassandraWire_HeaderSize;
  if l>CassandraMessage_Max then
    raise ECassandraWireError.Create('Maximum message size exceeded.');
  //FPosition:=6;w(Result);
  FData[5]:=d[3];
  FData[6]:=d[2];
  FData[7]:=d[1];
  FData[8]:=d[0];
  Result:=FPosition;
  FPosition:=0;
end;

function TCassandraMessage.GetMemory:pointer;
begin
  Result:=@FData[0];
end;

procedure TCassandraMessage.w1(x: byte);
begin
  CheckPos(1);
  FData[FPosition]:=x; inc(FPosition);
end;

procedure TCassandraMessage.w2(x: word);
var
  d:array[0..1] of byte absolute x;
begin
  CheckPos(2);
  FData[FPosition]:=d[1]; inc(FPosition);
  FData[FPosition]:=d[0]; inc(FPosition);
end;

procedure TCassandraMessage.w4(x: integer);
var
  d:array[0..3] of byte absolute x;
begin
  CheckPos(4);
  FData[FPosition]:=d[3]; inc(FPosition);
  FData[FPosition]:=d[2]; inc(FPosition);
  FData[FPosition]:=d[1]; inc(FPosition);
  FData[FPosition]:=d[0]; inc(FPosition);
end;

procedure TCassandraMessage.w4u(x: cardinal);
var
  d:array[0..3] of byte absolute x;
begin
  CheckPos(4);
  FData[FPosition]:=d[3]; inc(FPosition);
  FData[FPosition]:=d[2]; inc(FPosition);
  FData[FPosition]:=d[1]; inc(FPosition);
  FData[FPosition]:=d[0]; inc(FPosition);
end;

procedure TCassandraMessage.w8(x: int64);
var
  d:array[0..7] of byte absolute x;
begin
  CheckPos(8);
  FData[FPosition]:=d[7]; inc(FPosition);
  FData[FPosition]:=d[6]; inc(FPosition);
  FData[FPosition]:=d[5]; inc(FPosition);
  FData[FPosition]:=d[4]; inc(FPosition);
  FData[FPosition]:=d[3]; inc(FPosition);
  FData[FPosition]:=d[2]; inc(FPosition);
  FData[FPosition]:=d[1]; inc(FPosition);
  FData[FPosition]:=d[0]; inc(FPosition);
end;

procedure TCassandraMessage.ws(const x: UTF8String);
var
  l:integer;
  d:array[0..1] of byte absolute l;
begin
  l:=Length(x);
  if l>=$10000 then
    raise ECassandraWireError.Create('Maximum string length exceeded.');
  CheckPos(2+l);
  FData[FPosition]:=d[1]; inc(FPosition);
  FData[FPosition]:=d[0]; inc(FPosition);
  Move(x[1],FData[FPosition],l); inc(FPosition,l);
end;

procedure TCassandraMessage.wl(const x: UTF8String);
var
  l:integer;
  d:array[0..3] of byte absolute l;
begin
  l:=Length(x);
  CheckPos(4);
  FData[FPosition]:=d[3]; inc(FPosition);
  FData[FPosition]:=d[2]; inc(FPosition);
  FData[FPosition]:=d[1]; inc(FPosition);
  FData[FPosition]:=d[0]; inc(FPosition);
  Move(x[1],FData[FPosition],l); inc(FPosition,l);
end;

procedure TCassandraMessage.wx(const Data;Length:integer);
begin
  CheckPos(Length);
  Move(Data,FData[FPosition],Length);
  inc(FPosition,Length);
end;

function TCassandraMessage.ReadMsg(Capacity:integer):pointer;
begin
  FPosition:=0;
  FSize:=0;
  CheckPos(Capacity);
  Result:=@FData[0];
end;

procedure TCassandraMessage.OpenMsg(Size:integer);
begin
  FPosition:=0;
  FSize:=Size;
  //assert FSize<=Length(FData);
end;

function TCassandraMessage.MoreMsg1(TotalSize: integer): pointer;
var
  l:integer;
begin
  //TODO: refactor into something more elegant!!!
  //CheckPos(TotalSize-Position);
  l:=Length(FData);
  if TotalSize>l then
   begin
    while (TotalSize>l) do inc(l,CassandraMessage_GrowStep);
    SetLength(FData,l);
   end;
  Result:=@FData[FSize];
end;

procedure TCassandraMessage.MoreMsg2(AddSize: integer);
begin
  //assert FSize+AddSize<Length(FData);
  inc(FSize,AddSize);
end;

function TCassandraMessage.r1: byte;
begin
  CheckSize(1);
  Result:=FData[FPosition]; inc(FPosition);
end;

function TCassandraMessage.r2: word;
var
  d:array[0..1] of byte absolute Result;
begin
  CheckSize(2);
  d[1]:=FData[FPosition]; inc(FPosition);
  d[0]:=FData[FPosition]; inc(FPosition);
end;

function TCassandraMessage.r4: integer;
var
  d:array[0..3] of byte absolute Result;
begin
  CheckSize(4);
  d[3]:=FData[FPosition]; inc(FPosition);
  d[2]:=FData[FPosition]; inc(FPosition);
  d[1]:=FData[FPosition]; inc(FPosition);
  d[0]:=FData[FPosition]; inc(FPosition);
end;

function TCassandraMessage.r4u: cardinal;
var
  d:array[0..3] of byte absolute Result;
begin
  CheckSize(4);
  d[3]:=FData[FPosition]; inc(FPosition);
  d[2]:=FData[FPosition]; inc(FPosition);
  d[1]:=FData[FPosition]; inc(FPosition);
  d[0]:=FData[FPosition]; inc(FPosition);
end;

function TCassandraMessage.r8: int64;
var
  d:array[0..7] of byte absolute Result;
begin
  CheckSize(8);
  d[7]:=FData[FPosition]; inc(FPosition);
  d[6]:=FData[FPosition]; inc(FPosition);
  d[5]:=FData[FPosition]; inc(FPosition);
  d[4]:=FData[FPosition]; inc(FPosition);
  d[3]:=FData[FPosition]; inc(FPosition);
  d[2]:=FData[FPosition]; inc(FPosition);
  d[1]:=FData[FPosition]; inc(FPosition);
  d[0]:=FData[FPosition]; inc(FPosition);
end;

function TCassandraMessage.rs: UTF8String;
var
  l:integer;
  d:array[0..1] of byte absolute l;
begin
  l:=0;
  CheckSize(2);
  d[1]:=FData[FPosition]; inc(FPosition);
  d[0]:=FData[FPosition]; inc(FPosition);
  CheckSize(l);
  SetLength(Result,l);
  Move(FData[FPosition],Result[1],l);
  inc(FPosition,l);
end;

function TCassandraMessage.rl: UTF8String;
var
  l:integer;
  d:array[0..3] of byte absolute l;
begin
  CheckSize(4);
  d[3]:=FData[FPosition]; inc(FPosition);
  d[2]:=FData[FPosition]; inc(FPosition);
  d[1]:=FData[FPosition]; inc(FPosition);
  d[0]:=FData[FPosition]; inc(FPosition);
  CheckSize(l);
  SetLength(Result,l);
  Move(FData[FPosition],Result[1],l);
  inc(FPosition,l);
end;

procedure TCassandraMessage.rx(var Data;Length:integer);
begin
  CheckSize(Length);
  Move(FData[FPosition],Data,Length);
  inc(FPosition,Length);
end;

{ Processors }

type
  TCassandraListProcessor=class
  private
    FValue:TCassandraValueReader;
  public
    //constructor Create(...
    function readValue(Msg:TCassandraMessage;Size:integer):Variant;
  end;

  TCassandraMapProcessor=class
  private
    FKey,FValue:TCassandraValueReader;
  public
   //constructor Create(...
   function readValue(Msg:TCassandraMessage;Size:integer):Variant;
  end;

  TCassandraUDTProcessor=class
  private
    //TODO: FWire:TCassandraWire?
    FKeySpace,FName:UTF8String;
    FFields:array of record
      Name:UTF8String;
      Value:TCassandraValueReader;
    end;
  public
   //constructor Create(...
   function readValue(Msg:TCassandraMessage;Size:integer):Variant;
  end;

  TCassandraProcessorStore=class
  private
    FListProcessors:array of TCassandraListProcessor;
    FMapProcessors:array of TCassandraMapProcessor;
    FUDTProcessors:array of TCassandraUDTProcessor;
  protected
    function readBoolean(Msg:TCassandraMessage;Size:integer):Variant;
    function read1(Msg:TCassandraMessage;Size:integer):Variant;
    function read2(Msg:TCassandraMessage;Size:integer):Variant;
    function read4(Msg:TCassandraMessage;Size:integer):Variant;
    function read8(Msg:TCassandraMessage;Size:integer):Variant;
    function readUUID(Msg:TCassandraMessage;Size:integer):Variant;
    function readVarchar(Msg:TCassandraMessage;Size:integer):Variant;
    function readBlob(Msg:TCassandraMessage;Size:integer):Variant;
    function readFloat(Msg:TCassandraMessage;Size:integer):Variant;
    function readDouble(Msg:TCassandraMessage;Size:integer):Variant;
    function readDate(Msg:TCassandraMessage;Size:integer):Variant;
    function readTime(Msg:TCassandraMessage;Size:integer):Variant;
    function readTimestamp(Msg:TCassandraMessage;Size:integer):Variant;
  public
    constructor Create;
    destructor Destroy; override;
    function GetListProcessor(Value:TCassandraValueReader):TCassandraValueReader;
    function GetMapProcessor(Key,Value:TCassandraValueReader):TCassandraValueReader;
    function GetUDTProcessor(Qry:TCassandraQuery):TCassandraValueReader;
  end;

var
  ProcessorStore:TCassandraProcessorStore; //singleton

const
  GetValueReader_ColumnIndex_Unspecified = -1;

{ TCassandraQuery }

constructor TCassandraQuery.Create(Wire: TCassandraWire);
begin
  inherited Create;
  FWire:=Wire;
  FMsg:=TCassandraMessage.Create;
end;

destructor TCassandraQuery.Destroy;
begin
  FMsg.Free;
  inherited;
end;

procedure TCassandraQuery.Query(const SQL: UTF8String);
var
  b:byte;
  w:word;
  i,j,l:integer;
begin
  FRowCount:=-1;//default
  FRowIndex:=-1;//default
  FColumnCount:=0;//default

  FMsg.BuildMsg(CassandraWire_OpCode_Query,1);
  FMsg.wl(SQL);
  FMsg.w2(CassandraWire_ConsistencyLevel_LocalOne);//TODO: arg/prop
  FMsg.w1(CassandraWire_QueryFlag_None);//TODO: arg/prop
  FWire.SendMessage(FMsg);

  i:=FWire.ReceiveMessage(FMsg);

  //TODO: move this into ReceiveMessage?
  FMsg.r1; //assert = CassandraWire_Version or $80;
  b:=FMsg.r1;
  if b<>0 then raise Exception.Create('//TODO: flags');
  w:=FMsg.r2;
  if w<>1 then raise Exception.Create('//TODO: streams');
  b:=FMsg.r1;//opcode

  l:=FMsg.r4;//size
  dec(i,CassandraWire_HeaderSize);
  while i<l do
   begin
    j:=FWire.FSocket.ReceiveBuf(FMsg.MoreMsg1(l+CassandraWire_HeaderSize)^,l-i);
    FMsg.MoreMsg2(j);
    inc(i,j);
   end;

  case b of
    CassandraWire_OpCode_Error:
     begin
      i:=FMsg.r4;
      raise ECassandraError.Create(i,FMsg.rs);
     end;

    CassandraWire_OpCode_Result:
     begin

      //
      i:=FMsg.r4;
      case i of

        CassandraWire_ResultKind_Void:;

        CassandraWire_ResultKind_Rows:
         begin
          i:=FMsg.r4;//flags
          if i<>0 then raise Exception.Create('//TODO: rows flags');
          FColumnCount:=FMsg.r4;//column count
          SetLength(FColumns,FColumnCount);
          i:=0;
          while i<FColumnCount do
           begin
            //TODO: if?
            if true then
             begin
              FColumns[i].KeySpace:=FMsg.rs;
              FColumns[i].Table:=FMsg.rs;
             end
            else
             begin
              FColumns[i].KeySpace:='';//??
              FColumns[i].Table:='';//??
             end;
            FColumns[i].Name:=FMsg.rs;
            FColumns[i].Reader:=GetValueReader(FMsg,i);
            inc(i);
           end;
          FRowCount:=FMsg.r4;
          FRowStart:=FMsg.Position;
          //FRowIndex:=-1;//see above
          //read columns: see function Read
         end;

        CassandraWire_ResultKind_SetKeyspace:
          FMsg.rs;//?

        //CassandraWire_ResultKind_Prepared://TODO:
        //CassandraWire_ResultKind_SchemaChange://TODO:

        else
          raise ECassandraWireError.CreateFmt('Unexpected response kind %.4x',[i]);
      end;
     end;
    else
      raise ECassandraWireError.CreateFmt('Unexpected response op-code %.2x',[b]);
  end;

end;

function TCassandraQuery.IsEOF: boolean;
begin
  Result:=(FRowIndex<0) or (FRowIndex>=FRowCount);
end;

function TCassandraQuery.Read: boolean;
var
  i,p,l:integer;
begin
  inc(FRowIndex);
  Result:=FRowIndex<FRowCount;
  ///index columns
  if Result then
   begin
    p:=FRowStart;
    i:=0;
    while i<FColumnCount do
     begin
      FMsg.Position:=p;
      l:=FMsg.r4;
      inc(p,4);
      FColumns[i].MsgPos:=p;
      FColumns[i].Size:=l;
      inc(i);
      if l>0 then //if l<>CassandraWire_ValueLength_Null then
        inc(p,l);
     end;
    FRowStart:=p;
   end;
end;

function TCassandraQuery.GetValueReader(Msg: TCassandraMessage;
  ColumnIndex: integer): TCassandraValueReader;
var
  w:word;
  r1,r2:TCassandraValueReader;
begin
  w:=Msg.r2;
  case w of
    //CassandraWire_FieldType_Custom
    //CassandraWire_FieldType_Ascii
    CassandraWire_FieldType_Bigint:    Result:=ProcessorStore.read8;
    CassandraWire_FieldType_Blob:      Result:=ProcessorStore.readBlob;
    CassandraWire_FieldType_Boolean:   Result:=ProcessorStore.readBoolean;
    CassandraWire_FieldType_Counter:   Result:=ProcessorStore.read8;//?
    //CassandraWire_FieldType_Decimal
    CassandraWire_FieldType_Double:    Result:=ProcessorStore.readDouble;
    CassandraWire_FieldType_Float:     Result:=ProcessorStore.readFloat;
    CassandraWire_FieldType_Int:       Result:=ProcessorStore.read4;
    CassandraWire_FieldType_Timestamp: Result:=ProcessorStore.readTimestamp;
    CassandraWire_FieldType_Uuid:      Result:=ProcessorStore.readUUID;
    CassandraWire_FieldType_Varchar:   Result:=ProcessorStore.readVarchar;
    //CassandraWire_FieldType_Varint
    CassandraWire_FieldType_Timeuuid:  Result:=ProcessorStore.readUUID;//?
    //CassandraWire_FieldType_Inet
    CassandraWire_FieldType_Date:      Result:=ProcessorStore.readDate;
    CassandraWire_FieldType_Time:      Result:=ProcessorStore.readTime;
    CassandraWire_FieldType_Smallint:  Result:=ProcessorStore.read2;
    CassandraWire_FieldType_Tinyint:   Result:=ProcessorStore.read1;
    CassandraWire_FieldType_List:
      Result:=ProcessorStore.GetListProcessor(
        GetValueReader(Msg,GetValueReader_ColumnIndex_Unspecified));
    CassandraWire_FieldType_Map:
     begin
      r1:=GetValueReader(Msg,GetValueReader_ColumnIndex_Unspecified);
      r2:=GetValueReader(Msg,GetValueReader_ColumnIndex_Unspecified);
      Result:=ProcessorStore.GetMapProcessor(r1,r2);
     end;
    CassandraWire_FieldType_Set:
      Result:=ProcessorStore.GetListProcessor(//?
        GetValueReader(Msg,GetValueReader_ColumnIndex_Unspecified));
    CassandraWire_FieldType_UDT:
      Result:=ProcessorStore.GetUDTProcessor(Self);
    //CassandraWire_FieldType_Tuple
    else
      raise ECassandraWireError.CreateFmt(
        'Unsupported field type %.4x (#%d)',[w,ColumnIndex]);
  end;
end;

function TCassandraQuery.GetColumnKeySpace(Idx: integer): UTF8String;
begin
  //TODO: check 0<=Idx<FColumnCount
  Result:=FColumns[Idx].KeySpace;
end;

function TCassandraQuery.GetColumnTable(Idx: integer): UTF8String;
begin
  //TODO: check 0<=Idx<FColumnCount
  Result:=FColumns[Idx].Table;
end;

function TCassandraQuery.GetColumnName(Idx: integer): UTF8String;
begin
  //TODO: check 0<=Idx<FColumnCount
  Result:=FColumns[Idx].Name;
end;

function TCassandraQuery.GetColumnIndex(const Idx: Variant): integer;
var
  s:UTF8String;
begin
  if VarIsNumeric(Idx) then
   begin
    Result:=Idx;
    if (Result<0) or (Result>=FColumnCount) then
      raise ECassandraQueryError.CreateFmt(
        'Field index out of range: %d/%d',[Result,FColumnCount]);
   end
  else
   begin
    s:=UTF8Encode(VarToWideStr(Idx));
    Result:=0;
    while (Result<FColumnCount) and (FColumns[Result].Name<>s) do inc(Result);
    if Result=FColumnCount then
      raise ECassandraQueryError.Create('Field not found "'+s+'"');
   end;
end;

function TCassandraQuery.GetValue(const Idx: Variant): Variant;
var
  i:integer;
begin
  if FRowIndex=-1 then
    if not Read then
      raise ECassandraQueryEmpty.Create('Empty result set');
  i:=GetColumnIndex(Idx);
  if FColumns[i].Size=CassandraWire_ValueLength_Null then
    Result:=Null
  else
   begin
    FMsg.Position:=FColumns[i].MsgPos;
    Result:=FColumns[i].Reader(FMsg,FColumns[i].Size);
   end;
end;

function TCassandraQuery.Value(const KeySpace, Table,
  Name: UTF8String): Variant;
var
  i:integer;
begin
  i:=0;
  while (i<FColumnCount) and not((FColumns[i].KeySpace=KeySpace) and
    (FColumns[i].Table=Table) and (FColumns[i].Name=Name)) do inc(i);
  if i=FColumnCount then
    raise ECassandraQueryError.Create(
      'Field not found "'+KeySpace+'"."'+Table+'"."'+Name+'"');
  if FColumns[i].Size=CassandraWire_ValueLength_Null then
    Result:=Null
  else
   begin
    FMsg.Position:=FColumns[i].MsgPos;
    Result:=FColumns[i].Reader(FMsg,FColumns[i].Size);
   end;
end;

function TCassandraQuery.GetDate(const Idx: Variant): TDateTime;
var
  i:integer;
  p:TCassandraValueReader;
begin
  i:=GetColumnIndex(Idx);
  p:=ProcessorStore.readTimestamp;
  if @FColumns[i].Reader=@p then
    if FColumns[i].Size=CassandraWire_ValueLength_Null then
      Result:=0.0
    else
     begin
      FMsg.Position:=FColumns[i].MsgPos;
      Result:=(FMsg.r8+int64(UnixDateDelta)*int64(MSecsPerDay))/int64(MSecsPerDay);
     end
  else
    raise ECassandraQueryError.Create(
      'Field is not a date "'+FColumns[i].Name+'"');
end;

function TCassandraQuery.GetInt(const Idx: Variant): integer;
var
  i:integer;
begin
  i:=GetColumnIndex(Idx);
  case FColumns[i].Size of
    -1:Result:=0;
    1:
     begin
      FMsg.Position:=FColumns[i].MsgPos;
      Result:=FMsg.r1;
     end;
    2:
     begin
      FMsg.Position:=FColumns[i].MsgPos;
      Result:=FMsg.r2;
     end;
    4:
     begin
      FMsg.Position:=FColumns[i].MsgPos;
      Result:=FMsg.r4;
     end;
    {8:
     begin
      FMsg.Position:=FColumns[i].MsgPos;
      Result:=FMsg.r8;
     end;
    }
    else
      raise ECassandraQueryError.Create(
        'Field not numeric "'+FColumns[i].Name+'"');
  end;
end;

function TCassandraQuery.GetStr(const Idx: Variant): UTF8String;
var
  i,l:integer;
begin
  i:=GetColumnIndex(Idx);
  l:=FColumns[i].Size;
  if l=CassandraWire_ValueLength_Null then
    Result:=''
  else
   begin
    FMsg.Position:=FColumns[i].MsgPos;
    SetLength(Result,l);
    FMsg.rx(Result[1],l);
   end;
end;

function TCassandraQuery.IsNull(const Idx: Variant): boolean;
begin
  Result:=FColumns[GetColumnIndex(Idx)].Size=CassandraWire_ValueLength_Null;
end;

{ ECassandraError }

constructor ECassandraError.Create(ErrorCode:integer;const Msg:string);
begin
  inherited Create(Msg);
  FErrorCode:=ErrorCode;
end;

function rv(Reader:TCassandraValueReader;Msg:TCassandraMessage):Variant; //inline
var
  l:integer;
begin
  l:=Msg.r4;
  if l=CassandraWire_ValueLength_Null then
    Result:=Null
  else
    Result:=Reader(Msg,l);
end;

{ TCassandraProcessorStore }

constructor TCassandraProcessorStore.Create;
begin
  inherited Create;
  SetLength(FListProcessors,0);
  SetLength(FMapProcessors,0);
  SetLength(FUDTProcessors,0);
end;

destructor TCassandraProcessorStore.Destroy;
var
  i:integer;
begin
  for i:=0 to Length(FListProcessors)-1 do FreeAndNil(FListProcessors[i]);
  SetLength(FListProcessors,0);
  for i:=0 to Length(FMapProcessors)-1 do FreeAndNil(FMapProcessors[i]);
  SetLength(FMapProcessors,0);
  for i:=0 to Length(FUDTProcessors)-1 do FreeAndNil(FUDTProcessors[i]);
  SetLength(FUDTProcessors,0);
  inherited;
end;

function TCassandraProcessorStore.readBoolean(
  Msg:TCassandraMessage;Size:integer):Variant;
begin
  if Size<>1 then
    raise ECassandraWireError.Create('Unexpected boolean length');
  Result:=Msg.r1=0;
end;

function TCassandraProcessorStore.read1(
  Msg:TCassandraMessage;Size:integer):Variant;
begin
  if Size<>1 then
    raise ECassandraWireError.Create('Unexpected byte length');
  Result:=Msg.r1;
end;

function TCassandraProcessorStore.read2(
  Msg:TCassandraMessage;Size:integer):Variant;
begin
  if Size<>2 then
    raise ECassandraWireError.Create('Unexpected value length');
  Result:=Msg.r2;
end;

function TCassandraProcessorStore.read4(
  Msg:TCassandraMessage;Size:integer):Variant;
begin
  if Size<>4 then
    raise ECassandraWireError.Create('Unexpected value length');
  Result:=Msg.r4;
end;

function TCassandraProcessorStore.read8(
  Msg:TCassandraMessage;Size:integer):Variant;
begin
  if Size<>8 then
    raise ECassandraWireError.Create('Unexpected value length');
  Result:=Msg.r8;
end;

function TCassandraProcessorStore.readUUID(
  Msg:TCassandraMessage;Size:integer):Variant;
var
  g:TGUID;
begin
  if Size<>16 then
    raise ECassandraWireError.Create('Unexpected value length');
  Msg.rx(g,16);
  Result:=GUIDToString(g);//?
end;

function TCassandraProcessorStore.readVarchar(
  Msg:TCassandraMessage;Size:integer):Variant;
var
  x:UTF8String;
begin
  SetLength(x,Size);
  Msg.rx(x[1],Size);
  Result:=UTF8Decode(x);
end;

function TCassandraProcessorStore.readBlob(
  Msg:TCassandraMessage;Size:integer):Variant;
var
  p:pointer;
begin
  Result:=VarArrayCreate([0,Size-1],varByte);
  p:=VarArrayLock(Result);
  try
    Msg.rx(p^,Size);
  finally
    VarArrayUnlock(Result);
  end;
end;

function TCassandraProcessorStore.readFloat(
  Msg:TCassandraMessage;Size:integer):Variant;
var
  f:single;
  l:integer absolute f;
begin
  if Size<>4 then
    raise ECassandraWireError.Create('Unexpected value length');
  l:=Msg.r4;
  Result:=f;
end;

function TCassandraProcessorStore.readDouble(
  Msg:TCassandraMessage;Size:integer):Variant;
var
  f:double;
  l:int64 absolute f;
begin
  if Size<>8 then
    raise ECassandraWireError.Create('Unexpected value length');
  l:=Msg.r8;
  Result:=f;
end;

function TCassandraProcessorStore.readDate(Msg: TCassandraMessage;
  Size: integer): Variant;
begin
  if Size<>4 then
    raise ECassandraWireError.Create('Unexpected value length');
  Result:=VarFromDateTime(UnixDateDelta+Msg.r4u-$80000000);
end;

function TCassandraProcessorStore.readTime(Msg: TCassandraMessage;
  Size: integer): Variant;
begin
  if Size<>4 then
    raise ECassandraWireError.Create('Unexpected value length');
  Result:=VarFromDateTime(Msg.r8/(int64(MSecsPerDay)*1000));
end;

function TCassandraProcessorStore.readTimestamp(
  Msg:TCassandraMessage;Size:integer):Variant;
begin
  if Size<>8 then
    raise ECassandraWireError.Create('Unexpected value length');
  Result:=VarFromDateTime((Msg.r8+int64(UnixDateDelta)*int64(MSecsPerDay))/int64(MSecsPerDay));
end;

function TCassandraProcessorStore.GetListProcessor(
  Value: TCassandraValueReader): TCassandraValueReader;
var
  i,l:integer;
begin
  i:=0;
  l:=Length(FListProcessors);
  while (i<l) and not(@FListProcessors[i].FValue=@Value) do inc(i);
  if i=l then
   begin
    SetLength(FListProcessors,l+1);
    FListProcessors[i]:=TCassandraListProcessor.Create;
    FListProcessors[i].FValue:=Value;
   end;
  Result:=FListProcessors[i].readValue;
end;

function TCassandraProcessorStore.GetMapProcessor(Key,
  Value: TCassandraValueReader): TCassandraValueReader;
var
  i,l:integer;
begin
  i:=0;
  l:=Length(FMapProcessors);
  while (i<l) and not((@FMapProcessors[i].FKey=@Key)
    and (@FMapProcessors[i].FValue=@Value)) do inc(i);
  if i=l then
   begin
    SetLength(FMapProcessors,l+1);
    FMapProcessors[i]:=TCassandraMapProcessor.Create;
    FMapProcessors[i].FKey:=Key;
    FMapProcessors[i].FValue:=Value;
   end;
  Result:=FMapProcessors[i].readValue;
end;

function TCassandraProcessorStore.GetUDTProcessor(
  Qry: TCassandraQuery): TCassandraValueReader;
var
  n1,n2:UTF8String;
  w:word;
  i,j,l:integer;
  p:TCassandraValueReader;
begin
  n1:=Qry.FMsg.rs;//keyspace
  n2:=Qry.FMsg.rs;//typename
  w:=Qry.FMsg.r2;//field count
  i:=0;
  l:=Length(FUDTProcessors);
  while (i<l) and not(
    //(FUDTProcessors[i].FWire=FWire) and ?
    (FUDTProcessors[i].FKeySpace=n1) and
    (FUDTProcessors[i].FName=n2)) do inc(i);
  if i=l then
   begin
    SetLength(FUDTProcessors,l+1);
    FUDTProcessors[i]:=TCassandraUDTProcessor.Create;
    FUDTProcessors[i].FKeySpace:=n1;
    FUDTProcessors[i].FName:=n2;
    SetLength(FUDTProcessors[i].FFields,w);
    for j:=0 to w-1 do
     begin
      FUDTProcessors[i].FFields[j].Name:=Qry.FMsg.rs;
      FUDTProcessors[i].FFields[j].Value:=Qry.GetValueReader(
        Qry.FMsg,GetValueReader_ColumnIndex_Unspecified);
     end;
   end
  else
   begin
    //TODO check Length(FUDTProcessors[i].FFields) and types?
    for j:=0 to w-1 do
     begin
      Qry.FMsg.rs;
      p:=Qry.GetValueReader(Qry.FMsg,GetValueReader_ColumnIndex_Unspecified);
     end;
   end;
  Result:=FUDTProcessors[i].readValue;
end;

{ TCassandraListProcessor }

function TCassandraListProcessor.readValue(Msg:TCassandraMessage;Size:integer):Variant;
var
  i:integer;
  v:Variant;
begin
  if Size=0 then
    Result:=VarArrayCreate([0,-1],varVariant)//Null?
  else
   begin
    v:=rv(FValue,Msg);
    Result:=VarArrayCreate([0,Size-1],VarType(v));
    Result[0]:=v;
    i:=1;
    while (i<Size) do
     begin
      Result[i]:=rv(FValue,Msg);
      inc(i);
     end;
   end;
end;

{ TCassandraMapProcessor }

function TCassandraMapProcessor.readValue(Msg:TCassandraMessage;Size:integer):Variant;
var
  i,l:integer;
  d:IJSONDocument;
  s:WideString;
begin
  //TODO: check size
  l:=Msg.r4;//count
  d:=JSON;//TODO: re-use existing JSON instance...
  i:=0;
  while i<l do
   begin
    s:=FKey(Msg,Msg.r4);
    d[s]:=rv(FValue,Msg);
    inc(i);
   end;
  Result:=d;
end;

{ TCassandraUDTProcessor }

function TCassandraUDTProcessor.readValue(Msg:TCassandraMessage;Size:integer):Variant;
var
  i:integer;
  d:IJSONDocument;
begin
  //TODO: check size
  d:=JSON;//TODO: re-use existing JSON instance...
  for i:=0 to Length(FFields)-1 do
    d[FFields[i].Name]:=rv(FFields[i].Value,Msg);
  Result:=d;
end;

initialization
  ProcessorStore:=TCassandraProcessorStore.Create;
finalization
  FreeAndNil(ProcessorStore);
end.
