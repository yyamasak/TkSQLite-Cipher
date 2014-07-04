#
# Tcl package index file
#
# Note sqlite*3* init specifically
#
package ifneeded sqlite3 3.8.5 \
    [list load [file join $dir sqlite385.dll] Sqlite3]
