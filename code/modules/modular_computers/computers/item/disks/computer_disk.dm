/obj/item/disk/computer
	/// The amount of free storage space
	var/max_capacity = 16
	/// The amount of storage space occupied
	var/used_capacity = 0
	/// List of stored files on this drive. Do NOT directly modify; use setters instead.
	var/list/datum/computer_file/stored_files = list()

	/// List of all programs that the disk should start with
	var/list/datum/computer_file/starting_programs = list()

/obj/item/disk/computer/Initialize(mapload)
	. = ..()
	for(var/programs in starting_programs)
		var/datum/computer_file/program_type = new programs
		add_file(program_type)

/obj/item/disk/computer/Destroy(force)
	. = ..()
	QDEL_LIST(stored_files)

/**
 * add_file
 *
 * Attempts to add an already existing file to the computer disk, then adds that capacity to the used capicity.
 */
/obj/item/disk/computer/proc/add_file(datum/computer_file/file)
	if((file.size + used_capacity) > max_capacity)
		return FALSE
	stored_files.Add(file)
	file.disk_host = src
	used_capacity += file.size
	return TRUE

/**
 * remove_file
 *
 * Removes an app from the stored_files list, then removes their size from the capacity.
 */
/obj/item/disk/computer/proc/remove_file(datum/computer_file/file)
	if(!(file in stored_files))
		return FALSE
	stored_files.Remove(file)
	used_capacity -= file.size
	qdel(file)
	return TRUE

/obj/item/disk/computer/advanced
	name = "advanced data disk"
	icon_state = "datadisk5"
	max_capacity = 64

/obj/item/disk/computer/super
	name = "super data disk"
	desc = "Removable disk used to store large amounts of data."
	icon_state = "datadisk3"
	max_capacity = 256
