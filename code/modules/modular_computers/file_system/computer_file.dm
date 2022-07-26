/datum/computer_file
	var/filename = "NewFile" // Placeholder. No spacebars
	var/filetype = "XXX" // File full names are [filename].[filetype] so like NewFile.XXX in this case
	var/size = 1 // File size in GQ. Integers only!
	var/obj/item/computer_hardware/hard_drive/holder // Holder that contains this file.
	var/obj/item/modular_computer/computer
	var/unsendable = FALSE // Whether the file may be sent to someone via NTNet transfer or other means.
	var/undeletable = FALSE // Whether the file may be deleted. Setting to TRUE prevents deletion/renaming/etc.
	var/uid // UID of this file
	var/static/file_uid = 0

/datum/computer_file/New()
	..()
	uid = file_uid++

/datum/computer_file/Destroy()
	if(!holder)
		return ..()

	holder.remove_file(src)
	// holder.holder is the computer that has drive installed. If we are Destroy()ing program that's currently running kill it.
	if(computer && computer.active_program == src)
		computer.kill_program(forced = TRUE)
	holder = null
	computer = null
	return ..()

// Returns independent copy of this file.
/datum/computer_file/proc/clone(rename = FALSE)
	var/datum/computer_file/temp = new type
	temp.unsendable = unsendable
	temp.undeletable = undeletable
	temp.size = size
	if(rename)
		temp.filename = filename + "(Copy)"
	else
		temp.filename = filename
	temp.filetype = filetype
	return temp
