/**
 * Instrument key datums contain everything needed to know how to play a specific
 * note of an instrument.*
 */
/datum/instrument_key
	/// The numerical key of what this is, from 1 to 127 on a standard piano keyboard.
	var/key
	/// The actual sample file that will be loaded when playing.
	var/sample
	/// The frequency to play the sample to get our desired note.
	var/frequency
	/// Deviation up/down from the pivot point that uses its sample. Used to calculate frequency.
	var/deviation

/datum/instrument_key/New(sample = src.sample, key = src.key, deviation = src.deviation, frequency = src.frequency)
	src.sample = sample
	src.key = key
	src.deviation = deviation
	src.frequency = frequency
	if(!frequency && deviation)
		calculate()

/**
 * Calculates and stores our deviation.
 */
/datum/instrument_key/proc/calculate()
	if(!deviation)
		CRASH("Invalid calculate call: No deviation or sample in instrument_key")
	#define KEY_TWELTH (1/12)
	frequency = 2 ** (KEY_TWELTH * deviation)
	#undef KEY_TWELTH
