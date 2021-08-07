/// Ensure the frequency is within bounds of what it should be sending/receiving at
/proc/sanitize_frequency(frequency, free = FALSE)
	frequency = round(frequency)
	if(free)
		. = clamp(frequency, MIN_FREE_FREQ, MAX_FREE_FREQ)
	else
		. = clamp(frequency, MIN_FREQ, MAX_FREQ)
	if(!(. % 2)) // Ensure the last digit is an odd number
		. += 1

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
	while((freq_to_check == 0) || ("[freq_to_check]" in GLOB.reverseradiochannels))

	return freq_to_check
