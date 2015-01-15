#
# Tcl package index file
#
# Note sqlite*3* init specifically
#
package ifneeded sqlite3 3.8.7.4 \
    [list load [file join $dir sqlite3874.dll] Sqlite3]
