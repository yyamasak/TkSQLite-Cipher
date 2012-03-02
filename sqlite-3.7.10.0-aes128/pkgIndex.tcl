#
# Tcl package index file
#
# Note sqlite*3* init specifically
#
package ifneeded sqlite3 3.7.10 \
    [list load [file join $dir sqlite3710.dll] Sqlite3]
