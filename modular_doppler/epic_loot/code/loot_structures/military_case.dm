/datum/storage/maintenance_loot_structure/military_case
	max_slots = 8
	max_specific_storage = WEIGHT_CLASS_BULKY
	max_total_storage = WEIGHT_CLASS_BULKY * 8
	screen_max_columns = 4
	opening_sound = 'modular_doppler/epic_loot/sound/containers/wood_crate_3.mp3'

/obj/structure/maintenance_loot_structure/military_case
	name = "large shipping crate"
	desc = "A reinforced shipping crate for the transport of larger items."
	icon_state = "military_crate"
	storage_datum_to_use = /datum/storage/maintenance_loot_structure/military_case
	loot_spawn_dice_string = "1d10-2"
	loot_weighted_list = list(
		/obj/effect/spawner/random/epic_loot/random_engineering = 1,
		/obj/effect/spawner/random/epic_loot/random_provisions = 1,
		/obj/effect/spawner/random/epic_loot/random_other_military_loot = 1,
	)

/obj/structure/maintenance_loot_structure/military_case/evil
	icon_state = "guncrate_dark"

/obj/structure/maintenance_loot_structure/military_case/super_evil
	icon_state = "larpbox"

/obj/structure/maintenance_loot_structure/military_case/random
	icon_state = "military_crate_random"
	/// The different icon states we can swap to when initializing
	var/list/random_icon_states = list(
		"military_crate",
		"military_crate_dark",
		"larpbox",
	)

/obj/structure/maintenance_loot_structure/military_case/random/Initialize(mapload)
	. = ..()
	icon_state = pick(random_icon_states)
	update_appearance()
