/obj/item/computer_disk
	name = "data disk"
	desc = "Removable disk used to store data."
	icon_state = "datadisk6"
	w_class = WEIGHT_CLASS_TINY
	///The amount of storage space is on the disk
	var/max_capacity = 16
	///The amount of storage space we've got filled
	var/used_capacity = 0
	///List of stored files on this drive. DO NOT MODIFY DIRECTLY!
	var/list/datum/computer_file/stored_files = list()

	///List of stored files on this drive. DO NOT MODIFY DIRECTLY!
	var/list/datum/computer_file/starting_programs = list()

/obj/item/computer_disk/Initialize(mapload)
	. = ..()
	for(var/programs in starting_programs)
		var/datum/computer_file/program/program_type = new programs
		store_file(program_type)

/obj/item/computer_disk/advanced
	name = "advanced data disk"
	icon_state = "datadisk5"
	max_capacity = 64

/obj/item/computer_disk/super
	name = "super data disk"
	desc = "Removable disk used to store large amounts of data."
	icon_state = "datadisk3"
	max_capacity = 256
