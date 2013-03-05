#
# Tcl package index file
#
# Note sqlite*3* init specifically
#
package ifneeded sqlite3 3.7.15.1 \
    [list load [file join $dir sqlite37151.dll] Sqlite3]
