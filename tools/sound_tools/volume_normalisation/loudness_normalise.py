import os
import subprocess
import re
import tempfile
import time
import shutil

def get_sample_rate(file_path):
    """Gets the sample rate of an audio file using ffprobe."""
    try:
        # Run ffprobe to get the sample rate
        command = [
            'ffprobe',
            '-v', 'error',  # Suppress unnecessary output
            '-select_streams', 'a:0',  # Select the first audio stream
            '-show_entries', 'stream=sample_rate',  # Show only the sample rate
            '-of', 'default=noprint_wrappers=1:nokey=1',  # Clean output format
            file_path
        ]
        result = subprocess.run(command, capture_output=True, text=True)

        sample_rate = result.stdout.strip()

        if sample_rate:
            return int(sample_rate)
        else:
            print(f"Could not extract sample rate from {file_path}")
            return None

    except Exception as e:
        print(f"Error getting sample rate for {file_path}: {e}")
        return None

def get_lufs(file_path):
    """Gets the LUFS of an audio file using ffmpeg loudnorm filter."""
    try:
        # Run the ffmpeg loudnorm filter and capture the output in stderr
        command = [
            'ffmpeg',
            '-i', file_path,
            '-filter_complex', 'loudnorm=print_format=summary',
            '-f', 'null', '/dev/null'
        ]
        result = subprocess.run(command, capture_output=True, text=True)

        # The output of the ffmpeg command will be in stderr
        output = result.stderr

        # Look for the "input integrated:" in the output using updated regex
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

def normalize_loudness(file_path, target_lufs=-23):
    """Normalizes the loudness of an audio file to the target LUFS using ffmpeg."""
    try:
        # Get the current LUFS of the file
        current_lufs = get_lufs(file_path)

        if current_lufs is None:
            return False

        # Get the original sample rate
        sample_rate = get_sample_rate(file_path)
        if sample_rate is None:
            return False

        # Calculate the difference between current LUFS and target LUFS
        loudness_diff = target_lufs - current_lufs

        # Create a temporary file to save the normalized version
        temp_file = tempfile.NamedTemporaryFile(delete=False, suffix=".ogg")

        # Run the ffmpeg loudnorm filter to normalize the loudness
        command = [
            'ffmpeg',
            '-i', file_path,
            '-af', f'loudnorm=I={target_lufs}:TP=-1.0:LRA=11.0',
            '-ar', str(sample_rate),  # Use the original sample rate
            '-map_metadata', '0',  # Copy metadata from the input file
            '-y',  # overwrites the previous file
            temp_file.name
        ]
        subprocess.run(command, check=True)

        # Close the temporary file and ensure it's not in use
        temp_file.close()

        # Introduce a short delay to ensure the temporary file is fully released
        time.sleep(0.5)

        # Replace the original file with the normalized version using shutil.move
        shutil.move(temp_file.name, file_path)

        print(f"Normalized {file_path} to {target_lufs} LUFS with sample rate {sample_rate} Hz.")
        return True

    except Exception as e:
        print(f"Error normalizing {file_path}: {e}")
        return False

def process_folder(folder_path):
    """Process all audio files in the folder and normalize them to -23 LUFS."""
    for root, dirs, files in os.walk(folder_path):
        for file in files:
            file_path = os.path.join(root, file)

            # Process only audio files (you can modify this list to include more formats)
            if file.lower().endswith(('.mp3', '.wav', '.flac', '.ogg')):
                success = normalize_loudness(file_path)
                if not success:
                    print(f"Failed to normalize {file_path}")

if __name__ == "__main__":
    folder_path = input("Enter the folder path containing audio files: ")
    process_folder(folder_path)
