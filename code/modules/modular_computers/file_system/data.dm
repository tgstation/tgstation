/// Data files. Doesn't really hold many important functionalities, here for organization.
/datum/computer_file/data
	/// Whether the user will be reminded that the file probably shouldn't be edited.
	var/do_not_edit = FALSE
	filetype = "DAT"

// /data/text files store data in string format.
// They don't contain other logic for now.
/datum/computer_file/data/text
	filetype = "TXT"
	/// Stored data in string format.
	var/stored_text = ""
	var/block_size = 250

/datum/computer_file/data/text/clone()
	var/datum/computer_file/data/text/temp = ..()
	temp.stored_text = stored_text
	return temp

// Calculates file size from amount of characters in saved string
/datum/computer_file/data/text/proc/calculate_size()
	size = max(1, round(length(stored_text) / block_size))

/datum/computer_file/data/text/logfile
	filetype = "LOG"

