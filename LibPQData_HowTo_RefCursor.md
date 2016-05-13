# How to use LibPQData's RefCursor function

PostgreSQL doesn't allow this:

    create or replace function MyFunc1() returns table as
    $$
    begin
    return query select * from MyTable1;
    end
    $$ language plpgsql;

This is mainly because PostgreSQL wants to know the full type description of the columns in the returned table. Also `returns setof record` is not allowed. In some cases it is highly desirable to have a function return result-sets of variable column count and types.

There is a way to make this work: using the `refcursor` type and have the function assign this cursor to the desired query. A possible downside is this requires an extra `fetch all "cursorname"`, and a transaction must be currently active.

To make this work, script the function like this:

    create or replace function TestCursorFunc (c refcursor) returns void as
    $$
    begin
    open c for select * from Table1;
    end
    $$ language plpgsql;

Then in the application write code like this:

    var
      db:TDataConnection;
      qr:TQueryResult;
      s:string;
    begin
      db:=TDataConnection.Create('host=...');

      s:=Format('c%.8x%.8x%.8x',
        [GetCurrentProcessId,GetCurrentThreadId,GetTickCount]);

      db.Perform('begin',[]);
      try
        qr:=TQueryResult.Create(db,'select TestCursorFunc($1)',[RefCursor(s)]);
        try
          qr.Read;
        finally
          qr.Free;
        end;

        qr:=TQueryResult.Create(db,'fetch all "'+s+'"',[]);
        try
          while qr.Read do
           begin
            //...
           end;
        finally
          qr.Free;
        end;

        db.Perform('commit',[]);
      except
        db.Perform('rollback',[]);
        raise;
      end;

    end;
