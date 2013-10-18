# user functions for sqlite
# version0.5

namespace eval Sqlite::func {
	variable db ""
	variable version ""
	variable encoding ""

	# install functions to db
	proc install {dbcmd {enc ""}} {
		variable db $dbcmd
		variable version
		variable encoding
		
		set db_encoding [$db eval {PRAGMA encoding;}]
		set version  [lindex [split [$db eval "select sqlite_version();"] .] 0]
		if {$enc eq ""} {
			if {$version == 3} {
				set encoding "utf-8"
			}
			if {$version == 2} {
				set encoding [encoding system]
			}
		}
		
		foreach cmd [info command [namespace current]::*] {
			set func [namespace tail $cmd]
			if {$func eq "install"} {continue}
			if {[string match "_*" $func]} {continue}
			$db function $func $cmd
		}
	}

	proc _getUnicodeByteArray {str isLE} {
		if {$str eq ""} return
		set data [encoding convertto unicode $str]

		if {$::tcl_platform(byteOrder) eq "littleEndian"} {
			if {$isLE} {
				return $data
			} else {
				binary scan $data s* str
				return [binary format S* $str]
			}
		} else {
			if {$isLE} {
				binary scan $data s* str
				return [binary format S* $str]
			} else {
				return $data
			}
		}
	}
	proc _getStringFromUnicodeByteArray {bytearray isLE} {
		if {$bytearray eq ""} return
		if {$::tcl_platform(byteOrder) eq "littleEndian"} {
			if {!$isLE} {
				binary scan $bytearray s* data
				set bytearray [binary format S* $data]
			}
		} else {
			if {$isLE} {
				binary scan $bytearray s* data
				set bytearray [binary format S* $data]
			}
		}
		return [encoding convertfrom unicode $bytearray]
	}
	proc _getEncodedByteArray {data binary} {
		variable db
		variable version
		variable encoding
		if {$version == 3} {
			if {!$binary} {
				set db_encoding [$db eval {PRAGMA encoding;}]
				if {$db_encoding eq "UTF-8" && $encoding eq "utf-8"} {
					set data [encoding convertto "utf-8" $data]
				}
				if {$db_encoding eq "UTF-16le"} {set data [_getUnicodeByteArray $data 1]}
				if {$db_encoding eq "UTF-16be"} {set data [_getUnicodeByteArray $data 0]}
			}
		}
		if {$version == 2} {
			set data [encoding convertto identity $data]
		}
		return $data
	}
	proc _getDataFromByteArray {data binary} {
		variable db
		variable version
		variable encoding
		if {$version == 3} {
			if {!$binary} {
				set db_encoding [$db eval {PRAGMA encoding;}]
				if {$db_encoding eq "UTF-8" && $encoding eq "utf-8"} {
					set data [encoding convertfrom "utf-8" $data]
				}
				if {$db_encoding eq "UTF-16le"} {set data [_getStringFromUnicodeByteArray $data 1]}
				if {$db_encoding eq "UTF-16be"} {set data [_getStringFromUnicodeByteArray $data 0]}
			}
		}
		if {$version == 2} {
			if {!$binary} {
				set data [encoding convertfrom identity $data]
			}
		}
		return $data
	}

	proc _getTclString {data} {
		variable db
		variable version
		variable encoding
		if {$encoding ne "utf-8" && $encoding ne "unicode"} {
			return [encoding convertfrom $encoding $data]
		} else {
			return $data
		}
	}

	# String Format
	proc ascii     {a} {binary scan $a c x; return $x}
	#    char      Sqlite built-in
	proc concat    args {join $args {}}
	proc concat_ws {s args} {join $args $s}
	proc convert {str from to} {
		variable version
		variable db
		if {$version == 3} {
			if {$from eq "utf-8"} {
			set str [encoding convertto identity $str]
			}
			set str [encoding convertfrom $from $str]
			set str [encoding convertto $to $str]
			if {$to eq "utf-8"} {
			set str [encoding convertfrom identity $str]
			}
			return $str
		}
		if {$version == 2} {
			set str [encoding convertto identity $str]
			set str [encoding convertfrom $from $str]
			set str [encoding convertto $to $str]
			set str [encoding convertfrom identity $str]
			return $str
		}
	}
	proc elt       {n args} {lindex $args [incr n -1]}
	#    hex       Sqlite built-in
	proc initcap   {str} {
		set ret ""
		set len [string length $str]
		set u 1
		for {set i 0} {$i < $len} {incr i} {
			set c [string index $str $i]
			if {$u == 1} {
				set c [string toupper $c]
				set u 0
			} else {
				set c [string tolower $c]
			}
			if {[string is space $c]} {
				set u 1
			}
			append ret $c
		}
		return $ret
	}
	proc insert    {s pos len ns} {string replace $s [expr {$pos-1}] [expr {$pos-2+$len}] $ns} ;#MySQL insert
	#    instr     Sqlite built-in
	proc _instr     {str sstr {st 0} {n 1}} {
		if {$n < 1} {return 0}
		if {$st >= 0} {
			incr st -1
			for {set i 0} {$i < $n} {incr i} {
				set st [string first $sstr $str $st]
				if {$st == -1} {return 0}
				incr st
			}
		} else {
			set st [expr {[string length $str] + $st - 1}]
			for {set i 0} {$i < $n} {incr i} {
				set st [string last $sstr $str $st]
				if {$st == -1} {return 0}
			}
			incr st
		}
		return $st
	}
	proc locate    {sstr str pos} {_instr $str $sstr $pos 1}
	proc position  {sstr in str} {_instr $str $sstr}
	proc left      {s n} {string range $s 0 [incr n -1]}
	#    length    Sqlite built-in
	#    lower     Sqlite built-in
	proc lpad      {s n {p " "}} {
		if {$p eq {}} {set p " "}
		set slen 0
		set ns ""
		set i [string length $s]
		while {[incr i -1] >= 0} {
			set c [string index $s $i]
			if {[string is ascii -strict $c]} {set icount 1} else {set icount 2}
			incr slen $icount
			if {$slen > $n} {
				if {$icount == 2} {set ns " $ns"}
				return $ns
			}
			set ns $c$ns
		}
		set sep [expr {$n - $slen}]
		set i 0
		set rstr ""
		foreach c [split [string repeat $p $n] {}] {
			if {[string is ascii -strict $c]} {set icount 1} else {set icount 2}
			incr i $icount
			if {$i > $sep} {
				if {$icount == 2 && $i - $icount != $sep} {
					return [append rstr " $ns"]
				}
				return [append rstr $ns]
			}
			append rstr $c
		}
	}
	#    ltrim     Sqlite built-in
	proc mid       {str pos len} {incr pos -1; string range $str $pos [expr {$pos+$len-1}]}
	
	proc repeat    {s n} {string repeat $s $n}
	#    replace   Sqlite built-in
	proc reverse   {s} {set i [string len $s]; set r ""; while {[incr i -1] >= 0} {append r [string index  $s $i] }; return $r}
	proc right     {s n} {string range $s end-[incr n -1] end}
	proc rpad      {s n {p " "}} {
		if {$p eq {}} {set p " "}
		set i 0
		set ret ""
		foreach c [split $s[string repeat $p $n] {}] {
			if {[string is ascii -strict $c]} {set icount 1} else {set icount 2}
			incr i $icount
			if {$i > $n} {
				if {$icount == 2 && $i - $icount < $n} {
					return "$ret "
				}
				return $ret
			}
			append ret $c
		}
	}
	#    rtrim     Sqlite built-in
	#    substr    Sqlite built-in
	proc space     {n} {string repeat " " $n}
	#    strftime  Sqlite built-in
	proc translate {s nl ml} {
		set max [string length $nl]
		set map [list]; 
		for {set i 0} {$i < $max} {incr i} {
			lappend map [string index $nl $i] [string index $ml $i]
		}
		string map $map $s
	}
	#    trim      Sqlite built-in
	proc to_char {num fmt} {
		set fmt [string map {G , D . L \$} $fmt]
		if {![string is double $num]} {return "####"}
		set sign [expr {$num >= 0 ? 0 : 1}]
		set nnum [expr {abs($num)}]

		set ndig [string first . $nnum]
		if {$ndig != [string last . $nnum]} {return "####"}
		set fdig [string first . $fmt]
		if {$fdig != [string last . $fmt]} {return "####"}
		if {$fdig > -1} {set D 1} else {set D 0}
		set B 0; set FM 0; set S 0;
		foreach i {1 2 3} {
			switch -- [string index $fmt 0] {
				B {set fmt [string range $fmt 1 end]; set B 1}
				S {set fmt [string range $fmt 1 end]; set S 1}
				F {
					if {[string range $fmt 0 1] eq "FM"} {
					set fmt [string range $fmt 2 end]; set FM 1
					} else {
					return "####"
					}
				}
			}
		}
		if {[string index $fmt end] eq "S"} {
			set fmt [string range $fmt 0 end-1]; set S 2
		}

		foreach {num1 num2} [split $nnum .] break
		foreach {fmt1 fmt2} [split $fmt .] break

		if {$num1 == 0} {set num1 ""}
		set str1 ""
		set ni [expr {[string length $num1] - 1}]
		set fi [string length $fmt1]
		set zero [string first "0" $fmt1]
		if {$zero == -1} {set zero $fi}
		while {[incr fi -1] >= 0} {
			set c [string index $fmt1 $fi]
			if {$c eq "0" || $c eq "9"} {
				if {$ni >= 0} {
					set str1 [string index $num1 $ni]$str1
				} else {
					if {$fi < $zero} {
						set str1 " $str1"
					} else {
						set str1 "0$str1"
					}
				}
				incr ni -1
				continue
			}
			if {$c eq ","} {
				if {$fi < $zero && $ni < 0} {
					set str1 " $str1"
				} else {
					set str1 ",$str1"
				}
				continue
			}
			return "####"
		}
		if $FM {
			set str1 [string trimleft $str1 " "]
		}
		
		set str2 ""
		set num2 [string trimright $num2 0]
		set ni 0
		set fmax [string length $fmt2]
		set fi 0
		set zero [string last "0" $fmt2]
		while {$fi < $fmax} {
			set c [string index $fmt2 $fi]
			if {$c eq "0" || $c eq "9"} {
				set nc [string index $num2 $ni]
				if {$nc ne {}} {
					append str2 $nc
				} else {
					if {$fi <= $zero} {
						append str2 "0"
					} else {
						append str2 " "
					}
				}
				incr ni
			} else {
				return "####"
			}
			incr fi
		}
		if $FM {
			set str2 [string trimright $str2 " "]
		} else {
			set str2 [string map {" " "0"} $str2]
		}

		set str $str1
		if {$D} {append str . $str2}
		if {$B} {
			if {$str == 0} {set str [string repeat " " [string length $str]]}
		}
		if {$B == 0 && $D == 0 && $FM == 0} {
			if {[string index $str end] eq " "} {
				set str [string replace $str end end "0"]
			}
		}
		set space [string last " " $str]
		switch -exact -- $S {
			0 {
				if {$sign == 1} {set s "-"}
				if {$sign == 0 && $FM == 0} {set s " "}
				if {$sign == 0 && $FM == 1} {set s ""}
				set str [string range $str 0 $space]$s[string range $str [incr space] end]
			}
			1 {
				if {$sign == 1} {set s "-"} else {set s "+"}
				set str [string range $str 0 $space]$s[string range $str [incr space] end]
			}
			2 {
				if {$sign == 1} {set str "$str-"}
				if {$sign == 0} {set str "$str+"}
			}
		}
		return $str
	}
#        upper     Sqlite built-in

	# Math Functions
	#    abs   Sqlite built-in
	proc acos  {x} {expr {acos($x)}}
	proc asin  {x} {expr {asin($x)}}
	proc atan  {x} {expr {atan($x)}}
	proc atan2 {x y} {expr {atan2($x,$y)}}
	#    avg   Sqlite built-in
	proc ceil  {n} {expr {int(ceil($n))}}
	proc cos   {x} {expr {cos($x)}}
	proc cot   {x} {if {$x!=0} {expr {1/tan($x)}}}
	proc degrees {a} {expr {$a/3.14159265358979*180.0}}
	proc exp     {x} {expr {exp($x)}}
	proc floor   {n} {expr {int(floor($n))}}
	proc greatest args { set m [lindex $args 0]
				foreach n [lrange $args 1 end] {if {$n > $m} {set m $n}}; return $m }
	proc least    args { set m [lindex $arformat %02Xgs 0]
				foreach n [lrange $args 1 end] {if {$n < $m} {set m $n}}; return $m }
	proc log     {x} {if {$x != 0} {expr {log($x)}}}
	proc log10   {x} {if {$x != 0} {expr {log10($x)}}}
	proc mod     {m n} {expr {$m % $n}}
	proc pi      args {return 3.14159265358979}
	proc pow     {x y} {expr {pow($x,$y)}}
	proc radians {x} {expr {$x*3.14159265358979/180}}
	proc rand    {} {expr {rand()}}
	#    random  Sqlite built-in
	#    round   Sqlite built-in
	proc sign    {x} {expr {$x == 0 ? 0 : ($x > 0 ? 1 : -1)}}
	proc sin     {x} {expr {sin($x)}}
	proc sqrt    {x} {expr {sqrt($x)}}
	proc tan     {x} {expr {tan($x)}}
	proc trunc   {n {d 0}} {set t [expr {pow(10,$d)}]; 
						expr {$d <= 0 ? int(int($n*$t)/$t) : int($n*$t)/$t}}
	
	# DateTime Functions
	proc now {} {clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S" -gmt 0};#Access now()
#    julianday Sqlite built-in
#    datetime  Sqlite built-in
#    date      Sqlite built-in
#    strftime  Sqlite built-in
	
	# Other Functions
#    min         Sqlite built-in
#    max         Sqlite built-in
#    coalesce    Sqlite built-in
#    nullif      Sqlite built-in
#    ifnull      Sqlite built-in
#    last_insert_rowid Sqlite built-in
	proc user {} {set env(USERNAME)}

	# regexp, regsub
	interp alias {} [namespace current]::regexp {} regexp
	interp alias {} [namespace current]::regsub {} regsub
	

	# md5, md5_hmac
	if {![catch {package require md5}]} {
		proc md5 {data {binary 0}} {
			set data [_getEncodedByteArray $data $binary]
			return [::md5::md5 -hex $data]
		}
		proc md5_hmac {key data {binary 0}} {
			set key  [_getEncodedByteArray $key 0]
			set data [_getEncodedByteArray $data $binary]
			return [::md5::hmac -hex -key $key $data]
		}
	}
	# md5crypt, apr_crypt
	if {![catch {package require md5crypt}]} {
		proc md5_crypt {pass salt {binary 0}} {
			set pass [_getEncodedByteArray $pass 0]
			set salt [_getEncodedByteArray $salt $binary]
			return [::md5crypt::md5crypt $pass $salt]
		}
		proc apr_crypt {pass salt {binary 0}} {
			set pass [_getEncodedByteArray $pass 0]
			set salt [_getEncodedByteArray $salt $binary]
			return [::md5crypt::aprcrypt $pass $salt]
		}
	}
	# sha1, sha1_hmac
	if {![catch {package require sha1}]} {
		proc sha1 {data {binary 0}} {
			set data [_getEncodedByteArray $data $binary]
			return [::sha1::sha1 -hex $data]
		}
		proc sha1_hmac {key data {binary 0}} {
			set key  [_getEncodedByteArray $key 0]
			set data [_getEncodedByteArray $data $binary]
			return [::sha1::hmac -hex -hey $key $data]
		}
	}
	# aes_encrypt, aes_decrypt
	if {![catch {package require aes}]} {
		proc aes_encrypt {key data {binary 0}} {
			set key  [_getEncodedByteArray $key 0]
			set data [_getEncodedByteArray $data $binary]
			return [::aes::aes -mode ecb -dir encrypt -key $key -- $data]
		}
		proc aes_decrypt {key data {binary 0}} {
			set key  [_getEncodedByteArray $key 0]
			set result [::aes::aes -mode ecb -dir decrypt -key $key -- $data]
			set result [_getDataFromByteArray $result $binary]
			return $result
		}
	}
	# blowfish_encrypt, blowfish_decrypt
	if {![catch {package require blowfish}]} {
		proc blowfish_encrypt {key data {binary 0}} {
			set key  [_getEncodedByteArray $key 0]
			set data [_getEncodedByteArray $data $binary]
			return [::blowfish::blowfish -mode ecb -dir encrypt -key $key -- $data]
		}
		proc blowfish_decrypt {key data {binary 0}} {
			set key  [_getEncodedByteArray $key 0]
			set result [::blowfish::blowfish -mode ecb -dir decrypt -key $key -- $data]
			set result [_getDataFromByteArray $result $binary]
			return $result
		}
	}
	# des_decrypt, des_encrypt
	if {![catch {package require des}]} {
		proc des_encrypt {key data} {
			set key  [_getEncodedByteArray $key 0]
			set data [_getEncodedByteArray $data $binary]
			return [::DES::des -mode ecb -dir encrypt -key $key -- $data]
		}
		proc des_decrypt {key data} {
			set key  [_getEncodedByteArray $key 0]
			set result [::DES::des -mode ecb -dir decrypt -key $key -- $data]
			set result [_getDataFromByteArray $result $binary]
			return $result
		}
	}
	# base64_encode, base64_decode
	if {![catch {package require Trf}]} {
		proc base64_encode {data {binary 0}} {
			set data [_getEncodedByteArray $data $binary]
			return [::base64 -mode encode -- $data]
		}
		proc base64_decode {data {binary 0}} {
			set result [::base64 -mode decode -- $data]
			set result [_getDataFromByteArray $result $binary]
			return $result
		}
	}
	# uuid
	if {![catch {package require uuid}]} {
		proc uuid {} {return [::uuid::uuid generate]}
	}
	# compress
	if {![catch {package require Trf}]} {
		proc compress {data {binary 0}} {
			set data [_getEncodedByteArray $data $binary]
			return [zip -mode compress -- $data]
		}
		proc decompress {data {binary 0}} {
			set result [zip -mode decompress -- $data]
			set result [_getDataFromByteArray $result $binary]
			return $result
		}
	}
	# file io
	if {![catch {package require Trf}]} {
		proc write_file {file val {binary 0}} {
			variable version
			set file [_getTclString $file]
			if {[catch {open $file w} fp]} {error "failed to open '$file'"}
			set val [_getEncodedByteArray $val $binary]
			if {$binary && $version == 2} {
				set val [::base64 -mode decode $val]
			}
			fconfigure $fp -translation binary -encoding binary
			puts -nonewline $fp $val
			close $fp
			return
		}
		proc read_file {file {binary 0}} {
			variable version
			set file [_getTclString $file]
			if {[catch {open $file r} fp]} {error "failed to open '$file'"}
			fconfigure $fp -translation binary -encoding binary
			set val [::read $fp]
			close $fp
			set val [_getDataFromByteArray $val $binary]
			if {$binary && $version == 2} {
				set val [::base64 -mode encode $val]
			}
			return $val
		}
	}
}

