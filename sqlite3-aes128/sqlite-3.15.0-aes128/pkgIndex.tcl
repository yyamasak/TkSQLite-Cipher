#
# Tcl package index file
#
# Note sqlite*3* init specifically
#
package ifneeded sqlite3 3.15.0 \
    [list load [file join $dir sqlite3150.dll] Sqlite3]
