#
# Tcl package index file
#
# Note sqlite*3* init specifically
#
package ifneeded sqlite3 3.8.4.3 \
    [list load [file join $dir sqlite3843.dll] Sqlite3]
