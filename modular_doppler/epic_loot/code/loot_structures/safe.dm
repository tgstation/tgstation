/datum/storage/maintenance_loot_structure/desk_safe
	max_slots = 2
	max_specific_storage = WEIGHT_CLASS_NORMAL
	max_total_storage = WEIGHT_CLASS_NORMAL * 2
	screen_max_columns = 1
	opening_sound = 'modular_doppler/epic_loot/sound/containers/wood_crate_3.mp3'

/obj/structure/maintenance_loot_structure/desk_safe
	name = "compact safe"
	desc = "A not-so-secure safe meant to fit around or under desks."
	icon_state = "safe"
	storage_datum_to_use = /datum/storage/maintenance_loot_structure/desk_safe
	loot_spawn_dice_string = "1d3-1"
	loot_weighted_list = list(
		/obj/effect/spawner/random/epic_loot/random_strongbox_loot = 1,
	)

/obj/structure/maintenance_loot_structure/desk_safe/bleu
	icon_state = "safe_blue"

/obj/structure/maintenance_loot_structure/desk_safe/random
	icon_state = "safe_random"
	/// The different icon states we can swap to when initializing
	var/list/random_icon_states = list(
		"safe",
		"safe_blue",
	)

/obj/structure/maintenance_loot_structure/desk_safe/random/Initialize(mapload)
	. = ..()
	icon_state = pick(random_icon_states)
	update_appearance()
