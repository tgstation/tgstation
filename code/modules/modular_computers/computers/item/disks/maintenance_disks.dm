/obj/item/computer_disk/maintenance
	name = "maintenance data disk"
	desc = "A data disk forgotten in the depths of maintenance, might have some useful program on it."

/// Medical health analyzer app
/obj/item/computer_disk/maintenance/scanner
	preinstalled_programs = list(/datum/computer_file/program/maintenance/phys_scanner)

///Camera app, forced to always have largest image size
/obj/item/computer_disk/maintenance/camera
	preinstalled_programs = list(/datum/computer_file/program/maintenance/camera)

///MODsuit UI, in your PDA!
/obj/item/computer_disk/maintenance/modsuit_control
	preinstalled_programs = list(/datum/computer_file/program/maintenance/modsuit_control)

///Returns A 'spookiness' value based on the number of ghastly creature and hauntium and their distance from the PC.
/obj/item/computer_disk/maintenance/spectre_meter
	preinstalled_programs = list(/datum/computer_file/program/maintenance/spectre_meter)

///A version of the arcade program with less HP/MP for the enemy and more for the player
/obj/item/computer_disk/maintenance/arcade
	preinstalled_programs = list(/datum/computer_file/program/arcade/eazy)

/obj/item/computer_disk/maintenance/theme/Initialize(mapload)
	preinstalled_programs = list(pick(subtypesof(/datum/computer_file/program/maintenance/theme)))
	return ..()
