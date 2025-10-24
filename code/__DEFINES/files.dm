// I would include .mp3 in this but valid_file_extensions does not have it which scares me
/// Not a complete list of all valid sounds but all of them work with rustg_sound_length
#define IS_SOUND_FILE(file) is_file_type_in_list(##file, list(".ogg", ".wav"))
#define IS_OGG_FILE(file) is_file_type(##file, ".ogg")
#define IS_WAV_FILE(file) is_file_type(##file, ".wav")
