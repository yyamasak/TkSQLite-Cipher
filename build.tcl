source rewrite_vs_version_info.tcl
set target_dir .

proc append_line {f line} {
	set ch [open $f a]
	puts $ch $line
	close $ch
}

proc rewrite_version {f _fv} {
	upvar $_fv fv
	set fv [get_string_file_info_file_version $f]
	rewrite_vs_version_info $f $fv
}

set logfile tksqlite.tpj.log
set bench [time {exec tclapp -log $logfile -verbose -config tksqlite.tpj}]
puts $bench
append_line $logfile $bench
set tmp [file join $target_dir tksqlite.exe]
rewrite_version $tmp fv
set out [file join $target_dir tksqlite.$fv.exe]
if {[file exists $out]} {
	file delete $out
}
file rename $tmp $out
append_line $logfile [clock format [clock seconds]]

exit
