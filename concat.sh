#!/bin/bash

dir="files"
count_files=1

while [ -n "$1" ]
do
	case "$1" in
		-h) 
			echo "Usage:"
			echo "-h	show this menu"
			echo "-d	path to directory with audio files"
			echo "-c	number of output files" ;;
		-d) 
			dir="$2"
			if ! [ -d $dir ]; then
				echo 'No directory'
				exit 1
			fi
			
			if [ -z "$(ls -A $dir | grep -E -E '*.mp3|*.wav')" ] ; then 
				echo 'No audio files in directory'
				exit 2
			fi
			shift ;;
		-c) 
			count_files="$2"
			if [ "$count_files" -eq "$count_files" ] 2>/dev/null; then
				:
				else 
					echo 'Param -c must be a number'
					exit 3
			fi
			shift ;;
		--) 
			shift
			break ;;
		*)
			echo "$1 is not an option";;
	esac
	shift
	
done

find $dir -name '*.mp3' -o -name '*.wav' | sort > /tmp/Audio_Concat_files

number_files=$(cat /tmp/Audio_Concat_files | wc -l)

if [ $number_files -lt $count_files ] ; then
	echo '-c must me greatest then number of files'
	exit 4
fi

let "delimiter = number_files / count_files"
i=0
part=0
for file in `cat /tmp/Audio_Concat_files` ; do
	let "i = i + 1"
	let "check = i % delimiter"
	let "test = i + delimiter"

	str="$str|$file"
	if [ $check -eq 0 -a $test -le $number_files -o $i -eq $number_files ] ; then
		let "part = part + 1"
		
		echo $str > /tmp/Audio_Concat_temp
		str=$(cut -b 2- /tmp/Audio_Concat_temp)
		
		ffmpeg -i "concat:$str" -acodec copy "output$part.wav"
		str=""
	fi
done

rm /tmp/Audio_Concat_files /tmp/Audio_Concat_temp
