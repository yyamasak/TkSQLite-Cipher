#
# Tcl package index file
#
# Note sqlite*3* init specifically
#
package ifneeded sqlite3 3.10.2 \
    [list load [file join $dir sqlite3102.dll] Sqlite3]
