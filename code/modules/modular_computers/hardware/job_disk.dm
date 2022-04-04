/obj/item/computer_hardware/hard_drive/role
	name = "job data disk"
	desc = "A disk meant to give a worker the needed programs to work."
	power_usage = 0
	icon_state = "datadisk6"
	w_class = WEIGHT_CLASS_TINY
	critical = FALSE
	max_capacity = 50
	device_type = MC_HDD_JOB
	default_installs = FALSE

	var/disk_flags = 0 // bit flag for the programs

/obj/item/computer_hardware/hard_drive/role/Initialize(mapload)
	. = ..()
	if(disk_flags & DISK_POWER)
		store_file(new /datum/computer_file/program/power_monitor(src))

/obj/item/computer_hardware/hard_drive/role/engineering
	name = "Power-ON disk"
	desc = "Engineers ignoring station power-draw since 2400."
	disk_flags = DISK_POWER
