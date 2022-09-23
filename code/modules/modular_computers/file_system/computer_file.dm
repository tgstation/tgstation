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

/datum/computer_file/Destroy(force)
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

/**
 * Called when examining a modular computer
 * Args:
 * Source - The tablet that's being examined
 * User - Person examining the computer
 *
 * note: please replace this with signals when hdd's are removed and program's New() already has the tablet set.
 */
/datum/computer_file/proc/on_examine(obj/item/modular_computer/source, mob/user)
	return null

/// Called when someone tries to insert something one of your applications needs, like an Intellicard for AI restoration.
/datum/computer_file/proc/try_insert(obj/item/attacking_item, mob/living/user)
	return FALSE

/**
 * Implement this when your program has an object that the user can eject.
 *
 * Examples include ejecting cells AI intellicards.
 * Arguments:
 * * user - The mob requesting the eject.
 * * forced - Whether we are forced to eject everything (usually by the app being deleted)
 */
/datum/computer_file/proc/try_eject(mob/living/user, forced = FALSE)
	return FALSE
