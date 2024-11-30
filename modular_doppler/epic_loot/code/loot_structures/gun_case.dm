/datum/storage/maintenance_loot_structure/gun_box
	max_slots = 4
	max_specific_storage = WEIGHT_CLASS_BULKY
	max_total_storage = WEIGHT_CLASS_BULKY * 4
	screen_max_columns = 4
	opening_sound = 'modular_lethal_doppler/epic_loot/sound/containers/wood_crate_3.mp3'

/obj/structure/maintenance_loot_structure/gun_box
	name = "large gun case"
	desc = "A military-grade gun case for secure storage of firearms."
	icon_state = "guncrate"
	storage_datum_to_use = /datum/storage/maintenance_loot_structure/gun_box
	loot_spawn_dice_string = "1d7-3"
	loot_weighted_list = list(
		/obj/effect/spawner/random/epic_loot/random_ammunition = 8,
		/obj/effect/spawner/random/epic_loot/random_silly_arms = 2,
		/obj/effect/spawner/random/epic_loot/random_serious_arms = 1,
	)

/obj/structure/maintenance_loot_structure/gun_box/evil
	icon_state = "guncrate_dark"

/obj/structure/maintenance_loot_structure/gun_box/random
	icon_state = "guncrate_random"
	/// The different icon states we can swap to when initializing
	var/list/random_icon_states = list(
		"guncrate",
		"guncrate_dark",
	)

/obj/structure/maintenance_loot_structure/gun_box/random/Initialize(mapload)
	. = ..()
	icon_state = pick(random_icon_states)
	update_appearance()
