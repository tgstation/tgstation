#define DATUMLESS "NO_DATUM"

SUBSYSTEM_DEF(sounds)
	name = "Sounds"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_SOUNDS
	var/static/using_channels_max = CHANNEL_HIGHEST_AVAILABLE		//BYOND max channels

	// Hey uh these two needs to be initialized fast because the whole "things get deleted before init" thing.
	/// Assoc list, "[channel]" = either the datum using it or TRUE for an unsafe-reserved (datumless reservation) channel
	var/list/using_channels = list()
	/// Assoc list datum = list(channel1, channel2, ...) for what channels something reserved.
	var/list/using_channels_by_datum = list()
	/// List of all available channels with associations set to TRUE for fast lookups/allocation.
	var/list/available_channels

/datum/controller/subsystem/sounds/Initialize()
	setup_available_channels()
	return ..()

/datum/controller/subsystem/sounds/proc/setup_available_channels()
	available_channels = list()
	for(var/i in 1 to using_channels_max)
		available_channels[num2text(i)] = TRUE

/// Removes a channel from using list.
/datum/controller/subsystem/sounds/proc/free_sound_channel(channel)
	channel = num2text(channel)
	var/using = using_channels[channel]
	using_channels -= channel
	if(using)
		using_channels_by_datum[using] -= channel
		if(!length(using_channels_by_datum[using]))
			using_channels_by_datum -= using
	available_channels[channel] = TRUE

/// Frees all the channels a datum is using.
/datum/controller/subsystem/sounds/proc/free_datum_channels(datum/D)
	var/list/L = using_channels_by_datum[D]
	if(!L)
		return
	for(var/channel in L)
		using_channels -= channel
		available_channels[channel] = TRUE
	using_channels_by_datum -= D

/// Frees all datumless channels
/datum/controller/subsystem/sounds/proc/free_datumless_channels()
	free_datum_channels(DATUMLESS)

/// NO AUTOMATIC CLEANUP - If you use this, you better manually free it later! Returns an integer for channel.
/datum/controller/subsystem/sounds/proc/reserve_sound_channel_datumless()
	var/channel = random_available_channel_text()
	if(!channel)		//oh no..
		return FALSE
	available_channels -= channel
	using_channels[channel] = DATUMLESS
	LAZYINITLIST(using_channels_by_datum[DATUMLESS])
	using_channels_by_datum[DATUMLESS] += channel
	return text2num(channel)

/// Reserves a channel for a datum. Automatic cleanup only when the datum is deleted. Returns an integer for channel.
/datum/controller/subsystem/sounds/proc/reserve_sound_channel(datum/D)
	if(!D)		//i don't like typechecks but someone will fuck it up
		CRASH("Attempted to reserve sound channel without datum using the managed proc.")
	var/channel = random_available_channel_text()
	if(!channel)
		return FALSE
	available_channels -= channel
	using_channels[channel] = D
	LAZYINITLIST(using_channels_by_datum[D])
	using_channels_by_datum[D] += channel
	return text2num(channel)

/// Random available channel, returns text.
/datum/controller/subsystem/sounds/proc/random_available_channel_text()
	return pick(available_channels)

/// Random available channel, returns number
/datum/controller/subsystem/sounds/proc/random_available_channel()
	return text2num(pick(available_channels))

/// If a channel is available
/datum/controller/subsystem/sounds/proc/is_channel_available(channel)
	return available_channels[num2text(channel)]

/// How many channels we have left.
/datum/controller/subsystem/sounds/proc/available_channels_left()
	return length(available_channels)

#undef DATUMLESS
