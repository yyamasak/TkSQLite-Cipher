#
# Tcl package index file
#
# Note sqlite*3* init specifically
#
package ifneeded sqlite3 3.8.7.2 \
    [list load [file join $dir sqlite3872.dll] Sqlite3]
