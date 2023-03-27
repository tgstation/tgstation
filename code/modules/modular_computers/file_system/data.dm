///Used to calculate how large a text file is.
#define BLOCK_SIZE 250

/**
 * Base DATA file type
 * Doesn't do anything, mostly here for organization.
 */
/datum/computer_file/data
	filetype = "DAT"

/**
 * Holds data in string format.
 */
/datum/computer_file/data/text
	filetype = "TXT"

	/// Stored data in string format.
	var/stored_text = ""

/datum/computer_file/data/text/clone()
	var/datum/computer_file/data/text/temp = ..()
	temp.stored_text = stored_text
	return temp

// Calculates file size from amount of characters in saved string
/datum/computer_file/data/text/proc/calculate_size()
	size = max(1, round(length(stored_text) / BLOCK_SIZE))

/**
 * A text file with a different filetype
 * Used for flavortext
 */
/datum/computer_file/data/text/logfile
	filetype = "LOG"

#undef BLOCK_SIZE
