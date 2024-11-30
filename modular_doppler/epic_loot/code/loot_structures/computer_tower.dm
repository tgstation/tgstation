/datum/storage/maintenance_loot_structure/computer
	max_slots = 4
	max_specific_storage = WEIGHT_CLASS_NORMAL
	max_total_storage = WEIGHT_CLASS_NORMAL * 4
	screen_max_columns = 2
	opening_sound = 'modular_lethal_doppler/epic_loot/sound/containers/plastic.mp3'

/obj/structure/maintenance_loot_structure/computer_tower
	name = "computer tower"
	desc = "A relatively compact computer unit, missing it's monitor. May still contain valuable components inside."
	icon_state = "alienware"
	storage_datum_to_use = /datum/storage/maintenance_loot_structure/computer
	loot_spawn_dice_string = "1d7-3"
	loot_weighted_list = list(
		/obj/effect/spawner/random/epic_loot/random_computer_parts = 1,
	)

/obj/structure/maintenance_loot_structure/computer_tower/white
	icon_state = "alienware_honeycrisp"

/obj/structure/maintenance_loot_structure/computer_tower/eighties
	icon_state = "alienware_tan_man"

/obj/structure/maintenance_loot_structure/computer_tower/random
	icon_state = "alienware_random"
	/// The different icon states we can swap to when initializing
	var/list/random_icon_states = list(
		"alienware",
		"alienware_honeycrisp",
		"alienware_tan_man",
	)

/obj/structure/maintenance_loot_structure/computer_tower/random/Initialize(mapload)
	. = ..()
	icon_state = pick(random_icon_states)
	update_appearance()
