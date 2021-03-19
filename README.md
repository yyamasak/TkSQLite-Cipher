TkSQLite-Cipher
===============

TkSQLite powered by [SQLite3 Multiple Ciphers](https://github.com/utelle/SQLite3MultipleCiphers) by Ulrich Telle.

Installation
---------------------------------------
## Single binary executable
Download "/release/tksqlite.x.x.x.exe".
Double click it.

## Tcl script
Install Tcl (>=8.5).
Download "/tksqlite.tcl" and sqlite-3.x.x.x-aes128.zip.
Place tksqlite.tcl in any folder and sqlite-3.x.x.x-aes128 in Tcl/lib folder.
Double click "tksqlite.tcl".

Purpose of this project
-----------------------
1. To provide encryption enabled TkSQLite and its binary executable for Windows.
2. To provide encryption enabled TclSQLite package for Windows.

Background
----------
TkSQLite was originally written by Yoshio Ohtsuka (http://reddog.s35.xrea.com/wiki/TkSQLite.html).
I have been using it as the best frontend to sqlite3 database.

One day, one of my customers wanted to protect his database with a password.
Google told me a lot of solutions that encrypt and decrypt sqlite database
and those were very expensive or hard to compile on windows platform.

Then I found an open source project ["wxSQLite3"](https://github.com/utelle/wxsqlite3).
It was [relatively easy](http://yusuke-blog.info/20150115/tclsqlite-configuration/ "Tcl SQLite build configuration") 
to integrate wxSQLite3 and TclSQLite package.

For some time, I was using [SQLite2009 Pro Enterprise Manager](http://osenxpsuite.net/?xp=3 "SQLite2009 Pro Enterprise Manager") 
as a frontend to the encrypted database but I was not content with the user interface.
So I decided to customize original TkSQLite to support wxSQLite3's AES-128bit encryption.
What I did for TkSQLite was to check if the database is encrypted and to show password dialog automatically.

About the change of the project name
-----------
Originally, this project was names as TkSQLite-AES128 because it supported only AES128CBC cipher.  
Since v0.9.19, it has been renamed to TkSQLite-Cipher because it supports more ciphers with the power of [SQLite3 Multiple Ciphers](https://github.com/utelle/SQLite3MultipleCiphers) library.

Limitations
-----------
tclsqlite3 binary package is provided only for Windows 32bit platform.

Build it yourself
-----------
https://yusuke-blog.info/20210225/tclsqlite-configuration/

Screenshot
----------
![TkSQLite screenshot](https://raw.github.com/yyamasak/TkSQLite-AES128/master/img/TkSQLite-aes128-Screenshot.png "TkSQLite-aes128 screenshot")
