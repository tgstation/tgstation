/obj/effect/spawner/random/exotic
	name = "exotic spawner"
	desc = "Super duper rare stuff."

/obj/effect/spawner/random/exotic/technology
	name = "technology spawner"
	icon_state = "disk"
	spawn_loot_count = 2
	loot = list( // Space loot spawner. Couple of random bits of technology-adjacent stuff including anomaly cores and BEPIS techs.
		/obj/item/raw_anomaly_core/random,
		/obj/item/disk/tech_disk/spaceloot,
		/obj/item/camera_bug,
	)

/obj/effect/spawner/random/exotic/languagebook
	name = "language book spawner"
	icon_state = "book"
	loot = list( // A single roundstart species language book.
		/obj/item/language_manual/roundstart_species = 100,
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
		/obj/item/storage/firstaid/regular = 45,
		/obj/item/storage/firstaid/toxin = 35,
		/obj/item/storage/firstaid/brute = 27,
		/obj/item/storage/firstaid/fire = 27,
		/obj/item/grenade/clusterbuster/smoke = 15,
		/obj/item/clothing/under/chameleon = 13,
		/obj/item/storage/toolbox/syndicate = 12,
		/obj/item/melee/baton/telescopic = 12,
		/obj/item/melee/baton = 11,
		/obj/item/book/granter/spell/smoke = 10,
		/obj/item/book/granter/spell/blind = 10,
		/obj/item/clothing/shoes/chameleon/noslip = 10,
		/obj/item/grenade/c4 = 7,
		/obj/item/borg/upgrade/ddrill = 3,
		/obj/item/borg/upgrade/soh = 3,
	)

/obj/effect/spawner/random/exotic/antag_gear
	name = "antag gear"
	icon_state = "esword"
	loot = list(
		/obj/item/storage/firstaid/tactical = 35,
		/obj/item/book/granter/spell/summonitem = 20,
		/obj/item/book/granter/spell/forcewall = 17,
		/obj/item/pneumatic_cannon = 15,
		/obj/item/book/granter/spell/knock = 15,
		/obj/item/storage/backpack/holding = 12,
		/obj/item/shield/riot/tele = 12,
		/obj/item/stack/sheet/mineral/diamond{amount = 15} = 10,
		/obj/item/stack/sheet/mineral/uranium{amount = 15} = 10,
		/obj/item/stack/sheet/mineral/plasma{amount = 15} = 10,
		/obj/item/stack/sheet/mineral/gold{amount = 15} = 10,
		/obj/item/grenade/spawnergrenade/spesscarp = 7,
		/obj/item/melee/energy/sword = 7,
		/obj/item/borg/upgrade/disablercooler = 7,
		/obj/item/dnainjector/lasereyesmut = 7,
		/obj/item/shield/energy = 6,
		/obj/item/pickaxe/drill/diamonddrill = 6,
		/obj/item/grenade/spawnergrenade/manhacks = 6,
		/obj/item/defibrillator/compact = 6,
		/obj/item/book/granter/spell/barnyard = 4,
		/obj/item/grenade/clusterbuster/inferno = 3,
		/obj/item/gun/magic/wand/fireball/inert = 3,
	)

/obj/effect/spawner/random/exotic/antag_gear_strong
	name = "antag gear strong"
	icon_state = "esword_dual"
	loot = list(
		/obj/item/pickaxe/drill/jackhammer = 30,
		/obj/item/singularityhammer = 25,
		/obj/item/fireaxe = 25,
		/obj/item/organ/brain/alien = 17,
		/obj/item/borg/upgrade/selfrepair = 17,
		/obj/item/gun/ballistic/automatic/c20r/unrestricted = 16,
		/obj/item/dualsaber = 15,
		/obj/item/gun/magic/wand/resurrection/inert = 15,
		/obj/item/grenade/clusterbuster/spawner_manhacks = 15,
		/obj/item/borg/upgrade/syndicate = 13,
		/obj/item/book/granter/spell/charge = 12,
		/obj/item/book/granter/spell/fireball = 10,
		/obj/item/gun/magic/wand/resurrection = 10,
		/obj/item/mjollnir = 10,
		/obj/item/organ/heart/demon = 7,
		/obj/item/uplink/old = 2,
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
		/obj/vehicle/sealed/mecha/working/ripley/mining = 1,
	)
