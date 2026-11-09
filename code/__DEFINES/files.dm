// None of these should be trusted for the purpose of user input
// They do not check the actual type of the file, a user could just rename it

/// File types we can sniff the duration from using rustg.
#define IS_SOUND_FILE_SAFE(file) is_file_type_in_list(##file, SSsounds.safe_formats)

#define IS_SOUND_FILE(file) is_file_type_in_list(##file, SSsounds.byond_sound_formats)

#define IS_OGG_FILE(file) is_file_type(##file, "ogg")
#define IS_WAV_FILE(file) is_file_type(##file, "wav")
#define IS_MP3_FILE(file) is_file_type(##file, "mp3")
