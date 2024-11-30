/datum/storage/maintenance_loot_structure/large_crate
	max_slots = 16
	max_specific_storage = WEIGHT_CLASS_BULKY
	max_total_storage = WEIGHT_CLASS_BULKY * 16
	screen_max_columns = 4
	opening_sound = 'modular_doppler/epic_loot/sound/containers/wood_crate_3.mp3'

/obj/structure/maintenance_loot_structure/large_crate
	name = "provision transport crate"
	desc = "A large crate for transporting equally large amounts of food supplies around."
	icon_state = "foodcrate"
	storage_datum_to_use = /datum/storage/maintenance_loot_structure/large_crate
	loot_spawn_dice_string = "4d5-4"
	loot_weighted_list = list(
		/obj/effect/spawner/random/epic_loot/random_provisions = 1,
	)

/obj/structure/maintenance_loot_structure/large_crate/medical
	name = "medical transport crate"
	desc = "A large crate for transporting equally large amounts of medical supplies around."
	icon_state = "medcrate"
	loot_weighted_list = list(
		/obj/effect/spawner/random/epic_loot/medical_everything = 1,
	)

/obj/structure/maintenance_loot_structure/large_crate/medical/airdrop
	icon_state = "supplydrop"

/obj/structure/maintenance_loot_structure/large_crate/engineering
	name = "engineering transport crate"
	desc = "A large crate for transporting equally large amounts of tools and components around."
	icon_state = "toolcrate"
	loot_weighted_list = list(
		/obj/effect/spawner/random/epic_loot/random_engineering = 1,
	)

/obj/structure/maintenance_loot_structure/large_crate/engineering/airdrop
	icon_state = "supplydrop_yellow"

/obj/structure/maintenance_loot_structure/large_crate/military
	name = "reinforced transport crate"
	desc = "A large crate for transporting equally large amounts of militar."
	icon_state = "supplydrop_green"
	loot_weighted_list = list(
		/obj/effect/spawner/random/epic_loot/random_engineering = 1,
		/obj/effect/spawner/random/epic_loot/random_provisions = 1,
		/obj/effect/spawner/random/epic_loot/random_other_military_loot = 1,
		/obj/effect/spawner/random/epic_loot/medical_everything = 1,
	)

/obj/effect/spawner/random/epic_loot/random_supply_crate
	name = "random supply crate spawner"
	desc = "Automagically transforms into a random supply crate, hopefully filled with goodies."
	icon = 'modular_doppler/epic_loot/icons/loot_structures.dmi'
	icon_state = "crate_random"
	loot = list(
		/obj/structure/maintenance_loot_structure/large_crate,
		/obj/structure/maintenance_loot_structure/large_crate/medical,
		/obj/structure/maintenance_loot_structure/large_crate/medical/airdrop,
		/obj/structure/maintenance_loot_structure/large_crate/engineering,
		/obj/structure/maintenance_loot_structure/large_crate/engineering/airdrop,
		/obj/structure/maintenance_loot_structure/large_crate/military,
	)
