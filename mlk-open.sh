#!/bin/bash

input="$1"

tmp=$(mktemp -d)
#tar -xf "$input" -C "$tmp"

files=$(tar -tf "$input" | sort | grep -F "notes.txt")

#escapehtml() {
#	sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g; s/'"'"'/\&#39;/g' <<< "$1"
#}
#eval "echo \"$(< ./prompt.html)\"" | zenity --text-info --title="Add song" --filename=/dev/stdin --html --width=600 --height=300

declare -a data

while read -r notespath
do
	notes=$(tar -xf "$input" "$notespath" -O)
	title=$(echo "$notes" | grep "^#TITLE:" | cut -c 8- | tr -d '\r\n')
	artist=$(echo "$notes" | grep "^#ARTIST:" | cut -c 9- | tr -d '\r\n')
	creator=$(echo "$notes" | grep "^#CREATOR:" | cut -c 10- | tr -d '\r\n')
	language=$(echo "$notes" | grep "^#LANGUAGE:" | cut -c 11- | tr -d '\r\n')
	directory="$(dirname "$notespath")"

	data+=("TRUE" "$directory" "$title" "$artist" "$creator" "$language")
done <<< "$files"

list=$(zenity --list --checklist --title="Add songs to My Little Karaoke from \"$(basename "$input" ".tar.mlk")\"" --width=800 --height=350 --separator='\n' --column="" --column="Directory" --column="Title" --column="Artist" --column="Creator" --column="Language" "${data[@]}")

case $? in
	1)
		exit 0
		;;
	-1)
		echo "An unexpected error has occurred."
		exit 1
		;;
esac

outdir="$HOME/.ultrastardx/songs/"

while read -r directory
do
	mkdir -pv "$outdir"
	tar -xvf "$input" -C "$outdir" "$directory"
done <<< "$list"

