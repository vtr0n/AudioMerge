#!/usr/bin/env bash

audio_dir="files"
count_of_output_files=1

while [[ -n "$1" ]]
do
	case "$1" in
		-h) 
			echo "Usage:"
			echo "-h	show this menu"
			echo "-d	path to directory with audio files"
			echo "-c	number of output files" 
			exit 0 ;;
		-d) 
			audio_dir="$2"
			if ! [[ -d ${audio_dir} ]]; then
				echo 'No directory'
				exit 1
			fi
			
			if [[ $(find ${audio_dir} -iname "*.mp3" -o -iname "*.wav" | wc -l) -eq 0 ]] ; then
				echo 'No audio files in directory'
				exit 2
			fi
			shift ;;
		-c) 
			count_of_output_files="$2"
			if [[ "$count_of_output_files" -eq "$count_of_output_files" ]] 2>/dev/null ; then
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

count_file_in_dir=$(find ${audio_dir} -iname "*.mp3" -o -iname "*.wav" | wc -l)
if [[ ${count_file_in_dir} -eq 0 ]] ; then
    echo 'No audio files in directory'
    exit 5
fi
if [[ ${count_file_in_dir} -lt ${count_of_output_files} ]] ; then
	echo '-c must be less then number of files'
	exit 6
fi

number_files_in_merge=$(( ${count_file_in_dir} / ${count_of_output_files} ))
i=0
part=0
out=''
find ${audio_dir} -iname "*.mp3" -o -iname "*.wav" | sort | while read file  ; do
	i=$(( ${i} + 1 ))
	need_new_part=$(( ${i} % ${number_files_in_merge} ))
	test=$(( ${i} + ${number_files_in_merge} ))

	str="$str|$file"
	if [[ ${need_new_part} -eq 0 && ${test} -le ${count_file_in_dir} || ${i} -eq ${count_file_in_dir} ]] ; then
		part=$(( ${part} + 1))
        str="${str:1}"
		$(ffmpeg -i "concat:$str" -acodec copy "output$part.wav")
		str=''
	fi
done
