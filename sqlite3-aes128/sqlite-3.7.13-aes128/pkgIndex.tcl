#
# Tcl package index file
#
# Note sqlite*3* init specifically
#
package ifneeded sqlite3 3.7.13 \
    [list load [file join $dir sqlite3713.dll] Sqlite3]
