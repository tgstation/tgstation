/datum/storage/maintenance_loot_structure/file_cabinet
	max_slots = 6
	max_specific_storage = WEIGHT_CLASS_NORMAL
	max_total_storage = WEIGHT_CLASS_NORMAL * 6
	screen_max_columns = 2
	opening_sound = 'modular_doppler/epic_loot/sound/containers/cabinet.mp3'

/obj/structure/maintenance_loot_structure/file_cabinet
	name = "filing cabinet"
	desc = "A large filing cabinet, it even comes with terrible sounding unlubricated rails!"
	icon_state = "files"
	storage_datum_to_use = /datum/storage/maintenance_loot_structure/file_cabinet
	loot_spawn_dice_string = "1d10-4"
	loot_weighted_list = list(
		/obj/effect/spawner/random/epic_loot/random_documents = 9,
	)

/obj/structure/maintenance_loot_structure/file_cabinet/white
	icon_state = "files_clean"

/obj/structure/maintenance_loot_structure/file_cabinet/random
	icon_state = "files_random"
	/// The different icon states we can swap to when initializing
	var/list/random_icon_states = list(
		"files",
		"files_clean",
	)

/obj/structure/maintenance_loot_structure/file_cabinet/random/Initialize(mapload)
	. = ..()
	icon_state = pick(random_icon_states)
	update_appearance()
