proc stringfy_version {bin} {
	binary scan $bin s4 v
	foreach {fv2 fv1 fv4 fv3} $v break
	set fv "$fv1.$fv2.$fv3.$fv4"
	return $fv
}

proc binary_version {v} {
	foreach {fv1 fv2 fv3 fv4} [split $v .] break
	binary format s4 [list $fv2 $fv1 $fv4 $fv3]
}

proc print_version {prefix bin} {
	set fv [stringfy_version $bin]
	puts "$prefix FileVersion $fv"
}

proc get_backup_name {f1} {
	set pre [file rootname $f1].backup
#	set n [llength [glob -nocomplain "${pre}*"]]
#	set f2 "${pre}[expr {$n+1}][file extension $f1]"
	set f2 "${pre}[file extension $f1]"
	return $f2
}

proc rewrite_vs_version_info {f1 fv} {
	if {![file exists $f1]} {
		puts "no such file $f1"
		return 1
	}
	set ch [open $f1 rb]
	fconfigure $ch -encoding binary
	set data1 [read $ch]
	close $ch
	
	set VS_VERSION_INFO "\u056\u000\u053\u000\u05F\u000\u056\u000\u045\u000\u052\u000\u053\u000\u049\u000\u04F\u000\u04E\u000\u05F\u000\u049\u000\u04E\u000\u046\u000\u04F\u000"
	set dwSignature [binary format c4 {0xbd 0x04 0xef 0xfe}]
	
	set index [string first $VS_VERSION_INFO $data1]
	set index [string first $dwSignature $data1 $index]
	
	set offset 8
	set length 8
	set head [expr {$index + $offset}]
	set tail [expr {$head + $length - 1}]
	
	set bfv1 [string range $data1 $head $tail]
	set bfv2 [binary_version $fv]
	
	print_version old $bfv1
	print_version new $bfv2
	
	if {[stringfy_version $bfv2] eq [stringfy_version $bfv1]} {
		return 2
	}
	
	set data2 [string replace $data1 $head $tail $bfv2]
	
	set f2 [get_backup_name $f1]
	file copy -force $f1 $f2
	
	set ch [open $f1 wb]
	fconfigure $ch -encoding binary
	puts -nonewline $ch $data2
	close $ch
	
	return 0
}

proc get_string_file_info_file_version {f1} {
	package require twapi
	foreach {var val} [twapi::get_file_version_resource $f1 FileVersion] break
	return $val
}

if {[info exists ::argv0] && $::argv0 eq [info script]} {
if {[llength $argv] == 1} {
	# Copy StringFileInfo.FileVersion to VS_VERSION_INFO.FileVersion.
	set f1 [lindex $argv 0]
	if {![file exists $f1]} {
		set code 1
	} else {
		set fv [get_string_file_info_file_version $f1]
		set code [rewrite_vs_version_info $f1 $fv]
	}
} elseif {[llength $argv] == 2} {
	# Set a specified number to VS_VERSION_INFO.FileVersion.
	foreach {f1 fv} $argv break
	set code [rewrite_vs_version_info $f1 $fv]
} else {
	# Error
	puts "usage: tclsh rewrite_vs_version_info.tcl executable ?FileVersion(x.x.x.x)?"
	set code 3
}
exit $code
}
