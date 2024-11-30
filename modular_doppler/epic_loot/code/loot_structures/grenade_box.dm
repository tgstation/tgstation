/datum/storage/maintenance_loot_structure/grenade_box
	max_slots = 4
	max_specific_storage = WEIGHT_CLASS_NORMAL
	max_total_storage = WEIGHT_CLASS_NORMAL * 4
	screen_max_columns = 2
	opening_sound = 'modular_lethal_doppler/epic_loot/sound/containers/wood_crate_2.mp3'

/obj/structure/maintenance_loot_structure/grenade_box
	name = "grenade box"
	desc = "A military-grade grenade box for secure storage of explosives."
	icon_state = "grenade_box"
	storage_datum_to_use = /datum/storage/maintenance_loot_structure/grenade_box
	loot_spawn_dice_string = "1d6-2"
	loot_weighted_list = list(
		/obj/effect/spawner/random/epic_loot/random_grenade_or_explosive = 1,
	)

/obj/structure/maintenance_loot_structure/grenade_box/evil
	icon_state = "grenade_box_evil"

/obj/structure/maintenance_loot_structure/grenade_box/random
	icon_state = "grenade_box_random"
	/// The different icon states we can swap to when initializing
	var/list/random_icon_states = list(
		"grenade_box",
		"grenade_box_evil",
	)

/obj/structure/maintenance_loot_structure/grenade_box/random/Initialize(mapload)
	. = ..()
	icon_state = pick(random_icon_states)
	update_appearance()
