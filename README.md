# DataLank

## What is it?

DataLank is the lightest possible abstract layer to access data. It is so light it is not complete. It is not [ORM](https://en.wikipedia.org/wiki/Object-relational_mapping). It is not an be-all-end-all solution. It is not a data link. It provides a singular way to fetch and forward-only iterate single simple query result sets. Want more? Look elsewhere. The point of using a few objects with a pre-described interface is to avoid _some_ of the work of switching to a different database somewhere down along the lifetime of a project, but not all.

## How does it work?

`DataLankProtocol.pas` defines the interface for the `TDataConnection` and `TQueryResult` and  objects, but you're not supposed to use it. (Except perhaps to include it in a project to see wether it compiles without syntax errors.)

In your project, include a `DataLank.pas` unit that just contains code like this, patching the objects through to the implementation of your choosing:

    unit DataLink;

    interface

    uses SomeDBData;

    type
      TDataConnection = TSomeDBConnection;
      TQueryResult = TSomeDBCommand;

    implementation

    end.

This enables you to use `TDataConnection` in the initialization code and `TQueryResult` throughout the application, and still change to a different database solition at a later point in the project's lifetime.

## Implementations

* ADODB: //TODO:
* SQLite: https://github.com/stijnsanders/TSQLite
* PostgreSQL: //TODO
* (more? feel free to give it a try and post a pull request!)

## Why 'Data Lank'

It's not quite a _data l**i**nk_. The point is to have a data-layer that is as thin as possible, so I selected something from [m-w: thesaurus/thin](http://www.merriam-webster.com/thesaurus/thin) and as noted by [m-w: dictionary/lank](http://www.merriam-webster.com/dictionary/lank) _'lank'_ stands for:

* _not well filled out:_ not every operation on the database is available in the limited abstraction. Normal operation can use the TQueryResult object, but advanced work like iterating over the results in a different manner or initiating an automated backup had to be done by talking to the specific database interface or other tools.

* _insufficient in quality, degree or extent:_ it is not suitable to everyone or for any project. Select to use DataLank in projects that will primarily use data from the database in a straight-forward manner, and can divert to other means to perform any advanced work on the data.

* _hanging straight and limp without spring or curl:_ it just lets you get and use data from the database using TQueryResult, nothing much more. It doesn't do any extra work for you. It's not ORM. It's only a clean simple imperfect abstraction layer to deminish the work needed to switch to a different database at a later point in the project's lifetime, but specifically _not_ to eleminate that effort.

## Examples of things made with DataLank

* https://github.com/stijnsanders/xxm
* https://github.com/stijnsanders/tx
* (know more? feel free to post a pull request)
