#define DATUMLESS "NO_DATUM"

SUBSYSTEM_DEF(sounds)
	name = "Sounds"
	flags = SS_NO_FIRE
	init_stage = INITSTAGE_EARLY
	var/static/using_channels_max = CHANNEL_HIGHEST_AVAILABLE //BYOND max channels
	/// Amount of channels to reserve for random usage rather than reservations being allowed to reserve all channels. Also a nice safeguard for when someone screws up.
	var/static/random_channels_min = 50

	// Hey uh these two needs to be initialized fast because the whole "things get deleted before init" thing.
	/// Assoc list, `"[channel]" =` either the datum using it or TRUE for an unsafe-reserved (datumless reservation) channel
	var/list/using_channels
	/// Assoc list datum = list(channel1, channel2, ...) for what channels something reserved.
	var/list/using_channels_by_datum
	// Special datastructure for fast channel management
	/// List of all channels as numbers
	var/list/channel_list
	/// Associative list of all reserved channels associated to their position. `"[channel_number]" =` index as number
	var/list/reserved_channels
	/// lower iteration position - Incremented and looped to get "random" sound channels for normal sounds. The channel at this index is returned when asking for a random channel.
	var/channel_random_low
	/// higher reserve position - decremented and incremented to reserve sound channels, anything above this is reserved. The channel at this index is the highest unreserved channel.
	var/channel_reserve_high

	/// All valid sound files in the sound directory
	var/list/all_sounds

	// || Sound caching ||
	/// k:v list of file_path : length
	VAR_PRIVATE/list/sound_lengths
	/// A list of sounds to cache upon initialize.
	VAR_PRIVATE/list/sounds_to_precache = list()
	/// Any errors from precaching.
	VAR_PRIVATE/list/precache_errors = list()

/datum/controller/subsystem/sounds/Initialize()
	setup_available_channels()
	find_all_available_sounds()

	if(!(RUST_G))
		to_chat(world, span_boldnotice("Sounds subsystem: No rust_g detected."))
		return ..()

	// Precache ambience sounds
	for(var/key in GLOB.ambience_assoc)
		sounds_to_precache |= GLOB.ambience_assoc[key]

	precache_sounds()

	return SS_INIT_SUCCESS

/datum/controller/subsystem/sounds/proc/setup_available_channels()
	channel_list = list()
	reserved_channels = list()
	using_channels = list()
	using_channels_by_datum = list()
	for(var/i in 1 to using_channels_max)
		channel_list += i
	channel_random_low = 1
	channel_reserve_high = length(channel_list)

/datum/controller/subsystem/sounds/proc/find_all_available_sounds()
	all_sounds = list()
	// Put more common extensions first to speed this up a bit
	var/static/list/valid_file_extensions = list(
		".ogg",
		".wav",
		".mid",
		".midi",
		".mod",
		".it",
		".s3m",
		".xm",
		".oxm",
		".raw",
		".wma",
		".aiff",
	)

	all_sounds = pathwalk("sound/", valid_file_extensions)

/// Removes a channel from using list.
/datum/controller/subsystem/sounds/proc/free_sound_channel(channel)
	var/text_channel = num2text(channel)
	var/using = using_channels[text_channel]
	using_channels -= text_channel
	if(using != TRUE) // datum channel
		using_channels_by_datum[using] -= channel
		if(!length(using_channels_by_datum[using]))
			using_channels_by_datum -= using
	free_channel(channel)

/// Frees all the channels a datum is using.
/datum/controller/subsystem/sounds/proc/free_datum_channels(datum/D)
	var/list/L = using_channels_by_datum[D]
	if(!L)
		return
	for(var/channel in L)
		using_channels -= num2text(channel)
		free_channel(channel)
	using_channels_by_datum -= D

/// Frees all datumless channels
/datum/controller/subsystem/sounds/proc/free_datumless_channels()
	free_datum_channels(DATUMLESS)

/// NO AUTOMATIC CLEANUP - If you use this, you better manually free it later! Returns an integer for channel.
/datum/controller/subsystem/sounds/proc/reserve_sound_channel_datumless()
	. = reserve_channel()
	if(!.) //oh no..
		return FALSE
	var/text_channel = num2text(.)
	using_channels[text_channel] = DATUMLESS
	LAZYINITLIST(using_channels_by_datum[DATUMLESS])
	using_channels_by_datum[DATUMLESS] += .

/// Reserves a channel for a datum. Automatic cleanup only when the datum is deleted. Returns an integer for channel.
/datum/controller/subsystem/sounds/proc/reserve_sound_channel(datum/D)
	if(!D) //i don't like typechecks but someone will fuck it up
		CRASH("Attempted to reserve sound channel without datum using the managed proc.")
	.= reserve_channel()
	if(!.)
		CRASH("No more sound channels can be reserved")
	var/text_channel = num2text(.)
	using_channels[text_channel] = D
	LAZYINITLIST(using_channels_by_datum[D])
	using_channels_by_datum[D] += .

/**
 * Reserves a channel and updates the datastructure. Private proc.
 */
/datum/controller/subsystem/sounds/proc/reserve_channel()
	PRIVATE_PROC(TRUE)
	if(channel_reserve_high <= random_channels_min) // out of channels
		return
	var/channel = channel_list[channel_reserve_high]
	reserved_channels[num2text(channel)] = channel_reserve_high--
	return channel

/**
 * Frees a channel and updates the datastructure. Private proc.
 */
/datum/controller/subsystem/sounds/proc/free_channel(number)
	PRIVATE_PROC(TRUE)
	var/text_channel = num2text(number)
	var/index = reserved_channels[text_channel]
	if(!index)
		CRASH("Attempted to (internally) free a channel that wasn't reserved.")
	reserved_channels -= text_channel
	// push reserve index up, which makes it now on a channel that is reserved
	channel_reserve_high++
	// swap the reserved channel wtih the unreserved channel so the reserve index is now on an unoccupied channel and the freed channel is next to be used.
	channel_list.Swap(channel_reserve_high, index)
	// now, an existing reserved channel will likely (exception: unreserving last reserved channel) be at index
	// get it, and update position.
	var/text_reserved = num2text(channel_list[index])
	if(!reserved_channels[text_reserved]) //if it isn't already reserved make sure we don't accidently mistakenly put it on reserved list!
		return
	reserved_channels[text_reserved] = index

/// Random available channel, returns text.
/datum/controller/subsystem/sounds/proc/random_available_channel_text()
	if(channel_random_low > channel_reserve_high)
		channel_random_low = 1
	. = "[channel_list[channel_random_low++]]"

/// Random available channel, returns number
/datum/controller/subsystem/sounds/proc/random_available_channel()
	if(channel_random_low > channel_reserve_high)
		channel_random_low = 1
	. = channel_list[channel_random_low++]

/// How many channels we have left.
/datum/controller/subsystem/sounds/proc/available_channels_left()
	return length(channel_list) - random_channels_min

/datum/controller/subsystem/sounds/proc/precache_sounds()
	if(!length(sounds_to_precache))
		return

	var/list/lengths = rustg_sound_length_list(sounds_to_precache)
	precache_errors = lengths[RUSTG_SOUNDLEN_ERRORS]
	sound_lengths = lengths[RUSTG_SOUNDLEN_SUCCESSES]
	for(var/sound_path in sound_lengths)
		sound_lengths[sound_path] = text2num(sound_lengths[sound_path])

	sounds_to_precache = null

/// Cache a list of sound lengths.
/datum/controller/subsystem/sounds/proc/cache_sounds(list/paths)
	var/list/reconstructed = list()
	reconstructed.len = length(paths)

	for(var/i in 1 to length(paths))
		reconstructed[i] = "[paths[i]]"

	var/list/out = rustg_sound_length_list(paths)
	var/list/successes = out[RUSTG_SOUNDLEN_SUCCESSES]
	for(var/sound_path in successes)
		sound_lengths[sound_path] = text2num(successes[sound_path])

/// Cache and return a single sound.
/datum/controller/subsystem/sounds/proc/get_sound_length(file_path)
	. = 0
	if(!istext(file_path))
		if(!isfile(file_path))
			CRASH("rustg_sound_length error: Passed non-text object")

		if(length("[file_path]")) // Runtime generated RSC references stringify into 0-length strings.
			file_path = "[file_path]"
		else
			CRASH("rustg_sound_length does not support non-static file refs.")

	var/cached_length = sound_lengths[file_path]
	if(!isnull(cached_length))
		return cached_length

	var/ret = RUSTG_CALL(RUST_G, "sound_len")(file_path)
	var/as_num = text2num(ret)
	if(isnull(ret))
		. = 0
		CRASH("rustg_sound_length error: [ret]")

	sound_lengths[file_path] = as_num
	return as_num

#undef DATUMLESS
