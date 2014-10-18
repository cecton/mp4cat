#!/bin/sh

[ ${#@} -lt 3 ] && echo "too few arguments" && exit 1
ls "${@:1:$((${#@}-1))}" > /dev/null || exit 1
[ -f "${@:$#}" ] && echo "${@:$#}: file exists" && exit 1

tmp=`mktemp -d`

i=0
concat=
for input in "${@:1:$((${#@}-1))}"
do
	concat="$concat|$tmp/"$((++i))
	mkfifo "$tmp/$i"
	ffmpeg -y -i "$input" -c copy -bsf:v h264_mp4toannexb \
		-nostats -f mpegts "$tmp/$i" 2>> "$tmp/stderr" &
done

ffmpeg -i "concat:${concat:1}" -c copy -bsf:a aac_adtstoasc "${@:$#}"
res=$?

wait
rm -f "$tmp"/*
rmdir "$tmp"

exit $res
