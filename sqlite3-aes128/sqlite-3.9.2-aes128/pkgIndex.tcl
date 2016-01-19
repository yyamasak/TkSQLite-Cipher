#
# Tcl package index file
#
# Note sqlite*3* init specifically
#
package ifneeded sqlite3 3.9.2 \
    [list load [file join $dir sqlite392.dll] Sqlite3]
