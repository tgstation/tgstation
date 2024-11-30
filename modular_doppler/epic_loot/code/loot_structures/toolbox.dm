/datum/storage/maintenance_loot_structure/toolbox
	max_slots = 6
	max_specific_storage = WEIGHT_CLASS_BULKY
	max_total_storage = WEIGHT_CLASS_BULKY * 6
	screen_max_columns = 3
	opening_sound = 'modular_doppler/epic_loot/sound/containers/wood_crate_1.mp3'

/obj/structure/maintenance_loot_structure/toolbox
	name = "heavy toolbox"
	desc = "An industrial grade toolbox, for when you need to carry a LOT of things to a job. \
		It's previous owner has smartly attached this one pretty firmly to whatever surface it's on, \
		to prevent theft."
	icon_state = "toolbox"
	storage_datum_to_use = /datum/storage/maintenance_loot_structure/toolbox
	loot_spawn_dice_string = "1d8-2"
	loot_weighted_list = list(
		/obj/effect/spawner/random/epic_loot/random_engineering = 1,
	)

/obj/structure/maintenance_loot_structure/toolbox/yellow
	icon_state = "toolbox_yellow"

/obj/structure/maintenance_loot_structure/toolbox/red
	icon_state = "toolbox_red"

/obj/structure/maintenance_loot_structure/toolbox/random
	icon_state = "toolbox_random"
	/// The different icon states we can swap to when initializing
	var/list/random_icon_states = list(
		"toolbox",
		"toolbox_yellow",
		"toolbox_red",
	)

/obj/structure/maintenance_loot_structure/toolbox/random/Initialize(mapload)
	. = ..()
	icon_state = pick(random_icon_states)
	update_appearance()
