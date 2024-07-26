PROCESSING_SUBSYSTEM_DEF(instruments)
	name = "Instruments"
	wait = 0.5
	init_order = INIT_ORDER_INSTRUMENTS
	flags = SS_KEEP_TIMING
	priority = FIRE_PRIORITY_INSTRUMENTS
	/// List of all instrument data, associative id = datum
	var/static/list/datum/instrument/instrument_data = list()
	/// List of all song datums.
	var/static/list/datum/song/songs = list()
	/// Max lines in songs
	var/static/musician_maxlines = 600
	/// Max characters per line in songs
	var/static/musician_maxlinechars = 300
	/// Deciseconds between hearchecks. Too high and instruments seem to lag when people are moving around in terms of who can hear it. Too low and the server lags from this.
	var/static/musician_hearcheck_mindelay = 5
	/// Maximum instrument channels total instruments are allowed to use. This is so you don't have instruments deadlocking all sound channels.
	var/static/max_instrument_channels = MAX_INSTRUMENT_CHANNELS
	/// Current number of channels allocated for instruments
	var/static/current_instrument_channels = 0
	/// Single cached list for synthesizer instrument ids, so you don't have to have a new list with every synthesizer.
	var/static/list/synthesizer_instrument_ids
	var/static/list/note_sustain_modes = list(
		SUSTAIN_LINEAR,
		SUSTAIN_EXPONENTIAL,
	)

/datum/controller/subsystem/processing/instruments/Initialize()
	initialize_instrument_data()
	synthesizer_instrument_ids = get_allowed_instrument_ids()
	return SS_INIT_SUCCESS

/datum/controller/subsystem/processing/instruments/proc/on_song_new(datum/song/S)
	songs += S

/datum/controller/subsystem/processing/instruments/proc/on_song_del(datum/song/S)
	songs -= S

/datum/controller/subsystem/processing/instruments/proc/initialize_instrument_data()
	for(var/path in subtypesof(/datum/instrument))
		var/datum/instrument/I = path
		if(initial(I.abstract_type) == path)
			continue
		I = new path
		I.Initialize()
		if(!I.id)
			qdel(I)
			continue
		instrument_data[I.id] = I
		CHECK_TICK

/datum/controller/subsystem/processing/instruments/proc/get_instrument(id_or_path)
	return instrument_data["[id_or_path]"]

/datum/controller/subsystem/processing/instruments/proc/reserve_instrument_channel(datum/instrument/I)
	if(current_instrument_channels > max_instrument_channels)
		return
	. = SSsounds.reserve_sound_channel(I)
	if(!isnull(.))
		current_instrument_channels++
