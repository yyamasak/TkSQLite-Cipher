#
# Tcl package index file
#
# Note sqlite*3* init specifically
#
package ifneeded sqlite3 3.10.1 \
    [list load [file join $dir sqlite3101.dll] Sqlite3]
