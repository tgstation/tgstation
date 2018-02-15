//This is the hippie init file, here we will initialize everything hippie where possible.
//Create a proc to load something in the appropriate module file and call the proc here.

/proc/hippie_initialize()
	load_mentors()
	init_sprite_accessory_subtypes(/datum/sprite_accessory/screen, GLOB.ipc_screens_list, roundstart = TRUE)
	initialize_global_loadout_items()