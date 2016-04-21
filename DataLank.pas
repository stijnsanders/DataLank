unit DataLank;

interface

{
uses ADOTools;

type
  TDataConnection = TADOLink;
  TQueryResult = TADOResult;
}

{
uses SQLiteData;

type
  TDataConnection = TSQLiteConnection;
  TQueryResult = TSQLiteStatement;
}

uses LibPQData;

type
  TDataConnection = TPostgresConnection;
  TQueryResult = TPostgresCommand;

implementation

end.
