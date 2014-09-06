#!/bin/sh

tmp=`mktemp -d`

[ ${#@} -lt 2 ] && echo "too few arguments" && exit 1
[ -f "${@:$#:1}" ] && echo "file exists" && exit 1

i=0
concat=
for file in "$@"
do
	if [ $((++i)) -lt ${#@} ]; then
		concat="$concat|$tmp/$i"
		mkfifo "$tmp/$i"
		ffmpeg -y -i "$file" -c copy -bsf:v h264_mp4toannexb -f mpegts "$tmp/$i" 2> "$tmp/stderr" &
	else
		ffmpeg -i "concat:${concat:1}" -c copy -bsf:a aac_adtstoasc "$file"
	fi
done

wait
rm -f "$tmp"/*
rmdir "$tmp"
