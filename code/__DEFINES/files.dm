/// Not a complete list of all valid sounds but all of them work with rustg_sound_length
#define IS_SOUND_FILE(file) is_file_type_in_list(##file, list(".ogg", ".wav", ".mp3"))

#define IS_SOUND_FILE_COMPLETE(file) is_file_type_in_list(##file, SSsounds.valid_file_extensions)

#define IS_OGG_FILE(file) is_file_type(##file, ".ogg")
#define IS_WAV_FILE(file) is_file_type(##file, ".wav")
#define IS_MP3_FILE(file) is_file_type(##file, ".mp3")
