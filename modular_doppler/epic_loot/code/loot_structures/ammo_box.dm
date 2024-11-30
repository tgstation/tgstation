/datum/storage/maintenance_loot_structure/ammo_box
	max_slots = 6
	max_specific_storage = WEIGHT_CLASS_NORMAL
	max_total_storage = WEIGHT_CLASS_NORMAL * 6
	screen_max_columns = 3
	opening_sound = 'modular_lethal_doppler/epic_loot/sound/containers/wood_crate_3.mp3'

/obj/structure/maintenance_loot_structure/ammo_box
	name = "ammunition box"
	desc = "A military-grade lockbox for secure storage of ammunition."
	icon_state = "ammo_box"
	storage_datum_to_use = /datum/storage/maintenance_loot_structure/ammo_box
	loot_spawn_dice_string = "1d10-4"
	loot_weighted_list = list(
		/obj/effect/spawner/random/epic_loot/random_ammunition = 1,
	)

/obj/structure/maintenance_loot_structure/ammo_box/super_evil
	icon_state = "cache"

/obj/structure/maintenance_loot_structure/ammo_box/random
	icon_state = "ammo_box_random"
	/// The different icon states we can swap to when initializing
	var/list/random_icon_states = list(
		"ammo_box",
		"cache",
	)

/obj/structure/maintenance_loot_structure/ammo_box/random/Initialize(mapload)
	. = ..()
	icon_state = pick(random_icon_states)
	update_appearance()
