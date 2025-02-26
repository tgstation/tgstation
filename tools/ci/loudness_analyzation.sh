#!/bin/bash

# Directory with sound files
DIRECTORY="./sound"

# LUFS range
MIN_LUFS=-24
MAX_LUFS=-21

# Arrays to store bad files and retrieval errors
BAD_FILES=()
RETRIEVAL_ERRORS=()

# Enable nullglob to prevent errors if no files match
shopt -s nullglob

# Check if ffmpeg is installed
command -v ffmpeg > /dev/null 2>&1 || { echo "ffmpeg is not installed. Please install it."; exit 1; }

# Iterate over .ogg files, handling filenames with spaces
find "$DIRECTORY" -type f -name "*.ogg" -print0 | while IFS= read -r -d '' file; do
  echo "Checking LUFS for $file..."

  # Extract LUFS value using ffmpeg
  lufs_output=$(ffmpeg -i "$file" -filter_complex ebur128 -f null - 2>&1)

  # Check if ffmpeg failed
  if [[ "$lufs_output" == *"error"* ]]; then
    echo "Error: Could not analyze LUFS for $file."
    RETRIEVAL_ERRORS+=("$file")
    continue
  fi

  # Extract LUFS value
  lufs_value=$(echo "$lufs_output" | awk '/I:/{print $2; exit}')

  # Debugging output
  echo "Extracted LUFS: $lufs_value"

  # Check if LUFS retrieval was successful
  if [ -z "$lufs_value" ] || [ "$lufs_value" == "-70.0" ]; then
    echo "Error: Invalid LUFS value for $file."
    RETRIEVAL_ERRORS+=("$file")
    continue
  fi

  # Compare LUFS value with the required range
  if awk "BEGIN {exit !($lufs_value < $MIN_LUFS || $lufs_value > $MAX_LUFS)}"; then
    echo "ERROR: LUFS for $file is $lufs_value, outside the acceptable range ($MIN_LUFS to $MAX_LUFS)."
    BAD_FILES+=("$file")
  else
    echo "SUCCESS: LUFS for $file is $lufs_value, within the acceptable range."
  fi
done

# Output results
echo ""
if [ ${#BAD_FILES[@]} -gt 0 ]; then
  echo "The following files have LUFS outside the acceptable range ($MIN_LUFS to $MAX_LUFS):"
  printf '%s\n' "${BAD_FILES[@]}"
fi

if [ ${#RETRIEVAL_ERRORS[@]} -gt 0 ]; then
  echo "The following files had errors retrieving LUFS:"
  printf '%s\n' "${RETRIEVAL_ERRORS[@]}"
fi

# Debugging info
echo "BAD_FILES count: ${#BAD_FILES[@]}"
echo "RETRIEVAL_ERRORS count: ${#RETRIEVAL_ERRORS[@]}"

# Exit with an appropriate status code
if [ ${#BAD_FILES[@]} -gt 0 ] || [ ${#RETRIEVAL_ERRORS[@]} -gt 0 ]; then
  echo "Some files are outside the acceptable LUFS range or had retrieval errors."
  exit 1
else
  echo "All files passed LUFS normalization checks!"
  exit 0
fi
