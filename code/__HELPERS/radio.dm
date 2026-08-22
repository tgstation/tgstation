/// Ensure the frequency is within bounds of what it should be sending/receiving at
/proc/sanitize_frequency(frequency, free = FALSE, syndie = FALSE)
	frequency = round(frequency)
	if(free)
		. = clamp(frequency, MIN_FREE_FREQ, MAX_FREE_FREQ)
	else
		. = clamp(frequency, MIN_FREQ, MAX_FREQ)
	if(!(. % 2)) // Ensure the last digit is an odd number
		. += 1
	if(. == FREQ_SYNDICATE && !syndie) // Prevents people from picking (or rounding up) into the syndie frequency
		. = FREQ_COMMON

/// Format frequency by moving the decimal.
/proc/format_frequency(frequency)
	frequency = text2num(frequency)
	return "[round(frequency / 10)].[frequency % 10]"

///Opposite of format, returns as a number
/proc/unformat_frequency(frequency)
	frequency = text2num(frequency)
	return frequency * 10

///returns a random unused frequency between MIN_FREE_FREQ & MAX_FREE_FREQ if free = TRUE, and MIN_FREQ & MAX_FREQ if FALSE
/proc/return_unused_frequency(free = FALSE)
	var/start = free ? MIN_FREE_FREQ : MIN_FREQ
	var/end = free ? MAX_FREE_FREQ : MAX_FREQ

	var/freq_to_check = 0
	do
		freq_to_check = rand(start, end)
		if(!(freq_to_check % 2)) // Ensure the last digit is an odd number
			freq_to_check++
	while((freq_to_check == 0) || ("[freq_to_check]" in GLOB.reserved_radio_frequencies))

	return freq_to_check

/proc/get_voice_description(atom/movable/speaker)
	var/voice_description

	if(isobj(speaker))
		voice_description = VOICE_DESCRIPTION_NEUTER
		return voice_description

	//If they're human and their voice isn't their 'real_name' then we'll just default to 'PLURAL'.
	//This isn't ideal at all (and could be metagamed), but no 'voice_gender' exists.
	if(ishuman(speaker))
		var/mob/living/carbon/human/human_speaker = speaker
		if(speaker.get_voice() != human_speaker.real_name)
			voice_description = VOICE_DESCRIPTION_PLURAL //"Their" instead of "its" to be less /obj
			return voice_description

	switch(speaker.gender)
		if(NEUTER)
			voice_description = VOICE_DESCRIPTION_NEUTER
		if(FEMALE)
			voice_description = VOICE_DESCRIPTION_FEMININE
		if(MALE)
			voice_description = VOICE_DESCRIPTION_MASCULINE
		if(PLURAL)
			voice_description =  VOICE_DESCRIPTION_PLURAL

	return voice_description
