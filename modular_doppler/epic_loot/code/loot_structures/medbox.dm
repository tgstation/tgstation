/datum/storage/maintenance_loot_structure/medical_box
	max_slots = 6
	max_specific_storage = WEIGHT_CLASS_BULKY
	max_total_storage = WEIGHT_CLASS_BULKY * 6
	screen_max_columns = 3
	opening_sound = 'modular_doppler/epic_loot/sound/plastic.mp3'

/obj/structure/maintenance_loot_structure/medbox
	name = "emergency medical box"
	desc = "A large, atmos-sealed plastic container for holding emergency medical supplies."
	icon_state = "medbox"
	storage_datum_to_use = /datum/storage/maintenance_loot_structure/medical_box
	loot_spawn_dice_string = "1d8-2"
	loot_weighted_list = list(
		/obj/effect/spawner/random/epic_loot/medical_everything = 1,
	)

/obj/structure/maintenance_loot_structure/medbox/bleu
	icon_state = "medbox_blue"

/obj/structure/maintenance_loot_structure/medbox/red
	icon_state = "medbox_red"

/obj/structure/maintenance_loot_structure/medbox/random
	icon_state = "medbox_random"
	/// The different icon states we can swap to when initializing
	var/list/random_icon_states = list(
		"medbox",
		"medbox_blue",
		"medbox_red",
	)

/obj/structure/maintenance_loot_structure/medbox/random/Initialize(mapload)
	. = ..()
	icon_state = pick(random_icon_states)
	update_appearance()
