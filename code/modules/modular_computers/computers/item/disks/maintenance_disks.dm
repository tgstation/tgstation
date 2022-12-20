/obj/item/computer_disk/maintenance
	name = "maintenance data disk"
	desc = "A data disk forgotten in the depths of maintenance, might have some useful program on it."

/// Medical health analyzer app
/obj/item/computer_disk/maintenance/scanner
	starting_programs = list(/datum/computer_file/program/maintenance/phys_scanner)

/obj/item/computer_disk/maintenance/camera
	starting_programs = list(/datum/computer_file/program/maintenance/camera)

/obj/item/computer_disk/maintenance/modsuit_control
	starting_programs = list(/datum/computer_file/program/maintenance/modsuit_control)
