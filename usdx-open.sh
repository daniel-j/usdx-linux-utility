#!/bin/bash

input="$1"
simplename="$(basename "$input")"

if [ ! -e "$input" ]; then
	zenity --error --text="File does not exist\n$input"
	exit 1
fi

escapehtml() {
	sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g; s/'"'"'/\&#39;/g' <<< "$1"
}

add_one() {
	songpath="${songs[0]}"
	list="$songpath"
	load_song "$songpath"
	if [ ! -z "$cover" ]; then
		coverpath="$directory/$cover"
		image="data:image;base64,$(tar -xf "$input" "$coverpath" -O | base64 -w 0)"
	fi

	title=$(escapehtml "$title")
	artist=$(escapehtml "$artist")
	creator=$(escapehtml "$creator")
	language=$(escapehtml "$language")
	songpath=$(escapehtml "$songpath")
	eval "echo \"$(< ./prompt.html)\"" | zenity --text-info --title="Add song from \"$simplename\"" --filename=/dev/stdin --html --width=850 --height=350
}

add_many() {
	declare -a data

	for songpath in "${songs[@]}"
	do
		load_song "$songpath"

		data+=("TRUE" "$songpath" "$title" "$artist" "$creator" "$language")
	done
	list=$(zenity --list --checklist --title="Add songs from \"$simplename\"" --width=800 --height=350 --separator='\n' --column="" --column="Song file" --column="Title" --column="Artist" --column="Creator" --column="Language" "${data[@]}")
}

load_song() {
	song=$(tar -xf "$input" "$1" -O)
	directory=$(dirname "$1")
	title=$(echo "$song" | grep "^#TITLE:" | cut -c 8- | tr -d '\r\n')
	artist=$(echo "$song" | grep "^#ARTIST:" | cut -c 9- | tr -d '\r\n')
	creator=$(echo "$song" | grep "^#CREATOR:" | cut -c 10- | tr -d '\r\n')
	language=$(echo "$song" | grep "^#LANGUAGE:" | cut -c 11- | tr -d '\r\n')
	cover=$(echo "$song" | grep "^#COVER:" | cut -c 8- | tr -d '\r\n')
	audio=$(echo "$song" | grep "^#MP3:" | cut -c 6- | tr -d '\r\n')
	video=$(echo "$song" | grep "^#VIDEO:" | cut -c 8- | tr -d '\r\n')
	background=$(echo "$song" | grep "^#BACKGROUND:" | cut -c 13- | tr -d '\r\n')
}

txtfiles=$(tar -tf "$input" | sort | grep -i "\.txt$")

if [[ $? -ne 0 ]]; then
	zenity --error --text="Could not read tar archive\n$input"
	exit 1
fi

declare -a songs

while read -r txtpath
do
	song=$(tar -xf "$input" "$txtpath" -O | grep -E '^#TITLE:|^#ARTIST:' | wc -l)
	if [[ $song -eq 2 ]]; then songs+=("$txtpath"); fi
done <<< "$txtfiles"

songcount=${#songs[@]}

if [[ $songcount -lt 1 ]]; then
	zenity --error --text="No songs found"
	exit 1
fi

if [[ $songcount -eq 1 ]]; then
	add_one
else
	add_many
fi

if [[ $? -ne 0 ]] || [ -z "$list" ]; then exit 0; fi

outdir="$HOME/.ultrastardx/songs"

while read -r songpath
do
	load_song "$songpath"
	if [ -e "$outdir/$songpath" ]; then
		zenity --question --text="This song already exists. Do you want to overwrite it?\n\n$artist - $title\n\n$outdir/$songpath" --title="Overwrite song?"
		if [[ $? -ne 0 ]]; then continue; fi
	fi
	mkdir -pv "$outdir"
	echo "Extracting song to $outdir/$songpath"
	files=("$songpath")
	if [ ! -z "$cover" ]; then files+=("$directory/$cover"); fi
	if [ ! -z "$audio" ]; then files+=("$directory/$audio"); fi
	if [ ! -z "$video" ]; then files+=("$directory/$video"); fi
	if [ ! -z "$background" ]; then files+=("$directory/$background"); fi
	tar -xvf "$input" -C "$outdir" "${files[@]}"
done <<< "$list"
