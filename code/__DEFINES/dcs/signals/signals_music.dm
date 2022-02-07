// /datum/song signals

///sent to the instrument when a song starts playing
#define COMSIG_SONG_START "song_start"
///sent to the instrument when a song stops playing
#define COMSIG_SONG_END "song_end"
///sent to the instrument on /should_stop_playing(): (atom/player). Return values can be found in DEFINES/song.dm
#define COMSIG_SONG_SHOULD_STOP_PLAYING "song_should_stop_playing"
///sent to the instrument (and player if available) when a song repeats (datum/song)
#define COMSIG_SONG_REPEAT	"song_repeat"
