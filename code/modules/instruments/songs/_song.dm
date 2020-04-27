#define MUSICIAN_HEARCHECK_MINDELAY 4
#define MUSIC_MAXLINES 1000
#define MUSIC_MAXLINECHARS 300

/**
  * # Song datum
  *
  * These are the actual backend behind instruments.
  * They attach to an atom and provide the editor + playback functionality.
  */
/datum/song
	/// Name of the song
	var/name = "Untitled"

	/// The atom we're attached to/playing from
	var/atom/parent

	/// Our song lines
	var/list/lines

	/// delay between notes in deciseconds
	var/tempo = 5

	/// How far we can be heard
	var/instrument_range = 15

	/// Are we currently playing?
	var/playing = FALSE

	/// Are we currently editing?
	var/editing = TRUE
	/// Is the help screen open?
	var/help = FALSE

	/// Repeats left
	var/repeat = 0
	/// Maximum times we can repeat
	var/max_repeats = 10

	/// Our volume
	var/volume = 75
	/// Max volume
	var/max_volume = 75
	/// Min volume - This is so someone doesn't decide it's funny to set it to 0 and play invisible songs.
	var/min_volume = 1

	/// What instruments our built in picker can use. The picker won't show unless this is longer than one.
	var/list/allowed_instrument_ids = list("r3grand")

	//////////// Cached instrument variables /////////////
	/// Instrument we are currently using
	var/datum/instrument/using_instrument
	/// Cached legacy ext for legacy instruments
	var/cached_legacy_ext
	/// Cached legacy dir for legacy instruments
	var/cached_legacy_dir
	/// Cached list of samples, referenced directly from the instrument for synthesized instruments
	var/list/cached_samples
	/// Are we operating in legacy mode (so if the instrument is a legacy instrument)
	var/legacy = FALSE
	//////////////////////////////////////////////////////

	/////////////////// Playing variables ////////////////
	/**
	  * Only used in synthesized playback - The chords we compiled. Non assoc list of lists:
	  * list(list(key1, key2, key3..., tempo_divisor), list(key1, key2..., tempo_divisor), ...)
	  * tempo_divisor always exists
	  * if key1 (and so if there's no keys) doesn't exist it's a rest
	  * Compilation happens when we start playing and is cleared after we finish playing.
	  */
	var/list/compiled_chords
	/// Channel as text = current volume percentage but it's 0 to 100 instead of 0 to 1.
	var/list/channels_playing = list()
	/// List of channels that aren't being used, as text. This is to prevent unnecessary freeing and reallocations from SSsounds/SSinstruments.
	var/list/channels_idle = list()
	//////////////////////////////////////////////////////

	/// Last world.time we checked for who can hear us
	var/last_hearcheck = 0
	/// The list of mobs that can hear us
	var/list/hearing_mobs
	/// If this is enabled, some things won't be strictly cleared when they usually are (liked compiled_chords on play stop)
	var/debug_mode = FALSE
	/// Last time we processed decay
	var/last_process_decay
	/// Max sound channels to occupy
	var/max_sound_channels = CHANNELS_PER_INSTRUMENT
	/// Current channels, so we can save a length() call.
	var/using_sound_channels = 0
	/// Last channel to play. text.
	var/last_channel_played
	/// Should we not decay our last played note?
	var/full_sustain_held_note = TRUE

	/////////////////////// DO NOT TOUCH THESE ///////////////////
	var/octave_min = INSTRUMENT_MIN_OCTAVE
	var/octave_max = INSTRUMENT_MAX_OCTAVE
	var/key_min = INSTRUMENT_MIN_KEY
	var/key_max = INSTRUMENT_MAX_KEY
	var/static/list/note_offset_lookup = list(9, 11, 0, 2, 4, 5, 7)
	var/static/list/accent_lookup = list("b" = -1, "s" = 1, "#" = 1, "n" = 0)
	//////////////////////////////////////////////////////////////

	///////////// !!FUN!! - Only works in synthesized mode! /////////////////
	/// Note numbers to shift.
	var/note_shift = 0
	var/note_shift_min = -100
	var/note_shift_max = 100
	var/can_noteshift = TRUE
	/// The kind of sustain we're using
	var/sustain_mode = SUSTAIN_LINEAR
	/// When a note is considered dead if it is below this in volume
	var/sustain_dropoff_volume = 0
	/// Total duration of linear sustain for 100 volume note to get to SUSTAIN_DROPOFF
	var/sustain_linear_duration = 5
	/// Exponential sustain dropoff rate per decisecond
	var/sustain_exponential_dropoff = 1.4
	////////// DO NOT DIRECTLY SET THESE!
	/// Do not directly set, use update_sustain()
	var/cached_linear_dropoff = 10
	/// Do not directly set, use update_sustain()
	var/cached_exponential_dropoff = 1.045
	/////////////////////////////////////////////////////////////////////////

/datum/song/New(atom/parent, list/instrument_ids, new_range)
	SSinstruments.on_song_new(src)
	lines = list()
	tempo = sanitize_tempo(tempo)
	src.parent = parent
	if(instrument_ids)
		allowed_instrument_ids = islist(instrument_ids)? instrument_ids : list(instrument_ids)
	if(length(allowed_instrument_ids))
		set_instrument(allowed_instrument_ids[1])
	hearing_mobs = list()
	volume = clamp(volume, min_volume, max_volume)
	update_sustain()
	if(new_range)
		instrument_range = new_range

/datum/song/Destroy()
	stop_playing()
	SSinstruments.on_song_del(src)
	lines = null
	using_instrument = null
	allowed_instrument_ids = null
	parent = null
	return ..()

/**
  * Checks and stores which mobs can hear us. Terminates sounds for mobs that leave our range.
  */
/datum/song/proc/do_hearcheck()
	last_hearcheck = world.time
	var/list/old = hearing_mobs.Copy()
	hearing_mobs.len = 0
	var/turf/source = get_turf(parent)
	for(var/mob/M in get_hearers_in_view(instrument_range, source))
		hearing_mobs[M] = get_dist(M, source)
	var/list/exited = old - hearing_mobs
	for(var/i in exited)
		terminate_sound_mob(i)

/**
  * Sets our instrument, caching anything necessary for faster accessing. Accepts an ID, typepath, or instantiated instrument datum.
  */
/datum/song/proc/set_instrument(datum/instrument/I)
	if(using_instrument)
		using_instrument.songs_using -= src
	using_instrument = null
	cached_samples = null
	cached_legacy_ext = null
	cached_legacy_dir = null
	legacy = null
	if(istext(I) || ispath(I))
		I = SSinstruments.instrument_data[I]
	if(istype(I))
		using_instrument = I
		I.songs_using += src
		var/instrument_legacy = (I.instrument_flags & INSTRUMENT_LEGACY)
		if(instrument_legacy)
			cached_legacy_ext = I.legacy_instrument_ext
			cached_legacy_dir = I.legacy_instrument_path
			legacy = TRUE
		else
			cached_samples = I.samples
			legacy = FALSE

/**
  * Attempts to start playing our song.
  */
/datum/song/proc/start_playing(mob/user)
	if(playing)
		return
	if(!using_instrument?.ready())
		to_chat(user, "<span class='warning'>An error has occured with [src]. Please reset the instrument.</span>")
		return
	playing = TRUE
	updateDialog()
	//we can not afford to runtime, since we are going to be doing sound channel reservations and if we runtime it means we have a channel allocation leak.
	//wrap the rest of the stuff to ensure stop_playing() is called.
	last_process_decay = world.time
	START_PROCESSING(SSinstruments, src)
	SEND_SIGNAL(parent, COMSIG_SONG_START)
	. = do_play_lines(user)
	stop_playing()

/**
  * Stops playing, terminating all sounds if in synthesized mode. Clears hearing_mobs.
  */
/datum/song/proc/stop_playing()
	if(!playing)
		return
	playing = FALSE
	if(!debug_mode)
		compiled_chords = null
	STOP_PROCESSING(SSinstruments, src)
	SEND_SIGNAL(parent, COMSIG_SONG_END)
	terminate_all_sounds(TRUE)
	hearing_mobs.len = 0
	updateDialog()

/**
  * The actual blocking proc for playing. Uses legacy vs synthesized based on what kind of instrument we're using.
  */
/datum/song/proc/do_play_lines(user)
	if(!playing)
		return
	do_hearcheck()
	if(legacy)
		do_play_lines_legacy(user)
	else
		do_play_lines_synthesized(user)

/**
  * Checks if we should halt playback.
  */
/datum/song/proc/should_stop_playing(mob/user)
	return QDELETED(parent) || !using_instrument || !playing

/**
  * Sanitizes tempo to a value that makes sense and fits the current world.tick_lag.
  */
/datum/song/proc/sanitize_tempo(new_tempo)
	new_tempo = abs(new_tempo)
	return clamp(round(new_tempo, world.tick_lag), world.tick_lag, 5 SECONDS)

/**
  * Gets our beats per minute based on our tempo.
  */
/datum/song/proc/get_bpm()
	return 600 / tempo

/**
  * Sets our tempo from a beats-per-minute, sanitizing it to a valid number first.
  */
/datum/song/proc/set_bpm(bpm)
	tempo = sanitize_tempo(600 / bpm)

/**
  * Updates the window for our users. Override down the line.
  */
/datum/song/proc/updateDialog(mob/user)
	ui_interact(user)

/datum/song/process(wait)
	if(!playing)
		return PROCESS_KILL
	var/delay = world.time - last_process_decay
	process_decay(delay)
	last_process_decay = world.time

/**
  * Updates our cached linear/exponential falloff stuff, saving calculations down the line.
  */
/datum/song/proc/update_sustain()
	// Exponential is easy
	cached_exponential_dropoff = sustain_exponential_dropoff
	// Linear, not so much, since it's a target duration from 100 volume rather than an exponential rate.
	var/target_duration = sustain_linear_duration
	var/volume_diff = max(0, 100 - sustain_dropoff_volume)
	var/volume_decrease_per_decisecond = volume_diff / target_duration
	cached_linear_dropoff = volume_decrease_per_decisecond

/**
  * Setter for setting output volume.
  */
/datum/song/proc/set_volume(volume)
	src.volume = clamp(volume, max(0, min_volume), min(100, max_volume))
	update_sustain()
	updateDialog()

/**
  * Setter for setting how low the volume has to get before a note is considered "dead" and dropped
  */
/datum/song/proc/set_dropoff_volume(volume)
	sustain_dropoff_volume = clamp(volume, INSTRUMENT_MIN_SUSTAIN_DROPOFF, 100)
	update_sustain()
	updateDialog()

/**
  * Setter for setting exponential falloff factor.
  */
/datum/song/proc/set_exponential_drop_rate(drop)
	sustain_exponential_dropoff = clamp(drop, INSTRUMENT_EXP_FALLOFF_MIN, INSTRUMENT_EXP_FALLOFF_MAX)
	update_sustain()
	updateDialog()

/**
  * Setter for setting linear falloff duration.
  */
/datum/song/proc/set_linear_falloff_duration(duration)
	sustain_linear_duration = clamp(duration, 0.1, INSTRUMENT_MAX_TOTAL_SUSTAIN)
	update_sustain()
	updateDialog()

/datum/song/vv_edit_var(var_name, var_value)
	. = ..()
	if(.)
		switch(var_name)
			if(NAMEOF(src, volume))
				set_volume(var_value)
			if(NAMEOF(src, sustain_dropoff_volume))
				set_dropoff_volume(var_value)
			if(NAMEOF(src, sustain_exponential_dropoff))
				set_exponential_drop_rate(var_value)
			if(NAMEOF(src, sustain_linear_duration))
				set_linear_falloff_duration(var_value)

// subtype for handheld instruments, like violin
/datum/song/handheld

/datum/song/handheld/updateDialog(mob/user)
	parent.ui_interact(user || usr)

/datum/song/handheld/should_stop_playing(mob/user)
	. = ..()
	if(.)
		return TRUE
	var/obj/item/instrument/I = parent
	return I.should_stop_playing(user)

// subtype for stationary structures, like pianos
/datum/song/stationary

/datum/song/stationary/updateDialog(mob/user)
	parent.ui_interact(user || usr)

/datum/song/stationary/should_stop_playing(mob/user)
	. = ..()
	if(.)
		return TRUE
	var/obj/structure/musician/M = parent
	return M.should_stop_playing(user)
