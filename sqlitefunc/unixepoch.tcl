proc UnixEpoch {t} {
	clock format $t -format "%Y-%m-%d %H:%M:%S"
}

db function unixepoch UnixEpoch