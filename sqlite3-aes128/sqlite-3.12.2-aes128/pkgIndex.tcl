#
# Tcl package index file
#
# Note sqlite*3* init specifically
#
package ifneeded sqlite3 3.12.2 \
    [list load [file join $dir sqlite3122.dll] Sqlite3]
