import os
import subprocess
import tempfile
import shutil

def get_metadata(file_path):
    """Extract metadata from an audio file using ffmpeg."""
    try:
        # Extract metadata using ffmpeg
        command = [
            'ffmpeg',
            '-i', file_path,
            '-f', 'ffmetadata',
            '-y',  # Overwrite output if it exists
            'metadata.txt'
        ]
        subprocess.run(command, check=True, capture_output=True)

        # Read the metadata from the file
        with open('metadata.txt', 'r') as f:
            metadata = f.read()

        # Clean up temporary metadata file
        os.remove('metadata.txt')

        return metadata

    except Exception as e:
        print(f"Error extracting metadata from {file_path}: {e}")
        return None

def normalize_loudness(file_path, target_lufs=-23):
    """Normalizes the loudness of an audio file to the target LUFS using ffmpeg."""
    try:
        # Extract metadata from the original file
        metadata = get_metadata(file_path)

        # Create a temporary file to save the normalized version
        temp_file = tempfile.NamedTemporaryFile(delete=False, suffix=".ogg")

        # Apply the loudnorm filter to normalize the audio
        command = [
            'ffmpeg',
            '-i', file_path,
            '-filter_complex', f'loudnorm=I={target_lufs}:TP=-1.0:LRA=11.0',
            '-c:a', 'libvorbis',  # Re-encode the audio to the same format
            '-ar', '44100',  # Make sure the sample rate remains the same (you can change if needed)
            '-y',  # Overwrite the output file
            temp_file.name
        ]
        subprocess.run(command, check=True)

        # If metadata was extracted, write it to the new temporary file
        if metadata:
            with open('metadata.txt', 'w') as f:
                f.write(metadata)

            # Use ffmpeg to copy the metadata to the newly processed file
            command = [
                'ffmpeg',
                '-i', temp_file.name,
                '-i', 'metadata.txt',
                '-map_metadata', '1',  # Use the second input (metadata file)
                '-c', 'copy',  # Copy the streams (no re-encoding needed)
                '-y',  # Overwrite the output file
                temp_file.name
            ]
            subprocess.run(command, check=True)

            # Clean up temporary metadata file
            os.remove('metadata.txt')

        # Define the root folder and create a 'processed' folder at the root
        root_folder = os.path.dirname(folder_path)
        processed_folder = os.path.join(root_folder, 'processed')
        os.makedirs(processed_folder, exist_ok=True)

        # Define the path for the copied and processed file
        output_file_path = os.path.join(processed_folder, os.path.basename(file_path))

        # Move the processed file to the new folder
        shutil.move(temp_file.name, output_file_path)

        print(f"Normalized {file_path} to {target_lufs} LUFS and copied to {output_file_path}.")
        return True

    except Exception as e:
        print(f"Error normalizing {file_path}: {e}")
        return False

def process_folder(folder_path):
    """Process all .ogg files in the folder and normalize them to -23 LUFS."""
    for root, dirs, files in os.walk(folder_path):
        for file in files:
            file_path = os.path.join(root, file)

            # Process only .ogg files
            if file.lower().endswith('.ogg'):
                success = normalize_loudness(file_path)
                if not success:
                    print(f"Failed to normalize {file_path}")

if __name__ == "__main__":
    folder_path = input("Enter the folder path containing .ogg audio files: ")
    process_folder(folder_path)
