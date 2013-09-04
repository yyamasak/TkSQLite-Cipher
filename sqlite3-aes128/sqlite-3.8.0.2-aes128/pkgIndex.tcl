#
# Tcl package index file
#
# Note sqlite*3* init specifically
#
package ifneeded sqlite3 3.8.0.2 \
    [list load [file join $dir sqlite3802.dll] Sqlite3]
