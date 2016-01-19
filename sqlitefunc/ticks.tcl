proc CSharpTicks {t} {
	set ticks_1970 621355968000000000
	set unixepoch [expr {int(($t-$ticks_1970)/10000000)}]
	clock format $unixepoch -format "%Y-%m-%d %H:%M:%S"
}

db function ticks CSharpTicks
