/datum/computer_file
	///The name of the internal file shown in file management.
	var/filename = "NewFile"
	///The type of file format the file is in, placed after filename. PNG, TXT, ect. This would be NewFile.XXX
	var/filetype = "XXX"
	///How much GQ storage space the file will take to store. Integers only!
	var/size = 1
	///Whether the file may be deleted. Setting to TRUE prevents deletion/renaming/etc.
	var/undeletable = FALSE
	///The computer file's personal ID
	var/uid
	///Static ID to ensure all IDs are unique.
	var/static/file_uid = 0
	///The modular computer hosting the file.
	var/obj/item/modular_computer/computer
	///The computer disk hosting the file.
	var/obj/item/computer_disk/disk_host

/datum/computer_file/New()
	..()
	uid = file_uid++
	RegisterSignal(src, COMSIG_COMPUTER_FILE_STORE, PROC_REF(on_install))

/datum/computer_file/Destroy(force)
	if(computer)
		computer = null
	if(disk_host)
		disk_host = null
	return ..()

/**
 * Used for special cases where an application
 * Requires special circumstances to install on a PC
 * Args:
 * * potential_host - the ModPC that is attempting to store this file.
 */
/datum/computer_file/proc/can_store_file(obj/item/modular_computer/potential_host)
	return TRUE

// Returns independent copy of this file.
/datum/computer_file/proc/clone(rename = FALSE)
	var/datum/computer_file/temp = new type
	temp.undeletable = undeletable
	temp.size = size
	if(rename)
		temp.filename = filename + "(Copy)"
	else
		temp.filename = filename
	temp.filetype = filetype
	return temp

///Called post-installation of an application in a computer, after 'computer' var is set. Remember, the user is optional
/datum/computer_file/proc/on_install(datum/computer_file/source, obj/item/modular_computer/computer_installing, mob/user)
	SIGNAL_HANDLER
	SHOULD_CALL_PARENT(TRUE)
	computer_installing.stored_files.Add(src)

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

/// Called on modular computer item_interaction, checking if any application uses the given item. Uses the item interaction chain flags.
/datum/computer_file/proc/application_item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	return NONE

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

/**
 * Called when a computer program is shut down from the tablet's charge dying
 * Arguments:
 * * background - Whether the app is running in the background.
 */
/datum/computer_file/program/proc/event_powerfailure()
	if(program_flags & PROGRAM_RUNS_WITHOUT_POWER)
		return
	kill_program()

/**
 * Called when a computer program is crashing due to any required connection being shut off.
 * Arguments:
 * * background - Whether the app is running in the background.
 */
/datum/computer_file/program/proc/event_networkfailure(background)
	kill_program()
	if(background)
		computer.visible_message(span_danger("\The [computer]'s screen displays a \"Process [filename].[filetype] (PID [rand(100,999)]) terminated - Network Error\" error"))
	else
		computer.visible_message(span_danger("\The [computer]'s screen briefly freezes and then shows \"NETWORK ERROR - NTNet connection lost. Please retry. If problem persists contact your system administrator.\" error."))
