package require vfs::mk4

proc remove_sqlite {tclkit sqlite} {
	exec upx -d $tclkit
	vfs::mk4::Mount $tclkit t
	foreach f [glob -nocomplain t/lib/${sqlite}/*] {
		file delete $f
	}
	file delete t/lib/${sqlite}
	vfs::unmount t
	exec upx $tclkit
}

lappend tclkit_list "c:/Tcl/bin/tclkit-cli-8606.exe" "sqlite3.13.0"
lappend tclkit_list "c:/Tcl/bin/tclkit-gui-8606.exe" "sqlite3.13.0"

foreach {tclkit sqlite} $tclkit_list {
	remove_sqlite $tclkit $sqlite
}
