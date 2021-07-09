/**
 * Get all non admin_only instruments as a list of text ids.
 */
/proc/get_allowed_instrument_ids()
	. = list()
	for(var/id in SSinstruments.instrument_data)
		var/datum/instrument/I = SSinstruments.instrument_data[id]
		if(!I.admin_only)
			. += I.id

/**
 * # Instrument Datums
 *
 * Instrument datums hold the data for any given instrument, as well as data on how to play it and what bounds there are to playing it.
 *
 * The datums themselves are kept in SSinstruments in a list by their unique ID. The reason it uses ID instead of typepath is to support the runtime creation of instruments.
 * Since songs cache them while playing, there isn't realistic issues regarding performance from accessing.
 */
/datum/instrument
	/// Name of the instrument
	var/name = "Generic instrument"
	/// Uniquely identifies this instrument so runtime changes are possible as opposed to paths. If this is unset, things will use path instead.
	var/id
	/// Category
	var/category = "Unsorted"
	/// Used for categorization subtypes
	var/abstract_type = /datum/instrument
	/// Write here however many samples, follow this syntax: "%note num%"='%sample file%' eg. "27"='synthesizer/e2.ogg'. Key must never be lower than 0 and higher than 127
	var/list/real_samples
	/// assoc list key = /datum/instrument_key. do not fill this yourself!
	var/list/samples
	/// See __DEFINES/flags/instruments.dm
	var/instrument_flags = NONE
	/// For legacy instruments, the path to our notes
	var/legacy_instrument_path
	/// For legacy instruments, our file extension
	var/legacy_instrument_ext
	/// What songs are using us
	var/list/datum/song/songs_using = list()
	/// Don't touch this
	var/static/HIGHEST_KEY = 127
	/// Don't touch this x2
	var/static/LOWEST_KEY = 0
	/// Oh no - For truly troll instruments.
	var/admin_only = FALSE
	/// Volume multiplier. Synthesized instruments are quite loud and I don't like to cut off potential detail via editing. (someone correct me if this isn't a thing)
	var/volume_multiplier = 0.33

/datum/instrument/New()
	if(isnull(id))
		id = "[type]"

/**
 * Initializes the instrument, calculating its samples if necessary.
 */
/datum/instrument/proc/Initialize()
	if(instrument_flags & (INSTRUMENT_LEGACY | INSTRUMENT_DO_NOT_AUTOSAMPLE))
		return
	calculate_samples()

/**
 * Checks if this instrument is ready to play.
 */
/datum/instrument/proc/ready()
	if(instrument_flags & INSTRUMENT_LEGACY)
		return legacy_instrument_path && legacy_instrument_ext
	else if(instrument_flags & INSTRUMENT_DO_NOT_AUTOSAMPLE)
		return length(samples)
	return (length(samples) >= 128)

/datum/instrument/Destroy()
	SSinstruments.instrument_data -= id
	for(var/i in songs_using)
		var/datum/song/S = i
		S.set_instrument(null)
	real_samples = null
	samples = null
	songs_using = null
	return ..()

/**
 * For synthesized instruments, this is how the instrument generates the "keys" that a [/datum/song] uses to play notes.
 * Calculating them on the fly would be unperformant, so we do it during init and keep it all cached in a list.
 */
/datum/instrument/proc/calculate_samples()
	if(!length(real_samples))
		CRASH("No real samples defined for [id] [type] on calculate_samples() call.")
	var/list/real_keys = list()
	samples = list()
	for(var/key in real_samples)
		real_keys += text2num(key)
	sortTim(real_keys, /proc/cmp_numeric_asc, associative = FALSE)

	for(var/i in 1 to (length(real_keys) - 1))
		var/from_key = real_keys[i]
		var/to_key = real_keys[i+1]
		var/sample1 = real_samples[num2text(from_key)]
		var/sample2 = real_samples[num2text(to_key)]
		var/pivot = FLOOR((from_key + to_key) / 2, 1) //original code was a round but I replaced it because that's effectively a floor, thanks Baystation! who knows what was intended.
		for(var/key in from_key to pivot)
			samples[num2text(key)] = new /datum/instrument_key(sample1, key, key - from_key)
		for(var/key in (pivot + 1) to to_key)
			samples[num2text(key)] = new /datum/instrument_key(sample2, key, key - to_key)

	// Fill in 0 to first key and last key to 127
	var/first_key = real_keys[1]
	var/last_key = real_keys[length(real_keys)]
	var/first_sample = real_samples[num2text(first_key)]
	var/last_sample = real_samples[num2text(last_key)]
	for(var/key in LOWEST_KEY to (first_key - 1))
		samples[num2text(key)] = new /datum/instrument_key(first_sample, key, key - first_key)
	for(var/key in last_key to HIGHEST_KEY)
		samples[num2text(key)] = new /datum/instrument_key(last_sample, key, key - last_key)
