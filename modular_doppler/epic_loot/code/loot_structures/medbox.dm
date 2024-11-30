/datum/storage/maintenance_loot_structure/medical_box
	max_slots = 6
	max_specific_storage = WEIGHT_CLASS_BULKY
	max_total_storage = WEIGHT_CLASS_BULKY * 6
	screen_max_columns = 3
	opening_sound = 'modular_lethal_doppler/epic_loot/sound/containers/plastic.mp3'

/obj/structure/maintenance_loot_structure/medbox
	name = "emergency medical box"
	desc = "A large, atmos-sealed plastic container for holding emergency medical supplies."
	icon_state = "medbox"
	storage_datum_to_use = /datum/storage/maintenance_loot_structure/medical_box
	loot_spawn_dice_string = "1d8-2"
	loot_weighted_list = list(
		/obj/effect/spawner/random/epic_loot/medical_stack_item = 2,
		/obj/effect/spawner/random/epic_loot/medical_tools = 2,
		/obj/effect/spawner/random/epic_loot/medpens = 1,
	)

/obj/structure/maintenance_loot_structure/medbox/advanced_loot
	loot_weighted_list = list(
		/obj/effect/spawner/random/epic_loot/medical_stack_item_advanced = 2,
		/obj/effect/spawner/random/epic_loot/medical_tools = 2,
		/obj/effect/spawner/random/epic_loot/medpens = 2,
		/obj/effect/spawner/random/epic_loot/medpens_combat_based_redpilled = 1,
	)
	loot_spawn_dice_string = "1d6"

/obj/structure/maintenance_loot_structure/medbox/bleu
	icon_state = "medbox_blue"

/obj/structure/maintenance_loot_structure/medbox/advanced_loot/bleu
	icon_state = "medbox_blue"

/obj/structure/maintenance_loot_structure/medbox/red
	icon_state = "medbox_red"

/obj/structure/maintenance_loot_structure/medbox/advanced_loot/red
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

/obj/structure/maintenance_loot_structure/medbox/random/advanced_loot
	loot_weighted_list = list(
		/obj/effect/spawner/random/epic_loot/medical_stack_item_advanced = 2,
		/obj/effect/spawner/random/epic_loot/medical_tools = 2,
		/obj/effect/spawner/random/epic_loot/medpens = 2,
		/obj/effect/spawner/random/epic_loot/medpens_combat_based_redpilled = 1,
	)
	loot_spawn_dice_string = "1d6"
