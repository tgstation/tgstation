/datum/storage/maintenance_loot_structure/jacket
	max_slots = 2
	max_specific_storage = WEIGHT_CLASS_NORMAL
	max_total_storage = WEIGHT_CLASS_NORMAL * 4
	screen_max_columns = 2
	opening_sound = 'sound/items/handling/cloth_pickup.ogg'

/obj/structure/maintenance_loot_structure/wall_jacket
	name = "hanging jacket"
	desc = "Someone's old, now abandoned jacket. Maybe there's still stuff in the pockets?"
	icon_state = "jacket_green"
	density = FALSE
	storage_datum_to_use = /datum/storage/maintenance_loot_structure/jacket
	loot_spawn_dice_string = "1d3-1"
	loot_weighted_list = list(
		/obj/effect/spawner/random/epic_loot/pocket_sized_items = 1,
	)

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/maintenance_loot_structure/wall_jacket, 28)

/obj/structure/maintenance_loot_structure/wall_jacket/Initialize(mapload)
	. = ..()
	find_and_hang_on_wall()

/obj/structure/maintenance_loot_structure/wall_jacket/yellow
	icon_state = "jacket_yellow"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/maintenance_loot_structure/wall_jacket/yellow, 28)

/obj/structure/maintenance_loot_structure/wall_jacket/blue
	icon_state = "jacket_blue"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/maintenance_loot_structure/wall_jacket/blue, 28)

/obj/structure/maintenance_loot_structure/wall_jacket/police
	icon_state = "jacket_police"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/maintenance_loot_structure/wall_jacket/police, 28)

/obj/structure/maintenance_loot_structure/wall_jacket/black
	icon_state = "jacket_black"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/maintenance_loot_structure/wall_jacket/black, 28)

/obj/structure/maintenance_loot_structure/wall_jacket/military
	icon_state = "jacket_military"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/maintenance_loot_structure/wall_jacket/military, 28)

/obj/structure/maintenance_loot_structure/wall_jacket/random
	icon_state = "jacket_random"
	/// The different icon states we can swap to when initializing
	var/list/random_icon_states = list(
		"jacket_green",
		"jacket_yellow",
		"jacket_blue",
		"jacket_police",
		"jacket_black",
		"jacket_military",
	)

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/maintenance_loot_structure/wall_jacket/random, 28)

/obj/structure/maintenance_loot_structure/wall_jacket/random/Initialize(mapload)
	. = ..()
	icon_state = pick(random_icon_states)
	update_appearance()
