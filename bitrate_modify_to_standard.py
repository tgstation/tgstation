import os
from pydub import AudioSegment

def convert_ogg_sampling_rate(directory):
    # Traverse the directory recursively
    for root, _, files in os.walk(directory):
        root = root
        for file in files:
            if file.endswith('.ogg'):
                ogg_path = os.path.join(root, file)
                print(f'Processing {ogg_path}')

                # Load the OGG file
                audio = AudioSegment.from_ogg(ogg_path)

                # Set the sample rate to 41.1 kHz
                audio = audio.set_frame_rate(44100)

                # Export the modified audio
                audio.export(ogg_path, format='ogg')
                print(f'Converted {file} to 41.1 kHz')

if __name__ == "__main__":
    directory = input("Enter the directory path: ")
    convert_ogg_sampling_rate(directory)
