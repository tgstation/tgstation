/datum/storage/maintenance_loot_structure/register
	max_slots = 2
	max_specific_storage = WEIGHT_CLASS_NORMAL
	max_total_storage = WEIGHT_CLASS_NORMAL * 2
	screen_max_columns = 2
	opening_sound = 'modular_doppler/epic_loot/sound/wood_crate_2.mp3'

/obj/structure/maintenance_loot_structure/register
	name = "credits register"
	desc = "A compact computing unit to handle transfers of credits between accounts. May still contain currency left behind!"
	icon_state = "register_small"
	storage_datum_to_use = /datum/storage/maintenance_loot_structure/register
	loot_spawn_dice_string = "1d3-1"
	loot_weighted_list = list(
		/obj/effect/spawner/random/entertainment/coin = 1,
		/obj/effect/spawner/random/entertainment/money_small = 2,
		/obj/effect/spawner/random/entertainment/money = 1,
	)

/obj/structure/maintenance_loot_structure/register/white
	icon_state = "register_small_clean"

/obj/structure/maintenance_loot_structure/register/big
	icon_state = "register_big"

/obj/structure/maintenance_loot_structure/register/big_white
	icon_state = "register_big_clean"

/obj/structure/maintenance_loot_structure/register/random
	icon_state = "register_random"
	/// The different icon states we can swap to when initializing
	var/list/random_icon_states = list(
		"register_small",
		"register_small_clean",
		"register_big",
		"register_big_clean",
	)

/obj/structure/maintenance_loot_structure/register/random/Initialize(mapload)
	. = ..()
	icon_state = pick(random_icon_states)
	update_appearance()
