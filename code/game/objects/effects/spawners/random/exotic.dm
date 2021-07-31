obj/effect/spawner/random/exotic
	name = "exotic spawner"
	desc = "Super duper rare stuff."

/obj/effect/spawner/random/exotic/technology
	name = "technology spawner"
	lootcount = 2
	loot = list( // Space loot spawner. Couple of random bits of technology-adjacent stuff including anomaly cores and BEPIS techs.
		/obj/item/raw_anomaly_core/random,
		/obj/item/disk/tech_disk/spaceloot,
		/obj/item/camera_bug,
	)

/obj/effect/spawner/random/exotic/languagebook
	name = "language book spawner"
	loot = list( // A single roundstart species language book.
		/obj/item/language_manual/roundstart_species = 100,
		/obj/item/language_manual/roundstart_species/five = 3,
		/obj/item/language_manual/roundstart_species/unlimited = 1,
	)

/obj/effect/spawner/random/exotic/tool
	name = "exotic tool spawner"
	loot = list( // Some sort of random and rare tool.
		/obj/effect/spawner/random/engineering/tool_rare,
		/obj/effect/spawner/random/medical/surgery_tool_rare,
		/obj/effect/spawner/random/engineering/tool_advanced,
	)

/obj/effect/spawner/random/exotic/syndie
	lootcount = 2
	loot = list( // A selection of cosmetic syndicate items. Just a couple. No hardsuits or weapons.
		/obj/effect/spawner/random/clothing/syndie = 8,
		/obj/item/storage/fancy/cigarettes/cigpack_syndicate = 1,
		/obj/effect/spawner/random/entertainment/cigarette_pack = 1,
	)
