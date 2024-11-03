import os
from pydub.utils import mediainfo

def check_sample_rate(file_path):
    # Check if the sample rate of the .ogg file is 44.1 kHz.
    info = mediainfo(file_path)
    sample_rate = int(info['sample_rate'])
    return sample_rate == 44100

def find_bad_files(folder):
    # Recursively find .ogg files not at 44.1 kHz sample rate.
    bad_files = []
    for dirpath, _, filenames in os.walk(folder):
        for filename in filenames:
            if filename.lower().endswith('.ogg'):
                file_path = os.path.join(dirpath, filename)
                if not check_sample_rate(file_path):
                    bad_files.append(file_path)
    return bad_files

if __name__ == "__main__":
    folder_to_search = input("Enter the folder path to search: ")
    bad_files = find_bad_files(folder_to_search)
    print(folder_to_search)

    if bad_files:
        print("Files not at 44.1 kHz sample rate:")
        for file in bad_files:
            print(file)
        print("amount of files not at 44.1 kHz sample rate:",len(bad_files))
    else:
        print("All files are at 44.1 kHz sample rate.")
