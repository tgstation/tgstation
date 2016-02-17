// Ensure the frequency is within bounds of what it should be sending/recieving at
/proc/sanitize_frequency(frequency)
	. = round(frequency)
	. = Clamp(frequency, MIN_FREQ, MAX_FREQ)
	if(!(. % 2)) // Ensure the last digit is an odd number
		. += 1

// Format frequency by moving the decimal.
/proc/format_frequency(frequency)
	frequency = text2num(frequency)
	return "[round(frequency / 10)].[frequency % 10]"
