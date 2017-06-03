#!/bin/bash

size="$1"
output="$3"

urldecode() {
    # urldecode <string>

    local url_encoded="${1//+/ }"
    printf '%b' "${url_encoded//%/\\x}"
}
input="$(urldecode "$2" | sed -e 's/^file:\/\///')"

if [ ! -e "$input" ]; then
	echo -e "File does not exist\n$input"
	#zenity --info --text="File does not exist\n$input"
	exit 1
fi

load_song() {
	song=$(tar -xf "$input" "$1" -O)
	directory=$(dirname "$1")
	cover=$(echo "$song" | grep "^#COVER:" | cut -c 8- | tr -d '\r\n')
}

txtfiles=$(tar -tf "$input" | sort | grep -i "\.txt$")

if [[ $? -ne 0 ]]; then
	echo -e "Could not read tar archive\n$input"
	exit 1
fi

declare -A covers

while read -r txtpath
do
	song=$(tar -xf "$input" "$txtpath" -O | sed -e '1s/^\xef\xbb\xbf//' | grep -E '^#TITLE:|^#ARTIST:' | wc -l)
	if [[ $song -eq 2 ]]; then
		load_song "$txtpath"
		if [ ! -z "$cover" ]; then
			covers+=(["$covers$directory/$cover"]="$covers$directory/$cover")
		fi
	fi
done <<< "$txtfiles"

covercount="${#covers[@]}"

if [[ $covercount -lt 1 ]]; then
	echo -e "No songs found\n$input"
	exit 1
fi

for K in "${!covers[@]}"; do
	cover="$K"
	break
done

echo "$cover"

if [ ! -z "$size" ]; then
	resize="-resize ${size}x${size}"
fi

tar -xf "$input" "$cover" -O | convert - $resize "$output"

if [[ $? -ne 0 ]]; then
	echo -e "Could not create thumbnail\n$input"
	exit 1
fi
