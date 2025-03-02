import os
import subprocess
import re

def get_lufs(file_path):
    """Gets the LUFS of an audio file using ffmpeg loudnorm filter."""
    try:
        # Ensure the file_path is an absolute path
        file_path = os.path.abspath(file_path)

        # Run the ffmpeg loudnorm filter and capture the output in stderr
        command = [
            'ffmpeg',
            '-i', file_path,
            '-filter_complex', 'loudnorm=print_format=summary',
            '-f', 'null', 'NUL'  # On Windows, use 'NUL' instead of '/dev/null'
        ]
        result = subprocess.run(command, capture_output=True, text=True)

        # The output of the ffmpeg command will be in stderr
        output = result.stderr

        # Look for the "input integrated:" (with or without the colon) in the output using updated regex
        match = re.search(r'input integrated:?\s*(-?\d+\.\d+)', output, re.IGNORECASE)
        if match:
            integrated_loudness = float(match.group(1))  # LUFS value
            return integrated_loudness
        else:
            print(f"Output didn't contain LUFS data: {output}")  # Print the output for debugging
            raise ValueError("Could not extract LUFS from the file.")

    except Exception as e:
        print(f"Error processing {file_path}: {e}")
        return None

def check_loudness(file_path):
    """Checks the loudness of an audio file and reports if it's within range."""
    lufs = get_lufs(file_path)
    if lufs is not None:
        print(f"File: {file_path}, LUFS: {lufs}")
        # include a 3 unit margin error
        if -26 <= lufs <= -20:
            print(f"{file_path}: Up to standard (LUFS: {lufs})\n")
        else:
            print(f"{file_path}: NOT up to standard (LUFS: {lufs})\n")
    else:
        print(f"Could not determine LUFS for {file_path}\n")

def check_folder_loudness(folder_path):
    """Checks the loudness of all audio files in the specified folder."""
    for root, dirs, files in os.walk(folder_path):
        for file in files:
            file_path = os.path.join(root, file)
            file_path = os.path.abspath(file_path)  # Convert relative path to absolute path
            print("File path after join is now:", file_path)

            # Process only audio files (you can modify this list to include more formats)
            if file.lower().endswith(('.mp3', '.wav', '.flac', '.ogg')):
                print("Now checking:", file_path)
                check_loudness(file_path)

if __name__ == "__main__":
    folder_path = input("Enter the folder path containing audio files: ")
    check_folder_loudness(folder_path)
