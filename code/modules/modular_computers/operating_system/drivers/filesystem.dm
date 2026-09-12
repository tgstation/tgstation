/datum/driver/filesystem

/datum/driver/filesystem/proc/store_file(datum/computer_file/file_storing, mob/user)

/datum/driver/filesystem/proc/can_store_file(datum/computer_file/file)

/datum/driver/filesystem/proc/find_file_by_name(filename, obj/item/disk/computer/target_disk)

/datum/driver/filesystem/proc/find_file_by_full_name(full_path, obj/item/disk/computer/target_disk)

/datum/driver/filesystem/proc/find_file_by_uid(uid, obj/item/disk/computer/target_disk)

/datum/driver/filesystem/proc/remove_file(datum/computer_file/file_removing)

// NTFS - Nanotrasen File System driver for NTOS

/datum/driver/filesystem/ntfs

/**
 * store_file
 *
 * Adds an already initialized file to the computer, checking if one already exists.
 * Returns TRUE if successfully stored, FALSE otherwise.
 * user is optional: If set, the action was done by a mob/player
 */
/datum/driver/filesystem/ntfs/store_file(datum/computer_file/file_storing, mob/user)
	if(!file_storing || !istype(file_storing))
		return FALSE
	if(!can_store_file(file_storing))
		return FALSE

	// This file is already stored. Don't store it again.
	if(file_storing in hardware.stored_files)
		return FALSE

	file_storing.computer = hardware
	file_storing.os = hardware.os
	hardware.used_capacity += file_storing.size
	SEND_SIGNAL(file_storing, COMSIG_COMPUTER_FILE_STORE, hardware, user)
	SEND_SIGNAL(hardware, COMSIG_MODULAR_COMPUTER_FILE_STORE, file_storing, user)
	return TRUE

/**
 * remove_file
 *
 * Removes a given file from the computer, if possible.
 * Properly checking if the file even exists and is in the computer.
 * Returns TRUE if successfully completed, FALSE otherwise
 */
/datum/driver/filesystem/ntfs/remove_file(datum/computer_file/file_removing)
	if(!file_removing || !istype(file_removing))
		return FALSE
	if(!(file_removing in hardware.stored_files))
		return FALSE
	if(istype(file_removing, /datum/computer_file/program))
		var/datum/computer_file/program/program_file = file_removing
		//TODO: I dont think it's good
		hardware.os.kill_program(program_file)

	hardware.stored_files.Remove(file_removing)
	hardware.used_capacity -= file_removing.size
	SEND_SIGNAL(hardware, COMSIG_MODULAR_COMPUTER_FILE_DELETE, file_removing)
	SEND_SIGNAL(file_removing, COMSIG_COMPUTER_FILE_DELETE, hardware)
	qdel(file_removing)
	return TRUE

/**
 * can_store_file
 *
 * Checks if a computer can store a file, as computers can only store unique files.
 * returns TRUE if possible, FALSE otherwise.
 */
/datum/driver/filesystem/ntfs/can_store_file(datum/computer_file/file)
	if(!file || !istype(file))
		return FALSE
	if(file in hardware.stored_files)
		return FALSE
	if(find_file_by_name(file.filename))
		return FALSE
	// In the unlikely event someone manages to create that many files.
	// BYOND is acting weird with numbers above 999 in loops (infinite loop prevention)
	if(hardware.stored_files.len >= 999)
		return FALSE
	if((hardware.used_capacity + file.size) > hardware.max_capacity)
		return FALSE
	if(!file.can_store_file(hardware))
		return FALSE

	return TRUE

/**
 * find_file_by_name
 *
 * Will check all applications in a tablet for files and, if they have \
 * the same filename (disregarding extension), will return it.
 * If a computer disk is passed instead, it will check the disk over the computer.
 */
/datum/driver/filesystem/ntfs/find_file_by_name(filename, obj/item/disk/computer/target_disk)
	if(!istext(filename))
		return null
	if(isnull(target_disk))
		for(var/datum/computer_file/file as anything in hardware.stored_files)
			if(file.filename == filename)
				return file
	else
		for(var/datum/computer_file/file as anything in target_disk.stored_files)
			if(file.filename == filename)
				return file
	return null

/**
 * find_file_by_full_name
 *
 * Will check all applications in a tablet for files and, if they have \
 * the same filename AND extension, will return it.
 * If a computer disk is passed instead, it will check the disk over the computer.
 */
/datum/driver/filesystem/ntfs/find_file_by_full_name(full_path, obj/item/disk/computer/target_disk)
	if(!istext(full_path))
		return null
	if(isnull(target_disk))
		for(var/datum/computer_file/file as anything in hardware.stored_files)
			if("[file.filename].[file.filetype]" == full_path)
				return file
	else
		for(var/datum/computer_file/file as anything in target_disk.stored_files)
			if("[file.filename].[file.filetype]" == full_path)
				return file
	return null

/**
 * find_file_by_uid
 *
 * Will check all files in this computer and returns the file with the matching uid.
 * A file's uid is always unique to them, so this proc is sometimes preferable over find_file_by_name.
 * If a computer disk is passed instead, it will check the disk over the computer.
 */
/datum/driver/filesystem/ntfs/find_file_by_uid(uid, obj/item/disk/computer/target_disk)
	if(!isnum(uid))
		return null
	if(isnull(target_disk))
		for(var/datum/computer_file/file as anything in hardware.stored_files)
			if(file.uid == uid)
				return file
	else
		for(var/datum/computer_file/file as anything in target_disk.stored_files)
			if(file.uid == uid)
				return file
	return null
