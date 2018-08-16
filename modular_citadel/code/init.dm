//init file stolen from hippie

/proc/cit_initialize()
	load_mentors()
	initialize_global_loadout_items()

	//body parts and things
	init_sprite_accessory_subtypes(/datum/sprite_accessory/mam_body_markings, GLOB.mam_body_markings_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/mam_tails, GLOB.mam_tails_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/mam_ears, GLOB.mam_ears_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/mam_tails_animated, GLOB.mam_tails_animated_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/taur, GLOB.taur_list)
//	init_sprite_accessory_subtypes(/datum/sprite_accessory/beaks/avian, GLOB.avian_beaks_list)
//	init_sprite_accessory_subtypes(/datum/sprite_accessory/tails/avian, GLOB.avian_tails_list)
//	init_sprite_accessory_subtypes(/datum/sprite_accessory/avian_wings, GLOB.avian_wings_list)
//  init_sprite_accessory_subtypes(/datum/sprite_accessory/avian_open_wings, GLOB.avian_open_wings_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/xeno_head, GLOB.xeno_head_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/xeno_tail, GLOB.xeno_tail_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/xeno_dorsal, GLOB.xeno_dorsal_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/screen, GLOB.ipc_screens_list, roundstart = TRUE)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/antenna, GLOB.ipc_antennas_list, roundstart = TRUE)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/penis, GLOB.cock_shapes_list)
	for(var/K in GLOB.cock_shapes_list)
		var/datum/sprite_accessory/penis/value = GLOB.cock_shapes_list[K]
		GLOB.cock_shapes_icons[K] = value.icon_state
	init_sprite_accessory_subtypes(/datum/sprite_accessory/vagina, GLOB.vagina_shapes_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/breasts, GLOB.breasts_shapes_list)
	GLOB.breasts_size_list = list("a","b","c","d","e") //We need the list to choose from initialized, but it's no longer a sprite_accessory thing.
