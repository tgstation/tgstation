// /datum/song signals

///sent to the instrument when a song starts playing
#define COMSIG_INSTRUMENT_START "instrument_start"
///sent to the instrument when a song stops playing
#define COMSIG_INSTRUMENT_END "instrument_end"
///sent to the instrument on /should_stop_playing(): (atom/player). Return values can be found in DEFINES/song.dm
#define COMSIG_INSTRUMENT_SHOULD_STOP_PLAYING "instrument_should_stop_playing"
///sent to the instrument (and player if available) when a song repeats (datum/song)
#define COMSIG_INSTRUMENT_REPEAT "instrument_repeat"
///sent to the instrument when tempo changes, skipped on new. (datum/song)
#define COMSIG_INSTRUMENT_TEMPO_CHANGE "instrument_tempo_change"
