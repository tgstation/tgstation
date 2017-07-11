//This is the hippie init file, here we will initialize everything hippie where possible.
//Create a proc to load something in the appropriate module file and call the proc here.

/proc/hippie_initialize()
	load_hippie_config('config/hippiestation_config.txt')
	LAZYCLEARLIST(mentor_datums)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/moth_wings, GLOB.moth_wings_list, roundstart = TRUE)
	initialize_global_loadout_items()