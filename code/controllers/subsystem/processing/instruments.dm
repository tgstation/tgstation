PROCESSING_SUBSYSTEM_DEF(instruments)
	name = "Instruments"
	wait = 0.5
	init_order = INIT_ORDER_INSTRUMENTS
	flags = SS_KEEP_TIMING
	priority = FIRE_PRIORITY_INSTRUMENTS
	var/static/list/datum/instrument/instrument_data = list()		//id = datum
	var/static/list/datum/song/songs = list()
	var/static/musician_maxlines = 600
	var/static/musician_maxlinechars = 300
	var/static/musician_hearcheck_mindelay = 5
	var/static/max_instrument_channels = MAX_INSTRUMENT_CHANNELS
	var/static/current_instrument_channels = 0

/datum/controller/subsystem/processing/instruments/Initialize()
	initialize_instrument_data()
	return ..()

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
		instrument_data[I.id || "[I.type]"] = I
		CHECK_TICK

/datum/controller/subsystem/processing/instruments/proc/get_instrument(id_or_path)
	return instrument_data["[id_or_path]"]

/datum/controller/subsystem/processing/instruments/proc/reserve_instrument_channel(datum/instrument/I)
	if(current_instrument_channels > max_instrument_channels)
		return
	. = SSsounds.reserve_sound_channel(I)
	if(!isnull(.))
		current_instrument_channels++
