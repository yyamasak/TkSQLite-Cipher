TkSQLite-AES128
===============

TkSQLite with AES 128bit encryption support

Installation (single binary executable)
---------------------------------------
Download "release/tksqlite.x.x.x.exe".
Place the file in a folder whose full path does not contain neither spaces nor multibyte characters.
This is a regislation of single executable binaries compiled by TclApp.
Double click "tksqlite.exe".

Installation (Tcl script)
-------------------------
Install ActiveTcl (>8.4).
Download "release/tksqlite.tcl" and "sqlite3-aes128/sqlite-3.7.15.1-aes128".
Place tksqlite.tcl in any folder and sqlite-3.7.15.1-aes128 in Tcl/lib folder.
Double click "tksqlite.tcl".

Purpose of this project
-----------------------
1. To provide encryption enabled TkSQLite and its binary executable.
2. To provide encryption enabled TclSQLite package.

Background
----------
TkSQLite was originally written by Yoshio Ohtsuka (http://reddog.s35.xrea.com/wiki/TkSQLite.html).
I have been using it as the best frontend to sqlite3 database.
One day, one of my customers wanted to protect his database with a password.
Google told me a lot of solutions that encrypt and decrypt sqlite database
and those were very expensive or hard to compile on windows platform.
Then I found an open source project ["wxSQLite3"](http://wxcode.sourceforge.net/components/wxsqlite3/ "wxCode » Components » wxSQLite3").
It was [relatively easy](http://yusuke-blog.info/20130109/tclsqlite-configuration/ "Tcl SQLite build configuration") 
to integrate wxSQLite3 and TclSQLite package.

I was using [SQLite2009 Pro Enterprise Manager](http://osenxpsuite.net/?xp=3 "SQLite2009 Pro Enterprise Manager") 
as a frontend to the encrypted database but I was not content with the user interface.
So I decided to customize original TkSQLite to support wxSQLite3's AES-128bit encryption.
What I did for TkSQLite was to check if the database is encrypted and to show password dialog automatically.

Limitations
-----------
TkSQLite-AES128 does not support SQLite2.
Encryption enabled sqlite package is provided only for windows platform.

Screenshot
----------
![TkSQLite screenshot](/img/TkSQLite-aes128-Screenshot.png "TkSQLite-aes128 screenshot")
