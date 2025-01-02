# Directory with our sound files
DIRECTORY="./sound"

# LUFS range
MIN_LUFS=-25
MAX_LUFS=-20

# Arrays to store bad files and files with retrieval errors
BAD_FILES=()
RETRIEVAL_ERRORS=()

# Check if ffmpeg and ffmpeg-normalize are installed
command -v ffmpeg > /dev/null 2>&1 || { echo "ffmpeg is not installed. Please install it."; exit 1; }
command -v ffmpeg-normalize > /dev/null 2>&1 || { echo "ffmpeg-normalize is not installed. Please install it."; exit 1; }

# Iterate over .ogg files in the directory
for file in "$DIRECTORY"/*.ogg; do
  if [ -f "$file" ]; then
    echo "Checking LUFS for $file..."

    # Get LUFS value using ffmpeg-normalize
    lufs_value=$(ffmpeg-normalize "$file" -o /dev/null -a -1 -l -23 -v | grep -oP '(?<=Loudness: )[^\s]*')

    # If LUFS retrieval fails, add to retrieval error list
    if [ -z "$lufs_value" ]; then
      echo "Error: Could not retrieve LUFS for $file."
      RETRIEVAL_ERRORS+=("$file")
    else
      # Convert LUFS to a numeric value
      lufs_value=$(echo "$lufs_value" | awk '{print $1}')

      # Compare the LUFS value with the required range
      if (( $(echo "$lufs_value < $MIN_LUFS" | bc -l) )) || (( $(echo "$lufs_value > $MAX_LUFS" | bc -l) )); then
        echo "ERROR: LUFS for $file is $lufs_value, which is outside the acceptable range ($MIN_LUFS to $MAX_LUFS)."
        BAD_FILES+=("$file")
      else
        echo "SUCCESS: LUFS for $file is $lufs_value, which is within the acceptable range."
      fi
    fi
  fi
done

# Output bad files and retrieval errors
echo ""
if [ ${#BAD_FILES[@]} -gt 0 ]; then
  echo "The following files have LUFS outside the acceptable range ($MIN_LUFS to $MAX_LUFS):"
  for bad_file in "${BAD_FILES[@]}"; do
    echo "$bad_file"
  done
fi

if [ ${#RETRIEVAL_ERRORS[@]} -gt 0 ]; then
  echo "The following files had errors retrieving LUFS:"
  for error_file in "${RETRIEVAL_ERRORS[@]}"; do
    echo "$error_file"
  done
fi

# Exit with an appropriate status code after outputting the bad files if there are any
if [ ${#BAD_FILES[@]} -gt 0 ] || [ ${#RETRIEVAL_ERRORS[@]} -gt 0 ]; then
  exit 1
else
  echo "All checks passed!"
  exit 0
fi
