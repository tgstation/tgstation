/**
 * Command
 */
/obj/item/computer_disk/command
	icon_state = "datadisk7"
	max_capacity = 32


/obj/item/computer_disk/command/install_default_programs()
	. = ..()
	store_file(new /datum/computer_file/program/crew_manifest)
	store_file(new /datum/computer_file/program/science)
	store_file(new /datum/computer_file/program/status)
