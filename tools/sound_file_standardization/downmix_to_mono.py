import os
from pydub import AudioSegment

def downmix_to_mono(file_path):
    # Downmix stereo .ogg file to mono.
    try:
        audio = AudioSegment.from_file(file_path)
        if audio.channels != 1:  # Check if audio is not already mono
            mono_audio = audio.set_channels(1)
            mono_file_path = os.path.splitext(file_path)[0] + "_mono.ogg"
            mono_audio.export(mono_file_path, format="ogg")
            print(f"Converted {file_path} to {mono_file_path}")
    except Exception as e:
        print(f"Error processing {file_path}: {e}")

def process_directory(directory):
    # Recursively process directory to downmix .ogg files.
    for root, _, files in os.walk(directory):
        for file in files:
            if file.lower().endswith('.ogg'):
                file_path = os.path.join(root, file)
                downmix_to_mono(file_path)

if __name__ == "__main__":
    folder_path = input("Enter the path of the folder to process: ")
    process_directory(folder_path)
