/obj/effect/spawner/random/exotic
	name = "exotic spawner"
	desc = "Super duper rare stuff."

/obj/effect/spawner/random/exotic/technology
	name = "technology spawner"
	icon_state = "disk"
	spawn_loot_count = 2
	loot = list( // Space loot spawner. Couple of random bits of technology-adjacent stuff including anomaly cores and BEPIS techs.
		/obj/item/raw_anomaly_core/random,
		/obj/item/disk/design_disk/bepis,
		/obj/item/computer_disk/syndicate/camera_app,
	)

/obj/effect/spawner/random/exotic/languagebook
	name = "language book spawner"
	icon_state = "book"
	loot = list( // A single roundstart species language book.
		/obj/item/language_manual/roundstart_species = 96,
		/obj/item/book/granter/sign_language = 10,
		/obj/item/language_manual/piratespeak = 4,
		/obj/item/language_manual/roundstart_species/five = 3,
		/obj/item/language_manual/roundstart_species/unlimited = 1,
	)

/obj/effect/spawner/random/exotic/tool
	name = "exotic tool spawner"
	icon_state = "wrench"
	loot = list( // Some sort of random and rare tool.
		/obj/effect/spawner/random/engineering/tool_alien,
		/obj/effect/spawner/random/medical/surgery_tool_alien,
		/obj/effect/spawner/random/engineering/tool_advanced,
	)

/obj/effect/spawner/random/exotic/syndie
	name = "syndie cosmetic spawner"
	icon_state = "syndicate"
	spawn_loot_count = 2
	loot = list( // A selection of cosmetic syndicate items. Just a couple. No space suits or weapons.
		/obj/effect/spawner/random/clothing/syndie = 8,
		/obj/item/storage/fancy/cigarettes/cigpack_syndicate = 1,
		/obj/effect/spawner/random/entertainment/cigarette_pack = 1,
	)

/obj/effect/spawner/random/exotic/antag_gear_weak
	name = "antag gear weak"
	icon_state = "syndi_toolbox"
	loot = list(
		/obj/item/storage/medkit/regular = 45,
		/obj/item/storage/medkit/toxin = 35,
		/obj/item/storage/medkit/brute = 27,
		/obj/item/storage/medkit/fire = 27,
		/obj/item/storage/toolbox/syndicate = 12,
		/obj/item/borg/upgrade/diamond_drill = 3,
		/obj/item/knife/butcher = 14,
		/obj/item/clothing/glasses/night = 10,
		/obj/item/pickaxe/drill/diamonddrill = 6,
	)

/obj/effect/spawner/random/exotic/antag_gear
	name = "antag gear"
	icon_state = "esword"
	loot = list(
		/obj/item/clothing/glasses/science/night = 15,
		/obj/item/shield/riot = 12,
		/obj/item/stack/sheet/mineral/diamond{amount = 15} = 5,
		/obj/item/stack/sheet/mineral/uranium{amount = 15} = 5,
		/obj/item/stack/sheet/mineral/plasma{amount = 15} = 5,
		/obj/item/stack/sheet/mineral/gold{amount = 15} = 5,
		/obj/item/grenade/clusterbuster/smoke = 15,
		/obj/item/clothing/under/chameleon = 13,
		/obj/item/knife/combat = 10,
		/obj/item/implantcase/deathrattle = 5,
		/obj/item/storage/fancy/cigarettes/cigpack_syndicate = 1,
	)

/obj/effect/spawner/random/exotic/snow_gear
	name = "snow gear"
	icon_state = "snowman"
	loot = list(
		/obj/item/toy/snowball = 6,
		/obj/item/stack/sheet/mineral/snow{amount = 25} = 2,
		/obj/item/shovel = 2,
	)

/obj/effect/spawner/random/exotic/ripley
	name = "ripley spawner"
	icon_state = "ripley"
	loot = list(
		/obj/structure/mecha_wreckage/ripley = 3,
		/obj/vehicle/sealed/mecha/ripley/mining = 1,
	)
