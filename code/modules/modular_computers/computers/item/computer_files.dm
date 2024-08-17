/**
 * store_file
 *
 * Adds an already initialized file to the computer, checking if one already exists.
 * Returns TRUE if successfully stored, FALSE otherwise.
 */
/obj/item/modular_computer/proc/store_file(datum/computer_file/file_storing)
	if(!file_storing || !istype(file_storing))
		return FALSE
	if(!can_store_file(file_storing))
		return FALSE

	// This file is already stored. Don't store it again.
	if(file_storing in stored_files)
		return FALSE

	file_storing.computer = src
	used_capacity += file_storing.size
	SEND_SIGNAL(file_storing, COMSIG_COMPUTER_FILE_STORE, src)
	SEND_SIGNAL(src, COMSIG_MODULAR_COMPUTER_FILE_STORE, file_storing)
	return TRUE

/**
 * remove_file
 *
 * Removes a given file from the computer, if possible.
 * Properly checking if the file even exists and is in the computer.
 * Returns TRUE if successfully completed, FALSE otherwise
 */
/obj/item/modular_computer/proc/remove_file(datum/computer_file/file_removing)
	if(!file_removing || !istype(file_removing))
		return FALSE
	if(!(file_removing in stored_files))
		return FALSE
	if(istype(file_removing, /datum/computer_file/program))
		var/datum/computer_file/program/program_file = file_removing
		program_file.kill_program()

	stored_files.Remove(file_removing)
	used_capacity -= file_removing.size
	SEND_SIGNAL(src, COMSIG_MODULAR_COMPUTER_FILE_DELETE, file_removing)
	SEND_SIGNAL(file_removing, COMSIG_COMPUTER_FILE_DELETE, src)
	qdel(file_removing)
	return TRUE

/**
 * can_store_file
 *
 * Checks if a computer can store a file, as computers can only store unique files.
 * returns TRUE if possible, FALSE otherwise.
 */
/obj/item/modular_computer/proc/can_store_file(datum/computer_file/file)
	if(!file || !istype(file))
		return FALSE
	if(file in stored_files)
		return FALSE
	if(find_file_by_name(file.filename))
		return FALSE
	// In the unlikely event someone manages to create that many files.
	// BYOND is acting weird with numbers above 999 in loops (infinite loop prevention)
	if(stored_files.len >= 999)
		return FALSE
	if((used_capacity + file.size) > max_capacity)
		return FALSE
	if(!file.can_store_file(src))
		return FALSE

	return TRUE

/**
 * find_file_by_name
 *
 * Will check all applications in a tablet for files and, if they have \
 * the same filename (disregarding extension), will return it.
 * If a computer disk is passed instead, it will check the disk over the computer.
 */
/obj/item/modular_computer/proc/find_file_by_name(filename, obj/item/computer_disk/target_disk)
	if(!istext(filename))
		return null
	if(isnull(target_disk))
		for(var/datum/computer_file/file as anything in stored_files)
			if(file.filename == filename)
				return file
	else
		for(var/datum/computer_file/file as anything in target_disk.stored_files)
			if(file.filename == filename)
				return file
	return null

/**
 * find_file_by_uid
 *
 * Will check all files in this computer and returns the file with the matching uid.
 * A file's uid is always unique to them, so this proc is sometimes preferable over find_file_by_name.
 * If a computer disk is passed instead, it will check the disk over the computer.
 */
/obj/item/modular_computer/proc/find_file_by_uid(uid, obj/item/computer_disk/target_disk)
	if(!isnum(uid))
		return null
	if(isnull(target_disk))
		for(var/datum/computer_file/file as anything in stored_files)
			if(file.uid == uid)
				return file
	else
		for(var/datum/computer_file/file as anything in target_disk.stored_files)
			if(file.uid == uid)
				return file
	return null
