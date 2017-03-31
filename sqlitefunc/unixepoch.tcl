proc UnixEpoch {t} {
	set ret $t
	if {[string is integer -strict $t]} {
		set ret [clock format $t -format "%Y-%m-%d %H:%M:%S"]
	}
	return $ret
}

db function unixepoch UnixEpoch