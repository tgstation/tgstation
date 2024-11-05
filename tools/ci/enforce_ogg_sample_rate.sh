fail=0
find ~/tgstation/sound/ -type f \( -iname "*.mp3" -o -iname "*.wav" -o -iname "*.flac" -o -iname "*.aac" -o -iname "*.ogg" -o -iname "*.m4a" \) -print0 | xargs -0 -n 1 -P "$(nproc)" sh -c 'mediainfo --Inform="Audio;%SamplingRate%" "$1" > "./$(basename "$1").txt" && echo "File: $1" >> "./$(basename "$1").txt"' _ && cat *.txt > sample_rate.log && rm *.txt
done
if [ "$fail" = 1 ]; then
  echo "Files are not up to sample rate standard, see standard.dm in the sound folder."
  exit 1
else
	echo "All OGG files have the correct sample rate."
fi
exit 0
