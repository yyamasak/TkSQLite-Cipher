#
# Tcl package index file
#
# Note sqlite*3* init specifically
#
package ifneeded sqlite3 3.7.17 \
    [list load [file join $dir sqlite3717.dll] Sqlite3]
