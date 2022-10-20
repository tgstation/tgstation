// Use this proc to add file to the drive. Returns 1 on success and 0 on failure. Contains necessary sanity checks.
/obj/item/modular_computer/proc/store_file(datum/computer_file/file_storing)
	if(!file_storing || !istype(file_storing))
		return FALSE
	if(!can_store_file(file_storing))
		return FALSE

	// This file is already stored. Don't store it again.
	if(file_storing in stored_files)
		return FALSE

	SEND_SIGNAL(file_storing, COMSIG_MODULAR_COMPUTER_FILE_ADDING)
	file_storing.computer = src
	stored_files.Add(file_storing)
	recalculate_size()
	SEND_SIGNAL(file_storing, COMSIG_MODULAR_COMPUTER_FILE_ADDED)
	return TRUE

// Use this proc to remove file from the drive. Returns 1 on success and 0 on failure. Contains necessary sanity checks.
/obj/item/modular_computer/proc/remove_file(datum/computer_file/file_removing)
	if(!file_removing || !istype(file_removing))
		return FALSE
	if(!(file_removing in stored_files))
		return FALSE
	if(istype(file_removing, /datum/computer_file/program))
		var/datum/computer_file/program/program_file = file_removing
		if(program_file.program_state != PROGRAM_STATE_KILLED)
			program_file.kill_program(TRUE)

	SEND_SIGNAL(file_removing, COMSIG_MODULAR_COMPUTER_FILE_DELETING)
	stored_files.Remove(file_removing)
	recalculate_size()
	SEND_SIGNAL(file_removing, COMSIG_MODULAR_COMPUTER_FILE_DELETED)
	return TRUE

// Loops through all stored files and recalculates used_capacity of this drive
/obj/item/modular_computer/proc/recalculate_size()
	var/total_size = 0
	for(var/datum/computer_file/stored_files as anything in stored_files)
		total_size += stored_files.size

	used_capacity = total_size

// Checks whether file can be stored on the hard drive. We can only store unique files, so this checks whether we wouldn't get a duplicity by adding a file.
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

	return TRUE


// Tries to find the file by filename, will search a disk instead if there is one. Returns null on failure
/obj/item/modular_computer/proc/find_file_by_name(filename, obj/item/computer_disk/target_disk)
	if(!filename)
		return null
	if(target_disk)
		for(var/datum/computer_file/file as anything in target_disk.stored_files)
			if(file.filename == filename)
				return file
	else
		for(var/datum/computer_file/file as anything in stored_files)
			if(file.filename == filename)
				return file
	return null
