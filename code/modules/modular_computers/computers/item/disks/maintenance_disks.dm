/obj/item/computer_disk/maintenance
	name = "maintenance data disk"
	desc = "A data disk forgotten in the depths of maintenance, might have some useful program on it."

/// Medical health analyzer app
/obj/item/computer_disk/maintenance/scanner
	starting_programs = list(/datum/computer_file/program/maintenance/phys_scanner)

///Camera app, forced to always have largest image size
/obj/item/computer_disk/maintenance/camera
	starting_programs = list(/datum/computer_file/program/maintenance/camera)

///MODsuit UI, in your PDA!
/obj/item/computer_disk/maintenance/modsuit_control
	starting_programs = list(/datum/computer_file/program/maintenance/modsuit_control)

/obj/item/computer_disk/maintenance/theme/Initialize(mapload)
	starting_programs = list(pick(subtypesof(/datum/computer_file/program/maintenance/theme)))
	return ..()
