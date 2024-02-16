/obj/item/computer_disk
	name = "data disk"
	desc = "Removable disk used to store data."
	icon = 'icons/obj/devices/circuitry_n_data.dmi'
	icon_state = "datadisk6"
	w_class = WEIGHT_CLASS_TINY
	///The amount of storage space is on the disk
	var/max_capacity = 16
	///The amount of storage space we've got filled
	var/used_capacity = 0
	///List of stored files on this drive. DO NOT MODIFY DIRECTLY!
	var/list/datum/computer_file/stored_files = list()

	///List of all programs that the disk should start with.
	var/list/datum/computer_file/starting_programs = list()

/obj/item/computer_disk/Initialize(mapload)
	. = ..()
	for(var/programs in starting_programs)
		var/datum/computer_file/program_type = new programs
		add_file(program_type)

/obj/item/computer_disk/Destroy(force)
	. = ..()
	QDEL_LIST(stored_files)

/**
 * add_file
 *
 * Attempts to add an already existing file to the computer disk, then adds that capacity to the used capicity.
 */
/obj/item/computer_disk/proc/add_file(datum/computer_file/file)
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
/obj/item/computer_disk/proc/remove_file(datum/computer_file/file)
	if(!(file in stored_files))
		return FALSE
	stored_files.Remove(file)
	used_capacity -= file.size
	qdel(file)
	return TRUE

/obj/item/computer_disk/advanced
	name = "advanced data disk"
	icon_state = "datadisk5"
	max_capacity = 64

/obj/item/computer_disk/super
	name = "super data disk"
	desc = "Removable disk used to store large amounts of data."
	icon_state = "datadisk3"
	max_capacity = 256
