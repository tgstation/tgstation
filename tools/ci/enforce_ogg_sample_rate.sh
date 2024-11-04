for file in $(find . -type f -name '*.ogg'); do
  sample_rate=$(ffprobe -v error -select_streams a:0 -show_entries stream=sample_rate -of default=noprint_wrappers=1:nokey=1 "$file")
  if [ "$sample_rate" != "44100" ]; then
    fail = true
    echo "Error: $file has sample rate $sample_rate Hz (expected 44100 Hz)"
    fi
    done
if(fail); then
  exit 1
echo "All OGG files have the correct sample rate."
