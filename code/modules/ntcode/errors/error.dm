/datum/ntcode/error
	var/line_number
	var/line_offset

/datum/ntcode/error/New(line_number, line_offset)
	. = ..()
	src.line_number = line_number
	src.line_offset = line_offset 

/datum/ntcode/error/proc/to_string()