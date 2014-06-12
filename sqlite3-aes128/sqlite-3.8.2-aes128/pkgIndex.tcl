#
# Tcl package index file
#
# Note sqlite*3* init specifically
#
package ifneeded sqlite3 3.8.2 \
    [list load [file join $dir sqlite382.dll] Sqlite3]
